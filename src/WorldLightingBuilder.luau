-- Edit-only coordinated illumination; personal-room light recipe and all geometry remain unchanged.
local B = {}
function B.Build()
	assert(
		game.PlaceId == 94763223427049 and not game:GetService("RunService"):IsRunning(),
		"Original Edit place only"
	)
	local l = game.Lighting
	l.ClockTime = 16
	l.Brightness = 1.4
	l.ExposureCompensation = -0.10
	l.Ambient = Color3.fromRGB(128, 138, 132)
	l.OutdoorAmbient = Color3.fromRGB(155, 168, 161)
	l.EnvironmentDiffuseScale = 0.65
	l.EnvironmentSpecularScale = 0.12
	local count = 0
	for _, light in workspace.VesperLab:GetDescendants() do
		if light:IsA("SurfaceLight") then
			light.Brightness = 1.05
			light.Color = Color3.fromRGB(244, 228, 202)
			light.Shadows = false
			count += 1
		end
	end
	return { frontageTaskLights = count, roomPointLights = "Preserved", clockTime = l.ClockTime }
end
return B
