-- Both hands solve against a shared drill frame, not against last frame's hand.
local D = {}
local Players = game:GetService("Players")
-- Reuse the rigid-grip two-bone method already used by PickaxeHandling. Some
-- avatar joint rigs do not follow IKControl's requested hand rotation.
local function orient(restFrame, from, to, direction)
	local axisFrom = restFrame:VectorToWorldSpace(to - from).Unit
	local axis = axisFrom:Cross(direction.Unit)
	local rotation = axis.Magnitude > 1e-5
			and CFrame.fromAxisAngle(axis.Unit, math.acos(math.clamp(axisFrom:Dot(direction.Unit), -1, 1)))
		or CFrame.identity
	return rotation * restFrame.Rotation
end
local function restorePose(d)
	for joint, original in d.posed or {} do
		if joint.Parent then
			joint.Transform = original
		end
	end
	d.posed = {}
end
local function solveArm(d, ch, side, torsoFrame, handFrame)
	local upper, lower, hand =
		ch:FindFirstChild(side .. "UpperArm"),
		ch:FindFirstChild(side .. "LowerArm"),
		ch:FindFirstChild(side .. "Hand")
	local shoulder, elbow, wrist =
		ch:FindFirstChild(side .. "Shoulder", true),
		ch:FindFirstChild(side .. "Elbow", true),
		ch:FindFirstChild(side .. "Wrist", true)
	if not upper or not lower or not hand or not shoulder or not elbow or not wrist then
		return
	end
	local ua, ub =
		upper:FindFirstChild(side .. "ShoulderRigAttachment"),
		upper:FindFirstChild(side .. "ElbowRigAttachment")
	local la, lb, ha =
		lower:FindFirstChild(side .. "ElbowRigAttachment"),
		lower:FindFirstChild(side .. "WristRigAttachment"),
		hand:FindFirstChild(side .. "WristRigAttachment")
	if not ua or not ub or not la or not lb or not ha then
		return
	end
	local origin = (torsoFrame * shoulder.C0).Position
	local endPoint = (handFrame * ha.CFrame).Position
	local delta = endPoint - origin
	local l1, l2 = (ub.Position - ua.Position).Magnitude, (lb.Position - la.Position).Magnitude
	local distance = delta.Magnitude
	if distance >= l1 + l2 or distance <= math.abs(l1 - l2) + 0.001 then
		return
	end
	local direction = delta.Unit
	-- Elbows sit below the shoulder, outside the ribs and slightly forward.
	local pole = torsoFrame:VectorToWorldSpace(Vector3.new(side == "Left" and -0.7 or 0.7, -1, -0.15))
	pole = pole - direction * pole:Dot(direction)
	if pole.Magnitude < 0.01 then
		return
	end
	local along = (l1 * l1 - l2 * l2 + distance * distance) / (2 * distance)
	local mid = origin + direction * along + pole.Unit * math.sqrt(math.max(0, l1 * l1 - along * along))
	-- Solve from bind frames, not last frame's posed parts: no accumulated twist.
	local upperRest = torsoFrame * shoulder.C0 * shoulder.C1:Inverse()
	local upperFrame = CFrame.new(origin)
		* orient(upperRest, ua.Position, ub.Position, mid - origin)
		* CFrame.new(-ua.Position)
	local lowerRest = upperFrame * elbow.C0 * elbow.C1:Inverse()
	local lowerFrame = CFrame.new(mid)
		* orient(lowerRest, la.Position, lb.Position, endPoint - mid)
		* CFrame.new(-la.Position)
	for _, joint in { shoulder, elbow, wrist } do
		d.posed[joint] = joint.Transform
	end
	shoulder.Transform = shoulder.C0:Inverse() * torsoFrame:Inverse() * upperFrame * shoulder.C1
	elbow.Transform = elbow.C0:Inverse() * upperFrame:Inverse() * lowerFrame * elbow.C1
	wrist.Transform = wrist.C0:Inverse() * lowerFrame:Inverse() * handFrame * wrist.C1
