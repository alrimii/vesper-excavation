-- Edit-time, repeatable builder. The finished room is saved in the place.
local lab = workspace.VesperLab
local old = lab:FindFirstChild("SharedWorkshop")
local room = Instance.new("Model")
room.Name = "SharedWorkshop"
local origin = CFrame.new(135, 0.675, 0) * CFrame.Angles(0, -math.pi / 2, 0)
local ink = Color3.fromRGB(22, 31, 44)
local steel = Color3.fromRGB(48, 64, 79)
local white = Color3.fromRGB(214, 226, 231)
local mint = Color3.fromRGB(97, 234, 184)
local gold = Color3.fromRGB(248, 191, 89)
local function part(name, size, pos, color, material, solid)
	local p = Instance.new("Part")
	p.Name, p.Size, p.CFrame = name, size, origin * CFrame.new(pos)
	p.Anchored = true
	p.Color, p.Material = color, material or Enum.Material.SmoothPlastic
	p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	p.CanCollide = solid ~= false
	p.CanTouch = false
	p.CanQuery = solid ~= false
	p.Parent = room
	return p
end
local function label(p, heading, sub, color)
	local gui = Instance.new("SurfaceGui")
	gui.Name = "DisplayLabel"
	gui.Face = Enum.NormalId.Back
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 32
	gui.LightInfluence = 0
	gui.MaxDistance = 130
	gui.Parent = p
	for i, value in { heading, sub } do
		local t = Instance.new("TextLabel")
		t.Size = UDim2.fromScale(0.92, i == 1 and 0.58 or 0.26)
		t.Position = UDim2.fromScale(0.04, i == 1 and 0.06 or 0.68)
		t.BackgroundTransparency = 1
		t.Text, t.TextColor3 = value, i == 1 and (color or white) or white
		t.Font = i == 1 and Enum.Font.GothamBlack or Enum.Font.GothamMedium
		t.TextScaled = true
		t.Parent = gui
	end
end
part("Foundation", Vector3.new(80, 0.3, 52), Vector3.new(0, 0.15, 0), ink)
part("Floor", Vector3.new(78, 0.12, 50), Vector3.new(0, 0.36, 0), steel)
part("BackWall", Vector3.new(80, 20, 1.2), Vector3.new(0, 10, -25.4), ink)
for _, x in { -39.4, 39.4 } do
	part("SideWall", Vector3.new(1.2, 20, 50), Vector3.new(x, 10, 0), ink)
	part(
		"WallRail",
		Vector3.new(0.15, 0.18, 48),
		Vector3.new(x * 0.98, 5, 0),
		mint,
		Enum.Material.Neon,
		false
	)
end
-- Open central skylight keeps third-person camera clearance and sightlines to the egg.
for _, x in { -30, 30 } do
	part("RoofWing", Vector3.new(20, 1, 52), Vector3.new(x, 20.5, 0), ink)
	part("FrontPier", Vector3.new(2, 20, 2), Vector3.new(x, 10, 25), steel)
end
local sign = part("ShopSign", Vector3.new(58, 5, 1), Vector3.new(0, 18, 25), ink)
label(sign, "THE TOOLWORKS", "EQUIPMENT / UPGRADES", mint)
part("EntryLight", Vector3.new(58, 0.16, 0.18), Vector3.new(0, 15.4, 25.6), mint, Enum.Material.Neon, false)
for _, x in { -9, 9 } do
	part("AisleGuide", Vector3.new(0.12, 0.03, 34), Vector3.new(x, 0.44, 5), mint, Enum.Material.Neon, false)
end
local rules = require(game.ReplicatedStorage.VesperShared.ProgressionRules)
for i, id in rules.ToolOrder do
	local def = rules.Tools[id]
	local x = (i - 2) * 24
	part("DisplayPlinth", Vector3.new(18, 1.4, 10), Vector3.new(x, 1.1, -15), steel)
	part(
		"DisplayTrim",
		Vector3.new(18.1, 0.12, 10.1),
		Vector3.new(x, 1.85, -15),
		def.Color,
		Enum.Material.Neon,
		false
	)
	local panel =
		part(id .. "Label", Vector3.new(19, 3.4, 0.15), Vector3.new(x, 12.5, -24.65), ink, nil, false)
	label(
		panel,
		def.Name:upper(),
		string.format("%d POWER / %.2fs CYCLE", def.Power, def.Cooldown),
		def.Color
	)
	local asset = game.ReplicatedStorage.VesperShared.EquipmentAssets:FindFirstChild(id)
	if asset then
		local display = Instance.new("Model")
		display.Name = id .. "Display"
		for _, node in asset:GetDescendants() do
			if node:IsA("BasePart") then
				local p = node:Clone()
				for _, child in p:GetDescendants() do
					if
						child:IsA("JointInstance")
						or child:IsA("Constraint")
						or child:IsA("LuaSourceContainer")
					then
						child:Destroy()
					end
				end
				p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery = true, false, false, false
				p.Parent = display
			end
		end
		if #display:GetChildren() > 0 then
			local _, size = display:GetBoundingBox()
			display:ScaleTo(7 / math.max(size.X, size.Y, size.Z))
			local cf, scaled = display:GetBoundingBox()
			local desired = origin * CFrame.new(x, 2 + scaled.Y / 2, -15) * CFrame.Angles(0, -0.35, 0)
			display:PivotTo(desired * cf:ToObjectSpace(display:GetPivot()))
			display.Parent = room
		else
			display:Destroy()
		end
	end
end
local console = part("Console", Vector3.new(12, 3.6, 3), Vector3.new(0, 2.2, 9), ink)
label(console, "BROWSE EQUIPMENT", "BUY TO KEEP / EQUIP TO SWITCH", mint)
local prompt = Instance.new("ProximityPrompt")
prompt.Name, prompt.ActionText, prompt.ObjectText = "OpenEquipment", "Browse", "The Toolworks"
prompt.KeyboardKeyCode = Enum.KeyCode.F
prompt.HoldDuration, prompt.MaxActivationDistance, prompt.RequiresLineOfSight = 0, 12, true
prompt.Parent = console
local upgrades = part("UpgradeConsole", Vector3.new(10, 3.6, 3), Vector3.new(-25, 2.2, 8), ink)
label(upgrades, "UPGRADE YOUR TOOL", "EACH TOOL KEEPS ITS PROGRESS", gold)
local up = prompt:Clone()
up.Name, up.ObjectText = "OpenUpgrades", "Tool upgrades"
up.Parent = upgrades
room.WorldPivot = origin
if old then
	old:Destroy()
end
room.Parent = lab
-- Retain the old fixtures outside Workspace for easy restoration.
local archive = game.ServerStorage:FindFirstChild("RetiredPrivateShops") or Instance.new("Folder")
archive.Name, archive.Parent = "RetiredPrivateShops", game.ServerStorage
for _, personal in lab.Rooms:GetChildren() do
	local shop = personal:FindFirstChild("EquipmentStation")
	if shop then
		shop.Name = personal.Name .. "EquipmentStation"
		shop.Parent = archive
	end
end
return { parts = #room:GetDescendants(), location = tostring(origin.Position) }
