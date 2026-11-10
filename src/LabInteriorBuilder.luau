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
	l.Brightness = 1.05
	l.Color = Color3.fromRGB(244, 228, 202)
	l.Shadows = false
	l.Parent = p
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
local function triangle(parent, name, a, b, c, thickness, color, material)
	local ab, ac, bc = b - a, c - a, c - b
	if ab:Dot(ab) > ac:Dot(ac) and ab:Dot(ab) > bc:Dot(bc) then
		c, a = a, c
	elseif ac:Dot(ac) > bc:Dot(bc) then
		a, b = b, a
	end
	ab, ac, bc = b - a, c - a, c - b
	if ac:Cross(ab).Magnitude < 0.00001 then
		return
	end
	local right = ac:Cross(ab).Unit
	local back = bc.Unit
	local up = bc:Cross(right).Unit
	local height = math.abs(ab:Dot(up))
	for _, v in
		{
			{ (a + b) / 2, right, up, back, math.abs(ab:Dot(back)) },
			{
				(a + c) / 2,
				-right,
				up,
				-back,
				math.abs(ac:Dot(back)),
			},
		}
	do
		if height > 0.001 and v[5] > 0.001 then
			local q = Instance.new("WedgePart")
			q.Name = name
			q.Size = V(thickness, height, v[5])
			q.CFrame = CFrame.fromMatrix(v[1], v[2], v[3], v[4])
			q.Color = color
			q.Material = material
			q.Anchored = true
			q.CanCollide = true
			q.CanQuery = true
			q.CanTouch = false
			q.TopSurface = Enum.SurfaceType.Smooth
			q.BottomSurface = Enum.SurfaceType.Smooth
			q.Parent = parent
		end
	end
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
			local target = room:GetPivot() -- Phase 1 preserves the accepted compact arrangement.
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
			remove(room, "NumberSign")
			local owner = room.OwnerSign
			owner.Size = V(12, 1.35, 0.18)
			owner.CFrame = target * CF(0, 17.4, -36.3)
			owner.Color = C.dark
			owner.Display.CanvasSize = Vector2.new(840, 110)
			owner.Display.MaxDistance = 95
			owner.Display.LightInfluence = 0.3
			lamp(g, target * CF(0, 18.6, -36.1), 29)
			room:SetAttribute("CompactLayoutRevision", 1)
			task.wait()
		end
		local cf = rotation * CF(0, 0, 134)
		part(
			shared,
			"ContinuousWingFascia",
			V(265.4, 1, 1.4),
			cf * CF(0, 26.8, 0),
			C.metal,
			true,
			Enum.Material.Metal
		)
	end
	r:SetAttribute("CompactRoomLayoutRevision", 1)
	return "Room positions preserved; restrained ownership signs and finished frontage"