end
local function attachment(parent, name, cf)
	local a = Instance.new("Attachment")
	a.Name, a.CFrame, a.Parent = name, cf, parent
	return a
end
function D.Release(actor)
	local d = actor.drill
	if not d then
		return
	end
	restorePose(d)
	local hum = actor.character:FindFirstChildOfClass("Humanoid")
	if hum and d.autoRotate ~= nil then
		hum.AutoRotate = d.autoRotate
	end
	for _, ik in d.controls do
		ik.Enabled = false
		ik:Destroy()
	end
	for _, a in d.attachments do
		a:Destroy()
	end
	if d.rotor and d.rotor.Parent then
		d.rotor.Transform = CFrame.identity
	end
	actor.drill = nil
end
function D.Stop(actor)
	local d = actor.drill
	if not d then
		return
	end
	d.speed, d.drive = 0, 0
	local hum = actor.character:FindFirstChildOfClass("Humanoid")
	if hum and d.autoRotate ~= nil then
		hum.AutoRotate = d.autoRotate
		d.autoRotate = nil
	end
	if d.rotor and d.rotor.Parent then
		d.rotor.Transform = CFrame.identity
	end
end
function D.Attach(actor, tool)
	D.Release(actor)
	if not tool or tool:GetAttribute("ToolFamily") ~= "Drill" then
		return
	end
	local ch = actor.character
	local torso, hum = ch:FindFirstChild("UpperTorso"), ch:FindFirstChildOfClass("Humanoid")
	local d = {
		tool = tool,
		controls = {},
		attachments = {},
		speed = 0,
		angle = 0,
		rigidGrip = tool:GetAttribute("ToolVisualRevision") == "RodinDrill_20261111",
		drive = 0,
		rotor = tool:FindFirstChild("DrillRotor", true),
		torso = torso,
	}
	actor.drill = d
	if not torso or not hum then
		return
	end
	for _, side in { "Right", "Left" } do
		local upper, hand = ch:FindFirstChild(side .. "UpperArm"), ch:FindFirstChild(side .. "Hand")
		if upper and hand then
			local target = attachment(torso, "Drill" .. side .. "Target", CFrame.identity)
			local pole = attachment(
				torso,
				"Drill" .. side .. "Pole",
				CFrame.new(side == "Left" and -2 or 2, -0.45, 0.2)
			)
			local ik = Instance.new("IKControl")
			ik.Name = "VesperDrill" .. side
			ik.Type = (side == "Right" or tool:GetAttribute("ToolVisualRevision") == "RodinDrill_20261111")
					and Enum.IKControlType.Transform
				or Enum.IKControlType.Position
			ik.ChainRoot, ik.EndEffector, ik.Target, ik.Pole = upper, hand, target, pole
			ik.Priority, ik.SmoothTime, ik.Weight = 5, 0.055, 0
			ik.Enabled = false
			ik.Parent = hum
			table.insert(d.controls, ik)
			table.insert(d.attachments, target)
			table.insert(d.attachments, pole)
			local lower = ch:FindFirstChild(side .. "LowerArm")
			local shoulder = torso:FindFirstChild(side .. "ShoulderRigAttachment")
			local wrist = hand:FindFirstChild(side .. "WristRigAttachment")
			local reach
			if lower and upper:FindFirstChild(side .. "ElbowRigAttachment") then
				reach = (
					upper[side .. "ShoulderRigAttachment"].Position
					- upper[side .. "ElbowRigAttachment"].Position
				).Magnitude + (
					lower[side .. "ElbowRigAttachment"].Position
					- lower[side .. "WristRigAttachment"].Position
				).Magnitude
			end
			d[side] = {
				target = target,
				control = ik,
				grip = hand:FindFirstChild(side .. "GripAttachment"),
				shoulder = shoulder,
				wrist = wrist,
				reach = reach,
			}
		end
	end
