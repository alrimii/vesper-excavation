-- Apply once in Edit; the cabinet module also rebuilds this layout at runtime.
local rooms = workspace.VesperLab.Rooms
local fresh = game.ServerScriptService.Vesper.CollectionCabinet:Clone()
fresh.Parent = game.ServerScriptService.Vesper
local cabinet = require(fresh)
local count = 0
for _, room in rooms:GetChildren() do
	cabinet.Build(room)
	if not room:GetAttribute("RoomLayoutRevision30") then
		local station = room.TrainingStation
		local delta = room:GetPivot():VectorToWorldSpace(Vector3.new(-4, 0, -6))
		station:PivotTo(station:GetPivot() + delta)
		for _, p in station:GetDescendants() do
			local rest = p:GetAttribute("RestCFrame")
			if typeof(rest) == "CFrame" then
				p:SetAttribute("RestCFrame", rest + delta)
			end
		end
		-- Remove the decorative crossing lines that intersect the spawn lanes.
		for _, p in room:GetChildren() do
			if p.Name == "FloorSeam" then
				p:Destroy()
			end
		end
		room:SetAttribute("RoomLayoutRevision30", true)
	end
	count += 1
	task.wait()
end
fresh:Destroy()
return count
