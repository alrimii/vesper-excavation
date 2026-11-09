assert(not game:GetService("RunService"):IsRunning(), "Restore in Edit mode")
local package = workspace:FindFirstChild("VesperCurrent")
assert(package, "Insert VesperCurrent.rbxm into Workspace first")
for _, item in package:GetChildren() do
	local path = item:GetAttribute("ReleaseRestorePath")
	assert(type(path) == "string", "Snapshot entry is missing its restore path")
	local names = string.split(path, ".")
	local parent = game:GetService(names[1])
	for i = 2, #names - 1 do
		parent = assert(parent:FindFirstChild(names[i]), "Missing restore container: " .. names[i])
	end
	local previous = parent:FindFirstChild(names[#names])
	if previous then previous:Destroy() end
	item.Parent = parent
end
package:Destroy()
game.Lighting.Brightness = 2
game.Lighting.ExposureCompensation = 0.2
game.Lighting.Ambient = Color3.new(0.43921569,0.50980395,0.60392159)
game.Lighting.OutdoorAmbient = Color3.new(0.52941179,0.59607846,0.67843139)
game.Lighting.ClockTime = 14
game.Lighting.GeographicLatitude = 0
game.Lighting.EnvironmentDiffuseScale = 0.7
game.Lighting.EnvironmentSpecularScale = 0.48
game.Lighting.GlobalShadows = true
game.Lighting.ShadowSoftness = 0.2
game.Lighting.LightingStyle = Enum.LightingStyle.Soft
game.Lighting.PrioritizeLightingQuality = true
game.StarterPlayer.CameraMinZoomDistance = 0.5
game.StarterPlayer.CameraMaxZoomDistance = 40
game.StarterPlayer.CharacterWalkSpeed = 16
game.StarterPlayer.CharacterJumpPower = 50
game.StarterPlayer.CharacterUseJumpPower = false
game.StarterPlayer.EnableMouseLockOption = false
workspace.Gravity = 196.2
workspace.StreamingEnabled = false
print("Vesper snapshot restored. Save as a new place file.")
