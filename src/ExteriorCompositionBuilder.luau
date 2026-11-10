-- Edit-only scenery recipe. The native library contains adapted, attributed CC0 meshes.
-- Does not modify the dome, laboratory, runtime systems, or player records.
local B = {}
local function group(parent, name)
	local m = Instance.new("Model")
	m.Name = name
	m.Parent = parent
	return m
end
local function mesh(parent, library, name, cf, scale, color)
	local t = library:FindFirstChild(name)
	assert(t and t:IsA("MeshPart"), "Missing native scenery template: " .. name)
	local p = t:Clone()
	local s = typeof(scale) == "Vector3" and scale or Vector3.one * (scale or 1)
	p.Size = t.Size * s
	p.CFrame = cf * CFrame.new(t:GetAttribute("SourceCenter") * s)
	p.Color = color or Color3.new(1, 1, 1)
	local surface = p:FindFirstChildOfClass("SurfaceAppearance")
	if surface then
		surface.Color = p.Color
	end
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.CastShadow = false
	p.Parent = parent
	return p
end
local function groundHeight(x, z)
	-- FBX import mirrors the source X coordinate. Same continuous apron as the source mesh.
	x = -x
	local t = math.clamp((math.sqrt(x * x + z * z) - 400) / 650, 0, 1)
	return (-9 + t * (10 * math.sin(x / 420) * math.cos(z / 530) + 9 * math.sin(z / 370) - 5)) * 2.7 + 16.3
end
local function point(degrees, radius)
	local a = math.rad(degrees)
	local x, z = math.cos(a) * radius, math.sin(a) * radius
	return Vector3.new(x, groundHeight(x, z), z)
