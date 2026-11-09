-- Edit-time: retain one softbox per ceiling lens rather than stacking two lights.
assert(not game:GetService("RunService"):IsRunning(), "Edit only")
local count = 0
for _, room in workspace.VesperLab.Rooms:GetChildren() do
	for _, fixture in room:GetChildren() do
		if fixture.Name == "CeilingFixture" and fixture:FindFirstChild("RoomSoftbox") then
			for _, light in fixture:GetChildren() do
				if light:IsA("SurfaceLight") and light.Name ~= "RoomSoftbox" and light.Enabled then
					light:SetAttribute("BeforeStage23Enabled", light.Enabled)
					light.Enabled = false
					count += 1
				end
			end
		end
	end
end
return count
