-- Sole membrane pose owner. Every sector follows the same pressure/release clock.
local M = {}
function M.Start(chamber, state)
	local player = game:GetService("Players").LocalPlayer
	local Phase = require(script.Parent.ExpeditionPhase)
	game:GetService("RunService").PreSimulation:Connect(function()
		local veil = chamber:FindFirstChild("HatchingVeil")
		if not veil or not veil:IsA("Model") then
			return
		end
		local status, started = Phase.Read(state)
		local now = workspace:GetServerTimeNow()
		local age = math.max(0, now - started)
		local reduced = player:GetAttribute("ReducedMotion")
		local opening = status == "Revealed"
		local seal = veil:FindFirstChild("Seal")
		if seal then
			local compression = reduced and 0 or (0.5 + 0.5 * math.sin(now * 1.1)) * 0.0015
			if status == "Hatching" then
				compression += 0.012 * math.sin(math.clamp(age / 2.2, 0, 1) * math.pi)
			end
			local center = veil:GetPivot().Position
			for _, skin in seal:GetChildren() do
				skin.LocalTransparencyModifier = (opening or status == "Selecting" or status == "Delivering")
						and 1
					or 0
				local rest = skin:GetAttribute("RestCFrame")
				skin.Size = skin:GetAttribute("RestSize") * (1 - compression)
				skin.CFrame = rest + (center - rest.Position) * compression
			end
		end
		for _, p in veil:GetChildren() do
			if p:IsA("BasePart") then
				if not opening then
					p.Transparency = 1
					continue
				end
				local t = math.clamp(age / 1.4, 0, 1)
				local ease = t * t * (3 - 2 * t)
				local angle = p:GetAttribute("Angle")
				local direction = Vector3.new(math.cos(angle), 0, math.sin(angle))
				local rest = p:GetAttribute("RestCFrame")
				local pivot = Vector3.new(direction.X * 22, 6, direction.Z * 22)
				local axis = Vector3.yAxis:Cross(direction)
				local motion = reduced and 0.15 or 1
				p.CFrame = CFrame.new(
					pivot + direction * (8 * ease * motion) - Vector3.yAxis * (5 * ease * motion)
				) * CFrame.fromAxisAngle(axis, ease * 0.65 * motion) * CFrame.new(-pivot) * rest
				p.Transparency = math.clamp((age - (reduced and 0 or 0.9)) / 1.1, 0, 1)
			end
		end
	end)
end
return M
