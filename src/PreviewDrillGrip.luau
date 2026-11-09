-- Static grip/arm reach review in Edit mode only; not a gameplay test.
local old = workspace:FindFirstChild("Stage2DrillAssetReview")
if old then
	old:Destroy()
end
local rig = game.ServerStorage.Stage2GripReference:Clone()
rig.Name = "Stage2DrillAssetReview"
for _, p in rig:GetDescendants() do
	if p:IsA("BasePart") then
		p.Anchored = true
		p.CFrame += Vector3.new(1000, 100, 0)
	end
end
local torso = rig.UpperTorso
local tool = game.ServerStorage.VesperKit.StarterDrill:Clone()
local originalHandle = tool.Handle.CFrame
local desired = torso.CFrame * CFrame.new(0.52, -0.5, -0.95)
for _, p in tool:GetDescendants() do
	if p:IsA("BasePart") then
		p.Anchored = true
		p.CFrame = desired * originalHandle:ToObjectSpace(p.CFrame)
	end
end
tool.Parent = rig
local result = {}
for _, side in { "Right", "Left" } do
	local hand, upper, lower = rig[side .. "Hand"], rig[side .. "UpperArm"], rig[side .. "LowerArm"]
	local contact = side == "Right" and tool.Grip or tool.Handle.SupportGrip.CFrame
	hand.CFrame = desired * contact * hand[side .. "GripAttachment"].CFrame:Inverse()
	local shoulder = torso[side .. "ShoulderRigAttachment"].WorldPosition
	local wrist = hand[side .. "WristRigAttachment"].WorldPosition
	local a = (upper[side .. "ShoulderRigAttachment"].Position - upper[side .. "ElbowRigAttachment"].Position).Magnitude
	local b = (lower[side .. "ElbowRigAttachment"].Position - lower[side .. "WristRigAttachment"].Position).Magnitude
	local delta = wrist - shoulder
	local distance = delta.Magnitude
	local direction = delta.Unit
	local pole = torso.CFrame:PointToWorldSpace(Vector3.new(side == "Left" and -2 or 2, -0.45, 0.2))
		- shoulder
	local lateral = (pole - direction * pole:Dot(direction)).Unit
	local projection = math.clamp((a * a - b * b + distance * distance) / (2 * distance), 0, a)
	local elbow = shoulder
		+ direction * projection
		+ lateral * math.sqrt(math.max(0, a * a - projection * projection))
	local function align(part, start, finish, attachmentName)
		local rotation = CFrame.lookAt(start, finish) * CFrame.Angles(math.pi / 2, 0, 0)
		part.CFrame = rotation * CFrame.new(-part[attachmentName].Position)
	end
	align(upper, shoulder, elbow, side .. "ShoulderRigAttachment")
	align(lower, elbow, wrist, side .. "ElbowRigAttachment")
	result[side] = { reach = distance, maxReach = a + b, reachable = distance < a + b }
end
rig.Parent = workspace
return result
