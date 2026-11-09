local FX = {}
function FX.Start()
	local Tween = game:GetService("TweenService")
	local Debris = game:GetService("Debris")
	local player = game:GetService("Players").LocalPlayer
	local live = 0
	local folder = Instance.new("Folder")
	folder.Name = "LocalImpactFX"
	folder.Parent = workspace
	local function emit(position, color, heavy)
		local camera = workspace.CurrentCamera
		if not camera or (camera.CFrame.Position - position).Magnitude > 95 or live >= 12 then
			return
		end
		live += 1
		local anchor = Instance.new("Part")
		anchor.Size = Vector3.one * 0.1
		anchor.Position = position
		anchor.Transparency = 1
		anchor.Anchored = true
		anchor.CanCollide, anchor.CanTouch, anchor.CanQuery = false, false, false
		anchor.Parent = folder
		local dust = Instance.new("ParticleEmitter")
		dust.Texture = "rbxasset://textures/particles/smoke_main.dds"
		dust.Color = ColorSequence.new(color)
		dust.Lifetime = NumberRange.new(0.22, 0.55)
		dust.Speed = NumberRange.new(2, heavy and 12 or 6)
		dust.SpreadAngle = Vector2.new(180, 180)
		dust.Drag = 6
		dust.Rate = 0
		dust.LightInfluence = 0.7
		dust.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3),
			NumberSequenceKeypoint.new(0.4, heavy and 2.4 or 1.1),
			NumberSequenceKeypoint.new(1, 0),
		})
		dust.Transparency =
			NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(1, 1) })
		dust.Parent = anchor
		dust:Emit(player:GetAttribute("ReducedMotion") and 2 or heavy and 20 or 7)
		if not player:GetAttribute("ReducedMotion") then
			for i = 1, heavy and 9 or 4 do
				local chip = Instance.new("Part")
				chip.Size = Vector3.new(0.12, 0.08, 0.22) * (heavy and 2 or 1)
				chip.Color = color
				chip.Material = Enum.Material.SmoothPlastic
				chip.Anchored = true
				chip.CanCollide = false
				chip.CanQuery = false
				chip.CanTouch = false
				chip.CFrame = CFrame.new(position)
				chip.Parent = folder
				local offset = Vector3.new(math.cos(i * 2.4) * 1.5, 0.5 + i * 0.15, math.sin(i * 2.4) * 1.5)
				Tween
					:Create(
						chip,
						TweenInfo.new(0.38, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ CFrame = CFrame.new(position + offset) * CFrame.Angles(i, i * 0.4, 0), Transparency = 1 }
					)
					:Play()
				Debris:AddItem(chip, 0.4)
			end
		end
		Debris:AddItem(anchor, 1)
		task.delay(1, function()
			live -= 1
		end)
	end
	return { Emit = emit }
end
return FX
