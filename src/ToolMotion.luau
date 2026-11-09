-- A single authored-pose coordinator, applied after the standard character Animator.
local M = {}
local Players = game:GetService("Players")
local Run = game:GetService("RunService")
local C = require(script.Parent.ExcavationConfig)
local Clips = require(script.Parent.MotionClips)
local Drill = require(script.Parent.DrillHandling)
local Cycle = require(script.Parent.TrainingCycle)
local actors = {}
local started = false
local function capture(ch)
	local joints = {}
	for _, d in ch:GetDescendants() do
		if
			(d:IsA("Motor6D") or d:IsA("AnimationConstraint"))
			and (
				d.Name == "RightShoulder"
				or d.Name == "Right Shoulder"
				or d.Name == "RightElbow"
				or d.Name == "RightWrist"
				or d.Name == "LeftShoulder"
				or d.Name == "Left Shoulder"
				or d.Name == "Waist"
			)
		then
			joints[d.Name] = d
		end
	end
	return joints
end
local function actor(p)
	local a = actors[p]
	if a and a.character == p.Character then
		return a
	end
	if a then
		M.Cancel(p)
		Drill.Release(a)
	end
	if not p.Character then
		return
	end
	a = { character = p.Character, joints = capture(p.Character), additive = {} }
	actors[p] = a
	return a
end
local function synchronize(a)
	local tool = a.character:FindFirstChildOfClass("Tool")
	if tool ~= a.tool then
		if a.tool and not tool and not a.release then
			a.release = { at = os.clock(), poses = {} }
			for name, joint in a.joints do
				if joint.Parent then a.release.poses[name] = joint.Transform end
			end
		end
		if a.tool and a.grip and a.tool.Parent then
			a.tool.Grip = a.grip
		end
		a.phase = nil
		a.drillContact = nil
		a.drillRunning = nil
		if tool then a.release = nil end
		a.tool = tool
		a.grip = tool and tool.Grip
		a.equippedAt = os.clock()
		a.joints = capture(a.character)
		Drill.Attach(a, tool)
	end
	return tool
end
function M.Cancel(p)
	local a = actors[p]
	if not a then
		return
	end
	a.phase = nil
	a.drillContact = nil
	a.drillRunning = nil
	if a.tool and a.grip and a.tool.Parent then
		a.tool.Grip = a.grip
	end
	for joint, addition in a.additive do
		if joint.Parent then
			joint.Transform = joint.Transform * addition:Inverse()
		end
	end
	table.clear(a.additive)
	a.release = { at = os.clock(), poses = {} }
	for name, j in a.joints do
		if j.Parent then
			a.release.poses[name] = j.Transform
		end
	end
end
function M.DrillContact(p, enabled, point)
	local a = actor(p)
	if not a then
		return
	end
	a.drillContact = enabled and typeof(point) == "Vector3" and { point = point, at = os.clock() } or nil
end
function M.DrillRun(p, running, point, contact, lease)
	local a = actor(p)
	if not a then return end
	synchronize(a)
	if not a.drill then return end
	a.drillRunning = running and { untilTime = os.clock() + (lease or 0.12), point = point } or nil
	a.drillContact = running and contact and typeof(point) == "Vector3"
		and { point = point, at = os.clock(), lease = lease or 0.12 } or nil
end
function M.Begin(p, duration, sequence, target, expectedTool)
	local a = actor(p)
	if not a then
		return
	end
	local tool = synchronize(a)
	local human = a.character:FindFirstChildOfClass("Humanoid")
	if not human or human.Health <= 0 or (expectedTool and tool ~= expectedTool)
		or not tool or tool:GetAttribute("ToolKind") ~= "Pickaxe" then
		return
	end
	if sequence and a.lastSequence and sequence <= a.lastSequence then
		return
	end
	a.lastSequence = sequence
	a.release = nil
	a.phase = { kind = "Strike", at = os.clock(), duration = duration, sequence = sequence, target = target,
		tool = tool }
end
function M.Confirm(p, sequence)
	local a = actor(p)
	if not a then return end
	local tool = synchronize(a)
	if a.phase and a.phase.sequence == sequence and a.phase.tool == tool then
		a.phase.confirmed = os.clock()
	end
end
function M.Miss(p, sequence)
	local a = actors[p]
	if a and a.phase and a.phase.sequence == sequence then
		-- A rejected request has no contact accent, damage number or collection cue.
		a.phase.missed = os.clock()
		a.phase.missPose = a.lastPose or Clips.PickaxeIdle
	end
