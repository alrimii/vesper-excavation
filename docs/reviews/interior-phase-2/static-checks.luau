-- Focused Edit inspection only: no fake players, gameplay systems, rewards or saves.
assert(game.PlaceId == 94763223427049 and not game:GetService("RunService"):IsRunning())
local out = { rooms = {}, invalid = {}, oldNames = {}, anchors = 0 }
local old = {
	Workbench = true,
	BenchCabinet = true,
	WallPanel = true,
	PanelFrame = true,
	FrontageAndZones = true,
	CeilingFixture = true,
	SpawnLane = true,
	InnerSign = true,
	PracticeShell = true,
	PressHead = true,
	MachineLabel = true,
	Control = true,
}
for _, r in workspace.VesperLab.Rooms:GetChildren() do
	local basis = r:GetPivot()
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = { r }
	params.RespectCanCollide = true
	local function clear(cf, size)
		local hits = {}
		for _, p in workspace:GetPartBoundsInBox(basis * cf, size, params) do
			table.insert(hits, p:GetFullName())
		end
		return hits
	end
	local station = r.TrainingStation
	local count, slots = 0, 0
	local terminals = {}
	local specimens = {}
	for _, p in r:GetDescendants() do
		if old[p.Name] then
			table.insert(out.oldNames, p:GetFullName())
		end
		if p:IsA("BasePart") and p:GetAttribute("SlotIndex") then
			slots += 1
		end
		if p.Name == "Fern" and p.CanCollide then
			table.insert(out.invalid, "Snagging foliage: " .. p:GetFullName())
		end
	end
	for _, p in r:GetChildren() do
		if p.Name == "PersonalInterior" then
			count += 1
		end
		if p.Name == "Terminal" then
			terminals[p:GetAttribute("RoomTerminalPage")] = tostring(basis:ToObjectSpace(p.CFrame))
		end
	end
	for _, p in r.CollectionShelf:GetChildren() do
		if p:IsA("Model") and p:GetAttribute("Discovered") ~= nil then
			local cf, size = p:GetBoundingBox()
			local index = tonumber(p.Name:match("%d+"))
			local deck = r.CollectionShelf["Display" .. index]
			local pos = deck.CFrame:PointToObjectSpace(cf.Position)
			local inside = math.abs(pos.X) + size.Z / 2 <= deck.Size.X / 2 + 0.01
				and math.abs(pos.Z) + size.X / 2 <= deck.Size.Z / 2 + 0.01
			table.insert(
				specimens,
				{
					name = p.Name,
					size = tostring(size),
					center = tostring(pos),
					fit = inside,
					clearanceAboveDeck = pos.Y - size.Y / 2 - deck.Size.Y / 2,
				}
			)
			if not inside then
				table.insert(out.invalid, "Specimen fit: " .. p:GetFullName())
			end
		end
	end
	local record = {
		recipeCount = count,
		capacity = slots,
		id = r:GetAttribute("RoomNumber"),
		trainingLocal = tostring(basis:ToObjectSpace(station.TrainingSpot.CFrame)),
		restError = (station.PracticeEgg.Position - station.PracticeEgg:GetAttribute("RestCFrame").Position).Magnitude,
		terminals = terminals,
		specimens = specimens,
	}
	record.entrance = clear(CFrame.new(0, 4.5, -27), Vector3.new(12, 5, 16))
	record.spawn = clear(CFrame.new(0, 4.5, 0), Vector3.new(8, 5, 8))
	record.training = clear(CFrame.new(-23, 4.3, -9), Vector3.new(6.6, 5, 4.6))
	record.careEntry = clear(CFrame.new(12, 4.5, 19), Vector3.new(7, 5, 12))
	for _, key in { "entrance", "spawn", "training", "careEntry" } do
		if #record[key] > 0 then
			table.insert(out.invalid, r.Name .. " " .. key)
		end
	end
	if count ~= 1 or slots ~= 12 or record.restError > 0.001 then
		table.insert(out.invalid, r.Name .. " recipe/anchors")
	end
	out.rooms[r.Name] = record
end
for _, p in workspace.VesperLab.FunctionalAnchors:GetChildren() do
	if p:IsA("ObjectValue") and p.Value then
		out.anchors += 1
	else
		table.insert(out.invalid, "Broken anchor: " .. p.Name)
	end
end
return game.HttpService:JSONEncode(out)
