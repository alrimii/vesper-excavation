-- VESPER / session room ownership and character lifecycle.
-- No remotes, data stores, economy, egg logic or persistent ownership.
local Players = game:GetService("Players")
Players.CharacterAutoLoads = false
local rooms = workspace:WaitForChild("VesperLab"):WaitForChild("Rooms")
local RoomPool = require(script.Parent.RoomPool)
local ordered = {}
for _, room in rooms:GetChildren() do
	local id = room:GetAttribute("RoomNumber")
	assert(typeof(id) == "number" and not ordered[id], "Invalid or duplicate room number")
	assert(room:FindFirstChild("RoomSpawn") and room.RoomSpawn:IsA("SpawnLocation"), "Missing room spawn")
	ordered[id] = room
end
for id = 1, 12 do
	assert(ordered[id], "Missing room " .. id)
end
local pool = RoomPool.new(#ordered)
local sessions = {}
local function display(room, player)
	room:SetAttribute("Occupied", player ~= nil)
	room:SetAttribute("OwnerUserId", player and player.UserId or nil)
	room:SetAttribute("OwnerDisplayName", player and player.DisplayName or nil)
	local label = room.OwnerSign.Display.Text
	label.Text = player and player.DisplayName or "AVAILABLE"
	label.TextScaled = true
	label.TextColor3 = player and Color3.fromRGB(255, 218, 158) or Color3.fromRGB(219, 222, 208)
end
for _, room in ordered do
	display(room, nil)
end
local requestLoad
local function active(player, state)
	return sessions[player] == state and not state.closed and player.Parent == Players
end
local function characterAdded(player, state, character)
	if state.death then
		state.death:Disconnect()
		state.death = nil
	end
	local root = character:WaitForChild("HumanoidRootPart", 15)
	local humanoid = character:WaitForChild("Humanoid", 15)
	if not root or not humanoid or not active(player, state) or player.Character ~= character then
		return
	end
	state.death = humanoid.Died:Connect(function()
		task.delay(Players.RespawnTime, function()
			if active(player, state) and player.Character == character then
				requestLoad(player, state)
			end
		end)
	end)
	-- CharacterAdded can precede parenting to Workspace.
	local deadline = os.clock() + 15
	while
		not character:IsDescendantOf(workspace)
		and active(player, state)
		and player.Character == character
		and os.clock() < deadline
	do
		task.wait()
	end
	if
		not active(player, state)
		or player.Character ~= character
		or not character:IsDescendantOf(workspace)
	then
		return
	end
	local spawn = ordered[state.room].RoomSpawn
	character:PivotTo(spawn.CFrame * CFrame.new(0, 3.5, 0))
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
end
requestLoad = function(player, state)
	if not active(player, state) then
		return
	end
	if state.loading then
		state.pending = true
		return
	end
	state.loading = true
	task.spawn(function()
		while active(player, state) do
			local ok, err = pcall(function()
				player:SetAttribute("CharacterLoadComplete", false)
				player:LoadCharacterAsync()
				if active(player, state) and player.Character then
					player.Character:SetAttribute("EquipmentSpawnComplete", true)
					player:SetAttribute("CharacterLoadComplete", true)
				end
			end)
			if ok then
				break
			end
			if active(player, state) then
				warn("[Vesper] Character load failed; retrying: " .. tostring(err))
				task.wait(3)
			end
		end
		state.loading = false
		if state.pending and active(player, state) then
			state.pending = false
			task.defer(requestLoad, player, state)
		end
	end)
end
local function playerAdded(player)
	if sessions[player] or player.Parent ~= Players then
		return
	end
	local roomId = pool:Assign(player.UserId) -- no yield before ownership is reserved
	if not roomId then
		player:Kick("This laboratory has 12 occupied rooms. Please join another server.")
		return
	end
	local state = { room = roomId, closed = false, loading = false, pending = false }
	sessions[player] = state
	player:SetAttribute("RoomNumber", roomId)
	player.RespawnLocation = ordered[roomId].RoomSpawn
	display(ordered[roomId], player)
	state.added = player.CharacterAdded:Connect(function(character)
		task.spawn(characterAdded, player, state, character)
	end)
	if player.Character then
		task.spawn(characterAdded, player, state, player.Character)
	else
		requestLoad(player, state)
	end
end
local function playerRemoving(player)
	local state = sessions[player]
	if not state then
		return
	end
	state.closed = true
	if state.added then
		state.added:Disconnect()
	end
	if state.death then
		state.death:Disconnect()
	end
	sessions[player] = nil
	local roomId = pool:Release(player.UserId)
	if roomId then
		display(ordered[roomId], nil)
	end
	player.RespawnLocation = nil
	player:SetAttribute("RoomNumber", nil)
end
Players.PlayerRemoving:Connect(playerRemoving)
Players.PlayerAdded:Connect(playerAdded)
for _, player in Players:GetPlayers() do
	playerAdded(player)
end
print("[Vesper] 12 session rooms ready")
