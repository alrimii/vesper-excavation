-- Sole personal-room architecture recipe. Edit-only; no ownership or profile mutation.
local B = {}
local V, CF = Vector3.new, CFrame.new
local C = {
	stone = Color3.fromRGB(142, 139, 122),
	floor = Color3.fromRGB(112, 116, 104),
	metal = Color3.fromRGB(61, 77, 72),
	wood = Color3.fromRGB(127, 100, 70),
	dark = Color3.fromRGB(43, 53, 47),
	sage = Color3.fromRGB(106, 123, 104),
}
local retired = {
	CollectionShelf = true,
	MonitorStem = true,
	Workbench = true,
	BenchCabinet = true,
	Drawer = true,
	DrawerPull = true,
	BenchStool = true,
	StoolLeg = true,
	WallPanel = true,
	PanelFrame = true,
	RearPanel = true,
	RearSeam = true,
	ServiceConduit = true,
	Skirting = true,
	InnerSign = true,
	SpawnLane = true,
	CeilingFixture = true,
	FrontageAndZones = true,
	PersonalInterior = true,
}
local function model(parent, name)
	local m = Instance.new("Model")
	m.Name = name
	m.Parent = parent
	return m
end
function B.Room(room)
	assert(
		game.PlaceId == 94763223427049 and not game:GetService("RunService"):IsRunning(),
		"Original Edit place only"
	)
	local basis = room:GetPivot()
	local floor = basis:PointToObjectSpace(room.Floor.Position).Y + room.Floor.Size.Y / 2
	local station, egg, spot =
		room.TrainingStation, room.TrainingStation.PracticeEgg, room.TrainingStation.TrainingSpot
	local removed = {}
	for _, p in room:GetChildren() do
		if retired[p.Name] then
			table.insert(removed, p:GetFullName())
			p:Destroy()
		end
	end
	for _, p in station:GetChildren() do
		if p ~= egg and p ~= spot then
			table.insert(removed, p:GetFullName())
			p:Destroy()
		end
	end
	station:SetAttribute("CompactCradle", nil)
	station:SetAttribute("TrainingRevision", "PersonalRoomPhase2")
	station:SetAttribute("TrainingActive", false)
	station:SetAttribute("TrainingStartedAt", nil)
	station:SetAttribute("TrainingFamily", nil)
	local g = model(nil, "PersonalInterior")
	local function part(parent, name, size, cf, color, material, collide)
		local p = Instance.new("Part")
		p.Name, p.Size, p.CFrame = name, size, basis * cf
		p.Color, p.Material = color, material or Enum.Material.SmoothPlastic
		p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery = true, collide ~= false, false, true
		p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
		p.Parent = parent
		return p
	end
	local function lamp(parent, cf, width, range, brightness)
		part(parent, "LightHousing", V(width + 0.3, 0.35, 1), cf, C.metal, Enum.Material.Metal)
		local lens = part(
			parent,
			"WarmLens",
			V(width, 0.08, 0.65),
			cf * CF(0, -0.22, 0),
			Color3.fromRGB(206, 194, 153),
			nil,
			false
		)
		local light = Instance.new("PointLight")
		light.Color, light.Brightness, light.Range, light.Shadows =
			Color3.fromRGB(255, 235, 202), brightness, range, false
		light.Parent = lens
	end
	local function furniture(name, cf, parent, scale)
		local m = game.ServerStorage.PersonalRoomAssets[name]:Clone()
		m.Name = name
		if scale then
			m:ScaleTo(m:GetScale() * scale)
		end
		if name == "LabTable" then
			for _, p in m:GetDescendants() do
				if p:IsA("BasePart") then
					p.Color = p:GetAttribute("SourcePrimitive") == 1 and C.metal
						or Color3.fromRGB(134, 131, 112)
				end
			end
		end
		m:PivotTo(basis * cf)
		m.Parent = parent
		return m
	end
	local function plant(x, z, length)
		local p = model(g, "IntegratedPlanter")
		part(p, "StoneTrough", V(length, 1.35, 3), CF(x, floor + 0.675, z), C.stone, Enum.Material.Limestone)
		part(
			p,
			"Soil",
			V(length - 0.45, 0.12, 2.55),
			CF(x, floor + 1.38, z),
			Color3.fromRGB(57, 54, 40),
			Enum.Material.Ground,
			false
		)
		for i = -1, 1 do
			local leaf = game.ServerStorage.LivingLabArtAssets.ForestFern:Clone()
			leaf.Name = "Fern"
			local s = leaf.Size
			leaf.Size = s * (3.1 / math.max(s.X, s.Y, s.Z))
			leaf.CFrame = basis
				* CF(x + i * length * 0.28, floor + 1.4 + leaf.Size.Y / 2, z)
				* CFrame.Angles(0, i * 0.7, 0)
			leaf.Anchored, leaf.CanCollide, leaf.CanTouch, leaf.CanQuery = true, false, false, false
			leaf.Parent = p
		end
	end
	-- The selected structural floor remains the single floor, with a new stone finish.
	room.Floor.Color, room.Floor.Material, room.Floor.Reflectance = C.floor, Enum.Material.Limestone, 0
	for _, x in { -41.55, 41.55 } do
		part(
			g,
			"InnerStoneLining",
			V(0.45, 24.4, 67.4),
			CF(x, floor + 12.2, 0),
			C.stone,
			Enum.Material.Limestone
		)
		part(
			g,
			"TimberDado",
			V(0.5, 4, 67.4),
			CF(x - math.sign(x) * 0.3, floor + 2, 0),
			C.wood,
			Enum.Material.WoodPlanks
		)
		part(
			g,
			"DadoCap",
			V(0.7, 0.18, 67.4),
			CF(x - math.sign(x) * 0.3, floor + 4.1, 0),
			C.metal,
			Enum.Material.Metal
		)
	end
	part(
		g,
		"RearStoneLining",
		V(82.7, 24.4, 0.45),
		CF(0, floor + 12.2, 33.7),
		C.stone,
		Enum.Material.Limestone
	)
	part(g, "RearTimberDado", V(82, 4, 0.55), CF(0, floor + 2, 33.3), C.wood, Enum.Material.WoodPlanks)
	for _, x in { -29.5, 29.5 } do
		part(
			g,
			"EntryInnerLining",
			V(25, 24.4, 0.35),
			CF(x, floor + 12.2, -34.3),
			C.stone,
			Enum.Material.Limestone
		)
	end
	-- Structural ceiling ribs give the tall shell an intentional room scale without moving its roof.
	for _, z in { -22, 0, 22 } do
		part(g, "CeilingRib", V(82, 0.6, 0.85), CF(0, 25.6, z), C.wood, Enum.Material.Wood)
		for _, x in { -22, 22 } do
			lamp(g, CF(x, 24.9, z), 5.5, 32, 0.45)
		end
	end
	-- Wall joints are quiet material seams, not navigation stripes or floor overlays.
	for _, x in { -20, 0, 20 } do
		part(g, "RearJoint", V(0.08, 19, 0.08), CF(x, 14.7, 33.42), C.floor, nil, false)
	end
	local care = model(g, "CareReserve")
	part(care, "LowStoneDivider", V(26, 2.8, 1.25), CF(-6, floor + 1.4, 16), C.stone, Enum.Material.Limestone)
	part(care, "DividerCap", V(26.4, 0.25, 1.6), CF(-6, floor + 2.925, 16), C.wood, Enum.Material.Wood)
	furniture("CareBench", CF(-12, floor, 24) * CFrame.Angles(0, math.pi / 2, 0), care, 0.78)
	furniture("LabTable", CF(2, floor, 29) * CFrame.Angles(0, math.pi, 0), care, 1)
	part(care, "CareWorkBacking", V(22, 8, 0.4), CF(-3, floor + 6, 33), C.sage, Enum.Material.WoodPlanks)
	lamp(care, CF(-3, floor + 10.5, 32.4), 10, 23, 0.6)
	plant(-23, 28, 7)
	plant(19, 28, 9)
	-- Preserved functional terminals now stand on finished, human-scale desks.
	for _, terminal in room:GetChildren() do
		if terminal.Name == "Terminal" and terminal:IsA("BasePart") then
			local archive = terminal:GetAttribute("RoomTerminalPage") == "ARCHIVE"
			local x, z = archive and 26 or -34, archive and -24 or -26
			local yaw = archive and math.pi / 2 or -math.pi / 2
			local cf = CF(x, floor, z) * CFrame.Angles(0, yaw, 0)
			furniture("ArchiveDesk", cf, g)
			for _, child in terminal:GetChildren() do
				if child:IsA("SurfaceGui") then
					child:Destroy()
				end
			end
			terminal.Size, terminal.CFrame = V(3.2, 2, 0.18), basis * cf * CF(0, 4.05, 0.35)
			terminal.Color, terminal.Material = C.dark, Enum.Material.Metal
			terminal.CanCollide, terminal.CanTouch, terminal.CanQuery = true, false, true
			part(
				g,
				"MonitorSupport",
				V(0.35, 1.25, 0.35),
				cf * CF(0, 3.4, 0.55),
				C.metal,
				Enum.Material.Metal
			)
		end
	end
	-- Training footprint is flush and approachable. Only the real workbench collides.
	spot.Size, spot.CFrame = V(7, 0.12, 5), basis * CF(-23, floor + 0.065, -9)
	spot.Color, spot.Material = C.sage, Enum.Material.SmoothPlastic
	spot.Transparency, spot.CanCollide, spot.CanTouch, spot.CanQuery = 0, false, false, true
	spot:SetAttribute("RoomLocalCFrame", basis:ToObjectSpace(spot.CFrame))
	spot:SetAttribute("RoomThemeAccent", true)
	furniture("LabTable", CF(-23, floor, -4.4), station)
	for _, x in { -27.5, -18.5 } do
		part(
			station,
			"InstrumentUpright",
			V(0.45, 7.5, 0.55),
			CF(x, floor + 3.75, -3.2),
			C.metal,
			Enum.Material.Metal
		)
		part(
			station,
			"InstrumentFoot",
			V(1.3, 0.25, 2.2),
			CF(x, floor + 0.125, -3.2),
			C.metal,
			Enum.Material.Metal
		)
	end
	part(
		station,
		"InstrumentBridge",
		V(9.5, 0.5, 0.55),
		CF(-23, floor + 7.5, -3.2),
		C.metal,
		Enum.Material.Metal
	)
	lamp(station, CF(-23, floor + 7.15, -3.8), 4.2, 17, 0.55)
	for _, x in { -25.1, -20.9 } do
		part(
			station,
			"SampleClamp",
			V(0.35, 1.1, 1.4),
			CF(x, floor + 2.65, -4.4),
			C.metal,
			Enum.Material.Metal
		)
	end
	-- Keep the exact interaction reference; its old visual was removed. The mesh is the visible target.
	egg.Size, egg.CFrame = V(3.2, 3.2, 3.2), basis * CF(-23, floor + 3.7, -4.4)
	egg.Transparency, egg.CanCollide, egg.CanTouch, egg.CanQuery = 1, false, false, false
	egg:SetAttribute("RestCFrame", egg.CFrame)
	egg:SetAttribute("RestSize", egg.Size)
	egg:SetAttribute("FunctionalAnchorOnly", true)
	local target = model(station, "TrainingTargetVisual")
	local rock = game.ServerStorage.LivingLabArtAssets.RockRound:Clone()
	rock.Name = "PracticeSample"
	for _, child in rock:GetChildren() do
		if child:IsA("SurfaceAppearance") then
			child:Destroy()
		end
	end
	rock.TextureID = ""
	rock.Color, rock.Material = Color3.fromRGB(119, 111, 90), Enum.Material.Slate
	rock.Size = rock.Size * (3.2 / math.max(rock.Size.X, rock.Size.Y, rock.Size.Z))
	rock.CFrame = basis * CF(-23, floor + 2.1 + rock.Size.Y / 2, -4.4)
	rock.Anchored, rock.CanCollide, rock.CanTouch, rock.CanQuery = true, true, false, true
	rock.Parent = target
	target.WorldPivot = egg.CFrame
	local screen =
		part(station, "Screen", V(3, 1.2, 0.16), CF(-18, floor + 4.1, -3.5), C.dark, Enum.Material.Metal)
	part(station, "ScreenStem", V(0.3, 4, 0.35), CF(-18, floor + 2, -3.2), C.metal, Enum.Material.Metal)
	local gui = Instance.new("SurfaceGui")
	gui.Name, gui.Face, gui.CanvasSize = "TrainingStatus", Enum.NormalId.Front, Vector2.new(450, 170)
	gui.LightInfluence, gui.MaxDistance = 0.2, 55
	gui.Parent = screen
	for i, name in { "Status", "Subtitle" } do
		local label = Instance.new("TextLabel")
		label.Name, label.Size, label.Position =
			name, UDim2.fromScale(1, 0.5), UDim2.fromScale(0, (i - 1) * 0.5)
		label.Text, label.TextSize = i == 1 and "READY" or "STRENGTH", i == 1 and 36 or 24
		label.BackgroundTransparency, label.TextColor3, label.Font =
			1, Color3.fromRGB(219, 222, 197), Enum.Font.GothamMedium
		label.Parent = gui
	end
	part(station, "BenchStatusLens", V(0.5, 0.15, 0.2), CF(-18, floor + 3.42, -3.6), C.sage, nil, false)
	plant(-35, 1, 8)
	g.Parent = room
	local cabinet = require(game.ServerScriptService.Vesper.CollectionCabinet)
	local display = cabinet.Build(room)
	cabinet.Refresh(display, nil)
	room:SetAttribute("PersonalRoomRevision", 2)
	return {
		room = room.Name,
		removed = removed,
		trainingSpot = tostring(spot.CFrame),
		practiceRest = tostring(egg.CFrame),
		capacity = display.model:GetAttribute("SlotCapacity"),
	}
