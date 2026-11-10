-- Historical recipe: protected against restoring superseded map geometry.
assert(not (workspace:FindFirstChild("VesperLab") and workspace.VesperLab:GetAttribute("MapCleanupRevision")), "Historical recipe retired; use MapCleanupBuilder for the current map")
-- Edit-time art pass. Existing geometry is archived, never deleted.
local lab = workspace.VesperLab
local archive = game.ServerStorage:FindFirstChild("RoomRebuildArchive") or Instance.new("Folder")
archive.Name = "RoomRebuildArchive"
archive.Parent = game.ServerStorage
local dark = Color3.fromRGB(29, 43, 66)
local white = Color3.fromRGB(222, 233, 242)
local cyan = Color3.fromRGB(70, 215, 202)
local gold = Color3.fromRGB(255, 193, 83)
local function part(parent, name, size, cf, color, material)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Anchored = true
	p.CanTouch = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end
local function sign(parent, adornee, title, subtitle, color)
	local g = Instance.new("BillboardGui")
	g.Name = "MachineLabel"
	g.Adornee = adornee
	g.Size = UDim2.fromOffset(220, 65)
	g.StudsOffsetWorldSpace = Vector3.new(0, 5, 0)
	g.MaxDistance = 65
	g.AlwaysOnTop = false
	g.Parent = parent
	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1, 0.6)
	t.BackgroundTransparency = 1
	t.Text = title
	t.TextColor3 = color
	t.TextSize = 23
	t.Font = Enum.Font.GothamBlack
	t.TextStrokeTransparency = 0.65
	t.Parent = g
	local d = t:Clone()
	d.Position = UDim2.fromScale(0, 0.6)
	d.Size = UDim2.fromScale(1, 0.4)
	d.Text = subtitle
	d.TextSize = 12
	d.TextColor3 = white
	d.Parent = g
end
for _, room in lab.Rooms:GetChildren() do
	if room:FindFirstChild("TrainingStation") then
		continue
	end
	local basis = room:GetPivot()
	local station = Instance.new("Model")
	station.Name = "TrainingStation"
	station:SetAttribute("RoomNumber", room:GetAttribute("RoomNumber"))
	local origin = basis * CFrame.new(-22, 1.45, -4)
	local base = part(station, "Base", Vector3.new(14, 0.65, 12), origin * CFrame.new(0, 0.325, 0), dark)
	part(station, "Deck", Vector3.new(13, 0.2, 11), origin * CFrame.new(0, 0.75, 0), white)
	for _, x in { -6, 6 } do
		part(station, "Pillar", Vector3.new(1.3, 10, 2), origin * CFrame.new(x, 5.5, -3.6), white)
		part(
			station,
			"PillarInset",
			Vector3.new(0.3, 8, 0.15),
			origin * CFrame.new(x, 5.5, -2.5),
			cyan,
			Enum.Material.Neon
		)
		part(station, "PillarFoot", Vector3.new(2.2, 1, 3), origin * CFrame.new(x, 1, -3.6), dark)
	end
	part(station, "Crosshead", Vector3.new(13, 1.4, 3.2), origin * CFrame.new(0, 10.3, -3.6), dark)
	part(
		station,
		"Hydraulic",
		Vector3.new(0.65, 2.3, 0.65),
		origin * CFrame.new(0, 8.7, -3.6),
		white,
		Enum.Material.Metal
	)
	local hammer =
		part(station, "PressHead", Vector3.new(4.3, 0.7, 3.8), origin * CFrame.new(0, 7.65, -3.6), gold)
	hammer:SetAttribute("RestCFrame", hammer.CFrame)
	for _, name in { "PressHead", "Hydraulic" } do
		local decoration = station:FindFirstChild(name)
		decoration.Transparency = 1
		decoration.CanCollide = false
		decoration.CanQuery = false
		decoration.CanTouch = false
		decoration.CastShadow = false
	end
	local egg = part(
		station,
		"PracticeEgg",
		Vector3.new(3.4, 4.4, 3.4),
		origin * CFrame.new(0, 3.7, -3.6),
		Color3.fromRGB(240, 225, 188)
	)
	egg.Shape = Enum.PartType.Ball
	egg.CanCollide = false
	egg.CanTouch = false
	egg:SetAttribute("RestCFrame", egg.CFrame)
	egg:SetAttribute("RestSize", egg.Size)
	local cup = part(
		station,
		"Cradle",
		Vector3.new(0.6, 4.6, 4.6),
		origin * CFrame.new(0, 1.3, -3.6) * CFrame.Angles(0, 0, math.pi / 2),
		dark
	)
	cup.Shape = Enum.PartType.Cylinder
	local spot =
		part(station, "TrainingSpot", Vector3.new(4, 0.12, 2.4), origin * CFrame.new(0, 0.92, 0.2), cyan)
	spot.Material = Enum.Material.Neon
	spot.CanCollide = false
	local console =
		part(station, "Control", Vector3.new(2.6, 2.2, 1.2), origin * CFrame.new(4.3, 2.1, 2.4), dark)
	part(
		station,
		"Screen",
		Vector3.new(2.2, 1.2, 0.12),
		console.CFrame * CFrame.new(0, 0.2, 0.67),
		cyan,
		Enum.Material.Neon
	)
	-- Training entry uses the marked server-owned area; no TrainStrength prompt.
	sign(station, station.Crosshead, "TOOL PRACTICE", "EQUIP / TRAIN / GROW", cyan)
	station.PrimaryPart = base
	station.Parent = room
	local workshop = Instance.new("Model")
	workshop.Name = "EquipmentStation"
	local work = basis * CFrame.new(22, 1.45, -4)
	part(workshop, "Podium", Vector3.new(13, 0.8, 11), work * CFrame.new(0, 0.4, 0), dark)
	part(workshop, "Inlay", Vector3.new(12, 0.15, 10), work * CFrame.new(0, 0.9, 0), gold)
	local bench = part(workshop, "Console", Vector3.new(10, 3.2, 4), work * CFrame.new(0, 2.6, -2), white)
	part(workshop, "Screen", Vector3.new(8, 2, 0.15), work * CFrame.new(0, 3, -0.1), dark)
	local template = game.ServerStorage.VesperKit:FindFirstChild("StarterDrill")
	if template then
		local display = Instance.new("Model")
		display.Name = "DrillDisplay"
		for _, p in template:GetDescendants() do
			if p:IsA("BasePart") and p.Transparency < 1 then
				local c = p:Clone()
				for _, j in c:GetDescendants() do
					if j:IsA("JointInstance") or j:IsA("WeldConstraint") then
						j:Destroy()
					end
				end
				c.Anchored = true
				c.CanCollide = false
				c.Parent = display
			end
		end
		display:ScaleTo(2)
		local cf = display:GetBoundingBox()
		display:PivotTo(
			work
				* CFrame.new(0, 6.8, -2)
				* CFrame.Angles(0, math.rad(35), math.rad(-20))
				* CFrame.new(-cf.Position)
				* display:GetPivot()
		)
		display.Parent = workshop
	end
	local prompt2 = Instance.new("ProximityPrompt")
	prompt2.Name = "OpenEquipment"
	prompt2.ActionText = "Equipment"
	prompt2.ObjectText = "Upgrades + free drill trial"
	prompt2.KeyboardKeyCode = Enum.KeyCode.F
	prompt2.MaxActivationDistance = 14
	prompt2.RequiresLineOfSight = false
	prompt2.Parent = bench
	sign(workshop, bench, "GEAR UP", "UPGRADE / TRY THE HELIX DRILL", gold)
	workshop.PrimaryPart = bench
	workshop.Parent = room
	for _, p in room:GetDescendants() do
		if p:IsA("BasePart") and not p:IsDescendantOf(station) and not p:IsDescendantOf(workshop) then
			if p.Name == "WallPanel" or p.Name == "RearPanel" or p.Name == "Ceiling" then
				p.Color = Color3.fromRGB(111, 135, 153)
			elseif p.Name == "JambStripe" or p.Name == "HeaderLight" or p.Name == "SpawnLane" then
				p.Color = cyan
			end
			if p.Name == "CeilingFixture" then
				local light = Instance.new("SurfaceLight")
				light.Name = "RoomSoftbox"
				light.Face = Enum.NormalId.Bottom
				light.Angle = 150
				light.Range = 50
				light.Brightness = 2
				light.Color = Color3.fromRGB(220, 238, 255)
				light.Shadows = false
				light.Parent = p
			end
		end
	end
	task.wait()
