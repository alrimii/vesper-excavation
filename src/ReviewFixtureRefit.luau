-- Retired after the living-laboratory checkpoint.
assert(not (workspace:FindFirstChild("VesperLab") and workspace.VesperLab:GetAttribute("LivingLabRevision")), "Historical environment recipe retired; use LivingLabBuilder")
-- Edit-time repair recipe; original instances remain in ServerStorage.
local lab = workspace.VesperLab
local backup = game.ServerStorage:FindFirstChild("Stage28ReviewBackup")
assert(backup, "Create the review backup before applying this refit")
local count = { vents = 0, markings = 0, lights = 0 }
local centers = {}
for _, vent in lab.AtmosphereDetails:GetChildren() do
	if vent.Name == "CoolingVent" then
		local original = vent:GetAttribute("ReviewOriginalCFrame") or vent.CFrame
		table.insert(centers, original.Position)
	end
end
local function relocate(part)
	if part:GetAttribute("ReviewOriginalCFrame") then
		return
	end
	local closest, distance = nil, math.huge
	for _, center in centers do
		local d = (part.Position - center).Magnitude
		if d < distance then
			closest, distance = center, d
		end
	end
	if not closest or distance > 6 then
		return
	end
	part:Clone().Parent = backup
	part:SetAttribute("ReviewOriginalCFrame", part.CFrame)
	local radial = Vector3.new(closest.X, 0, closest.Z).Unit
	part.CFrame += radial * 9
	count.vents += 1
end
for _, part in lab.AtmosphereDetails:GetChildren() do
	if part:IsA("BasePart") and (part.Name == "CoolingVent" or part.Name == "StatusLens") then
		relocate(part)
	end
end
for _, model in lab.ThermalServiceBays:GetChildren() do
	if model.Name == "FloorVentHousing" then
		for _, part in model:GetDescendants() do
			if part:IsA("BasePart") then
				relocate(part)
			end
		end
	end
end
for _, room in lab.Rooms:GetChildren() do
	for _, part in room:GetChildren() do
		if part.Name == "FloorSeam" and not part:GetAttribute("ReviewOriginalCFrame") then
			part:Clone().Parent = backup
			part:SetAttribute("ReviewOriginalCFrame", part.CFrame)
			part.CFrame += Vector3.yAxis * 0.03
			count.markings += 1
		end
	end
end
for _, light in lab.CraneGantry:GetDescendants() do
	if light:IsA("SurfaceLight") and light:GetAttribute("ReviewOriginalBrightness") == nil then
		light:Clone().Parent = backup
		light:SetAttribute("ReviewOriginalBrightness", light.Brightness)
		light.Brightness = 0.6
		count.lights += 1
	end
end
return count
