-- Sole compact interior recipe. Original Edit place only; no runtime or player-data operations.
local B = {}
local V, CF = Vector3.new, CFrame.new
local DOME_HALF_WIDTH, DOME_CORNER_EXTENT = 214, 356
local function boundaryPoint(a, y, t)
	local s, c = math.sin(a), math.cos(a)
	local radius = math.min(
		DOME_HALF_WIDTH / math.max(math.abs(s), math.abs(c)),
		DOME_CORNER_EXTENT / (math.abs(s) + math.abs(c))
	)
	return V(s * (radius * t + 88 * (1 - t)), y, c * (radius * t + 88 * (1 - t)))
end
local C = {
	stone = Color3.fromRGB(153, 151, 134),
	edge = Color3.fromRGB(173, 170, 149),
	dark = Color3.fromRGB(43, 57, 59),
	sage = Color3.fromRGB(78, 105, 94),
	wood = Color3.fromRGB(117, 90, 63),
	metal = Color3.fromRGB(59, 76, 75),
	soil = Color3.fromRGB(67, 60, 42),
	warm = Color3.fromRGB(246, 222, 181),
}
local function lab()
	assert(
		game.PlaceId == 94763223427049 and not game:GetService("RunService"):IsRunning(),
		"Original Edit place only"
	)
	return workspace.VesperLab
end
local function remove(parent, name)
	for _, p in parent:GetChildren() do
		if p.Name == name then
			p:Destroy()
		end
	end
end
local function model(parent, name)
	remove(parent, name)
	local m = Instance.new("Model")
	m.Name = name
	m.Parent = parent
	return m
end
local function part(parent, name, size, cf, color, solid, material)
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
local function beam(parent, name, a, b, w, color)
	return part(
		parent,
		name,
		V(w, w, (b - a).Magnitude),
		CFrame.lookAt((a + b) / 2, b),
		color,
		false,
		Enum.Material.Metal
	)
end
local function lamp(parent, cf, w)
	part(parent, "TaskLightHousing", V(w + 0.4, 0.42, 0.8), cf, C.metal, false, Enum.Material.Metal)
	local p = part(
		parent,
		"DiffusedLens",
		V(w, 0.12, 0.55),
		cf * CF(0, -0.23, 0),
		C.warm,
		false,
		Enum.Material.SmoothPlastic
	)
	local l = Instance.new("SurfaceLight")
	l.Face = Enum.NormalId.Bottom
	l.Angle = 115
	l.Range = 28
	l.Brightness = 1.3
	l.Color = C.warm
	l.Shadows = false
	l.Parent = p
end
local function label(parent, name, cf, w, text)
	local p = part(parent, name, V(w, 2.6, 0.22), cf, C.dark, false, Enum.Material.Metal)
	local g = Instance.new("SurfaceGui")
	g.Face = Enum.NormalId.Front
	g.CanvasSize = Vector2.new(w * 70, 190)
	g.LightInfluence = 0.15
	g.MaxDistance = 130
	g.Parent = p
	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(0.94, 0.8)
	t.Position = UDim2.fromScale(0.03, 0.1)
	t.BackgroundTransparency = 1
	t.Text = text
	t.TextColor3 = C.warm
	t.TextScaled = true
	t.Font = Enum.Font.GothamMedium
	t.Parent = g
end
local function retainedMesh(parent, name, cf, scale, color)
	local t = game.ServerStorage.LivingLabArtAssets:FindFirstChild(name)
		or game.ServerStorage.LivingLabAssets:FindFirstChild(name)
	assert(t and t:IsA("MeshPart"), "Missing selected asset " .. name)
	local p = t:Clone()
	p.Size = t.Size * scale
	p.CFrame = cf * CF(t:GetAttribute("SourceCenter") * scale)
	if color then
		p.Color = color
		local a = p:FindFirstChildOfClass("SurfaceAppearance")
		if a then
			a.Color = color
		end
	end
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Parent = parent
	return p