end
local old = lab:FindFirstChild("TrainingStation")
if old then
	old.Parent = archive
end
-- Remove accumulated ornamental clutter while retaining the playable access ramp.
for _, name in
	{
		"PlatformFinish",
		"CollectionApron",
		"FloorMarkings",
		"RouteDetails",
		"ObservationConsole1",
		"ObservationConsole2",
		"ObservationConsole3",
		"ObservationConsole4",
	}
do
	local m = lab:FindFirstChild(name)
	if m then
		m.Parent = archive
	end
end
for _, p in lab.CentralPlatform:GetChildren() do
	if p:IsA("BasePart") then
		if
			p.Name == "SafetyHandrail"
			or p.Name == "RailStanchion"
			or p.Name == "DeckHazard"
			or p.Name == "DeckLightStem"
			or p.Name == "DeckLamp"
		then
			p.Parent = archive
		else
			p.Color = p.Name == "CradleAccent" and cyan or dark
		end
	end
end
for _, p in lab.ExcavationAccess:GetDescendants() do
	if p:IsA("BasePart") then
		if p.Name == "SmoothOuterBarrier" then
			p.Transparency = 0.65
			p.Color = Color3.fromRGB(149, 201, 219)
			p.Material = Enum.Material.Glass
		elseif p.Name == "ContinuousRamp" then
			p.Color = Color3.fromRGB(70, 87, 106)
			p.Material = Enum.Material.SmoothPlastic
		end
	end
end
for _, v in lab.ResourceDepot:GetDescendants() do
	if v:IsA("BillboardGui") or v:IsA("SurfaceGui") then
		v.Enabled = false
	end
	if v:IsA("BasePart") then
		v.Transparency = 1
		v.CanCollide = false
		v.CanQuery = false
	end
end
local light = game:GetService("Lighting")
light.Brightness = 2
light.Ambient = Color3.fromRGB(112, 130, 154)
light.OutdoorAmbient = Color3.fromRGB(135, 152, 173)
light.ExposureCompensation = 0.2
return "Twelve furnished home labs; old center clutter archived."