end
function D.Update(actor, dt)
	local d = actor.drill
	if not d or not d.tool.Parent then
		return
	end
	-- Restore the Animator's prior pose before it evaluates this frame. Release
	-- uses the same path so neither elbow nor wrist remains in the drill brace.
	restorePose(d)
	local hum = actor.character:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then
		D.Release(actor)
		return
	end
	local now = os.clock()
	local phase = actor.phase
	local contact = actor.drillContact
	local liveContact = contact and now - contact.at < (contact.lease or 0.15)
	local spinning = actor.drillRunning and now < actor.drillRunning.untilTime
	local driving = liveContact
		or (phase and phase.kind == "Strike" and now <= phase.at + phase.duration + 0.08)
	local aim = actor.training and actor.trainingAim
		or liveContact and contact.point
		or spinning and actor.drillRunning.point
		or phase and phase.target
	local player = Players:GetPlayerFromCharacter(actor.character)
	local root = actor.character:FindFirstChild("HumanoidRootPart")
	if actor.training then
		-- The station owns facing and movement during practice.
		d.autoRotate = nil
	elseif player == Players.LocalPlayer and root then
		if driving and typeof(aim) == "Vector3" then
			if d.autoRotate == nil then
				d.autoRotate = hum.AutoRotate
			end
			hum.AutoRotate = false
			local flat = Vector3.new(aim.X, root.Position.Y, aim.Z) - root.Position
			if flat.Magnitude > 0.2 then
				local stance = d.rigidGrip and -math.rad(55) or 0
				root.CFrame = root.CFrame:Lerp(
					CFrame.lookAt(root.Position, root.Position + flat) * CFrame.Angles(0, stance, 0),
					1 - math.exp(-dt * 12)
				)
			end
		elseif d.autoRotate ~= nil then
			hum.AutoRotate = d.autoRotate
			d.autoRotate = nil
		end
	end
	local requested = actor.training and (actor.trainingPressure or 0) or driving and 1 or 0
	d.drive += (requested - d.drive) * (1 - math.exp(-dt * (driving and 18 or 12)))
	local spin = requested > 0 and requested or spinning and 0.35 or 0
	if spin == 0 then
		d.speed = 0
	else
		d.speed += (spin * 65 - d.speed) * (1 - math.exp(-dt * 12))
	end
	local reduced = Players.LocalPlayer and Players.LocalPlayer:GetAttribute("ReducedMotion")
	d.angle = (d.angle + d.speed * dt * (reduced and 0.2 or 1)) % (math.pi * 2)
	if not d.torso then
		return
	end
	local scale = math.clamp(d.torso.Size.Y / 1.7, 0.7, 1.35)
	local holdOffset = d.tool:GetAttribute("HoldOffset") or Vector3.new(0.52, -0.56, -0.83)
	local pitch, yaw = 0, d.rigidGrip and math.rad(55) or 0
	if (driving or actor.training) and typeof(aim) == "Vector3" then
		local delta = d.torso.CFrame:PointToObjectSpace(aim)
			- (d.rigidGrip and holdOffset * scale or Vector3.new(0.52, 0.66, -0.95))
		pitch = math.clamp(math.atan2(delta.Y, math.sqrt(delta.X ^ 2 + delta.Z ^ 2)), -0.55, 0.55)
		yaw = math.clamp(
			math.atan2(-delta.X, -delta.Z),
			d.rigidGrip and math.rad(20) or -0.65,
			d.rigidGrip and math.rad(80) or 0.65
		)
	end
	local vibration = reduced and 0 or math.sin(now * 71) * 0.006 * d.drive
	-- Lowering the bit lowers the auxiliary grip even further. Lift the rear
	-- frame with that pitch so the support arm stays bent and within reach.
	local aimLift = d.rigidGrip and math.max(0, -math.sin(pitch)) * 2 or 0
	local handleFrame = CFrame.new(
		(holdOffset + Vector3.new(0, 0.06 * d.drive + aimLift, -0.12 * d.drive)) * scale
	) * (d.rigidGrip and CFrame.Angles(0, yaw, 0) * CFrame.Angles(pitch, 0, vibration) or CFrame.Angles(
		pitch - math.rad(10) * (1 - d.drive),
		yaw,
		vibration
	))
	local handle = d.tool:FindFirstChild("Handle")
	local support = handle and handle:FindFirstChild("SupportGrip")
	local hand = actor.character:FindFirstChild("RightHand") or actor.character:FindFirstChild("Right Arm")
	local rightGrip = hand and hand:FindFirstChild("RightGrip")
	local function handFrame(side, data, frame)
		if side == "Right" and rightGrip and rightGrip:IsA("JointInstance") and rightGrip.Part1 == handle then
			return frame * rightGrip.C1 * rightGrip.C0:Inverse()
		end
		local grasp = side == "Right" and d.tool.Grip or support and support.CFrame
		return grasp and frame * grasp * data.grip.CFrame:Inverse()
	end
	-- Pull the entire rig toward the chest when avatar proportions or aiming
	-- would otherwise overextend an arm; both hands keep the same contact frame.
	for _ = 1, 6 do
		-- The Rodin brace stays in front of the chest; never resolve reach by
		-- drawing its rear handle through the torso.
		if d.rigidGrip then
			break
		end
		local reachable = true
		for side, data in { Right = d.Right, Left = d.Left } do
			local contact = side == "Right" and d.tool.Grip or support and support.CFrame
			if data and data.grip and data.reach and data.shoulder and data.wrist and contact then
				local wristFrame = handFrame(side, data, handleFrame) * data.wrist.CFrame
				if (wristFrame.Position - data.shoulder.Position).Magnitude > data.reach * 0.97 then
					reachable = false
				end
			end
		end
		if reachable then
			break
		end
		handleFrame += Vector3.new(0, 0.015, 0.075) * scale
	end
	local blend = math.clamp((now - actor.equippedAt) / 0.2, 0, 1)
	d.handleFrame = handleFrame
	for side, data in { Right = d.Right, Left = d.Left } do
		if data and data.grip then
			local contact = side == "Right" and d.tool.Grip or support and support.CFrame
			if contact then
				data.target.CFrame = handFrame(side, data, handleFrame)
				data.control.Weight = blend
				data.control.Enabled = blend > 0.001 and not d.rigidGrip
			end
		end
	end