end
function B.RemoveRetiredScenery()
	local ss = game.ServerStorage
	local removed = {}
	local function remove(p)
		if p then
			table.insert(removed, p:GetFullName())
			p:Destroy()
		end
	end
	for _, name in
		{ "BeforeCabinetPolish_20261109", "BeforeTrainingBench_20261109", "TrainingStationGeneratedSource" }
	do
		remove(ss:FindFirstChild(name))
	end
	for _, name in { "BeforeRoomTerminals_20261109", "Stage26WorldBackup", "Stage30RoomHUDBackup" } do
		local root = ss:FindFirstChild(name)
		if root then
			for _, p in root:GetChildren() do
				if p.Name:match("^Room%d%d$") or p.Name == "CollectionCabinet" then
					remove(p)
				end
			end
		end
	end
	for rootName, childNames in
		{
			Stage23PresentationBackup = { "RoomLights" },
			Stage26SourceBackup = { "RoomAnimation", "CollectionCabinet" },
			Stage28ReviewBackup = { "RoomAnimation" },
			BeforeCollectionStage_20261109 = { "ExpeditionWorld" },
			RoomRebuildArchive = { "TrainingStation" },
		}
	do
		local root = ss:FindFirstChild(rootName)
		if root then
			for _, name in childNames do
				remove(root:FindFirstChild(name))
			end
		end
	end
	for _, name in
		{
			"RoomRigRefit",
			"RoomLayoutRefit",
			"TrainingBenchPolish",
			"RoomLightingCleanup",
			"CollectionCabinetV2",
		}
	do
		remove(ss.VesperTools:FindFirstChild(name))
	end
	return removed
end
function B.Build()
	local report = {}
	for _, room in workspace.VesperLab.Rooms:GetChildren() do
		table.insert(report, B.Room(room))
		task.wait()
	end
	require(game.ServerScriptService.Vesper.RoomTerminals).Build(workspace.VesperLab.Rooms)
	B.RemoveRetiredScenery()
	game:GetService("ChangeHistoryService"):SetWaypoint("Phase 2 twelve personal rooms")
	return report
end
return B
