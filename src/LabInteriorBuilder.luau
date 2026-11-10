-- Original-place Edit authoring only. Never constructs gameplay, room ownership or exterior systems.
local B = {}
local C = {
	stone = Color3.fromRGB(207, 199, 176),
	light = Color3.fromRGB(225, 218, 196),
	path = Color3.fromRGB(146, 163, 153),
	dark = Color3.fromRGB(48, 66, 68),
	metal = Color3.fromRGB(68, 99, 93),
	soil = Color3.fromRGB(71, 79, 54),
	warm = Color3.fromRGB(255, 225, 173),
}
local function lab()
	assert(
		game.PlaceId == 94763223427049 and not game:GetService("RunService"):IsRunning(),
		"Original Edit place only"
	)
	return workspace.VesperLab
end
local function clear(parent, name)
	local old = parent:FindFirstChild(name)
	if old then
		old:Destroy()
	end
end
local function model(parent, name)
	clear(parent, name)
	local m = Instance.new("Model")
	m.Name = name
	m.Parent = parent
	return m
end
local function part(parent, name, size, cf, color, material, solid)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color or C.stone
	p.Material = material or Enum.Material.Limestone
	p.Anchored = true
	p.CanCollide = solid == true
	p.CanQuery = solid == true
	p.CanTouch = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end
local function beam(parent, name, a, b, width, color)
	return part(
		parent,
		name,
		Vector3.new(width, width, (a - b).Magnitude),
		CFrame.lookAt((a + b) / 2, b),
		color,
		Enum.Material.Metal
	)
end
local function radial(degrees, radius, y)
	local a = math.rad(degrees)
	return Vector3.new(math.sin(a) * radius, y or 0, math.cos(a) * radius)
end
local function basis(degrees, radius, y)
	return CFrame.new(radial(degrees, radius, y)) * CFrame.Angles(0, math.rad(degrees), 0)
end
local function mesh(parent, name, cf, scale, color, centered)
	local t = game.ServerStorage.LivingLabArtAssets:FindFirstChild(name)
		or game.ServerStorage.LivingLabAssets:FindFirstChild(name)
	assert(t and t:IsA("MeshPart"), "Missing retained asset " .. name)
	local p = t:Clone()
	local sc = typeof(scale) == "Vector3" and scale or Vector3.one * (scale or 1)
	p.Size = t.Size * sc
	p.CFrame = centered and (cf * CFrame.new(0, p.Size.Y / 2, 0))
		or (cf * CFrame.new(t:GetAttribute("SourceCenter") * sc))
	p.Color = color or Color3.new(1, 1, 1)
	local sa = p:FindFirstChildOfClass("SurfaceAppearance")
	if sa then
		sa.Color = p.Color
	end
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Parent = parent
	return p
end
local function light(parent, cf, width)
	part(parent, "AttachedLightHousing", Vector3.new(width + 0.6, 0.5, 1.1), cf, C.metal, Enum.Material.Metal)
	local p = part(
		parent,
		"WarmLens",
		Vector3.new(width, 0.12, 0.7),
		cf * CFrame.new(0, -0.3, 0),
		C.warm,
		Enum.Material.SmoothPlastic
	)
	local l = Instance.new("SurfaceLight")
	l.Face = Enum.NormalId.Bottom
	l.Range = 24
	l.Angle = 110
	l.Brightness = 1.1
	l.Color = C.warm
	l.Shadows = false
	l.Parent = p
end
local function label(parent, cf, width, text)
	local p = part(parent, "Navigation", Vector3.new(width, 2.7, 0.25), cf, C.dark, Enum.Material.Metal)
	local g = Instance.new("SurfaceGui")
	g.Face = Enum.NormalId.Front
	g.CanvasSize = Vector2.new(width * 70, 190)
	g.LightInfluence = 0.2
	g.MaxDistance = 200
	g.Parent = p
	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(0.94, 0.8)
	t.Position = UDim2.fromScale(0.03, 0.1)
	t.BackgroundTransparency = 1
	t.Font = Enum.Font.FredokaOne
	t.Text = text
	t.TextScaled = true
	t.TextColor3 = C.warm
	t.Parent = g
