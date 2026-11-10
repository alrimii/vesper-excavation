-- Historical recipe: protected against restoring superseded map geometry.
assert(not (workspace:FindFirstChild("VesperLab") and workspace.VesperLab:GetAttribute("MapCleanupRevision")), "Historical recipe retired; use MapCleanupBuilder for the current map")
-- Edit-time construction. The fixed gantry carries every animated hoist cable.
local lab = workspace.VesperLab
local old = lab:FindFirstChild("CraneGantry")
local model = Instance.new("Model")
model.Name = "CraneGantry"
local graphite, steel, enamel =
	Color3.fromRGB(30, 38, 46), Color3.fromRGB(78, 89, 98), Color3.fromRGB(190, 198, 201)
local amber = Color3.fromRGB(224, 160, 68)
local function part(name, size, cf, color, material)
	local p = Instance.new("Part")
	p.Name, p.Size, p.CFrame = name, size, cf
	p.Color, p.Material = color, material or Enum.Material.Metal
	p.Anchored, p.CanTouch = true, false
	p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	p.Parent = model
	return p
end
local function beam(name, a, b, width, color)
	return part(name, Vector3.new(width, width, (b - a).Magnitude), CFrame.lookAt((a + b) / 2, b), color)
end
for _, x in { -96, 96 } do
	for _, z in { -96, 96 } do
		part("Foundation", Vector3.new(15, 2, 15), CFrame.new(x, 1.675, z), graphite)
		for _, dx in { -3.8, 3.8 } do
			for _, dz in { -3.8, 3.8 } do
				part("TowerChord", Vector3.new(2.4, 188, 2.4), CFrame.new(x + dx, 96, z + dz), enamel)
			end
		end
		for i = 0, 4 do
			local y = 3 + i * 37.4
			for _, side in { -1, 1 } do
				beam(
					"TowerDiagonal",
					Vector3.new(x - 3.8, y, z + side * 3.8),
					Vector3.new(x + 3.8, y + 37.4, z + side * 3.8),
					1.25,
					steel
				)
			end
			part("TowerCollar", Vector3.new(11, 1.4, 11), CFrame.new(x, y, z), graphite)
		end
		part("ImpactGuard", Vector3.new(11, 5, 11), CFrame.new(x, 5.2, z), graphite)
		part("GuardStripe", Vector3.new(11.1, 0.55, 11.1), CFrame.new(x, 7, z), amber)
		part("BearingCap", Vector3.new(15, 3, 15), CFrame.new(x, 191, z), steel)
	end
end
for _, side in { -96, 96 } do
	beam("Runway", Vector3.new(side, 190, -96), Vector3.new(side, 190, 96), 5, graphite)
	beam("RunwayTop", Vector3.new(side, 197, -96), Vector3.new(side, 197, 96), 3, enamel)
	beam("EndTie", Vector3.new(-96, 190, side), Vector3.new(96, 190, side), 4, steel)
	for i = 0, 7 do
		local z = -96 + i * 24
		beam("RunwayWeb", Vector3.new(side, 190, z), Vector3.new(side, 197, z + 24), 1.5, steel)
	end
end
for _, z in { -25, 25 } do
	beam("BridgeLowerChord", Vector3.new(-96, 187, z), Vector3.new(96, 187, z), 4, graphite)
	beam("BridgeUpperChord", Vector3.new(-96, 194, z), Vector3.new(96, 194, z), 3, enamel)
	for i = 0, 7 do
		local x = -96 + i * 24
		beam("BridgeWeb", Vector3.new(x, 187, z), Vector3.new(x + 24, 194, z), 1.5, steel)
	end
end
part("HoistPlatform", Vector3.new(58, 3, 58), CFrame.new(0, 190, 0), graphite)
part("DriveHousing", Vector3.new(18, 7, 15), CFrame.new(0, 195, 0), enamel)
for i = 0, 3 do
	local a = i * math.pi / 2
	local position = Vector3.new(math.cos(a) * 22, 189, math.sin(a) * 22)
	local mount = part("CableAnchor" .. (i + 1), Vector3.new(8, 3, 8), CFrame.new(position), steel)
	local light = Instance.new("SurfaceLight")
	light.Face = Enum.NormalId.Bottom
	light.Range = 90
	light.Brightness = 1.3
	light.Angle = 110
	light.Color = Color3.fromRGB(242, 231, 207)
	light.Shadows = false
	light.Parent = mount
	local drum = part("HoistDrum", Vector3.new(7, 6, 6), CFrame.new(position + Vector3.yAxis * 5), graphite)
	drum.Shape = Enum.PartType.Cylinder
	part(
		"DriveIndicator",
		Vector3.new(4, 0.25, 0.3),
		CFrame.new(position + Vector3.new(0, 6, -3.1)),
		amber,
		Enum.Material.Neon
	).CanCollide =
		false
end
if old then
	old:Destroy()
end
local previousRig = lab:FindFirstChild("OverheadRig")
if previousRig then
	local archive = game.ServerStorage:FindFirstChild("RetiredCraneFixtures") or Instance.new("Folder")
	archive.Name = "RetiredCraneFixtures"
	archive.Parent = game.ServerStorage
	previousRig.Parent = archive
end
model.Parent = lab
return { parts = #model:GetChildren(), name = model.Name }