end
function B.Floor()
	local r = lab()
	remove(r, "StoneCirculation")
	local f = model(r, "CompactStoneFloor")
	-- Fit slabs to a concealed bearing line inside the unchanged 74.25-stud cylinder.
	-- The 2.75-stud construction underlap accommodates native cylinder render facets. Outside polygons are disjoint; there is no extra overlay.
	local radius = 71.5
	local sides = 120
	local boundary = {}
	for i = 0, sides - 1 do
		local a = i * math.pi * 2 / sides
		boundary[i + 1] = Vector2.new(math.cos(a) * radius, math.sin(a) * radius)
	end
	local function clip(poly, a, b, inside)
		local out = {}
		local edge = b - a
		local function dist(v)
			return edge.X * (v.Y - a.Y) - edge.Y * (v.X - a.X)
		end
		for i, u in poly do
			local v = poly[i % #poly + 1]
			local du, dv = dist(u), dist(v)
			local keepU = inside and du >= -1e-6 or not inside and du <= 1e-6
			local keepV = inside and dv >= -1e-6 or not inside and dv <= 1e-6
			if keepU then
				table.insert(out, u)
			end
			if keepU ~= keepV then
				table.insert(out, u + (v - u) * (du / (du - dv)))
			end
		end
		return out
	end
	local colors = {
		Color3.fromRGB(151, 151, 137),
		Color3.fromRGB(147, 149, 137),
		Color3.fromRGB(155, 153, 138),
		Color3.fromRGB(149, 151, 141),
	}
	for row = 0, 22 do
		for col = 0, 16 do
			local x0, z0 = -134 + col * 16, -134 + row * 12
			local x1, z1 = math.min(x0 + 16, 134), math.min(z0 + 12, 134)
			x0 += col > 0 and 0.04 or 0
			z0 += row > 0 and 0.04 or 0
			x1 -= col < 16 and 0.04 or 0
			z1 -= row < 22 and 0.04 or 0
			local poly =
				{ Vector2.new(x0, z0), Vector2.new(x1, z0), Vector2.new(x1, z1), Vector2.new(x0, z1) }
			local color = colors[(row * 3 + col * 7) % 4 + 1]
			local nearX = math.clamp(0, x0, x1)
			local nearZ = math.clamp(0, z0, z1)
			if nearX * nearX + nearZ * nearZ >= radius * radius then
				part(
					f,
					"CoursedStone",
					V(x1 - x0, 0.18, z1 - z0),
					CF((x0 + x1) / 2, 0.78, (z0 + z1) / 2),
					color,
					true
				)
			else
				for i, a in boundary do
					if #poly < 3 then
						break
					end
					local b = boundary[i % #boundary + 1]
					local outside = clip(poly, a, b, false)
					for k = 2, #outside - 1 do
						local u, v, w = outside[1], outside[k], outside[k + 1]
						triangle(
							f,
							"FittedPlatformSlab",
							V(u.X, 0.78, u.Y),
							V(v.X, 0.78, v.Y),
							V(w.X, 0.78, w.Y),
							0.18,
							color,
							Enum.Material.Limestone
						)
					end
					poly = clip(poly, a, b, true)
				end
			end
		end
		task.wait()
	end
	return "One fitted stone surface meets the original platform; existing foundation unchanged"
end

function B.Commons()
	return require(script.Parent.IntegratedGreeneryBuilder).Commons()
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
function B.Workshop()
	local r = lab()
	local shop = r.SharedWorkshop
	local cf = CFrame.lookAt(V(132.2, 0, 44), V(0, 0, 44))
	local keep = { Console = true, UpgradeConsole = true, ApproachZone = true }
	for _, p in shop:GetChildren() do
		if not keep[p.Name] then
			p:Destroy()
		end
	end
	shop.WorldPivot = cf
	if r:FindFirstChild("CompactCommons") then
		remove(r.CompactCommons, "WorkshopBotanicalBed")
	end
	local g = model(shop, "IntegratedWorkshop")
	part(g, "WallToolMount", V(46, 13, 0.35), cf * CF(0, 10.7, 0.38), C.sage, true, Enum.Material.WoodPlanks)
	part(g, "CabinetBody", V(46, 3.05, 4.8), cf * CF(0, 2.6, -2.45), C.wood, true, Enum.Material.Wood)
	part(g, "StoneWorktop", V(47, 0.5, 5.6), cf * CF(0, 4.4, -2.65), C.edge, true)
	part(g, "RecessedToe", V(45, 0.45, 4.1), cf * CF(0, 1.08, -2.2), C.dark, true, Enum.Material.Metal)
	for _, x in { -15, 0, 15 } do
		part(
			g,
			"CabinetDoor",
			V(14, 2.45, 0.2),
			cf * CF(x, 2.65, -4.96),
			C.sage,
			false,
			Enum.Material.WoodPlanks
		)
		part(g, "Handle", V(2.3, 0.16, 0.35), cf * CF(x, 3.4, -5.15), C.metal, false, Enum.Material.Metal)
		part(g, "ToolMount", V(7, 0.35, 3.2), cf * CF(x, 4.82, -1.7), C.metal, true, Enum.Material.Metal)
	end
	displayTool(
		g,
		game.ServerStorage.VesperKit.StarterPickaxe,
		cf * CF(15, 5, -1.7) * CFrame.Angles(0, math.pi, 0.15),
		8,
		"PickaxeDisplay"
	)
	displayTool(
		g,
		game.ServerStorage.VesperKit.StarterDrill,
		cf * CF(0, 5, -1.7) * CFrame.Angles(0, 0.8, 0),
		6.4,
		"DrillDisplay"
	)
	displayTool(
		g,
		game.ServerStorage.VesperKit.StarterExplosive,
		cf * CF(-15, 5, -1.7) * CFrame.Angles(0, 0.35, 0),
		3.6,
		"ChargeDisplay"
	)
	lamp(g, cf * CF(0, 16.8, -1.1), 44)
	shop.Console.CFrame = cf * CF(12, 2.8, -5.25)
	shop.UpgradeConsole.CFrame = cf * CF(-12, 2.8, -5.25)
	shop.ApproachZone.CFrame = cf * CF(0, 4.8, -11)
	shop.ApproachZone.Size = V(48, 8, 10)
	return "Original shop interactions integrated between east-wing entrances"
end
function B.Laboratory()
	local r = lab()
	remove(r, "SharedLaboratory")
	local g = model(r, "WallResearchDetails")
	local placements =
		{ CFrame.lookAt(V(44, 0, -132.4), V(44, 0, 0)), CFrame.lookAt(V(-132.4, 0, -44), V(0, 0, -44)) }
	for i, cf in placements do
		local niche = model(g, "ResearchShelf" .. i)
		part(niche, "WallInset", V(18, 12, 0.3), cf * CF(0, 10.1, 0.1), C.dark, false, Enum.Material.Slate)
		part(niche, "StoneShelf", V(18.5, 0.45, 4.8), cf * CF(0, 4.25, -2.1), C.stone, true)
		for _, x in { -7.5, 7.5 } do
			part(
				niche,
				"SideReturn",
				V(0.6, 12.5, 4.2),
				cf * CF(x, 10.25, -1.8),
				C.metal,
				true,
				Enum.Material.Metal
			)
			beam(
				niche,
				"ShelfBracket",
				cf:PointToWorldSpace(V(x, 2.4, 0.1)),
				cf:PointToWorldSpace(V(x, 4, -3.6)),
				0.4,
				C.metal
			)
		end
		part(
			niche,
			"UpperReturn",
			V(18.5, 0.5, 4.8),
			cf * CF(0, 16.45, -2.1),
			C.metal,
			true,
			Enum.Material.Metal
		)
		lamp(niche, cf * CF(0, 16.1, -1.9), 15)
		imported(
			niche,
			"Microscope",
			cf * CF(i == 1 and -3.8 or 3.8, 4.5, -2.2) * CFrame.Angles(0, i == 1 and 0.4 or -0.4, 0),
			0.88
		)
		local tray = part(
			niche,
			"SampleTray",
			V(5, 0.18, 3),
			cf * CF(i == 1 and 4 or -4, 4.57, -2.2),
			C.metal,
			true,
			Enum.Material.Metal
		)
		for k = 1, 2 do
			retainedMesh(
				niche,
				"RockRound",
				tray.CFrame * CF((k - 1.5) * 2, 0.12, 0),
				0.17,
				Color3.fromRGB(158, 153, 132)
			)
		end
	end
	return "Unlabeled decorative instruments distributed onto two shallow wall-supported shelves"
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
	-- Attribution is retained on the imported meshes and in the source credits, not a prominent decor plaque.
	return "Finished museum scan replaces the complete rejected skeleton assembly"
end
function B.Access()
	local r = lab()
	local access = r.ExcavationAccess
	local ladder = access.AccessRevision4.LadderEntrance
	for _, name in { "AccessSign", "SignPost", "LandingColumn" } do
		remove(ladder, name)
	end
	remove(r, "AccessArtIntegration")
	-- Retired primitive vines are removed; the Phase 3 recipe owns all planting.
	remove(r, "CompactBotanicalSupports")
	remove(r, "RetainedFixedPlanting")
	local g = model(access, "Phase1StructuralConnections")
	local floorY = 3.645
	local beamBottom = 21.105
	for _, x in { 48.467273, 56.067273 } do
		for _, z in { -0.1, -7.8 } do
			part(
				g,
				"LandingFoot",
				V(1.3, 0.3, 1.3),
				CF(x, floorY + 0.15, z),
				C.metal,
				true,
				Enum.Material.Metal
			)
			part(
				g,
				"LandingColumn",
				V(0.65, beamBottom - floorY - 0.3, 0.65),
				CF(x, (beamBottom + floorY + 0.3) / 2, z),
				C.metal,
				true,
				Enum.Material.Metal
			)
		end
		part(
			g,
			"LandingSideBearer",
			V(0.75, 0.5, 8.95),
			CF(x, 21.355, -4),
			C.metal,
			true,
			Enum.Material.Metal
		)
		beam(g, "LandingKnee", V(x, 17.6, -0.1), V(x, 21.05, -4.2), 0.5, C.metal)
		beam(g, "LandingKnee", V(x, 17.6, -7.8), V(x, 21.05, -4.2), 0.5, C.metal)
	end
	for _, z in { -0.1, -7.8 } do
		part(
			g,
			"LandingCrossBearer",
			V(8.2, 0.5, 0.65),
			CF(52.267273, 21.355, z),
			C.metal,
			true,
			Enum.Material.Metal
		)
	end
	-- Trim each original decorative column to its actual bracket bearing, not a guessed height.
	for _, post in access:GetChildren() do
		if post.Name == "OutboardSupport" and post:IsA("BasePart") then
			local chosen, best = nil, math.huge
			for _, bracket in access.WalkwaySupportArms:GetChildren() do
				if bracket.Name == "TopBracket" then
					for _, sign in { -1, 1 } do
						local point = bracket.CFrame:PointToWorldSpace(V(0, 0, sign * bracket.Size.Z / 2))
						local distance = (Vector3.new(point.X, 0, point.Z) - Vector3.new(
							post.Position.X,
							0,
							post.Position.Z
						)).Magnitude
						if distance < best then
							best = distance
							chosen = point
						end
					end
				end
			end
			assert(chosen and best < 1.5, "Unmatched spiral support")
			local bottom = 3.795
			local top = chosen.Y - 0.24
			post.Size = V(0.65, top - bottom, 0.65)
			post.CFrame = CF(post.Position.X, (top + bottom) / 2, post.Position.Z)
			post.Color = C.metal
			post.CanCollide = true
			post.CanQuery = true
			part(
				g,
				"SpiralBearingPlate",
				V(1.1, 0.16, 1.1),
				CF(post.Position.X, top, post.Position.Z),
				C.metal,
				true,
				Enum.Material.Metal
			)
		end
	end
	local pocket = model(g, "FutureAccessPlantingPocket")
	part(pocket, "SolidPocket", V(2.8, 1.2, 2.8), CF(58.3, 4.245, 1.6), C.stone, true)
	part(pocket, "Soil", V(2.3, 0.12, 2.3), CF(58.3, 4.88, 1.6), C.soil, false, Enum.Material.Ground)
	if r:FindFirstChild("CompactSpecimenStudy") then
		remove(r.CompactSpecimenStudy, "ModelAttribution")
	end
	return "Measured landing and spiral bearings; obsolete sign and affected floating vines removed"
end
function B.Roofs()
	local r = lab()
	for _, room in r.Rooms:GetChildren() do
		remove(room, "Ceiling")
		local g = model(room, "FinishedRoof")
		local cf = room:GetPivot()
		part(
			g,
			"Soffit",
			V(86.4, 0.32, 70.2),
			cf * CF(0, 26.68, 0),
			Color3.fromRGB(108, 119, 122),
			true,
			Enum.Material.Concrete
		)
		local pitch = -math.atan(2.5 / 71.4)
		local slope = CFrame.Angles(pitch, 0, 0)
		for i = 0, 7 do
			local x = -38.325 + i * 10.95
			part(
				g,
				"RoofPanel",
				V(10.91, 0.32, math.sqrt(71.4 ^ 2 + 2.5 ^ 2)),
				cf * CF(x, 28.6, 0) * slope,
				Color3.fromRGB(78, 96, 99),
				true,
				Enum.Material.Metal
			)
			if i < 7 then
				part(
					g,
					"StandingSeam",
					V(0.13, 0.13, math.sqrt(71.4 ^ 2 + 2.5 ^ 2)),
					cf * CF(x + 5.475, 28.82, 0) * slope,
					C.metal,
					false,
					Enum.Material.Metal
				)
			end
		end
		part(
			g,
			"FrontFascia",
			V(87.6, 0.85, 0.65),
			cf * CF(0, 27.05, -35.7),
			C.metal,
			true,
			Enum.Material.Metal
		)
		part(g, "RearFascia", V(87.6, 3.35, 0.65), cf * CF(0, 28.3, 35.7), C.metal, true, Enum.Material.Metal)
		for _, x in { -43.8, 43.8 } do
			part(
				g,
				"SideFasciaBase",
				V(0.65, 0.6, 71.4),
				cf * CF(x, 26.95, 0),
				C.metal,
				true,
				Enum.Material.Metal
			)
			triangle(
				g,
				"FittedSideFascia",
				cf:PointToWorldSpace(V(x, 27.25, -35.7)),
				cf:PointToWorldSpace(V(x, 27.25, 35.7)),
				cf:PointToWorldSpace(V(x, 29.95, 35.7)),
				0.65,
				C.metal,
				Enum.Material.Metal
			)
		end
		for _, z in { -35.8, 35.8 } do
			part(
				g,
				"FoldedDripEdge",
				V(87.8, 0.16, 0.5),
				cf * CF(0, z < 0 and 27.57 or 30.07, z),
				C.edge,
				false,
				Enum.Material.Metal
			)
		end
		if room:GetAttribute("RoomNumber") == 3 or room:GetAttribute("RoomNumber") == 9 then
			local pocket = model(g, "FutureRoofSoilPocket")
			part(pocket, "EdgeTrough", V(16, 1.25, 3.6), cf * CF(25, 28.1, -32.8), C.stone, true)
			part(
				pocket,
				"Soil",
				V(15.2, 0.12, 2.8),
				cf * CF(25, 28.77, -32.8),
				C.soil,
				false,
				Enum.Material.Ground
			)
		end
		task.wait()
	end
	local junctions = model(r, "FinishedRoofJunctions")
	for side = 0, 3 do
		local rotation = CFrame.Angles(0, math.rad(side * 90), 0)
		for _, x in { -44, 44 } do
			part(
				junctions,
				"WingStandingJoint",
				V(0.65, 0.18, 71.4),
				rotation * CF(x, 28.86, 169.1) * CFrame.Angles(-math.atan(2.5 / 71.4), 0, 0),
				C.metal,
				false,
				Enum.Material.Metal
			)
		end
	end
	for _, p in r.CompactCornerClosures:GetChildren() do
		if p.Name == "CornerClosureCap" then
			p:Destroy()
		end
	end
	for _, x in { -1, 1 } do
		for _, z in { -1, 1 } do
			local cf = corner(x * 134, z * 134)
			part(
				junctions,
				"CornerRoofClosure",
				V(14.5, 0.55, 7.5),
				cf * CF(0, 27.75, 1.7),
				C.metal,
				true,
				Enum.Material.Metal
			)
			part(
				junctions,
				"CornerFoldedEdge",
				V(14.6, 0.18, 0.4),
				cf * CF(0, 28.1, -2.1),
				C.edge,
				false,
				Enum.Material.Metal
			)
		end
	end
	return "Segmented roof panels, fitted fascia and connected wing junctions replace blank caps"
end

function B.Lighting()
	return require(script.Parent.WorldLightingBuilder).Build()
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
			-- FinishedRoofJunctions owns the fitted corner roof; do not recreate the old cap.
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
	for _, name in
		{
			"BeforeToolworksPolish_20261109",
			"BeforeWayfinding_20261109",
			"RetiredPrivateShops",
			"BeforeAccessPolish_20261109",
			"Stage27AccessBackup",
		}
	do
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
				"DeckLamp",
				"DeckLightStem",
				"DeckHazard",
				"RailStanchion",
				"SafetyHandrail",
			}
		do
			remove(archive, name)
		end
	end
	return "Superseded decorative recovery assemblies removed from the place; native backup retained privately"
end
function B.Build()
	local r = lab()
	assert(game.ServerStorage.CompactInteriorAssets.Microscope, "Existing finished instruments required")
	B.Frontage()
	B.Floor()
	B.Workshop()
	B.Laboratory()
	B.Access()
	B.Roofs()
	B.RemoveRetiredScenery()
	r:SetAttribute("InteriorPhase1Revision", 1)
	game:GetService("ChangeHistoryService"):SetWaypoint("Phase 1 integrated architecture")
	return "Phase 1 architecture; compact room poses, dome, global lighting and gameplay retained"
end

return B
