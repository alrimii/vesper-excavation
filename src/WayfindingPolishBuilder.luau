-- Historical recipe: protected against restoring superseded map geometry.
assert(not (workspace:FindFirstChild("VesperLab") and workspace.VesperLab:GetAttribute("MapCleanupRevision")), "Historical recipe retired; use MapCleanupBuilder for the current map")
assert(not game:GetService("RunService"):IsRunning(), "Edit only")
local lab = workspace.VesperLab
assert(not lab:FindFirstChild("WayfindingFixtures"), "Wayfinding already installed")
local backup = Instance.new("Folder")
backup.Name = "BeforeWayfinding_20261109"
lab.Presentation:Clone().Parent = backup
lab.Infrastructure:Clone().Parent = backup
backup.Parent = game.ServerStorage
local retired = Instance.new("Folder")
retired.Name = "RetiredSigns"
retired.Parent = backup
local fixtures = Instance.new("Model")
fixtures.Name = "WayfindingFixtures"
local steel = Color3.fromRGB(74, 86, 94)
local ink = Color3.fromRGB(18, 28, 36)
local amber = Color3.fromRGB(224, 160, 68)
local function part(name, size, cf, color)
	local p = Instance.new("Part")
	p.Name, p.Size, p.CFrame = name, size, cf
	p.Color, p.Material = color, Enum.Material.Metal
	p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery = true, false, false, false
	p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	p.Parent = fixtures
	return p
end
local assigned = {}
for _, sign in lab.Presentation:GetChildren() do
	if sign.Name ~= "SectorNumber" then
		continue
	end
	local nearest, distance = nil, math.huge
	for _, room in lab.Rooms:GetChildren() do
		local d = (room.RoomSpawn.Position - sign.Position).Magnitude
		if d < distance then
			nearest, distance = room, d
		end
	end
	local number = nearest:GetAttribute("RoomNumber")
	assert(not assigned[number], "Duplicate room route assignment")
	assigned[number] = true
	local lintel, best = nil, math.huge
	for _, p in lab.Presentation:GetChildren() do
		if p.Name == "PortalLintel" and (p.Position - sign.Position).Magnitude < best then
			lintel, best = p, (p.Position - sign.Position).Magnitude
		end
	end
	assert(lintel, "Missing route support")
	local inward = Vector3.new(-lintel.Position.X, 0, -lintel.Position.Z).Unit
	local cf =
		CFrame.lookAt(lintel.Position + inward * (lintel.Size.Z / 2 + 0.35), lintel.Position + inward * 10)
	local housing = part("RoomRouteSign", Vector3.new(24, 4.8, 0.6), cf, steel)
	housing:SetAttribute("RoomNumber", number)
	local face = part("RouteSignFace", Vector3.new(23.4, 4.2, 0.12), cf * CFrame.new(0, 0, -0.37), ink)
	part("RouteAccent", Vector3.new(0.12, 3.2, 0.08), cf * CFrame.new(-10.8, 0, -0.48), amber)
	local gui = Instance.new("SurfaceGui")
	gui.Name = "RoomRouteLabel"
	gui.Face, gui.CanvasSize = Enum.NormalId.Front, Vector2.new(960, 168)
	gui.AlwaysOnTop, gui.LightInfluence, gui.Parent = false, 0, face
	local function label(text, x, w, size, color)
		local t = Instance.new("TextLabel")
		t.Size, t.Position = UDim2.new(w, 0, 1, 0), UDim2.fromScale(x, 0)
		t.Text, t.Font, t.TextSize = text, Enum.Font.GothamBold, size
		t.TextColor3, t.BackgroundTransparency, t.Parent = color, 1, gui
	end
	label(string.format("%02d", number), 0.04, 0.25, 95, Color3.fromRGB(246, 217, 163))
	label("PERSONAL LAB", 0.31, 0.65, 46, Color3.fromRGB(229, 239, 244))
	-- Housing rear face touches the beam; brackets remain visibly attached.
	for _, x in { -9, 9 } do
		part("SignMount", Vector3.new(0.8, 2, 0.5), cf * CFrame.new(x, 0, 0.3), steel)
	end
	sign.Parent = retired
end
local retiredSectorSigns = 0
for _, p in lab.Infrastructure:GetDescendants() do
	if p.Name == "SectorSign" and p:IsA("BasePart") then
		p.Parent = retired
		retiredSectorSigns += 1
	end
end
local lamps = 0
for _, p in lab.Infrastructure:GetDescendants() do
	if p:IsA("BasePart") and p.Name == "RouteLamp" then
		lamps += 1
		local cf = p.CFrame
		-- A recessed lens, opaque cap and rim replace the exposed glowing slab.
		p.Color = Color3.fromRGB(244, 231, 208)
		part("RouteLampCap", Vector3.new(4.6, 0.28, 4.6), cf * CFrame.new(0, 0.38, 0), steel)
		for _, x in { -2.18, 2.18 } do
			part("RouteLampRim", Vector3.new(0.2, 0.55, 4.6), cf * CFrame.new(x, 0, 0), ink)
		end
		for _, z in { -2.18, 2.18 } do
			part("RouteLampRim", Vector3.new(4.2, 0.55, 0.2), cf * CFrame.new(0, 0, z), ink)
		end
		local pole = p.Parent:FindFirstChild("LampPole")
		if pole then
			part(
				"LampFoot",
				Vector3.new(2.2, 0.28, 2.2),
				CFrame.new(pole.Position.X, 0.815, pole.Position.Z),
				steel
			)
			part(
				"LampCollar",
				Vector3.new(0.95, 0.5, 0.95),
				CFrame.new(pole.Position.X, 1.25, pole.Position.Z),
				ink
			)
		end
		for _, light in p:GetChildren() do
			if light:IsA("Light") then
				light.Color = Color3.fromRGB(244, 231, 208)
			end
		end
	end
end
fixtures.Parent = lab
return {
	roomRoutes = 12,
	retiredSectorSigns = retiredSectorSigns,
	lamps = lamps,
	newParts = #fixtures:GetChildren(),
}
