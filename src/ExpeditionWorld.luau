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
	for i, slot in display.slots do
		slot.part.Color = theme.Color
		local selected = owner and owner:GetAttribute("DisplaySlot" .. i)
		local entry = selected and Rules.Creature(selected)
		local id = entry and (owner:GetAttribute("Creature_" .. entry.Id) or 0) > 0 and entry.Id or nil
		slot.label.Text = entry and (entry.Name .. "\n" .. entry.Rarity)
			or ("DISPLAY 0" .. i .. "\nSELECT IN ARCHIVE")
		slot.label.TextColor3 = entry and entry.Color or Color3.fromRGB(140, 160, 174)
		slot.part.Color = entry and entry.Color or theme.Color
		slot.part.Material = Enum.Material.Metal
		slot.part.Color = Color3.fromRGB(30, 42, 52)
		slot.accent.Color = entry and entry.Color or theme.Color
		if id ~= slot.id then
			if slot.model then
				slot.model:Destroy()
				slot.model = nil
			end
			slot.id = id
			if id then
				local model = require(Shared.SpecimenBuilder).Build("crownback")
				Cabinet.Place(model, slot.part)
				for _, p in model:GetDescendants() do
					if p:IsA("BasePart") then
						p.Color = p.Color:Lerp(entry.Color, 0.35)
						local surface = p:FindFirstChildOfClass("SurfaceAppearance")
						if surface then
							surface.Color = entry.Color
						end
					end
				end
				model.Parent = display.model
				slot.model = model
			end
		end
	end
	local relic = display.model:FindFirstChild("AncientRelic")
	local count = owner and (owner:GetAttribute("Relics") or 0) or 0
	if count > 0 and not relic then
		relic = part(
			display.model,
			"AncientRelic",
			Vector3.new(2, 3, 2),
			display.basis * CFrame.new(0, 8.35, -2) * CFrame.Angles(0, 0, 0.4),
			Color3.fromRGB(255, 204, 101),
			Enum.Material.Neon
		)
	elseif count == 0 and relic then
		relic:Destroy()
	end
	for _, p in room:GetChildren() do
		if p:IsA("BasePart") and (p.Name == "JambStripe" or p.Name == "HeaderLight") then
			p.Color = theme.Color
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
			"Creature_crownback",
			"Creature_crownback_gilded",
			"Creature_crownback_ember",
			"RoomNumber",
		}
	do
		table.insert(list, p:GetAttributeChangedSignal(key):Connect(update))
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
