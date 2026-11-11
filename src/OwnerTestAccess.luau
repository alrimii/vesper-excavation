-- Temporary, exact-account live test routing. No profile data travels in teleports.
local A = {}
A.OwnerUserId = 291892217 -- Authenticated Studio identity AND user-owned experience creator.
local Players = game:GetService("Players")
local Teleport = game:GetService("TeleportService")
local Http = game:GetService("HttpService")
local modes, pending = {}, {}
local remote
local started = false
function A.IsOwner(userId)
	return userId == A.OwnerUserId
end
-- Teleport data selects a mode only AFTER exact UserId authorization. It never
-- grants privileges, carries currency, or contains a normal profile snapshot.
function A.Decide(userId, privateId, privateOwner, sourcePlace, data)
	local reserved = privateId ~= "" and privateOwner == 0
	if not A.IsOwner(userId) then
		return reserved and "deny" or "normal"
	end
	local normal = sourcePlace == game.PlaceId and type(data) == "table" and data.OwnerTestMode == "normal-v1"
	if normal then
		return reserved and "route-normal" or "normal"
	end
	return reserved and "test" or "route-test"
end
function A.IsTestPlayer(player)
	return A.IsOwner(player.UserId) and modes[player] == "test"
end
local function failed(player, message)
	if not pending[player] then
		return
	end
	pending[player] = nil
	player:SetAttribute("OwnerTestRouting", false)
	player:SetAttribute("OwnerTestError", "Rejoin failed. Retry or choose Normal play. " .. tostring(message))
end
local function travel(player, testMode)
	if not A.IsOwner(player.UserId) or pending[player] then
		return
	end
	pending[player] = true
	player:SetAttribute("OwnerTestRouting", true)
	player:SetAttribute("OwnerTestError", nil)
	local options = Instance.new("TeleportOptions")
	if testMode then
		options.ReservedServerId = Http:GenerateGUID(false)
	end
	options:SetTeleportData({ OwnerTestMode = testMode and "test-v1" or "normal-v1" })
	task.spawn(function()
		local ok, err = pcall(function()
			Teleport:TeleportAsync(game.PlaceId, { player }, options)
		end)
		if not ok then
			failed(player, err)
		end
	end)
end
function A.Start()
	if started then
		return
	end
	started = true
	remote = Instance.new("RemoteEvent")
	remote.Name = "OwnerTestMode"
	remote.Parent = game.ReplicatedStorage.VesperShared.Remotes
	local last = {}
	remote.OnServerEvent:Connect(function(player, enabled)
		if not A.IsOwner(player.UserId) or typeof(enabled) ~= "boolean" then
			return
		end
		if os.clock() - (last[player] or -math.huge) < 3 then
			return
		end
		last[player] = os.clock()
		travel(player, enabled)
	end)
	Teleport.TeleportInitFailed:Connect(function(player, result, message)
		failed(player, tostring(result) .. ": " .. message)
	end)
	Players.PlayerRemoving:Connect(function(player)
		modes[player], pending[player], last[player] = nil, nil, nil
	end)
end
-- Called before loading any profile or enabling gameplay. Test servers accept
-- only this owner; normal matchmaking and normal saves stay separate.
function A.Route(player)
	-- Keep the established memory-only Studio preview unchanged. Live access is
	-- decided by exact identity and reserved-server routing, never by this flag.
	if game:GetService("RunService"):IsStudio() then
		player:SetAttribute("OwnerTestEligible", false)
		player:SetAttribute("OwnerTestMode", false)
		return false
	end
	player:SetAttribute("OwnerTestEligible", A.IsOwner(player.UserId))
	player:SetAttribute("OwnerTestMode", false)
	local join = player:GetJoinData()
	local mode = A.Decide(
		player.UserId,
		game.PrivateServerId,
		game.PrivateServerOwnerId,
		join.SourcePlaceId,
		join.TeleportData
	)
	if mode == "deny" then
		player:Kick("This reserved server is for owner testing.")
		return true
	end
	if mode == "route-test" or mode == "route-normal" then
		travel(player, mode == "route-test")
		return true
	end
	modes[player] = mode
	player:SetAttribute("OwnerTestMode", mode == "test")
	return false
end
return A
