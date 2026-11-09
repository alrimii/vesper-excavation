local M = {}
function M.Start(player, entry)
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
	local gui = Instance.new("ScreenGui")
	gui.Name = "DiscoveryReveal"
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 200
	gui.Parent = player.PlayerGui
	local function text(name, value, y, size, color)
		local t = Instance.new("TextLabel")
		t.Name = name
		t.Size = UDim2.new(0.9, 0, 0, size + 14)
		t.Position = UDim2.fromScale(0.05, y)
		t.BackgroundTransparency = 1
		t.Text = value
		t.TextSize = size
		t.Font = Enum.Font.GothamBold
		t.TextColor3 = color
		t.TextWrapped = true
		t.Parent = gui
		return t
	end
	for _, y in { 0, 0.83 } do
		local bar = Instance.new("Frame")
		bar.Size = UDim2.fromScale(1, 0.17)
		bar.Position = UDim2.fromScale(0, y)
		bar.BackgroundColor3 = Color3.fromRGB(6, 13, 23)
		bar.BackgroundTransparency = 0.1
		bar.BorderSizePixel = 0
		bar.Parent = gui
	end
	text("Header", "LIFEFORM IDENTIFIED", 0.045, 15, entry.Color)
	text("Name", entry.Name, 0.85, 30, Color3.fromRGB(242, 248, 255))
	text("Description", entry.Description, 0.92, 13, entry.Color)
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
	local started = os.clock()
	local finished = false
	local function finish()
		if finished then
			return
		end
		finished = true
		Run:UnbindFromRenderStep("DiscoveryRevealCamera")
		CAS:UnbindAction("DiscoveryRevealLock")
		player:SetAttribute("DiscoveryCinematic", false)
		camera.CameraType = oldType
		camera.CFrame = oldCF
		camera.FieldOfView = oldFov
		if hud then
			hud.Enabled = hudWasEnabled
		end
		gui:Destroy()
	end
	camera.CameraType = Enum.CameraType.Scriptable
	Run:BindToRenderStep("DiscoveryRevealCamera", Enum.RenderPriority.Camera.Value + 2, function()
		local t = os.clock() - started
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