end
local function foliage(parent, cf, s, variant)
	mesh(parent, "GroundShrub", cf * CFrame.new(-2 * s, 0, 0) * CFrame.Angles(0, variant, 0), s)
	mesh(
		parent,
		"ForestFern",
		cf * CFrame.new(2 * s, 0, 1.4 * s) * CFrame.Angles(0, variant * 0.7, 0),
		s * 0.48
	)
	mesh(parent, "Broadleaf", cf * CFrame.new(0, 0, -1.5 * s) * CFrame.Angles(0, variant + 1, 0), s * 0.8)
end
local function vine(parent, points, size)
	for i = 2, #points do
		beam(parent, "AttachedVineStem", points[i - 1], points[i], 0.09, C.soil)
		local direction = (points[i] - points[i - 1]).Unit
		local cf = CFrame.lookAt(points[i], points[i] + direction) * CFrame.Angles(math.pi / 2, 0, i * 0.8)
		mesh(parent, "PlantLeaves", cf, size, Color3.fromRGB(103, 143, 75))
	end
end

function B.Floor()
	local r = lab()
	local f = model(r, "StoneCirculation")
	-- The original continuous collision slab stays intact; all new finishes are flush/noncolliding.
	local function disk(name, radius, y, color)
		local p = part(
			f,
			name,
			Vector3.new(0.075, radius * 2, radius * 2),
			CFrame.new(0, y, 0) * CFrame.Angles(0, 0, math.pi / 2),
			color
		)
		p.Shape = Enum.PartType.Cylinder
	end
	disk("WarmStoneCommons", 269, 0.74, C.stone)
	disk("ExcavationPromenade", 130, 0.785, C.path)
	disk("ClearExcavationApron", 100, 0.83, C.light)
	for _, a in { 45, 135, 225, 315 } do
		part(f, "ViewingApproach", Vector3.new(26, 0.08, 218), basis(a, 224, 0.85), C.light)
		part(f, "WindowTerrace", Vector3.new(53, 0.08, 73), basis(a, 305, 0.86), C.path)
	end
	part(f, "WorkshopApproach", Vector3.new(24, 0.08, 135), basis(75, 202, 0.86), C.light)
	for i = 0, 11 do
		part(
			f,
			"RoomApproach",
			Vector3.new(32, 0.08, 53),
			basis(i * 30, 243, 0.85),
			i % 3 == 1 and C.light or C.path
		)
	end
	for _, radius in { 100, 130, 262 } do
		for i = 0, 47 do
			local p = beam(
				f,
				"FlushStoneCourse",
				radial(i * 7.5, radius, 0.905),
				radial((i + 1) * 7.5, radius, 0.905),
				0.13,
				C.metal
			)
			p.CastShadow = false
		end
	end
	-- Sparse, aligned joints; no square tile field or extra collision seams.
	for _, a in { 0, 90, 180, 270 } do
		beam(
			f,
			"AlignedExpansionJoint",
			radial(a, 132, 0.89),
			radial(a, 260, 0.89),
			0.09,
			Color3.fromRGB(157, 155, 137)
		)
	end
	return "Continuous warm commons, excavation loop and flush destination approaches"
end

