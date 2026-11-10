-- Pure client presentation. No remotes, player records, gameplay or server updates.
local RunService = game:GetService("RunService")
local Config = require(
	game:GetService("ReplicatedStorage"):WaitForChild("VesperShared"):WaitForChild("ExteriorAtmosphereConfig")
)
local exterior = workspace:WaitForChild("VesperLab"):WaitForChild("DecorativeExterior")
local elapsed = 0
local connection
connection = RunService.Heartbeat:Connect(function(dt)
	elapsed += dt
	if elapsed < 0.1 then
		return
	end
	elapsed = 0
	local mist = exterior:FindFirstChild("ValleyMist")
	if not mist then
		return
	end
	local t = workspace:GetServerTimeNow()
	for _, host in mist:GetChildren() do
		local i = host:GetAttribute("RibbonIndex")
		local d = i and Config.Ribbons[i]
		local beam = host:FindFirstChild("DriftingMist")
		if not d or not beam then
			continue
		end
		-- Continuous, nonwrapping movement with independent slow shape/density phases.
		-- Texture advection supplies the prevailing drift; no spawning or resets.
		local phase = t * (0.035 + i * 0.0013) + i * 1.7
		local drift =
			Vector3.new(math.sin(phase) * 17, math.sin(phase * 0.71) * 3, math.sin(phase * 0.83 + 1) * 8)
		host.MistStart.Position = -d[2] + drift + Vector3.new(0, math.sin(phase + 0.8) * 4, 0)
		host.MistEnd.Position = d[2] + drift + Vector3.new(0, math.sin(phase + 2.3) * 5, 0)
		beam.Width0 = d[3] * (1 + 0.09 * math.sin(phase * 0.93))
		beam.Width1 = d[3] * (0.86 + 0.08 * math.sin(phase * 0.81 + 1))
		local opacity = math.clamp(d[4] * (1 + 0.10 * math.sin(phase * 0.67 + i)), 0, 0.92)
		beam.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.18, 1 - opacity * 0.72),
			NumberSequenceKeypoint.new(0.43, 1 - opacity),
			NumberSequenceKeypoint.new(0.70, 1 - opacity * 0.82),
			NumberSequenceKeypoint.new(1, 1),
		})
	end
end)
script.Destroying:Connect(function()
	connection:Disconnect()
end)
