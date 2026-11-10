local Players = game:GetService("Players")
local Shared = game.ReplicatedStorage:WaitForChild("VesperShared")
local Rules = require(Shared.ProgressionRules)
local rooms = workspace.VesperLab.Rooms
local displays = {}
local function part(parent, name, size, cf, color, material)
	local p = Instance.new("Part")
	p.Name, p.Size, p.CFrame = name, size, cf
	p.Color, p.Material = color, material or Enum.Material.Metal
	p.Anchored = true
	p.CanCollide, p.CanTouch, p.CanQuery = false, false, false
	p.Parent = parent
	return p
end
local Cabinet = require(script.Parent.CollectionCabinet)
for _, room in rooms:GetChildren() do
	displays[room] = Cabinet.Build(room)
	task.wait()
end
local function refresh(room)
	local display = displays[room]
	local owner = Players:GetPlayerByUserId(room:GetAttribute("OwnerUserId") or 0)
	local theme = Rules.RoomThemes[1]
	for _, entry in Rules.RoomThemes do
		if owner and owner:GetAttribute("RoomTheme") == entry.Id then
			theme = entry
		end
	end
	Cabinet.Refresh(display, owner)
	for _, p in room:GetDescendants() do
		if p:IsA("BasePart") and p:GetAttribute("RoomThemeAccent") then
			p.Color = Color3.fromRGB(94, 111, 97):Lerp(theme.Color, 0.25)
		end
	end
end
for room in displays do
	room:GetAttributeChangedSignal("OwnerUserId"):Connect(function()
		refresh(room)
	end)
	refresh(room)
end
local function outfit(character)
	local torso = character:WaitForChild("UpperTorso", 5) or character:FindFirstChild("Torso")
	if not torso or not character.Parent then
		return
	end
	local kit = Instance.new("Model")
	kit.Name = "VesperFieldHarness"
	local function attach(name, size, offset, color, material)
		local p = part(kit, name, size, torso.CFrame * offset, color, material)
		p.Anchored = false
		p.Massless = true
		local weld = Instance.new("WeldConstraint")
		weld.Part0, weld.Part1 = torso, p
		weld.Parent = p
	end
	attach("FieldPack", Vector3.new(1.55, 1.6, 0.55), CFrame.new(0, 0, 0.65), Color3.fromRGB(27, 43, 51))
	attach(
		"PowerCell",
		Vector3.new(0.22, 1.05, 0.15),
		CFrame.new(0.5, 0, 0.98),
		Color3.fromRGB(85, 227, 206),
		Enum.Material.Neon
	)
	attach(
		"ChestBadge",
		Vector3.new(0.45, 0.2, 0.08),
		CFrame.new(0.42, 0.25, -0.61),
		Color3.fromRGB(232, 191, 114),
		Enum.Material.Neon
	)
	kit.Parent = character
end
local links = {}
local function join(p)
	local list = {}
	local function update()
		for room in displays do
			if room:GetAttribute("OwnerUserId") == p.UserId then
				refresh(room)
			end
		end
	end
	for _, key in
		{
			"RoomTheme",
			"DisplaySlot1",
			"DisplaySlot2",
			"DisplaySlot3",
			"Relics",
			"ProfileReady",
			"RoomNumber",
		}
	do
		table.insert(list, p:GetAttributeChangedSignal(key):Connect(update))
	end
	for _, entry in Rules.CreatureVariants do
		table.insert(list, p:GetAttributeChangedSignal("Creature_" .. entry.Id):Connect(update))
	end
	table.insert(list, p.CharacterAdded:Connect(outfit))
	links[p] = list
	if p.Character then
		task.spawn(outfit, p.Character)
	end
	update()
end
Players.PlayerAdded:Connect(join)
Players.PlayerRemoving:Connect(function(p)
	for _, c in links[p] or {} do
		c:Disconnect()
	end
	links[p] = nil
end)
for _, p in Players:GetPlayers() do
	join(p)
end