function B.Frontage()
	local r = lab()
	clear(r, "PerimeterPlanting")
	local bays = r.LaboratoryBays
	for _, bay in bays:GetChildren() do
		local id = tonumber(bay.Name:match("%d+"))
		if id ~= 1 and id ~= 6 and id ~= 9 then
			bay:Destroy()
		else
			for _, p in bay:GetDescendants() do
				if p:IsA("BasePart") and p.Name == "BayCheek" then
					p.Color = C.stone
				end
			end
			for _, name in { "Discipline", "FossilLabel", "CoreLabel", "CuratedSpecimenLabel" } do
				clear(bay, name)
			end
		end
	end
	local retire = {
		FrontPanel = true,
		PortalJamb = true,
		PortalHeader = true,
		JambStripe = true,
		DoorwayRecess = true,
		HeaderLight = true,
		RoomType = true,
		RoomTypeMount = true,
		LivingLabFrontage = true,
	}
	for _, room in r.Rooms:GetChildren() do
		for _, p in room:GetChildren() do
			if retire[p.Name] then
				p:Destroy()
			end
		end
		local cf = room:GetPivot()
		local n = room:GetAttribute("RoomNumber")
		local offset = ({ 4, 9, 6 })[(n - 1) % 3 + 1]
		local g = model(room, "InteriorPortal")
		local face = -35.1
		for _, sign in { -1, 1 } do
			part(
				g,
				"RecessedWing",
				Vector3.new(22.3, 25.9, 4.4),
				cf * CFrame.new(sign * 32.06, 13.64, face + 0.6),
				C.dark,
				Enum.Material.Slate,
				true
			)
			part(
				g,
				"DressedPier",
				Vector3.new(3.6, 25.9, 4.1),
				cf * CFrame.new(sign * 22.7, 13.64, face - offset / 2),
				C.light,
				nil,
				true
			)
			part(
				g,
				"PierFoot",
				Vector3.new(4.4, 2.8, 5),
				cf * CFrame.new(sign * 22.7, 2.1, face - offset / 2),
				C.metal,
				Enum.Material.Metal,
				true
			)
			part(
				g,
				"OuterStoneReturn",
				Vector3.new(2.3, 25.9, offset + 2),
				cf * CFrame.new(sign * 42.5, 13.64, face - offset / 2),
				C.stone,
				nil,
				true
			)
			beam(
				g,
				"ChamferedPortalShoulder",
				cf:PointToWorldSpace(Vector3.new(sign * 22.7, 19.8, face - offset)),
				cf:PointToWorldSpace(Vector3.new(sign * 16.8, 24.5, face - offset)),
				2.8,
				C.light
			)
			part(
				g,
				"SideStonePanel",
				Vector3.new(15.3, 4.7, offset + 0.7),
				cf * CFrame.new(sign * 32.6, 24.1, face - offset / 2),
				C.stone,
				nil,
				true
			)
		end
		part(
			g,
			"RecessHead",
			Vector3.new(41, 8.6, 6),
			cf * CFrame.new(0, 22.2, face),
			C.dark,
			Enum.Material.Slate,
			true
		)
		part(
			g,
			"PortalLintel",
			Vector3.new(34.2, 2.1, 3.2),
			cf * CFrame.new(0, 24.5, face - offset),
			C.light,
			nil,
			true
		)
		part(
			g,
			"SteppedCanopy",
			Vector3.new(87.4, 0.7, offset + 3),
			cf * CFrame.new(0, 27.1, face - offset / 2),
			C.stone,
			nil,
			true
		)
		part(
			g,
			"PorchFloor",
			Vector3.new(84, 0.08, offset + 4),
			cf * CFrame.new(0, 1.20, face - offset / 2),
			C.path
		)
		light(g, cf * CFrame.new(0, 24.1, face - offset + 1), 28)
		-- Existing OwnerSign and NumberSign remain at their exact authoritative paths/poses.
		if n % 3 == 1 then
			local plantCF = cf * CFrame.new(34, 0.7, face - offset - 4)
			part(
				g,
				"IntegratedEntranceBed",
				Vector3.new(15, 2.5, 7),
				plantCF * CFrame.new(0, 1.25, 0),
				C.light,
				nil,
				true
			)
			part(
				g,
				"EntranceSoil",
				Vector3.new(13.8, 0.1, 5.9),
				plantCF * CFrame.new(0, 2.48, 0),
				C.soil,
				Enum.Material.Ground
			)
			foliage(g, plantCF * CFrame.new(-3, 2.6, 0), 1.0, n)
			foliage(g, plantCF * CFrame.new(3, 2.6, 0), 0.75, n + 1)
		end
		task.wait()
	end
	return "Twelve retained rooms; eight obsolete enclosed bays removed; varied recessed portals"