end
local function imported(parent, name, cf, scale)
	local t =
		assert(game.ServerStorage:FindFirstChild("CompactInteriorAssets"), "Imported library missing"):FindFirstChild(
			name
		)
	assert(t, "Missing " .. name)
	local m = t:Clone()
	m.Name = name
	for _, p in m:GetDescendants() do
		if p:IsA("BasePart") then
			p.Anchored = true
			p.CanCollide = false
			p.CanTouch = false
			p.CanQuery = false
		end
	end
	m:ScaleTo(m:GetScale() * (scale or 1))
	m:PivotTo(cf)
	m.Parent = parent
	return m
end
local function corner(x, z)
	return CFrame.lookAt(V(x, 0, z), Vector3.zero)
end
local function bed(parent, name, cf, w, d, variant)
	local g = model(parent, name)
	part(g, "SolidStoneBase", V(w, 2.1, d), cf * CF(0, 1.95, 0), C.stone, true)
	part(g, "InsetSoil", V(w - 1.3, 0.18, d - 1.3), cf * CF(0, 3.02, 0), C.soil, false, Enum.Material.Ground)
	local specs = variant == 1
			and {
				{ "ForestFern", -w * 0.29, 0, 0.58 },
				{ "Broadleaf", w * 0.2, d * 0.14, 1.25 },
				{ "Broadleaf", -w * 0.05, d * 0.22, 0.75 },
				{ "ForestFern", -w * 0.12, -d * 0.22, 0.34 },
				{
					"ForestFern",
					w * 0.35,
					-d * 0.2,
					0.4,
				},
			}
		or {
			{ "Broadleaf", -w * 0.27, d * 0.1, 1.15 },
			{ "ForestFern", w * 0.23, -d * 0.07, 0.48 },
			{
				"Broadleaf",
				w * 0.38,
				d * 0.24,
				0.6,
			},
		}
	for i, s in specs do
		retainedMesh(
			g,
			s[1],
			cf * CF(s[2], 3.12, s[3]) * CFrame.Angles(0, i * 1.7 + variant, 0),
			s[4],
			Color3.fromRGB(193, 212, 167)
		)
	end
	for i = 1, 5 do
		retainedMesh(
			g,
			"Clover",
			cf * CF(-w * 0.35 + i * w * 0.11, 3.12, -d * 0.26) * CFrame.Angles(0, i, 0),
			0.65
		)
	end
	return g
