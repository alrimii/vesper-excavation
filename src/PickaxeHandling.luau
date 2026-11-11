-- Short, rigid-grip contact pose using the avatar's real two-bone arm lengths.
-- Cosmetic only: eligibility, reach and damage remain server-owned.
local P = {}
function P.Release(actor)
	actor.pickHandling = nil
end
function P.Update(actor)
	local phase, tool, ch = actor.phase, actor.tool, actor.character
	local hum = ch:FindFirstChildOfClass("Humanoid")
	if not tool or tool:GetAttribute("ToolFamily") ~= "Pickaxe" or not hum or hum.Health <= 0 then
		P.Release(actor)
		return
	end
	local p = actor.pickHandling or {}
	actor.pickHandling = p
	p.weight = 0
	if phase and phase.kind == "Strike" and phase.target and not phase.missed then
		local t = math.clamp((os.clock() - phase.at) / phase.duration, 0, 1)
		local w = math.clamp(math.min((t - 0.28) / 0.12, (0.70 - t) / 0.12), 0, 1)
		p.weight, p.target = w * w * (3 - 2 * w), phase.target
	end
end
local function orient(part, from, to, start)
	local a, b = part.CFrame:VectorToWorldSpace(to - from).Unit, start.Unit
	local axis = a:Cross(b)
	local rotation = axis.Magnitude > 1e-5
			and CFrame.fromAxisAngle(axis.Unit, math.acos(math.clamp(a:Dot(b), -1, 1)))
		or CFrame.identity
	return rotation * part.CFrame.Rotation
end
function P.Apply(actor)
	local p, ch = actor.pickHandling, actor.character
	if not p or p.weight <= 0 then
		return
	end
	local upper, lower, hand, torso =
		ch:FindFirstChild("RightUpperArm"),
		ch:FindFirstChild("RightLowerArm"),
		ch:FindFirstChild("RightHand"),
		ch:FindFirstChild("UpperTorso")
	local shoulder, elbow, wrist =
		actor.joints.RightShoulder, actor.joints.RightElbow, actor.joints.RightWrist
	local tip = actor.tool and actor.tool:FindFirstChild("StrikeTip", true)
	local grip = hand and hand:FindFirstChild("RightGrip")
	if
		not upper
		or not lower
		or not hand
		or not torso
		or not shoulder
		or not elbow
		or not wrist
		or not tip
		or not grip
		or not grip:IsA("JointInstance")
	then
		return
	end
	local ua, ub =
		upper:FindFirstChild("RightShoulderRigAttachment"), upper:FindFirstChild("RightElbowRigAttachment")
	local la, lb, ha =
		lower:FindFirstChild("RightElbowRigAttachment"),
		lower:FindFirstChild("RightWristRigAttachment"),
		hand:FindFirstChild("RightWristRigAttachment")
	if not ua or not ub or not la or not lb or not ha then
		return
	end
	-- Joint transforms are applied as a batch after PreSimulation. Include the
	-- current authored waist pose instead of solving against last frame's torso.
	local waist = actor.joints.Waist
	local torsoFrame = waist and waist.Part0.CFrame * waist.C0 * waist.Transform * waist.C1:Inverse()
		or torso.CFrame
	local origin = (torsoFrame * shoulder.C0).Position
	local delta = p.target - origin
	if delta.Magnitude < 0.1 then
		return
	end
	local forward = delta.Unit
	local up = torsoFrame.UpVector
	up = up - forward * up:Dot(forward)
	if up.Magnitude < 0.01 then
		return
	end
	local localForward = tip.Position.Unit
	local localUp = Vector3.new(0, 0, 1):Cross(localForward).Unit
	local rotation = CFrame.fromMatrix(Vector3.zero, forward, up.Unit)
		* CFrame.fromMatrix(Vector3.zero, localForward, localUp):Inverse()
	local handle = CFrame.new(p.target) * rotation * CFrame.new(-tip.Position)
	local handFrame = handle * grip.C1 * grip.C0:Inverse()
	local endPoint = (handFrame * ha.CFrame).Position
	local length1, length2 = (ub.Position - ua.Position).Magnitude, (lb.Position - la.Position).Magnitude
	local direction = endPoint - origin
	local distance = direction.Magnitude
	-- Far targets retain the authored swing: never stretch or move the avatar.
	if distance >= length1 + length2 or distance <= math.abs(length1 - length2) + 0.001 then
		return
	end
	direction = direction.Unit
	local pole = torsoFrame.RightVector
	pole = pole - direction * pole:Dot(direction)
	if pole.Magnitude < 0.01 then
		return
	end
	local along = (length1 * length1 - length2 * length2 + distance * distance) / (2 * distance)
	local bend = math.sqrt(math.max(0, length1 * length1 - along * along))
	local mid = origin + direction * along + pole.Unit * bend
	local upperFrame = CFrame.new(origin)
		* orient(upper, ua.Position, ub.Position, mid - origin)
		* CFrame.new(-ua.Position)
	local lowerFrame = CFrame.new(mid)
		* orient(lower, la.Position, lb.Position, endPoint - mid)
		* CFrame.new(-la.Position)
	local function pose(joint, parentFrame, childFrame)
		local target = joint.C0:Inverse() * parentFrame:Inverse() * childFrame * joint.C1
		joint.Transform = joint.Transform:Lerp(target, p.weight)
	end
	pose(shoulder, torsoFrame, upperFrame)
	pose(elbow, upperFrame, lowerFrame)
	pose(wrist, lowerFrame, handFrame)
end
return P
