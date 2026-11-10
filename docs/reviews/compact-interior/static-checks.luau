-- Read-only Edit-mode inspection. No gameplay modules, players or simulations are executed.
return function(before)
	assert(game.PlaceId == 94763223427049 and not game:GetService("RunService"):IsRunning())
	local lab = workspace.VesperLab
	local out = { rooms = {}, clearances = {}, glazingIntersections = {}, obsoleteRoots = {}, duplicateRoots = {}, foliageColliders = {}, solidBases = {}, activeOldCharges = {} }
	local function cf(a) return CFrame.new(table.unpack(a)) end
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.RespectCanCollide = true
	params.FilterDescendantsInstances = { lab }
	local function corridor(name, pose, size)
		local hits = {}
		for _, p in workspace:GetPartBoundsInBox(pose, size, params) do table.insert(hits, p:GetFullName()) end
		out.clearances[name] = { size = { size.X, size.Y, size.Z }, colliders = hits }
	end
	for _, room in lab.Rooms:GetChildren() do
		local old = before.rooms[room.Name]
		local delta = room:GetPivot() * cf(old.pivot):Inverse()
		local record = { id = room:GetAttribute("RoomNumber"), anchorErrors = {}, restPoseErrors = {} }
		for _, name in { "RoomSpawn", "Threshold" } do
			record.anchorErrors[name] = (room[name].Position - (delta * cf(old.poses[name])).Position).Magnitude
		end
		record.anchorErrors.PracticeEgg = (room.TrainingStation.PracticeEgg.Position - (delta * cf(old.training)).Position).Magnitude
		for _, name in { "PracticeEgg", "PressHead" } do
			local p = room.TrainingStation[name]
			record.restPoseErrors[name] = (p.Position - p:GetAttribute("RestCFrame").Position).Magnitude
		end
		local doorway = room:GetPivot():PointToWorldSpace(Vector3.new(0, 0, -37))
		record.radialClearDistance = Vector3.new(doorway.X, 0, doorway.Z).Magnitude - 74.25
		record.floorSize = { room.Floor.Size.X, room.Floor.Size.Y, room.Floor.Size.Z }
		out.rooms[room.Name] = record
		corridor(room.Name, room:GetPivot() * CFrame.new(0, 5, -48), Vector3.new(12, 6, 24))
	end
	for name, point in { Workshop = Vector3.new(113.5, 0, 113.5), Laboratory = Vector3.new(-113.5, 0, -113.5) } do
		corridor(name, CFrame.lookAt(point, Vector3.zero) * CFrame.new(0, 5, -15), Vector3.new(30, 6, 10))
	end
	params.FilterDescendantsInstances = { lab.Rooms }
	for _, wall in lab.Dome.CompactLowerEnvelope:GetChildren() do
		if wall.Name == "ClerestoryGlazing" then
			for _, p in workspace:GetPartsInPart(wall, params) do table.insert(out.glazingIntersections, p:GetFullName()) end
		end
	end
	for _, name in { "StoneCirculation", "InteriorCommons", "LaboratoryBays", "PerimeterPlanting", "ResearchGardenIslands", "FocalResearchDisplays", "ExcavationPlanting", "AccessArtIntegration", "PlatformFinish", "FloorMarkings", "RouteDetails" } do
		if lab:FindFirstChild(name) then table.insert(out.obsoleteRoots, name) end
	end
	for _, name in { "CompactStoneFloor", "CompactCommons", "SharedWorkshop", "SharedLaboratory", "CompactSpecimenStudy", "CompactWingArchitecture", "CompactCornerClosures", "CompactBotanicalSupports" } do
		local count = 0
		for _, p in lab:GetChildren() do if p.Name == name then count += 1 end end
		if count ~= 1 then out.duplicateRoots[name] = count end
	end
	for _, root in { lab.CompactCommons, lab.CompactBotanicalSupports } do
		for _, p in root:GetDescendants() do
			if p:IsA("MeshPart") and p.CanCollide then table.insert(out.foliageColliders, p:GetFullName()) end
		end
	end
	for _, root in { lab.CompactCommons, lab.SharedWorkshop, lab.SharedLaboratory, lab.CompactSpecimenStudy } do
		for _, p in root:GetDescendants() do
			if p:IsA("BasePart") and (p.Name == "SolidStoneBase" or p.Name == "CabinetBody" or p.Name == "StoneWorktop" or p.Name == "SolidSpecimenPlinth" or p.Name == "FossilBearingPost") then out.solidBases[p:GetFullName()] = p.CanCollide end
		end
	end
	for _, root in { lab.SharedWorkshop, game.ServerStorage.VesperKit, game.ReplicatedStorage.VesperShared.EquipmentAssets } do
		for _, p in root:GetDescendants() do if p.Name == "ChargeCell" then table.insert(out.activeOldCharges, p:GetFullName()) end end
	end
	out.enclosureHalfWidth = lab:GetAttribute("CompactDomeHalfWidth")
	out.roomCount = #lab.Rooms:GetChildren()
	out.anchorCount = #lab.FunctionalAnchors:GetChildren()
	out.emptyRuntimeDependencies = { ResearchGallery = #lab.ResearchGallery:GetDescendants(), CinematicFixtures = #lab.CinematicFixtures:GetDescendants() }
	return out
end