end
function B.Frontage()
	local r = lab()
	for _, n in { "LaboratoryBays", "PerimeterPlanting" } do
		remove(r, n)
	end
	local shared = model(r, "CompactWingArchitecture")
	for side = 0, 3 do
		local rotation = CFrame.Angles(0, math.rad(side * 90), 0)
		for slot = 0, 2 do
			local n = side * 3 + slot + 1
			local room = assert(r.Rooms:FindFirstChild(string.format("Room%02d", n)))
			local old = room:GetPivot()
			local target = rotation * CF((slot - 1) * 88, 0, 169.1)
			if not room:GetAttribute("CompactOriginalPivot") then
				room:SetAttribute("CompactOriginalPivot", old)
			end
			local delta = target * old:Inverse()
			-- Transform world-space rest poses with each room; keep local joints, sizes and identities.
			for _, p in room:GetDescendants() do
				for k, v in p:GetAttributes() do
					if typeof(v) == "CFrame" then
						p:SetAttribute(k, delta * v)
					end
				end
			end
			room:PivotTo(target)
			for _, name in
				{
					"InteriorPortal",
					"LivingLabFrontage",
					"FrontPanel",
					"PortalJamb",
					"PortalHeader",
					"JambStripe",
					"DoorwayRecess",
					"HeaderLight",
					"RoomType",
					"RoomTypeMount",
					"OwnerSignMount",
					"NumberSignMount",
				}
			do
				remove(room, name)
			end
			local zones = room:FindFirstChild("FrontageAndZones")
			if zones then
				remove(zones, "Apron")
				remove(zones, "EntryNumber")
			end
			local g = model(room, "CompactFrontage")
			local facade = slot == 1 and C.sage or C.stone
			for _, s in { -1, 1 } do
				part(
					g,
					"EntranceWing",
					V(26.4, 25.4, 1.6),
					target * CF(s * 29.4, 13.6, -35.3),
					facade,
					true,
					slot == 1 and Enum.Material.WoodPlanks or Enum.Material.Limestone
				)
				part(
					g,
					"DarkDoorReveal",
					V(0.55, 18.5, 2.2),
					target * CF(s * 16.1, 10.35, -35.9),
					C.dark,
					true,
					Enum.Material.Metal
				)
				for k = 0, 2 do
					part(
						g,
						"PanelJoint",
						V(22, 0.09, 0.12),
						target * CF(s * 29.4, 6.2 + k * 5.5, -36.16),
						C.metal,
						false,
						Enum.Material.Metal
					)
				end
			end
			part(g, "DoorHead", V(32, 7.7, 1.6), target * CF(0, 22.45, -35.3), facade, true)
			part(g, "ThresholdApron", V(36, 0.16, 4), target * CF(0, 1.2, -36), C.stone, false)
			room.OwnerSign.CFrame = target * CF(0, 19.1, -36.3)
			room.NumberSign.CFrame = target * CF(-24.3, 12, -36.3)
			lamp(g, target * CF(0, 18.6, -36.1), 29)
			room:SetAttribute("CompactLayoutRevision", 1)
			task.wait()
		end
		local cf = rotation * CF(0, 0, 134)
		part(
			shared,
			"ContinuousWingCornice",
			V(265, 1.1, 3),
			cf * CF(0, 27.15, 0),
			C.metal,
			true,
			Enum.Material.Metal
		)
		part(shared, "StoneWingCap", V(265, 0.6, 4), cf * CF(0, 27.9, 0), C.stone, true)
	end
	r:SetAttribute("CompactRoomLayoutRevision", 1)
	return "Twelve rooms and world-space rest poses coherently relocated"