end
function M.Bucket(p, unload)
	local a = actor(p)
	if not a then
		return
	end
	local tool = synchronize(a)
	if not tool or tool:GetAttribute("ToolKind") ~= "Bucket" then
		return
	end
	if not unload and a.phase and a.phase.kind == "Collect" then
		a.phase.untilTime = os.clock() + 0.3
		return
	end
	a.phase = { kind = unload and "Unload" or "Collect", at = os.clock(), untilTime = os.clock() + 0.3 }
end
function M.Busy(p)
	local a = actors[p]
	return a
		and a.phase
		and a.phase.kind == "Strike"
		and (not a.drill or os.clock() < a.phase.at + a.phase.duration)
end
local function sample(t)
	local list = Clips.Strike
	for i = 2, #list do
		local b = list[i]
		if t <= b[1] then
			local a = list[i - 1]
			local u = math.clamp((t - a[1]) / (b[1] - a[1]), 0, 1)
			u = i == 3 and u * u or (1 - math.cos(u * math.pi)) * 0.5
			local pose = {}
			for j = 2, 6 do
				pose[j - 1] = a[j] + (b[j] - a[j]) * u
			end
			return pose
		end
	end
	return Clips.PickaxeIdle
end
function M.Start()
	if started then
		return
	end
	started = true
	Run.PreAnimation:Connect(function(dt)
		for p, a in actors do
			synchronize(a)
			local started = p:GetAttribute("TrainingStartedAt")
			local target = p:GetAttribute("TrainingTarget")
			if p:GetAttribute("Training") and started and a.tool and typeof(target) == "Vector3" then
				local family = a.tool:GetAttribute("ToolFamily")
				local _, t, _, drive, pressure = Cycle.Sample(started, workspace:GetServerTimeNow(), family)
				if not a.training then
					M.Cancel(p)
				end
				a.training = true
				a.trainingAim = target
				a.trainingPressure = pressure
				if family == "Drill" then
					a.phase = nil
					a.drillContact = drive and { point = target, at = os.clock() } or nil
				else
					a.phase = t < Cycle.SwingDuration
							and {
								kind = "Strike",
								at = os.clock() - t,
								duration = Cycle.SwingDuration,
								target = target,
							}
						or nil
				end
			elseif a.training then
				a.training = false
				a.trainingAim, a.trainingPressure = nil, nil
				M.Cancel(p)
			end
			for joint, addition in a.additive do
				if joint.Parent then
					joint.Transform = joint.Transform * addition:Inverse()
				end
			end
			table.clear(a.additive)
			Drill.Update(a, dt)
		end
	end)
	Players.PlayerRemoving:Connect(function(p)
		M.Cancel(p)
		if actors[p] then
			Drill.Release(actors[p])
		end
		actors[p] = nil
	end)
	Run.PreSimulation:Connect(function()
		for _, p in Players:GetPlayers() do
			local a = actor(p)
			if not a then
				continue
			end
			local tool = synchronize(a)
			local h = a.character:FindFirstChildOfClass("Humanoid")
			if not h or h.Health <= 0 then
				if not a.dead then
					M.Cancel(p)
					Drill.Release(a)
					for _, joint in a.joints do
						if joint.Parent then joint.Transform = CFrame.identity end
					end
					a.dead = true
				end
				continue
			end
			if not tool or not tool:GetAttribute("ToolKind") then
				if a.release then
					local t = math.clamp((os.clock() - a.release.at) / 0.16, 0, 1)
					for name, pose in a.release.poses do
						local j = a.joints[name]
						if j and j.Parent then
							j.Transform = j.Transform:Lerp(pose, 1 - t)
						end
					end
					if t >= 1 then
						a.release = nil
					end
				end
				continue
			end
			local bucket = tool:GetAttribute("ToolKind") == "Bucket"
			if tool:GetAttribute("ToolFamily") == "Drill" then
				Drill.Apply(a)
				if a.phase and os.clock() > a.phase.at + a.phase.duration + 0.08 then
					a.phase = nil
				end
				continue
			end
			local pose = table.clone(bucket and Clips.BucketIdle or Clips.PickaxeIdle)
			local phase = a.phase
			if phase then
				if phase.kind == "Strike" then
					local elapsed = os.clock() - phase.at
					local t = math.clamp(elapsed / phase.duration, 0, 1)
					if tool:GetAttribute("ToolFamily") == "Explosive" then
						pose = { 38 + math.sin(t * math.pi) * 32, 0, 8, 60, -15 * math.sin(t * math.pi) }
					else
						pose = sample(t)
					end
					if phase.missed then
						local recovery = math.clamp((os.clock() - phase.missed) / 0.16, 0, 1)
						for i, value in phase.missPose do
							pose[i] = value + (Clips.PickaxeIdle[i] - value) * recovery
						end
						t = recovery >= 1 and 1 or 0
					end
					a.visualPhase = t
					if t >= 1 then
						a.phase = nil
					end

				-- Keep locomotion and player facing under the normal character controller.
				elseif phase.kind == "Collect" then
					local fade = math.clamp((phase.untilTime - os.clock()) / 0.12, 0, 1)
					local wave = math.sin((os.clock() - phase.at) * 14) * fade
					pose[1] += wave * 8
					pose[4] += wave * 7
					pose[5] += wave * 9
					if fade <= 0 then
						a.phase = nil
					end
				else
					local t = (os.clock() - phase.at) / 0.65
					local wave = math.sin(math.min(t, 1) * math.pi)
					pose[1] += wave * 28
					pose[5] += wave * 90
					if t >= 1 then
						a.phase = nil
					end
				end
			end
			-- Aim the arm within comfortable limits; never move the player or extend reach.
			if phase and phase.target and tool:GetAttribute("ToolFamily") == "Pickaxe" and not phase.missed then
				local root = a.character:FindFirstChild("HumanoidRootPart")
				if root then
					local aim = root.CFrame:PointToObjectSpace(phase.target) - Vector3.new(0, 1.5, 0)
					local weight = math.sin(math.clamp(a.visualPhase or 0, 0, 1) * math.pi)
					pose[2] += math.clamp(math.deg(math.atan2(-aim.X, -aim.Z)), -25, 25) * weight
					pose[1] += math.clamp(math.deg(math.atan2(aim.Y, math.max(0.1, Vector2.new(aim.X, aim.Z).Magnitude))), -20, 20) * weight
				end
			end
			a.lastPose = pose
			local blend = math.clamp((os.clock() - a.equippedAt) / C.Animation.EquipTime, 0, 1)
			local sway = math.sin(os.clock() * 8) * h.MoveDirection.Magnitude * math.deg(C.Animation.WalkSway)
			local shoulder = a.joints.RightShoulder or a.joints["Right Shoulder"]
			if shoulder then
				local r6 = shoulder.Name == "Right Shoulder"
				shoulder.Transform = r6
						and CFrame.Angles(0, math.rad(pose[2] * blend), math.rad(pose[1] * blend))
					or CFrame.Angles(
						math.rad((pose[1] + sway) * blend),
						math.rad(pose[2] * blend),
						math.rad(pose[3] * blend)
					)
			end
			if a.joints.RightElbow then
				a.joints.RightElbow.Transform = CFrame.Angles(math.rad(pose[4] * blend), 0, 0)
			end
			if a.joints.RightWrist then
				a.joints.RightWrist.Transform = CFrame.Angles(math.rad((-8 + pose[5]) * blend), 0, 0)
			end
			-- Keep the handle rigid in the hand; the wrist supplies the tool rotation.
			local strike = a.phase and a.phase.kind == "Strike"
			local energy = strike
					and math.sin(math.clamp(a.visualPhase or 0, 0, 1) * math.pi)
				or 0
			local left = a.joints.LeftShoulder or a.joints["Left Shoulder"]
			if left and energy > 0 then
				local addition =
					CFrame.Angles(math.rad(20 * energy), math.rad(-12 * energy), math.rad(-10 * energy))
				left.Transform = left.Transform * addition
				a.additive[left] = addition
			end
			local waist = a.joints.Waist
			if waist and energy > 0 then
				local twist =
					math.sin(math.clamp(a.visualPhase or 0, 0, 1) * math.pi * 2)
				local addition =
					CFrame.Angles(math.rad(-5 * energy), math.rad(12 * twist), math.rad(-3 * energy))
				waist.Transform = waist.Transform * addition
				a.additive[waist] = addition
			end
		end
	end)
	Run:BindToRenderStep("VesperToolVisibility", Enum.RenderPriority.Camera.Value + 1, function()
		local a = actors[Players.LocalPlayer]
		local cam = workspace.CurrentCamera
		if not a or not a.tool or not cam then
			return
		end
		local head = a.character:FindFirstChild("Head")
		local first = head and (cam.CFrame.Position - head.Position).Magnitude < 1.2
		for _, d in a.tool:GetDescendants() do
			if d:IsA("BasePart") then
				d.LocalTransparencyModifier = 0
			end
		end
		if first then
			for _, name in
				{
					"RightUpperArm",
					"RightLowerArm",
					"RightHand",
					"Right Arm",
					"LeftUpperArm",
					"LeftLowerArm",
					"LeftHand",
					"Left Arm",
				}
			do
				local p = a.character:FindFirstChild(name)
				if p then
					p.LocalTransparencyModifier = 0
				end
			end
		end
	end)
end
return M
