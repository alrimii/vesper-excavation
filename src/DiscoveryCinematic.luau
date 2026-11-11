local M = {}
function M.Start(player, entry, revealedAt)
	if player:GetAttribute("DiscoveryCinematic") then
		return
	end
	local Run = game:GetService("RunService")
	local CAS = game:GetService("ContextActionService")
	local camera = workspace.CurrentCamera
	local character = player.Character
	local hud = player.PlayerGui:FindFirstChild("ExcavationHUD")
	local hudWasEnabled = hud and hud.Enabled
	local state = game.ReplicatedStorage.VesperShared.RoundState
	local round = state:GetAttribute("RoundId")
	local K = require(game.ReplicatedStorage.VesperShared.InterfaceKit)
	K.CloseAll()
	local gui = K.Make(
		"ScreenGui",
		player.PlayerGui,
		{
			Name = "DiscoveryReveal",
			DisplayOrder = 200,
			ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets,
			ResetOnSpawn = false,
		}
	)
	local card = K.Surface(gui, "DiscoveryCaption", K.Dark)
	card.AnchorPoint = Vector2.new(0.5, 1)
	card.Position = UDim2.new(0.5, 0, 1, -24)
	card.Size = UDim2.new(1, -32, 0, 134)
	K.Make("UISizeConstraint", card, { MaxSize = Vector2.new(620, 134) })
	local header = K.Text(card, "Header", "LIFEFORM IDENTIFIED", 12, K.Gold, true)
	header.Position = UDim2.fromOffset(20, 12)
	header.Size = UDim2.new(1, -40, 0, 20)
	local name = K.Text(card, "Name", entry.Name, 32, K.Paper)
	name.Font = K.Title
	name.Position = UDim2.fromOffset(20, 36)
	name.Size = UDim2.new(1, -40, 0, 44)
	local desc = K.Text(card, "Description", entry.Description, 15, K.Line)
	desc.Position = UDim2.fromOffset(20, 84)
	desc.Size = UDim2.new(1, -40, 0, 40)
	local oldType, oldCF, oldFov = camera.CameraType, camera.CFrame, camera.FieldOfView
	player:SetAttribute("DiscoveryCinematic", true)
	if hud then
		hud.Enabled = false
	end
	CAS:BindActionAtPriority(
		"DiscoveryRevealLock",
		function()
			return Enum.ContextActionResult.Sink
		end,
		false,
		5000,
		Enum.KeyCode.W,
		Enum.KeyCode.A,
		Enum.KeyCode.S,
		Enum.KeyCode.D,
		Enum.KeyCode.Space,
		Enum.KeyCode.E,
		Enum.KeyCode.ButtonR2,
		Enum.KeyCode.Thumbstick1
	)
	game.ReplicatedStorage.VesperShared.Remotes.Action:FireServer("Cancel")
	local started = revealedAt or workspace:GetServerTimeNow()
	local finished = false
	local function finish()
		if finished then
			return
		end
		finished = true
		Run:UnbindFromRenderStep("DiscoveryRevealCamera")
		CAS:UnbindAction("DiscoveryRevealLock")
		player:SetAttribute("DiscoveryCinematic", false)
		if camera == workspace.CurrentCamera then
			camera.CameraType = player.Character == character and oldType or Enum.CameraType.Custom
			if player.Character == character then
				camera.CFrame = oldCF
			end
			camera.FieldOfView = oldFov
			local current = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
			if current then
				camera.CameraSubject = current
			end
		end
		if hud then
			hud.Enabled = hudWasEnabled
		end
		gui:Destroy()
	end
	camera.CameraType = Enum.CameraType.Scriptable
	Run:BindToRenderStep("DiscoveryRevealCamera", Enum.RenderPriority.Camera.Value + 2, function()
		local t = math.max(0, workspace:GetServerTimeNow() - started)
		local hum = character and character:FindFirstChildOfClass("Humanoid")
		if
			t >= 7.5
			or player.Character ~= character
			or not hum
			or hum.Health <= 0
			or state:GetAttribute("RoundId") ~= round
			or state:GetAttribute("Status") ~= "Revealed"
		then
			finish()
			return
		end
		local reduced = player:GetAttribute("ReducedMotion")
		local angle = -0.45 + (reduced and 0 or t * 0.075)
		local portrait = camera.ViewportSize.X < camera.ViewportSize.Y
		local radius = portrait and 110 or 90
		local pos = Vector3.new(math.sin(angle) * radius, 47, -math.cos(angle) * radius)
		local shot = CFrame.lookAt(pos, Vector3.new(0, 43.4, 0))
		local blend = math.clamp(t / 0.45, 0, 1)
		camera.CFrame = reduced and shot or oldCF:Lerp(shot, blend * blend * (3 - 2 * blend))
		camera.FieldOfView = portrait and 72 or 58
	end)
end
return M