end

function B.Commons()
	local r = lab()
	for _, name in { "ResearchGardenIslands", "FocalResearchDisplays", "ExcavationPlanting" } do
		clear(r, name)
	end
	local root = model(r, "InteriorCommons")
	local gardens = model(root, "PlantedCommons")
	for i, a in { 15, 195, 300 } do
		local cf = basis(a, i == 3 and 190 or 180, 0.9)
		local g = model(gardens, "Garden" .. i)
		local sc = Vector3.new(1.8, 1.3, 1.4)
		local bed = mesh(g, "CrescentBed", cf, sc, Color3.new(1, 1, 1), true)
		bed.CanCollide = true
		bed.CanQuery = true
		mesh(g, "CrescentSoil", cf, sc, Color3.new(1, 1, 1), true)
		for j = -2, 2 do
			local z = j * 10
			foliage(g, cf * CFrame.new(4 - z * z * 0.005, 2.65, z), 1.25, i + j * 0.8)
		end
		mesh(g, i == 2 and "CanopyTwisted" or "CanopyYoung", cf * CFrame.new(1, 2.6, 8), 0.8)
		mesh(g, "RockRound", cf * CFrame.new(2, 2.6, -18), 0.7, Color3.fromRGB(207, 207, 185))
		part(
			g,
			"AttachedStoneSeat",
			Vector3.new(4, 0.6, 29),
			cf * CFrame.new(-20, 2.5, 0),
			C.light,
			nil,
			true
		)
		for _, z in { -11, 11 } do
			part(
				g,
				"SeatSupport",
				Vector3.new(3, 2.2, 3),
				cf * CFrame.new(-20, 1.1, z),
				C.metal,
				Enum.Material.Metal,
				true
			)
		end
	end
	local inner = model(root, "ExcavationBoundary")
	for _, a in { 42, 138, 222, 318 } do
		local cf = CFrame.new(0, 0.75, 0) * CFrame.Angles(0, math.rad(90 - a), 0)
		mesh(inner, "CrescentBed", cf, 1)
		mesh(inner, "CrescentSoil", cf, 1)
		for _, delta in { -8, 0, 8 } do
			foliage(inner, CFrame.new(radial(a + delta, 86, 2.95)), 0.9, a + delta)
		end
	end
	local exhibits = model(root, "SpecimenStudies")
	for i, a in { 120, 255 } do
		local cf = basis(a, 170, 0.9)
		local g = model(exhibits, "SupportedSpecimen" .. i)
		part(g, "StoneStudyIsland", Vector3.new(54, 2.5, 28), cf * CFrame.new(0, 1.25, 0), C.light, nil, true)
		part(
			g,
			"RecessedSpecimenBed",
			Vector3.new(50, 0.3, 24),
			cf * CFrame.new(0, 2.6, 0),
			C.dark,
			Enum.Material.Slate
		)
		mesh(
			g,
			"FossilRibcage",
			cf * CFrame.new(2, 5.1, 0) * CFrame.Angles(0, math.pi / 2, 0),
			1.6,
			Color3.fromRGB(227, 215, 182)
		)
		mesh(
			g,
			"FossilSkull",
			cf * CFrame.new(-17, 6.7, 0) * CFrame.Angles(0, -math.pi / 2, 0),
			2.3,
			Color3.fromRGB(227, 215, 182)
		)
		for _, x in { -16, -6, 7, 17 } do
			part(
				g,
				"SpecimenSupport",
				Vector3.new(0.45, 4, 0.45),
				cf * CFrame.new(x, 4.5, 0),
				C.metal,
				Enum.Material.Metal
			)
			part(
				g,
				"PaddedCradle",
				Vector3.new(3, 0.35, 4),
				cf * CFrame.new(x, 6.4, 0),
				C.dark,
				Enum.Material.SmoothPlastic
			)
		end
		for _, x in { -23, 23 } do
			part(
				g,
				"TaskLightPier",
				Vector3.new(0.7, 14, 0.7),
				cf * CFrame.new(x, 9.4, 10),
				C.metal,
				Enum.Material.Metal
			)
			beam(
				g,
				"LightReturn",
				cf:PointToWorldSpace(Vector3.new(x, 16.4, 10)),
				cf:PointToWorldSpace(Vector3.new(x, 16.4, 4)),
				0.65,
				C.metal
			)
		end
		light(g, cf * CFrame.new(0, 16.4, 4), 46)
		foliage(g, cf * CFrame.new(22, 2.8, -7), 0.85, i + 12)
	end
	-- Four low viewing terraces. Seating stays to the sides of a 28-stud clear central view/route.
	local terraces = model(root, "ViewingTerraces")
	for i, a in { 45, 135, 225, 315 } do
		local cf = basis(a, 312, 0.9)
		local g = model(terraces, "Terrace" .. i)
		for _, x in { -23, 23 } do
			part(
				g,
				"TerracePlantBed",
				Vector3.new(6, 2.7, 24),
				cf * CFrame.new(x, 1.35, 0),
				C.light,
				nil,
				true
			)
			part(
				g,
				"TerraceSoil",
				Vector3.new(4.9, 0.1, 22.9),
				cf * CFrame.new(x, 2.7, 0),
				C.soil,
				Enum.Material.Ground
			)
			for _, z in { -7, 5 } do
				foliage(g, cf * CFrame.new(x, 2.8, z), 0.7, i + z)
			end
			part(
				g,
				"TerraceSeat",
				Vector3.new(3, 0.6, 17),
				cf * CFrame.new(x * 0.73, 2.5, 0),
				C.stone,
				nil,
				true
			)
			for _, z in { -6, 6 } do
				part(
					g,
					"SeatPedestal",
					Vector3.new(2, 2.2, 2),
					cf * CFrame.new(x * 0.73, 1.1, z),
					C.metal,
					Enum.Material.Metal,
					true
				)
			end
		end
	end
	return "Three planted commons, two supported specimen studies, four open viewing terraces"
