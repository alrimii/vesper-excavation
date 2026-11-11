-- Cosmetic screen geometry and server-clock countdown; no authority or damage.
local M = {}
M.BackContact = Vector3.new(0.553454, 0.245960, 0.368089)
M.ScreenCenter = Vector3.new(0.5525, 0.306, -0.30685)
-- Centers sampled along the supplied rope, tip to cap, in the tool's frame.
M.FusePath = {
	Vector3.new(0.5073, 1.018, 0.0712),
	Vector3.new(0.5131, 0.958, 0.0693),
	Vector3.new(0.5361, 0.9005, 0.0669),
	Vector3.new(0.5493, 0.847, 0.0740),
	Vector3.new(0.5748, 0.7756, 0.0873),
}
function M.AddScreen(tool)
	local screen = Instance.new("Part")
	screen.Name, screen.Size = "ChargeScreen", Vector3.new(0.391, 0.255, 0.005)
	screen.CFrame = tool.Handle.CFrame * CFrame.new(M.ScreenCenter)
	screen.Transparency, screen.Massless = 1, true
	screen.CanCollide, screen.CanTouch, screen.CanQuery, screen.CastShadow = false, false, false, false
	screen.Parent = tool
	local weld = Instance.new("WeldConstraint")
	weld.Name, weld.Part0, weld.Part1, weld.Parent = "ScreenMount", tool.Handle, screen, screen
	local gui = Instance.new("SurfaceGui")
	gui.Name, gui.Face = "CountdownScreen", Enum.NormalId.Front
	gui.CanvasSize, gui.LightInfluence = Vector2.new(400, 220), 0
	gui.AlwaysOnTop = false
	gui.Parent = screen
	local text = Instance.new("TextLabel")
	text.Name, text.Size = "Digits", UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.Font, text.TextScaled = Enum.Font.GothamBold, true
	text.Size, text.Position = UDim2.fromScale(0.9, 0.9), UDim2.fromScale(0.05, 0.05)
	text.TextColor3, text.Text = Color3.fromRGB(90, 249, 248), "--"
	text.Parent = gui
	return screen
end
local started = false
function M.Digit(remaining)
	-- Reserve the final 0.12s for a visible zero/warning, before the same deadline.
	return math.max(0, math.ceil(remaining - 0.12))
