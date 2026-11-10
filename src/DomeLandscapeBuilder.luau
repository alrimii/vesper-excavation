-- Edit-only bounded continuation of the accepted Foggy exterior; no runtime builder.
local B = {}
local function part(parent, name, size, cf, color, material)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.Metal
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.CastShadow = false
	p.Parent = parent
	return p
end
local function beam(parent, name, a, b, width, color)
	return part(
		parent,
		name,
		Vector3.new(width, width, (b - a).Magnitude),
		CFrame.lookAt((a + b) / 2, b),
		color
	)
end
local function triangle(parent, a, b, c, color)
	local ab, ac, bc = b - a, c - a, c - b
	if ab.Magnitude > ac.Magnitude and ab.Magnitude > bc.Magnitude then
		c, a = a, c
	elseif ac.Magnitude > bc.Magnitude then
		a, b = b, a
	end
	ab, ac, bc = b - a, c - a, c - b
	local right = ac:Cross(ab).Unit
	local back = bc.Unit
	local up = bc:Cross(right).Unit
	local h = math.abs(ab:Dot(up))
	for _, v in
		{ { (a + b) / 2, right, back, math.abs(ab:Dot(back)) }, { (a + c) / 2, -right, -back, math.abs(
			ac:Dot(back)
		) } }
	do
		local w = Instance.new("WedgePart")
		w.Name = "ContinuousSlope"
		w.Size = Vector3.new(0.1, h, math.max(0.01, v[4]))
		w.CFrame = CFrame.fromMatrix(v[1], v[2], up, v[3])
		w.Color = color
		w.Material = Enum.Material.SmoothPlastic
		w.Anchored = true
		w.CanCollide = false
		w.CanQuery = false
		w.CanTouch = false
		w.CastShadow = false
		w.Parent = parent
	end
