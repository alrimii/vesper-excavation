-- Retired after the living-laboratory checkpoint.
assert(not (workspace:FindFirstChild("VesperLab") and workspace.VesperLab:GetAttribute("LivingLabRevision")), "Historical environment recipe retired; use LivingLabBuilder")
-- Edit-time: bridge entry-lamp mounting points into their actual portal headers.
assert(not game:GetService("RunService"):IsRunning(), "Edit only")
local lab = workspace.VesperLab
local headers = {}
for _, room in lab.Rooms:GetChildren() do
	local header = room:FindFirstChild("PortalHeader")
	if header then
		table.insert(headers, header)
	end
end
local count = 0
for _, model in lab.FixtureHousings:GetChildren() do
	local housing = model:FindFirstChild("ContinuousHousing")
	if
		housing
		and housing.Position.Y > 25
		and housing.Position.Y < 32
		and not model:FindFirstChild("WallBracket")
	then
		local nearest, distance
		for _, header in headers do
			local d = (header.Position - housing.Position).Magnitude
			if not distance or d < distance then
				nearest, distance = header, d
			end
		end
		if nearest and distance < 15 then
			for _, mount in model:GetChildren() do
				if mount.Name == "Mount" and mount:IsA("BasePart") then
					local start = mount.Position
					local localPoint = nearest.CFrame:PointToObjectSpace(start)
					local finish = nearest.CFrame:PointToWorldSpace(
						Vector3.new(
							localPoint.X,
							localPoint.Y,
							math.sign(localPoint.Z) * (nearest.Size.Z / 2 - 0.2)
						)
					)
					local length = (finish - start).Magnitude
					if length > 0.05 and length < 4 then
						local bracket = Instance.new("Part")
						bracket.Name = "WallBracket"
						bracket.Size = Vector3.new(0.5, 0.35, length)
						bracket.CFrame = CFrame.lookAt((start + finish) / 2, finish)
						bracket.Color, bracket.Material = mount.Color, Enum.Material.Metal
						bracket.Anchored = true
						bracket.CanCollide, bracket.CanTouch, bracket.CanQuery = false, false, false
						bracket.Parent = model
						count += 1
					end
				end
			end
		end
	end
end
return count
