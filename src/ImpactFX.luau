-- Only called after a unique server-confirmed impact. Cosmetic, no physics/rewards.
local FX = {}
function FX.Start()
	local Tween = game:GetService("TweenService")
	local Debris = game:GetService("Debris")
	local player = game:GetService("Players").LocalPlayer
	local live = 0
	local folder = Instance.new("Folder")
	folder.Name, folder.Parent = "LocalImpactFX", workspace
	local function emit(position, color, broken, normal, strong, family)
		local camera = workspace.CurrentCamera
		if not camera or (camera.CFrame.Position - position).Magnitude > 80 or live >= 8 then return end
		live += 1
		normal = typeof(normal) == "Vector3" and normal.Magnitude > 0.01 and normal.Unit or Vector3.yAxis
		local tangent = normal:Cross(math.abs(normal.Y) < 0.95 and Vector3.yAxis or Vector3.xAxis).Unit
		local bitangent = normal:Cross(tangent)
		local reduced = player:GetAttribute("ReducedMotion") == true
		local anchor = Instance.new("Part")
		anchor.Name, anchor.Size = "ConfirmedImpact", Vector3.one * 0.05
		anchor.CFrame = CFrame.lookAt(position + normal * 0.025, position + normal, tangent)
		anchor.Transparency, anchor.Anchored = 1, true
		anchor.CanCollide, anchor.CanTouch, anchor.CanQuery, anchor.CastShadow = false, false, false, false
		anchor.Parent = folder
		local dust = Instance.new("ParticleEmitter")
		dust.Texture = "rbxasset://textures/particles/smoke_main.dds"
		dust.Color = ColorSequence.new(color)
		dust.Lifetime = NumberRange.new(0.12, 0.3)
		dust.Speed = NumberRange.new(1, broken and 5 or 3)
		dust.EmissionDirection, dust.SpreadAngle = Enum.NormalId.Front, Vector2.new(45, 45)
		dust.Drag, dust.Rate, dust.LightInfluence = 7, 0, 1
		dust.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.12),
			NumberSequenceKeypoint.new(0.4, broken and 0.75 or 0.4), NumberSequenceKeypoint.new(1, 0) })
		dust.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.55), NumberSequenceKeypoint.new(1, 1) })
		dust.Parent = anchor
		dust:Emit(reduced and 1 or broken and 6 or family == "Drill" and 1 or strong and 4 or 2)
		if not reduced and (family ~= "Drill" or broken) then
			for i = 1, broken and 5 or strong and 3 or 2 do
				local chip = Instance.new("Part")
				chip.Name, chip.Size = "ImpactChip", Vector3.new(0.09, 0.06, 0.16)
				chip.Color, chip.Material = color, Enum.Material.SmoothPlastic
				chip.Anchored, chip.CastShadow = true, false
				chip.CanCollide, chip.CanQuery, chip.CanTouch = false, false, false
				chip.CFrame, chip.Parent = anchor.CFrame, folder
				local spread = broken and 0.85 or 0.45
				local offset = normal * (0.35 + i * 0.08)
					+ (tangent * math.cos(i * 2.4) + bitangent * math.sin(i * 2.4)) * spread
				Tween:Create(chip, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ CFrame = CFrame.new(position + offset) * CFrame.Angles(i, i * 0.4, 0), Transparency = 1 }):Play()
				Debris:AddItem(chip, 0.3)
			end
		end
		Debris:AddItem(anchor, 0.4)
		task.delay(0.4, function() live -= 1 end)
	end
	return { Emit = emit }
end
return FX