end
function M.Start()
	if started then
		return
	end
	started = true
	local folder = workspace:WaitForChild("PlacedExcavationCharges")
	local player = game.Players.LocalPlayer
	local C = require(script.Parent.ExcavationConfig)
	local active = {}
	local function remove(model)
		local item = active[model]
		if item then
			item.ember:Destroy() -- also removes emitters, light and both sounds
			active[model] = nil
		end
	end
	local function attach(model, digits, deadline)
		local ember = Instance.new("Part")
		ember.Name, ember.Shape, ember.Size = "BurningFuse", Enum.PartType.Ball, Vector3.one * 0.075
		ember.Material, ember.Color = Enum.Material.Neon, Color3.fromRGB(255, 164, 58)
		ember.Anchored, ember.CastShadow = true, false
		ember.CanCollide, ember.CanTouch, ember.CanQuery = false, false, false
		local function particles(name, texture, rate, color, size, life, speed)
			local e = Instance.new("ParticleEmitter")
			e.Name, e.Texture, e.Rate = name, texture, rate
			e.Color = ColorSequence.new(color)
			e.Size = size
			e.Lifetime, e.Speed = life, speed
			e.SpreadAngle = Vector2.new(25, 25)
			e.LightEmission = name == "FuseSmoke" and 0 or 0.7
			e.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, name == "FuseSmoke" and 0.72 or 0.15),
				NumberSequenceKeypoint.new(1, 1),
			})
			e.Parent = ember
		end
		particles(
			"FuseSparks",
			"rbxasset://textures/particles/sparkles_main.dds",
			12,
			Color3.fromRGB(255, 188, 78),
			NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.05), NumberSequenceKeypoint.new(1, 0) }),
			NumberRange.new(0.12, 0.25),
			NumberRange.new(1, 2.3)
		)
		particles(
			"FuseSmoke",
			"rbxasset://textures/particles/smoke_main.dds",
			3,
			Color3.fromRGB(169, 165, 153),
			NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.06), NumberSequenceKeypoint.new(1, 0.28) }),
			NumberRange.new(0.3, 0.55),
			NumberRange.new(0.25, 0.5)
		)
		local light = Instance.new("PointLight")
		light.Color, light.Brightness, light.Range, light.Shadows = ember.Color, 0.5, 1.8, false
		light.Parent = ember
		local function sound(name, id, gain)
			local s = Instance.new("Sound")
			s.Name, s.SoundId = name, id
			s.RollOffMinDistance, s.RollOffMaxDistance = C.MiningAudio.MinDistance, C.MiningAudio.MaxDistance
			s.RollOffMode = Enum.RollOffMode.InverseTapered
			s.Volume = gain * (player:GetAttribute("SFXVolume") or 1)
			s.Parent = ember
			return s
		end
		local ignition = sound("FuseIgnition", C.MiningAudio.ChargeIgnition, 0.13)
		local tick = sound("CountdownTick", C.MiningAudio.ChargeTick, 0.12)
		ember.CFrame = model:GetPivot() * CFrame.new(M.FusePath[1])
		ember.Parent = model
		local remaining = deadline - workspace:GetServerTimeNow()
		if remaining > C.Tools.Explosive.Fuse - 0.5 then
			ignition:Play()
		end
		local item = {
			ember = ember,
			light = light,
			ignition = ignition,
			tick = tick,
			digits = digits,
			deadline = deadline,
			ignitionUntil = workspace:GetServerTimeNow() + 0.55,
		}
		active[model] = item
		return item
	end
	folder.ChildRemoved:Connect(remove)
	game:GetService("RunService").RenderStepped:Connect(function()
		local now = workspace:GetServerTimeNow()
		for _, model in folder:GetChildren() do
			local deadline = model:GetAttribute("DetonatesAt")
			local screen = model:FindFirstChild("ChargeScreen")
			local gui = screen and screen:FindFirstChild("CountdownScreen")
			local digits = gui and gui:FindFirstChild("Digits")
			if type(deadline) == "number" and digits then
				local item = active[model] or attach(model, digits, deadline)
				local remaining = math.max(0, item.deadline - now)
				local digit = M.Digit(remaining)
				if item.lastDigit ~= digit then
					item.lastDigit = digit
					if remaining > 0 then
						item.tick:Play()
					end
				end
				digits.Text = tostring(digit)
				model:SetAttribute("DisplayedCountdown", digits.Text)
				local progress = math.clamp(1 - remaining / C.Tools.Explosive.Fuse, 0, 1) * (#M.FusePath - 1)
				local index = math.min(#M.FusePath - 1, math.floor(progress) + 1)
				local pos = M.FusePath[index]:Lerp(M.FusePath[index + 1], progress - (index - 1))
				item.ember.CFrame = model:GetPivot() * CFrame.new(pos)
				local warning = remaining <= 0.45
				local pulse = warning and (0.5 + 0.5 * math.sin(now * 24)) or 0
				digits.TextColor3 = warning and Color3.fromRGB(255, 172 + 65 * pulse, 75)
					or Color3.fromRGB(90, 249, 248)
				item.ember.Size = Vector3.one * (0.075 + pulse * 0.025)
				item.light.Brightness = 0.5 + pulse * 0.5
				local volume = player:GetAttribute("SFXVolume") or 1
				item.tick.Volume, item.ignition.Volume = 0.12 * volume, 0.13 * volume
				if now >= item.ignitionUntil then
					item.ignition:Stop()
				end
			end
		end
	end)
end
return M
