assert(not game:GetService("RunService"):IsRunning(), "Edit only")
local lab = workspace.VesperLab
local archive = game.ServerStorage.Stage27AccessBackup
local result = { retired = 0, signMounts = 0, fanRails = 0 }
for _, p in lab.Infrastructure:GetDescendants() do
	if p.Name == "VentSlat" or p.Name == "EquipmentAccent" then
		p.Parent = archive.Retired
		result.retired += 1
	end
end
local function support(parent, name, size, cf)
	local p = Instance.new("Part")
	p.Name, p.Size, p.CFrame = name, size, cf
	p.Color, p.Material = Color3.fromRGB(48, 63, 76), Enum.Material.Metal
	p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery = true, false, false, false
	p.Parent = parent
	return p
end
for _, room in lab.Rooms:GetChildren() do
	local targets = {}
	for _, p in room:GetChildren() do
		if p.Name == "PortalHeader" or p.Name == "FrontPanel" then
			table.insert(targets, p)
		end
	end
	local params = RaycastParams.new()
	params.BruteForceAllSlow = true
	params.FilterType, params.FilterDescendantsInstances = Enum.RaycastFilterType.Include, targets
	for _, name in { "OwnerSign", "RoomType", "NumberSign" } do
		local sign = room:FindFirstChild(name)
		if sign and not room:FindFirstChild(name .. "Mount") then
			local back = -sign.CFrame.LookVector
			local origin = sign.Position + back * sign.Size.Z / 2
			local hit = workspace:Raycast(origin, back * 4, params)
			if hit and hit.Distance > 0.03 then
				support(
					room,
					name .. "Mount",
					Vector3.new(sign.Size.X * 0.85, sign.Size.Y * 0.7, hit.Distance + 0.1),
					sign.CFrame * CFrame.new(0, 0, sign.Size.Z / 2 + hit.Distance / 2)
				)
				result.signMounts += 1
			end
		end
	end
end
for _, bay in lab.ThermalServiceBays:GetChildren() do
	if not bay:FindFirstChild("GrilleCrossRail") then
		for _, shroud in bay:GetChildren() do
			if shroud.Name == "FanShroud" then
				local sum, count, reference = Vector3.zero, 0, nil
				for _, bar in bay:GetChildren() do
					if bar.Name == "FanGuard" and (bar.Position - shroud.Position).Magnitude < 3.8 then
						sum += bar.Position
						count += 1
						reference = bar
					end
				end
				if reference and count == 3 then
					local center = sum / count
					local back = (shroud.Position - center).Unit * 0.17
					for _, side in { -1, 1 } do
						support(
							bay,
							"GrilleCrossRail",
							Vector3.new(3.4, 0.16, 0.65),
							CFrame.new(center + reference.CFrame.UpVector * (side * 2.75) + back)
								* reference.CFrame.Rotation
						)
						result.fanRails += 1
					end
				end
			end
		end
	end
end
local display = lab.SharedWorkshop.PickaxeDisplay
if not display:GetAttribute("SeatedOnPlinth") then
	display:Clone().Parent = archive
	display:PivotTo(display:GetPivot() - Vector3.yAxis * 0.11)
	display:SetAttribute("SeatedOnPlinth", true)
end
return result