end

function B.Workshop()
	local r = lab()
	local shop = r.SharedWorkshop
	local cf = basis(75, 291, 0)
	local retire = {
		ArtFraming = true,
		AcousticCeiling = true,
		BayCheek = true,
		PortalColumn = true,
		ColumnSocket = true,
		JointBand = true,
		IntegratedLintel = true,
		RecessedHeader = true,
		TaskLightHousing = true,
		WarmDiffuser = true,
		ApproachNotice = true,
	}
	for _, p in shop:GetChildren() do
		if retire[p.Name] then
			p:Destroy()
		end
	end
	local g = model(shop, "InteriorWorkshopFraming")
	for _, x in { -27, 27 } do
		part(
			g,
			"WorkshopSideWall",
			Vector3.new(1.5, 28, 43),
			cf * CFrame.new(x, 14.7, 0),
			C.dark,
			Enum.Material.Slate,
			true
		)
		part(
			g,
			"WorkshopStonePier",
			Vector3.new(4.2, 25, 5),
			cf * CFrame.new(x, 13.2, -22),
			C.light,
			nil,
			true
		)
		part(
			g,
			"PierShoe",
			Vector3.new(5, 3, 5.7),
			cf * CFrame.new(x, 2.2, -22),
			C.metal,
			Enum.Material.Metal,
			true
		)
		beam(
			g,
			"WorkshopShoulder",
			cf:PointToWorldSpace(Vector3.new(x, 24, -22)),
			cf:PointToWorldSpace(Vector3.new(x * 0.74, 29, -22)),
			3.2,
			C.light
		)
	end
	part(
		g,
		"WorkshopCeiling",
		Vector3.new(57, 1, 44),
		cf * CFrame.new(0, 29.1, 0),
		C.dark,
		Enum.Material.Slate,
		true
	)
	part(g, "StoneCornice", Vector3.new(59, 1.3, 7), cf * CFrame.new(0, 29.4, -21), C.stone, nil, true)
	label(g, cf * CFrame.new(0, 26.5, -24.6), 28, "WORKSHOP")
	light(g, cf * CFrame.new(0, 27.8, -13), 42)
	light(g, cf * CFrame.new(0, 24, 0), 34)
	-- Actual tool models, Console/UpgradeConsole/ApproachZone and all prompts stay unchanged.
	return "Recessed workshop re-framed around unchanged tool/interaction geometry"
