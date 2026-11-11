-- Brief contact correction for reachable targets. No movement, extended reach or damage.
local P = {}
function P.Release(actor)
	local p = actor.pickHandling
	if p then
		p.ik:Destroy()
		p.target:Destroy()
		p.pole:Destroy()
		actor.pickHandling = nil
	end
end
function P.Update(actor)
	local tool = actor.tool
	local phase = actor.phase
	local ch = actor.character
	local hum = ch:FindFirstChildOfClass("Humanoid")
	if not tool or tool:GetAttribute("ToolFamily") ~= "Pickaxe" or not hum or hum.Health <= 0 then
		P.Release(actor)
		return
	end
	local hand, upper, torso =
		ch:FindFirstChild("RightHand"), ch:FindFirstChild("RightUpperArm"), ch:FindFirstChild("UpperTorso")
	local grip = hand and hand:FindFirstChild("RightGripAttachment")
	local tip = tool:FindFirstChild("StrikeTip", true)
	if not hand or not upper or not torso or not grip or not tip then
		return
	end
	local p = actor.pickHandling
	if p and p.tool ~= tool then
		P.Release(actor)
		p = nil
	end
	if not p then
		local target = Instance.new("Attachment")
		target.Name = "PickContactTarget"
		target.Parent = torso
		local pole = Instance.new("Attachment")
		pole.Name = "PickElbowPole"
		pole.Position = Vector3.new(2, 0, -0.3)
		pole.Parent = torso
		local ik = Instance.new("IKControl")
		ik.Name = "VesperPickContact"
		ik.Type = Enum.IKControlType.Position
		ik.ChainRoot = upper
		ik.EndEffector = hand
		ik.Target = target
		ik.Pole = pole
		ik.Priority = 6
		ik.SmoothTime = 0.015
		ik.EndEffectorOffset = grip.CFrame * tool.Grip:Inverse() * tip.CFrame
		ik.Weight = 0
		ik.Enabled = false
		ik.Parent = hum
		p = { ik = ik, target = target, pole = pole, tool = tool }
		actor.pickHandling = p
	end
	local weight = 0
	if phase and phase.kind == "Strike" and phase.target and not phase.missed then
		local t = math.clamp((os.clock() - phase.at) / phase.duration, 0, 1)
		local reach = upper.Size.Y
			+ (ch:FindFirstChild("RightLowerArm") and ch.RightLowerArm.Size.Y or 1)
			+ tip.Position.Magnitude
		if (phase.target - upper.Position).Magnitude <= reach then
			weight = math.clamp(math.min((t - 0.28) / 0.12, (0.70 - t) / 0.12), 0, 1)
			weight = weight * weight * (3 - 2 * weight)
			p.target.WorldPosition = phase.target
		end
	end
	p.ik.Weight = weight
	p.ik.Enabled = weight > 0.001
end
return P