end
function B.Build()
	assert(
		game.PlaceId == 94763223427049 and not game:GetService("RunService"):IsRunning(),
		"Original Edit place only"
	)
	local lab = workspace.VesperLab
	local assets = game.ServerStorage:FindFirstChild("ExteriorCompositionAssets")
	assert(assets and #assets:GetChildren() == 67, "Import the complete attributed scenery library first")
	local vegetation = game.ServerStorage.LivingLabArtAssets
	local old = lab:FindFirstChild("DecorativeExterior")
	-- All affected placements were preserved in the native recovery checkpoint.
	-- Libraries are retained; retired placements do not remain elsewhere in Workspace.
	if old then
		old:Destroy()
	end
	local root = group(lab, "DecorativeExterior")
	root:SetAttribute("SceneryOnly", true)
	root:SetAttribute("CompositionRevision", 1)
	local ground = group(root, "ContinuousLowGround")
	for _, t in assets:GetChildren() do
		if t.Name:match("^Ground_") then
			local p = mesh(
				ground,
				assets,
				t.Name,
				CFrame.new(0, 16.3, 0),
				Vector3.new(1, 2.7, 1),
				Color3.fromRGB(104, 120, 78)
			)
			p.Material = Enum.Material.Grass
		end
	end
	task.wait()
	local peaks = group(root, "SeparatedRockMassifs")
	-- Real downloaded mountain geometry; rotations and unequal scales expose different peaks.
	-- An opening toward +X,+Z remains between the eastern and northern massifs.
	for i, d in
		{
			{ 8, 2100, -62, 1.06, 1.70, 1.09, 14 },
			{ 112, 1850, -65, 1.10, 1.75, 0.94, 137 },
			{ 226, 1900, -62, 1.08, 2.00, 1.10, 259 },
			{ 308, 2210, -62, 0.92, 1.50, 1.03, 78 },
			{ 55, 3520, -62, 1.08, 1.10, 0.94, 220 },
		}
	do
		local p = point(d[1], d[2])
		local m = mesh(
			peaks,
			assets,
			"AlpineRange",
			CFrame.new(p.X, d[3], p.Z) * CFrame.Angles(0, math.rad(d[7]), 0),
			Vector3.new(d[4], d[5], d[6])
		)
		m.Name = "RockMassif" .. i
	end
	local cliffs = group(root, "RockyFoothills")
	for _, d in
		{
			{ -7, 1570, 1.4, 0.9, 22 },
			{ 27, 1590, 1.1, 0.8, -32 },
			{ 103, 1510, 1.6, 1.15, 127 },
			{ 133, 1730, 1.35, 0.9, 91 },
			{ 211, 1740, 1.5, 1.2, 217 },
			{ 246, 1800, 1.2, 0.8, 265 },
			{ 319, 2060, 1.0, 0.85, 305 },
		}
	do
		local p = point(d[1], d[2])
		mesh(
			cliffs,
			assets,
			"StrataCliff",
			CFrame.new(p - Vector3.new(0, 65, 0)) * CFrame.Angles(0, math.rad(d[5]), 0),
			Vector3.new(d[3], d[4], d[3])
		)
		mesh(
			cliffs,
			assets,
			"RockButtress",
			CFrame.new(p + Vector3.new(90, -31, 40)) * CFrame.Angles(0, math.rad(d[5] + 60), 0),
			Vector3.new(d[3], d[4] * 0.75, d[3])
		)
	end
	task.wait()
	local forest = group(root, "IrregularForestIslands")
	local rng = Random.new(17741)
	local names = { "CanopyOak", "CanopyYoung", "MountainPine", "CanopyTwisted", "MountainPine" }
	-- Groups have individual centers, depth and density; no circular row or uniform tree wall.
	for i, d in
		{
			{ -18, 840, 13, 160, 115 },
			{ 19, 1080, 11, 160, 190 },
			{ 89, 960, 14, 135, 200 },
			{ 128, 1030, 9, 185, 110 },
			{ 175, 850, 12, 130, 180 },
			{ 218, 1160, 15, 200, 155 },
			{ 259, 950, 9, 135, 130 },
			{ 302, 1090, 11, 165, 170 },
			{ 343, 1350, 8, 120, 200 },
		}
	do
		local island = group(forest, "TreeGroup" .. i)
		local center = point(d[1], d[2])
		for j = 1, d[3] do
			local angle = rng:NextNumber(0, math.pi * 2)
			local radius = math.sqrt(rng:NextNumber())
			local x, z =
				center.X + math.cos(angle) * radius * d[4], center.Z + math.sin(angle) * radius * d[5]
			local s = rng:NextNumber(3.4, 5.4)
			mesh(
				island,
				vegetation,
				names[(j + i) % #names + 1],
				CFrame.new(x, groundHeight(x, z) - 0.6, z)
					* CFrame.Angles(0, rng:NextNumber(0, math.pi * 2), 0),
				Vector3.new(s * rng:NextNumber(0.82, 1.13), s, s),
				Color3.fromRGB(239, 245, 226)
			)
		end
		task.wait()
	end
	local apron = group(root, "SparseMeadowPockets")
	for i, d in
		{
			{ 12, 520 },
			{ 72, 620 },
			{ 121, 475 },
			{ 162, 610 },
			{ 202, 530 },
			{ 244, 650 },
			{ 293, 515 },
			{ 334, 590 },
			{ 43, 960 },
			{ 151, 1280 },
			{ 276, 1380 },
		}
	do
		local pocket = group(apron, "MeadowPocket" .. i)
		local center = point(d[1], d[2])
		for j = 1, 8 do
			local x, z = center.X + rng:NextNumber(-39, 39), center.Z + rng:NextNumber(-25, 25)
			local name = j <= 4 and "SoftGrass"
				or j == 5 and "ForestFern"
				or j == 6 and "GroundShrub"
				or j == 7 and "RockRound"
				or "LeafShrub"
			local s = name == "RockRound" and rng:NextNumber(0.65, 1.4) or rng:NextNumber(1.2, 2.3)
			mesh(
				pocket,
				vegetation,
				name,
				CFrame.new(x, groundHeight(x, z), z) * CFrame.Angles(0, rng:NextNumber(0, 6.28), 0),
				s,
				Color3.fromRGB(240, 243, 223)
			)
		end
	end
	local mist = group(root, "ValleyMist")
	for i, d in { { 1650, 16, 56, 300 }, { 2350, 25, 56, 410 } } do
		local p = point(d[3], d[1])
		local host = Instance.new("Part")
		host.Name = "ValleyWisp" .. i
		host.Size = Vector3.one
		host.Transparency = 1
		host.Anchored = true
		host.CanCollide = false
		host.CanTouch = false
		host.CanQuery = false
		host.CFrame = CFrame.new(p.X, d[2], p.Z)
		host.Parent = mist
		local a, b = Instance.new("Attachment"), Instance.new("Attachment")
		a.Position = Vector3.new(-d[4], 0, d[4] * 0.5)
		b.Position = -a.Position
		a.Parent = host
		b.Parent = host
		local beam = Instance.new("Beam")
		beam.Name = "LowValleyHaze"
		beam.Attachment0 = a
		beam.Attachment1 = b
		beam.FaceCamera = true
		beam.Width0 = 70
		beam.Width1 = 90
		beam.Texture = "rbxasset://textures/particles/smoke_main.dds"
		beam.TextureMode = Enum.TextureMode.Stretch
		beam.TextureSpeed = 0.015
		beam.Segments = 12
		beam.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.3, 0.94),
			NumberSequenceKeypoint.new(0.7, 0.94),
			NumberSequenceKeypoint.new(1, 1),
		})
		beam.Color = ColorSequence.new(Color3.fromRGB(217, 224, 211))
		beam.LightInfluence = 0
		beam.Parent = host
	end
	local atmosphere = game.Lighting:FindFirstChildOfClass("Atmosphere")
	if atmosphere then
		atmosphere.Density = 0.18
		atmosphere.Haze = 1.0
		atmosphere.Color = Color3.fromRGB(214, 220, 211)
		atmosphere.Decay = Color3.fromRGB(166, 180, 169)
	end
	local clouds = workspace.Terrain:FindFirstChildOfClass("Clouds") or Instance.new("Clouds")
	clouds.Cover = 0.58
	clouds.Density = 0.62
	clouds.Color = Color3.fromRGB(236, 239, 233)
	clouds.Parent = workspace.Terrain
	lab:SetAttribute("ExteriorCompositionRevision", 1)
	return "Separated sourced rock massifs, open valley, grouped forest, continuous low apron; preserved laboratory"
end
return B
