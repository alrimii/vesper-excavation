-- One continuous third-person view, using Roblox's native orbit and zoom controls.
local Camera = {}
function Camera.Start(player, gui, config)
	local Run = game:GetService("RunService")
	local settings = config.Camera
	local old = gui:FindFirstChild("AimMode")
	if old then
		old:Destroy()
	end
	player:SetAttribute("CenteredAim", nil)
	player.CameraMode = Enum.CameraMode.Classic
	player.CameraMinZoomDistance = settings.MinZoom
	player.CameraMaxZoomDistance = settings.MaxZoom
	local previousHumanoid
	local offset = Vector3.zero
	Run:BindToRenderStep("VesperExcavationCamera", Enum.RenderPriority.Camera.Value - 1, function(dt)
		local ch = player.Character
		local hum = ch and ch:FindFirstChildOfClass("Humanoid")
		local root = ch and ch:FindFirstChild("HumanoidRootPart")
		local camera = workspace.CurrentCamera
		if not camera or not hum or not root then
			return
		end
		if previousHumanoid ~= hum then
			previousHumanoid = hum
			offset = Vector3.zero
		end
		if player:GetAttribute("LabReady") ~= true or player:GetAttribute("DiscoveryCinematic") then
			return
		end
		-- Smooth in world space so character turns do not swing the camera sideways.
		local right = camera.CFrame.RightVector
		local desired = Vector3.new(right.X, 0, right.Z) * settings.Shoulder + Vector3.yAxis * settings.Height
		local alpha = 1 - math.exp(-settings.BlendSpeed * dt)
		offset = offset:Lerp(desired, alpha)
		hum.CameraOffset = root.CFrame:VectorToObjectSpace(offset)
		camera.FieldOfView += (settings.FieldOfView - camera.FieldOfView) * alpha
	end)
end
return Camera
