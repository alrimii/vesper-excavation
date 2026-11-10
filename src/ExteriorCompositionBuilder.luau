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
local layout = require(script.Parent.ExteriorIntegrationLayout)
local function groundHeight(x, z)
	local r = math.sqrt(x * x + z * z)
	local t = math.clamp((r - 350) / 500, 0, 1)
	t = t * t * (3 - 2 * t)
	local y = -8 + t * (8 + 13 * math.sin(x / 430) * math.cos(z / 520) + 9 * math.sin(z / 310))
	for _, d in layout.grading do
		y += t * d[3] * math.exp(-(((x - d[1]) / d[4]) ^ 2 + ((z - d[2]) / d[5]) ^ 2) * 1.7)
	end
	local a = math.rad(55)
	local u = x * math.cos(a) + z * math.sin(a)
	local v = -x * math.sin(a) + z * math.cos(a)
	y -= math.clamp((u - 800) / 900, 0, 1) * math.exp(-((v - 110 * math.sin(u / 650)) / 360) ^ 2) * 18
	return y
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
	local grading = game.ServerStorage:FindFirstChild("ExteriorIntegrationAssets")
	assert(grading and #grading:GetChildren() == 64, "Imported continuous grading required")
	local old = lab:FindFirstChild("DecorativeExterior")
	-- All affected placements were preserved in the native recovery checkpoint.
	-- Libraries are retained; retired placements do not remain elsewhere in Workspace.
	if old then
		old:Destroy()
	end
	local root = group(lab, "DecorativeExterior")
	root:SetAttribute("SceneryOnly", true)
	root:SetAttribute("CompositionRevision", 2)
	local ground = group(root, "ContinuousLowGround")
	for _, d in layout.ground do
		local p = mesh(ground, grading, d.name, CFrame.identity, 1, Color3.new(1, 1, 1))
		p.TextureID = grading:GetAttribute("GroundColor")
		p.Material = Enum.Material.SmoothPlastic
	end
	task.wait()
	local peaks = group(root, "SeparatedRockMassifs")
	-- Real downloaded mountain geometry; rotations and unequal scales expose different peaks.
	-- An opening toward +X,+Z remains between the eastern and northern massifs.
	for i, d in layout.peaks do
		local p = point(d[1], d[2])
		local m = mesh(
			peaks,
			assets,
			"AlpineRange",
			CFrame.new(p.X, d[3], p.Z) * CFrame.Angles(0, math.rad(d[7]), 0),
			Vector3.new(d[4], d[5], d[6])
		)
		m.Name = "RockMassif" .. i
		m.TextureID = grading:GetAttribute("AlpineColor")
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
		-- The seven open-backed StrataCliff scan sheets are retired: grading exposed thin fragments.
		local x, z = p.X + 90, p.Z + 40
		local seat = math.min(
			groundHeight(x, z),
			groundHeight(x - 70, z),
			groundHeight(x + 70, z),
			groundHeight(x, z - 70),
			groundHeight(x, z + 70)
		)
		local buttress = mesh(
			cliffs,
			assets,
			"RockButtress",
			CFrame.new(x, seat - 35, z) * CFrame.Angles(0, math.rad(d[5] + 60), 0),
			Vector3.new(d[3], d[4] * 0.6, d[3])
		)
		buttress.TextureID = grading:GetAttribute("ButtressColor")
	end
	task.wait()
	local forest = group(root, "IrregularForestIslands")
	local apron = group(root, "SparseMeadowPockets")
	local patches = {}
	for index, d in layout.planting do
		local parent = d.kind == "tree" and forest or apron
		if not patches[d.patch] then
			patches[d.patch] = group(parent, d.patch)
		end
		local p = mesh(
			patches[d.patch],
			vegetation,
			d.name,
			CFrame.new(d.x, d.y, d.z) * CFrame.Angles(0, d.yaw, 0),
			Vector3.new(unpack(d.scale)),
			Color3.fromRGB(unpack(d.color))
		)
		p:SetAttribute("RetainedV180Placement", d.retained)
		if index % 60 == 0 then
			task.wait()
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
		host.CFrame = CFrame.new(p.X, groundHeight(p.X, p.Z) + 12, p.Z)
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
	-- Keep the v180 sky, shared lighting, glazing and atmosphere unchanged.
	lab:SetAttribute("ExteriorCompositionRevision", 2)
	return "Integrated v180 massifs, continuous foothill grading, connected woodland patches and softened source materials"
end
return B