end
function B.Floor()
	local r = lab()
	remove(r, "StoneCirculation")
	for _, n in { "ArenaFloor", "Foundation", "CompactFoundation" } do
		remove(r.Architecture, n)
	end
	local base = model(r.Architecture, "CompactFoundation")
	local boundary = {}
	for i = 0, 23 do
		boundary[i + 1] = boundaryPoint(math.rad(i * 15 - 7.5), 0, 1)
	end
	local function halfAt(z)
		local x = 0
		for i, a in boundary do
			local b = boundary[i % #boundary + 1]
			if
				math.abs(b.Z - a.Z) > 0.001
				and z >= math.min(a.Z, b.Z) - 0.001
				and z <= math.max(a.Z, b.Z) + 0.001
			then
				x = math.max(x, a.X + (b.X - a.X) * (z - a.Z) / (b.Z - a.Z))
			end
		end
		return x
	end
	for _, s in { -1, 1 } do
		for i = 0, DOME_HALF_WIDTH / 2 - 1 do
			local z = 1 + i * 2
			local half = halfAt(z + 1)
			part(
				base,
				"FittedPerimeterSlab",
				V(half * 2, 1.35, 2.02),
				CF(0, 0, s * z),
				C.dark,
				true,
				Enum.Material.Concrete
			)
			if i % 40 == 0 then
				task.wait()
			end
		end
	end
	local f = model(r, "CompactStoneFloor")
	local colors = {
		Color3.fromRGB(151, 151, 137),
		Color3.fromRGB(147, 149, 137),
		Color3.fromRGB(155, 153, 138),
		Color3.fromRGB(149, 151, 141),
	}
	for row = 0, 21 do
		for col = 0, 16 do
			local z = -128 + row * 12
			local x = -126 + col * 16
			if x * x + z * z > 70 * 70 then
				part(
					f,
					"CoursedStone",
					V(15.88, 0.18, 11.88),
					CF(x, 0.78, z),
					colors[(row * 3 + col * 7) % 4 + 1],
					false
				)
			end
		end
		if row % 4 == 0 then
			task.wait()
		end
	end
	return "Fitted foundation and quiet stone court replace oversized overlays"
end
function B.Commons()
	local r = lab()
	for _, n in { "InteriorCommons", "ResearchGardenIslands", "FocalResearchDisplays", "ExcavationPlanting" } do
		remove(r, n)
	end
	local g = model(r, "CompactCommons")
	bed(g, "SouthwestFernCourt", corner(-116, 116), 29, 12, 1)
	retainedMesh(g, "CanopyYoung", corner(-116, 116) * CF(5, 3.12, 1.5), 0.5, Color3.fromRGB(164, 182, 142)).Name =
		"SelectedSmallCanopy"
	local cf = corner(-116, 116)
	part(g, "StoneSeat", V(28, 0.75, 3.5), cf * CF(0, 3.2, -11), C.edge, true)
	for _, x in { -10, 10 } do
		part(g, "SeatLeg", V(2, 2.3, 3), cf * CF(x, 1.8, -11), C.metal, true, Enum.Material.Metal)
	end
	bed(g, "LabFernBed", CF(-44, 0, -121), 18, 10, 2)
	bed(g, "WorkshopBotanicalBed", CF(121, 0, 44) * CFrame.Angles(0, math.pi / 2, 0), 16, 10, 1)
	return "Three botanical compositions replace block shrubs and repeated islands"
end
local function displayTool(parent, tool, cf, height, name)
	local m = Instance.new("Model")
	m.Name = name
	for _, p in tool:GetChildren() do
		p:Clone().Parent = m
	end
	for _, p in m:GetDescendants() do
		if p:IsA("BasePart") then
			p.Anchored = true
			p.CanCollide = false
			p.CanTouch = false
			p.CanQuery = false
		end
	end
	local box, size = m:GetBoundingBox()
	m:ScaleTo(m:GetScale() * height / size.Y)
	box, size = m:GetBoundingBox()
	m:PivotTo(cf * CF(0, size.Y / 2, 0) * box:Inverse() * m:GetPivot())
	m.Parent = parent
end
local function serviceCase(parent, name, cf, w)
	local g = model(parent, name)
	part(g, "ServicePlinth", V(w + 2, 0.8, 14), cf * CF(0, 1.25, 0), C.dark, true, Enum.Material.Slate)
	part(g, "CabinetBody", V(w, 2.9, 12), cf * CF(0, 3.1, 0), C.sage, true, Enum.Material.WoodPlanks)
	part(g, "StoneWorktop", V(w + 1, 0.6, 13), cf * CF(0, 4.85, 0), C.edge, true)
	for x = -w / 2 + 5, w / 2 - 3, 10 do
		part(g, "InsetCabinetDoor", V(9, 2.3, 0.2), cf * CF(x, 3, -6.15), C.wood, false, Enum.Material.Wood)
		part(
			g,
			"BrassPull",
			V(2, 0.16, 0.3),
			cf * CF(x, 3.8, -6.4),
			Color3.fromRGB(166, 139, 85),
			false,
			Enum.Material.Metal
		)
	end
	part(
		g,
		"DisplayBacking",
		V(w + 1, 13, 0.7),
		cf * CF(0, 11.7, 5.7),
		Color3.fromRGB(102, 117, 107),
		true,
		Enum.Material.WoodPlanks
	)
	for _, x in { -w / 2, w / 2 } do
		part(
			g,
			"LightingStandard",
			V(0.65, 15, 0.65),
			cf * CF(x, 10, 5.7),
			C.metal,
			false,
			Enum.Material.Metal
		)
		beam(
			g,
			"TaskArm",
			cf:PointToWorldSpace(V(x, 17.5, 5.7)),
			cf:PointToWorldSpace(V(x, 17.5, -4.5)),
			0.45,
			C.metal
		)
	end
	lamp(g, cf * CF(0, 17.5, -4.5), w - 1)
	return g
end
function B.Workshop()
	local r = lab()
	local shop = r.SharedWorkshop
	local cf = corner(113.5, 113.5)
	local keep = { Console = true, UpgradeConsole = true, ApproachZone = true }
	for _, p in shop:GetChildren() do
		if not keep[p.Name] then
			p:Destroy()
		end
	end
	shop.WorldPivot = cf
	local g = serviceCase(shop, "CompactWorkshop", cf, 37)
	shop.Console.CFrame = cf * CF(10.5, 3.2, -6.55)
	shop.UpgradeConsole.CFrame = cf * CF(-10.5, 3.2, -6.55)
	shop.ApproachZone.CFrame = cf * CF(0, 4.8, -13.8)
	shop.ApproachZone.Size = V(39, 8, 14)
	displayTool(
		g,
		game.ServerStorage.VesperKit.StarterPickaxe,
		cf * CF(12, 6.1, 2) * CFrame.Angles(0, math.pi, 0.18),
		9,
		"PickaxeDisplay"
	)
	displayTool(
		g,
		game.ServerStorage.VesperKit.StarterDrill,
		cf * CF(0, 6.1, 1) * CFrame.Angles(0, 0.8, 0),
		7.2,
		"DrillDisplay"
	)
	displayTool(
		g,
		game.ServerStorage.VesperKit.StarterExplosive,
		cf * CF(-12, 6.1, 1) * CFrame.Angles(0, 0.35, 0),
		4.4,
		"ChargeDisplay"
	)
	for _, x in { -12, 0, 12 } do
		part(g, "ToolCradle", V(10, 0.7, 6), cf * CF(x, 5.55, 1), C.metal, true, Enum.Material.Metal)
	end
	label(g, "WorkshopIdentity", cf * CF(0, 19.4, 5.1), 32, "WORKSHOP")
	return "Original shop interactions at a shallow projecting service counter"
end
function B.Laboratory()
	local r = lab()
	local root = model(r, "SharedLaboratory")
	local cf = corner(-113.5, -113.5)
	local g = serviceCase(root, "ResearchCounter", cf, 37)
	imported(g, "Microscope", cf * CF(11, 5.2, 0) * CFrame.Angles(0, 0.5, 0), 1)
	imported(g, "Microscope", cf * CF(-12, 5.2, 2) * CFrame.Angles(0, -0.25, 0), 0.8)
	local tray =
		part(g, "CoreSampleTray", V(10, 0.35, 6), cf * CF(0, 5.33, 0), C.metal, true, Enum.Material.Metal)
	for i = 1, 3 do
		retainedMesh(
			g,
			"RockRound",
			tray.CFrame * CF((i - 2) * 2.8, 0.2, 0),
			0.2,
			Color3.fromRGB(158, 153, 132)
		)
	end
	label(g, "LaboratoryIdentity", cf * CF(0, 19.4, 5.1), 32, "RESEARCH LAB")
	return "Finished optical apparatus at an open laboratory frontage"
end
function B.Specimen()
	local r = lab()
	local g = model(r, "CompactSpecimenStudy")
	local cf = corner(114.8, -114.8)
	part(g, "SolidSpecimenPlinth", V(42, 2.6, 12), cf * CF(0, 2.2, 0), C.stone, true)
	part(
		g,
		"RecessedSpecimenSurface",
		V(41, 0.3, 11.5),
		cf * CF(0, 3.65, 0),
		C.dark,
		true,
		Enum.Material.Slate
	)
	local specimen = imported(g, "FossilStudy", cf * CF(0, 3.8, 0) * CFrame.Angles(0, math.pi / 2, 0), 1)
	for _, p in specimen:GetDescendants() do
		if p:IsA("MeshPart") then
			p.CanCollide, p.CanQuery = true, true
			p.CollisionFidelity = Enum.CollisionFidelity.Hull
		end
	end
	-- Contact heights are measured against the adapted bone triangles, not guessed supports.
	for _, support in { { -13, -1, 17.607929 }, { 9, 1, 14.696894 } } do
		local x, z, contact = table.unpack(support)
		local top = contact - 0.3
		part(
			g,
			"FossilBearingPost",
			V(0.38, top - 3.8, 0.38),
			cf * CF(x, (top + 3.8) / 2, z),
			C.metal,
			true,
			Enum.Material.Metal
		)
		part(
			g,
			"PaddedBearing",
			V(1.2, 0.3, 1.2),
			cf * CF(x, contact - 0.15, z),
			C.metal,
			true,
			Enum.Material.Metal
		)
	end
	for _, x in { -20, 20 } do
		part(
			g,
			"SpecimenLightStandard",
			V(0.6, 23, 0.6),
			cf * CF(x, 14.2, 5.3),
			C.metal,
			false,
			Enum.Material.Metal
		)
		beam(
			g,
			"SpecimenLightArm",
			cf:PointToWorldSpace(V(x, 25.7, 5.3)),
			cf:PointToWorldSpace(V(x, 25.7, 0)),
			0.45,
			C.metal
		)
	end
	lamp(g, cf * CF(0, 25.7, 0), 40)
	label(g, "ModelAttribution", cf * CF(0, 2.3, -6.15), 27, "Triceratops · Smithsonian / CC0")
	return "Finished museum scan replaces the complete rejected skeleton assembly"
end
function B.Access()
	local r = lab()
	remove(r, "AccessArtIntegration")
	local g = model(r, "CompactBotanicalSupports")
	for _, x in { 47.2, 57.3 } do
		part(
			g,
			"LandingBearingPost",
			V(0.8, 14.7, 0.8),
			CF(x, 14.15, 0.8),
			C.metal,
			true,
			Enum.Material.Metal
		)
		part(g, "BearingShoe", V(2, 1.5, 2), CF(x, 7.5, 0.8), C.stone, true)
		beam(g, "LandingBrace", V(x, 7.5, 0.8), V(x, 21.5, -6.5), 0.65, C.metal)
	end
	local function vine(base, height, phase)
		local prev = base.Position
		for i = 1, math.floor(height / 0.7) do
			local point = base:PointToWorldSpace(
				V(0.22 * math.sin(i * 0.45 + phase), i * 0.7, 0.15 * math.cos(i * 0.4))
			)
			beam(g, "GrowingStem", prev, point, 0.095, C.soil)
			if i % 2 == 0 then
				local side = i % 4 == 0 and 1 or -1
				local tip = point + base:VectorToWorldSpace(V(side * 0.65, 0.32, -0.15))
				beam(g, "ConnectedPetiole", point, tip, 0.055, Color3.fromRGB(82, 109, 52))
				retainedMesh(
					g,
					"Clover",
					CFrame.lookAt(tip, tip + base.LookVector) * CFrame.Angles(0, 0, side * 0.45),
					1.2,
					Color3.fromRGB(147, 171, 125)
				).Name =
					"AttachedLeafCluster"
			end
			prev = point
		end
	end
	vine(CF(57.8, 7.8, 1.3), 12.4, 0)
	local angle = math.rad(37.5)
	local radius = DOME_CORNER_EXTENT / (math.sin(angle) + math.cos(angle))
	local x, z = math.sin(angle) * radius, math.cos(angle) * radius
	vine(CF(-x + 0.7, 1.1, z - 0.7), 21.2, 2)
	vine(CF(x - 0.7, 1.1, -z + 0.7), 17.8, 4)
	vine(CF(-68, 247.75, 18.4) * CFrame.Angles(0, 0, -math.pi / 2), 9, 1)
	return "Connected selective vines on stationary supports"
end
function B.Lighting()
	lab()
	local l = game.Lighting
	l.ClockTime = 16
	l.Brightness = 1.65
	l.ExposureCompensation = -0.12
	l.Ambient = Color3.fromRGB(104, 111, 114)
	l.OutdoorAmbient = Color3.fromRGB(151, 163, 170)
	l.EnvironmentDiffuseScale = 0.72
	l.EnvironmentSpecularScale = 0.2
	return "Softer afternoon illumination; atmosphere, sky, clouds and wind untouched"
end
function B.Enclosure()
	local r = lab()
	local dome = r.Dome
	local library =
		assert(game.ServerStorage:FindFirstChild("CompactInteriorAssets"), "Imported library missing")
	local panes = assert(library:FindFirstChild("EnclosurePanes"), "Fitted glass panes not imported")
	-- The retained crown is opaque; it must never supply lower glazing transparency.
	local glassColor = Color3.fromRGB(151, 173, 173)
	local glassAlpha = 0.72
	for _, sector in dome:GetChildren() do
		if sector:IsA("Model") and sector.Name:match("^DomeSector") then
			for _, p in sector:GetChildren() do
				local keep = p.Name == "DomePane5"
					or (p.Name == "ConnectedMeridian" and p:IsA("BasePart") and p.Position.Y > 250)
					or (
						p.Name == "LatitudeJoint"
						and p:IsA("BasePart")
						and math.abs(p.Position.Y - 247) < 0.1
					)
				if not keep then
					p:Destroy()
				end
			end
		end
	end
	local g = model(dome, "CompactLowerEnvelope")
	local glass = panes:Clone()
	glass.Name = "FittedGlazing"
	for _, p in glass:GetDescendants() do
		if p:IsA("BasePart") then
			p.Color = glassColor
			p.Transparency = glassAlpha
			p.Material = Enum.Material.SmoothPlastic
			p.Anchored = true
			p.CanCollide = true
			p.CanQuery = true
			p.CanTouch = false
			p.CastShadow = false
			p.Reflectance = 0.03
			local a = p:FindFirstChildOfClass("SurfaceAppearance")
			if a then
				a:Destroy()
			end
		end
	end
	glass.Parent = g
	local ringPoint = boundaryPoint
	local levels = { { 52, 1 }, { 109, 0.88 }, { 170, 0.64 }, { 218, 0.34 }, { 247, 0 } }
	for i = 0, 23 do
		local a0 = math.rad(i * 15 - 7.5)
		local a1 = math.rad(i * 15 + 7.5)
		local low0 = ringPoint(a0, 0, 1)
		local low1 = ringPoint(a1, 0, 1)
		local mid = (low0 + low1) / 2
		local length = (low1 - low0).Magnitude
		local cf = CFrame.fromMatrix(mid, (low1 - low0).Unit, Vector3.yAxis)
		part(g, "SealedBoundarySill", V(length + 0.12, 7.5, 1.1), cf * CF(0, 4.4, 0), C.stone, true)
		local wall = part(
			g,
			"ClerestoryGlazing",
			V(length + 0.12, 44, 0.2),
			cf * CF(0, 30, 0),
			glassColor,
			true,
			Enum.Material.SmoothPlastic
		)
		wall.Transparency = glassAlpha
		wall.CastShadow = false
		part(
			g,
			"FixedBoundaryColumn",
			V(1.6, 52, 1.6),
			CF(low1 + V(0, 26, 0)),
			C.metal,
			true,
			Enum.Material.Metal
		)
		for j, l in levels do
			if j < #levels then
				local nextLevel = levels[j + 1]
				beam(
					g,
					"ConnectedMeridian",
					ringPoint(a1, l[1], l[2]),
					ringPoint(a1, nextLevel[1], nextLevel[2]),
					1.35,
					C.metal
				)
			end
			if j < 5 then
				beam(g, "LatitudeJoint", ringPoint(a0, l[1], l[2]), ringPoint(a1, l[1], l[2]), 1.35, C.metal)
			end
		end
		if i % 4 == 0 then
			task.wait()
		end
	end
	-- Fitted architectural backing closes each corner between the three-room wings.
	-- These are new solid case volumes; no retired scenery is concealed behind them.
	local cases = model(r, "CompactCornerClosures")
	for _, x in { -1, 1 } do
		for _, z in { -1, 1 } do
			local cf = corner(x * 134, z * 134)
			part(
				cases,
				"WingCornerClosure",
				V(14, 27, 1.2),
				cf * CF(0, 14, 0),
				C.sage,
				true,
				Enum.Material.WoodPlanks
			)
			part(cases, "CornerClosureCap", V(15, 0.65, 4), cf * CF(0, 27.8, 0), C.stone, true)
		end
	end
	r:SetAttribute("CompactDomeHalfWidth", DOME_HALF_WIDTH)
	return "Lower enclosure fitted to compact wings; original crown and hoist retained"
end
function B.Tools()
	lab()
	local template = assert(
		game.ServerStorage.CompactInteriorAssets:FindFirstChild("ChargeBundle"),
		"Finished charge missing"
	)
	for _, tool in
		{
			game.ServerStorage.VesperKit.StarterExplosive,
			game.ReplicatedStorage.VesperShared.EquipmentAssets.Explosive,
		}
	do
		local handle = tool.Handle
		for _, p in tool:GetChildren() do
			if p ~= handle then
				p:Destroy()
			end
		end
		-- Invisible functional grip remains; all rejected visible cells are deleted.
		handle.Transparency = 1
		for _, p in template:GetDescendants() do
			if p:IsA("BasePart") then
				local q = p:Clone()
				q.Name = "FinishedCharge"
				q.CFrame = handle.CFrame * CF(0, 0.4, 0) * p.CFrame
				q.Anchored = false
				q.Massless = true
				q.CanCollide = false
				q.CanQuery = false
				q.CanTouch = false
				q.Parent = tool
				local w = Instance.new("WeldConstraint")
				w.Part0 = handle
				w.Part1 = q
				w.Parent = q
			end
		end
		tool:SetAttribute("ChargeVisualRevision", 2)
	end
	return "Finished charge shared by equipped and displayed templates; grip and statistics preserved"
end
function B.RemoveRetiredScenery()
	lab()
	-- Exact obsolete decorative archives already preserved in the private native backup.
	for _, name in { "BeforeToolworksPolish_20261109", "BeforeWayfinding_20261109", "RetiredPrivateShops" } do
		remove(game.ServerStorage, name)
	end
	local archive = game.ServerStorage:FindFirstChild("RoomRebuildArchive")
	if archive then
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
			remove(archive, name)
		end
	end
	return "Superseded decorative recovery assemblies removed from the place; native backup retained privately"
end
function B.Build()
	local r = lab()
	local assets = assert(
		game.ServerStorage:FindFirstChild("CompactInteriorAssets"),
		"Imported compact asset library required"
	)
	for _, name in { "EnclosurePanes", "ChargeBundle", "Microscope", "FossilStudy" } do
		assert(assets:FindFirstChild(name), "Missing prepared asset " .. name)
		assert(assets[name]:GetAttribute("NormalizedFromExport"), "Unverified asset import " .. name)
	end
	B.Frontage()
	B.Floor()
	B.Commons()
	B.Enclosure()
	B.Tools()
	B.Workshop()
	B.Laboratory()
	B.Specimen()
	B.Access()
	B.Lighting()
	B.RemoveRetiredScenery()
	r:SetAttribute("InteriorRebuildRevision", 2)
	game:GetService("ChangeHistoryService"):SetWaypoint("Compact interior replacement")
	return "Compact interior revision 2"
end
return B