end
function B.Build()
	assert(
		game.PlaceId == 94763223427049 and not game:GetService("RunService"):IsRunning(),
		"Original Edit place only"
	)
	local lab = workspace.VesperLab
	local exterior = lab.DecorativeExterior
	local old = exterior:FindFirstChild("AtmosphericLayers")
	if old then
		old:Destroy()
	end
	local layers = Instance.new("Model")
	layers.Name = "AtmosphericLayers"
	layers:SetAttribute("SceneryOnly", true)
	layers.Parent = exterior
	lab.DecorativeExterior.FoggyGazeboExterior.BakedDistantForest:ClearAllChildren()
	-- Closed continuous radial terrain, grounded below the existing scene. No raised foreground shelf.
	local n = 72
	local bands = { { 980, -45 }, { 1400, 235 }, { 1950, 370 }, { 2600, 610 }, { 3200, -50 } }
	local colors = {
		Color3.fromRGB(83, 121, 108),
		Color3.fromRGB(102, 143, 133),
		Color3.fromRGB(137, 169, 164),
		Color3.fromRGB(153, 179, 176),
	}
	local function point(b, i)
		local angle = i * 2 * math.pi / n
		local radius, height = bands[b][1], bands[b][2]
		if b > 1 and b < 5 then
			height += math.sin(angle * 5 + 1.2 * b) * 55 + math.sin(angle * 9 - b) * 28 + math.sin(angle * 3) * 70
		end
		return Vector3.new(math.sin(angle) * radius, height, math.cos(angle) * radius)
	end
	for band = 1, 4 do
		for i = 0, n - 1 do
			local a, b, c, d = point(band, i), point(band, i + 1), point(band + 1, i), point(band + 1, i + 1)
			triangle(layers, a, b, c, colors[band])
			triangle(layers, b, d, c, colors[band])
		end
		task.wait()
	end
	-- Reuse already imported source foliage as a repeated distant tree line, not new asset selection.
	local assets = game.ServerStorage.FoggyGazeboAssets
	local tree = assets:FindFirstChild("Tree_0_leaf")
	if not tree then
		for _, p in assets:GetChildren() do
			if p.Name:match("_leaf$") then
				tree = p
				break
			end
		end
	end
	assert(tree, "Existing source leaf template required")
	for i = 0, 59 do
		local angle = i * math.pi * 2 / 60
		local scale = 0.48 + 0.12 * (0.5 + 0.5 * math.sin(i * 4.7))
		local radius = 1360 + 45 * math.sin(i * 2.3)
		local p = tree:Clone()
		p.Name = "DistantSourceCanopy"
		p.Size = tree.Size * scale
		local h = 235
			+ math.sin(angle * 5 + 2.4) * 55
			+ math.sin(angle * 9 - 2) * 28
			+ math.sin(angle * 3) * 70
		p.CFrame = CFrame.new(math.sin(angle) * radius, h + p.Size.Y * 0.12, math.cos(angle) * radius)
			* CFrame.Angles(0, angle, 0)
		p.TextureID = ""
		p.Color = Color3.fromRGB(77, 117, 102)
		p.Transparency = 0
		p.Material = Enum.Material.SmoothPlastic
		p.DoubleSided = true
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.CastShadow = false
		for _, c in p:GetChildren() do
			if c:IsA("SurfaceAppearance") then
				c:Destroy()
			end
		end
		local sa = Instance.new("SurfaceAppearance")
		sa.ColorMap = "rbxassetid://137012180294436"
		sa.RoughnessMap = "rbxassetid://113355786572368"
		sa.AlphaMode = Enum.AlphaMode.Transparency
		sa.Parent = p
		p.Color = Color3.fromRGB(160, 191, 175)
		p.Parent = layers
		if i % 12 == 0 then
			task.wait()
		end
	end
	local dark = Color3.fromRGB(39, 51, 50)
	for _, p in lab.Dome:GetDescendants() do
		if p:IsA("BasePart") then
			if p.Name:match("DomePane") or p.Name == "ClerestoryGlass" then
				p.Material = Enum.Material.SmoothPlastic
				p.Color = Color3.fromRGB(94, 115, 110)
				p.Transparency = 0.9
				p.Reflectance = 0
				p.CastShadow = false
			end
			if p.Name == "DomePane5" then
				p.Material = Enum.Material.Metal
				p.Color = Color3.fromRGB(67, 80, 76)
				p.Transparency = 0
				p.CastShadow = true
			end
			if p.Name == "ConnectedMeridian" or p.Name == "LatitudeJoint" then
				p.Size = Vector3.new(1.5, 1.5, p.Size.Z)
				p.Color = dark
			end
			if p.Name == "PeripheralColumn" or p.Name == "SillCap" or p.Name == "CrownJoint" then
				p.Color = dark
			end
		end
	end
	local dock = lab.CrownDeliveryDock
	local previous = dock:FindFirstChild("HoistHousing")
	if previous then
		previous:Destroy()
	end
	local housing = Instance.new("Model")
	housing.Name = "HoistHousing"
	housing.Parent = dock
	part(housing, "UpperEnclosure", Vector3.new(52, 5, 52), CFrame.new(0, 246, 0), Color3.fromRGB(64, 76, 72))
	part(housing, "LowerRim", Vector3.new(55, 1, 55), CFrame.new(0, 243.2, 0), dark)
	for i = 1, 4 do
		local socket = dock:FindFirstChild("DeliverySocket" .. i)
		local pos = socket.Position
		socket.Position = Vector3.new(pos.X, 242, pos.Z)
		local x, z = pos.X, pos.Z
		part(
			housing,
			"WinchCasing" .. i,
			Vector3.new(7, 3, 8),
			CFrame.new(x, 240.5, z),
			Color3.fromRGB(97, 109, 99)
		)
		part(housing, "CableGuide" .. i, Vector3.new(1.4, 0.6, 1.4), CFrame.new(x, 238.7, z), dark)
		part(
			housing,
			"StowedGripper" .. i,
			Vector3.new(3.6, 1.5, 3.6),
			CFrame.new(x, 237.5, z),
			Color3.fromRGB(121, 132, 123)
		)
		-- Restrained oxidation on fixed casing seams; cable routes remain bare.
		part(
			housing,
			"WeatheredSeam",
			Vector3.new(6, 0.12, 0.15),
			CFrame.new(x, 239.05, z + 3.8),
			Color3.fromRGB(112, 88, 66)
		)
	end
	for _, z in { -18, 18 } do
		for _, x in { -1, 1 } do
			beam(
				housing,
				"CrownBrace",
				Vector3.new(x * 26, 245, z),
				Vector3.new(x * math.sqrt(88 * 88 - z * z), 247, z),
				2.2,
				dark
			)
		end
	end
	-- A small patch on a fixed rim, away from the four cable guides.
	for i = 1, 7 do
		local p = part(
			housing,
			"FixedRimMoss",
			Vector3.new(2.5, 0.25, 1.8),
			CFrame.new(-22 + i * 1.1, 244, -25),
			Color3.fromRGB(83, 104, 69),
			Enum.Material.Grass
		)
	end
	local at = game.Lighting:FindFirstChildOfClass("Atmosphere")
	if at then
		at.Density = 0.24
		at.Haze = 1.65
		at.Color = Color3.fromRGB(200, 219, 216)
		at.Decay = Color3.fromRGB(137, 165, 160)
		at.Glare = 0
	end
	lab:SetAttribute("DomeLandscapeRevision", 1)
	return "Continuous distant terrain and source tree line, matte glazing, closed crown and supported hoist"
end
return B