end
function D.Apply(actor)
	local d = actor.drill
	if not d then
		return
	end
	if d.rigidGrip and d.torso and d.handleFrame then
		local waist = actor.joints.Waist
		local torsoFrame = waist and waist.Part0.CFrame * waist.C0 * waist.Transform * waist.C1:Inverse()
			or d.torso.CFrame
		local handleFrame = torsoFrame * d.handleFrame
		local hand = actor.character:FindFirstChild("RightHand")
		local grip = hand and hand:FindFirstChild("RightGrip")
		local support = d.tool.Handle:FindFirstChild("SupportGrip")
		if grip and grip:IsA("JointInstance") then
			solveArm(d, actor.character, "Right", torsoFrame, handleFrame * grip.C1 * grip.C0:Inverse())
		end
		if support and d.Left and d.Left.grip then
			solveArm(
				d,
				actor.character,
				"Left",
				torsoFrame,
				handleFrame * support.CFrame * d.Left.grip.CFrame:Inverse()
			)
		end
	end
	if d.rotor and d.rotor.Parent then
		d.rotor.Transform = CFrame.Angles(0, 0, -d.angle)
	end
	-- R6 has no elbow chain. Use a restrained two-arm brace instead of R15 IK.
	if not d.torso then
		local right, left = actor.joints["Right Shoulder"], actor.joints["Left Shoulder"]
		if right then
			right.Transform = CFrame.Angles(0, math.rad(-8), math.rad(82))
		end
		if left then
			left.Transform = CFrame.Angles(0, math.rad(12), math.rad(-67))
		end
	end
end
return D