end

function B.Access()
	local r = lab()
	local g = model(r, "AccessArtIntegration")
	for _, x in { 47.2, 57.3 } do
		part(
			g,
			"LandingBearingPost",
			Vector3.new(0.8, 14.7, 0.8),
			CFrame.new(x, 14.15, 0.8),
			C.metal,
			Enum.Material.Metal,
			true
		)
		part(g, "DressedSupportShoe", Vector3.new(2.1, 1.5, 2.1), CFrame.new(x, 7.5, 0.8), C.stone, nil, true)
		beam(g, "AttachedLandingBrace", Vector3.new(x, 7.5, 0.8), Vector3.new(x, 21.5, -6.5), 0.65, C.metal)
		beam(
			g,
			"LandingBearing",
			Vector3.new(x, 21.5, -6.5),
			Vector3.new(x < 52 and 48.5 or 56.1, 21.5, -6.5),
			0.8,
			C.metal
		)
	end
	vine(
		g,
		{
			Vector3.new(57.75, 8, 1.25),
			Vector3.new(57.75, 10.5, 1.25),
			Vector3.new(57.6, 13, 1.25),
			Vector3.new(57.7, 15.5, 1.2),
			Vector3.new(57.7, 18, 1.25),
			Vector3.new(57.65, 20.8, 1.25),
		},
		0.34
	)
	local bedCF = CFrame.new(82, 0.8, -28)
	part(g, "AccessBed", Vector3.new(12, 2.2, 7), bedCF * CFrame.new(0, 1.1, 0), C.light, nil, true)
	part(
		g,
		"AccessBedSoil",
		Vector3.new(10.8, 0.1, 5.8),
		bedCF * CFrame.new(0, 2.2, 0),
		C.soil,
		Enum.Material.Ground
	)
	foliage(g, bedCF * CFrame.new(0, 2.3, 0), 0.95, 31)
	-- Two selected fixed dome-border columns; no alteration of the frame/glazing itself.
	for _, a in { 52.5, 232.5 } do
		local cf = basis(a, 346, 0)
		local points = {}
		for j = 0, 5 do
			table.insert(points, cf:PointToWorldSpace(Vector3.new(0.4 * math.sin(j), 3 + j * 3, -1)))
		end
		vine(g, points, 0.43)
		part(g, "FramePlantingFoot", Vector3.new(4, 2.4, 4), cf * CFrame.new(0, 1.9, -1), C.stone, nil, true)
		foliage(g, cf * CFrame.new(0, 3.1, -1), 0.55, a)
	end
	return "Landing bears on fixed supports; restrained attached vines outside ladder clearance"
end

function B.Build()
	local r = lab()
	local messages = { B.Floor(), B.Frontage(), B.Commons(), B.Workshop(), B.Access() }
	r:SetAttribute("InteriorRebuildRevision", 1)
	return messages
end
return B
