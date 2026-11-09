-- Local, pooled landing dust. One burst per delivery; no physics or global lighting changes.
local M = {}
function M.new(parent)
	local root = Instance.new("Part")
	root.Name = "CradleLandingDust"
	root.Anchored = true
	root.Transparency = 1
	root.Size = Vector3.one
	root.CFrame = CFrame.new(0, 4.1, 0)
	root.CanCollide, root.CanTouch, root.CanQuery = false, false, false
	local emitters = {}
	for i = 0, 11 do
		local angle = i * math.pi / 6
		local radial = Vector3.new(math.cos(angle), 0, math.sin(angle))
		local attachment = Instance.new("Attachment")
		attachment.CFrame = CFrame.lookAt(radial * 32, radial * 40 + Vector3.yAxis * 1.2)
		attachment.Parent = root
		local dust = Instance.new("ParticleEmitter")
		dust.Name = "LandingPlume"
		dust.Texture = "rbxasset://textures/particles/smoke_main.dds"
		dust.Enabled = false
		dust.Rate = 0
		dust.EmissionDirection = Enum.NormalId.Front
		dust.Speed = NumberRange.new(10, 17)
		dust.Drag = 2.8
		dust.Acceleration = Vector3.new(0, 1.6, 0)
		dust.Lifetime = NumberRange.new(1.1, 1.8)
		dust.SpreadAngle = Vector2.new(16, 22)
		dust.Rotation = NumberRange.new(0, 360)
		dust.RotSpeed = NumberRange.new(-24, 24)
		dust.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 2),
			NumberSequenceKeypoint.new(0.3, 6),
			NumberSequenceKeypoint.new(1, 10),
		})
		dust.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.08, 0.55),
			NumberSequenceKeypoint.new(0.5, 0.78),
			NumberSequenceKeypoint.new(1, 1),
		})
		dust.Color = ColorSequence.new(Color3.fromRGB(186, 179, 164), Color3.fromRGB(122, 128, 136))
		dust.LightInfluence = 0.35
		dust.LightEmission = 0
		dust.Parent = attachment
		table.insert(emitters, dust)
	end
	root.Parent = parent
	local lastPhase, previousAge, emitted
	local api = {}
	function api:Update(status, started, age, reduced)
		if status ~= "Delivering" then
			lastPhase, previousAge, emitted = nil, nil, false
			return
		end
		if lastPhase ~= started then
			lastPhase, previousAge, emitted = started, age, age > 5.7
		end
		if not emitted and age >= 5.4 and previousAge <= 5.7 then
			emitted = true
			for _, emitter in emitters do
				emitter:Emit(reduced and 2 or 6)
			end
		end
		previousAge = age
	end
	return api
end
return M
