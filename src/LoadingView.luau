-- Full-screen 3D title scene. No entry card, marketing copy, or extra start gate.
local V = {}
function V.Build(parent)
	local Run = game:GetService("RunService")
	local Tween = game:GetService("TweenService")
	local gui = Instance.new("ScreenGui")
	gui.Name, gui.DisplayOrder, gui.ResetOnSpawn = "LabEntry", 1000, false
	gui.IgnoreGuiInset = true
	local canvas = Instance.new("CanvasGroup")
	canvas.Name, canvas.Size = "Cinema", UDim2.fromScale(1, 1)
	canvas.BackgroundColor3, canvas.BorderSizePixel = Color3.fromRGB(8, 15, 26), 0
	canvas.Active, canvas.Parent = true, gui
	local view = Instance.new("ViewportFrame")
	view.Name, view.Size, view.BackgroundTransparency = "EggStage", UDim2.fromScale(1, 1), 1
	view.Ambient = Color3.fromRGB(100, 137, 169)
	view.LightColor = Color3.fromRGB(255, 225, 169)
	view.LightDirection = Vector3.new(-0.5, -0.7, -1)
	view.Parent = canvas
	local camera = Instance.new("Camera")
	camera.FieldOfView, camera.Parent = 42, view
	view.CurrentCamera = camera
	local scene = script.Parent:FindFirstChild("EntryScene")
	if scene then
		local world = Instance.new("WorldModel")
		world.Parent = view
		scene:Clone().Parent = world
	end
	local function label(name, value, size, color)
		local t = Instance.new("TextLabel")
		t.Name, t.Text, t.TextSize = name, value, size
		t.BackgroundTransparency = 1
		t.TextColor3 = color
		t.Font = Enum.Font.GothamBlack
		t.TextXAlignment = Enum.TextXAlignment.Left
		t.Parent = canvas
		return t
	end
	local title = label("Title", "VESPER", 74, Color3.fromRGB(245, 248, 255))
	title.TextStrokeTransparency, title.TextStrokeColor3 = 0.5, Color3.fromRGB(8, 15, 26)
	local subtitle = label("Subtitle", "E X C A V A T I O N", 15, Color3.fromRGB(115, 233, 228))
	local bottom = Instance.new("Frame")
	bottom.Name, bottom.Size, bottom.Position =
		"LoadingStrip", UDim2.new(1, 0, 0, 112), UDim2.new(0, 0, 1, -112)
	bottom.BackgroundColor3, bottom.BackgroundTransparency, bottom.BorderSizePixel =
		Color3.fromRGB(8, 15, 26), 0.12, 0
	bottom.Parent = canvas
	local status = label("Status", "Preparing your expedition...", 14, Color3.fromRGB(211, 226, 238))
	status.Font = Enum.Font.GothamMedium
	status.TextWrapped = true
	local phase = label("Phase", "CONNECTING", 11, Color3.fromRGB(115, 233, 228))
	phase.TextXAlignment = Enum.TextXAlignment.Right
	local track = Instance.new("Frame")
	track.Name, track.BackgroundColor3, track.BorderSizePixel = "Track", Color3.fromRGB(39, 56, 73), 0
	track.Parent = canvas
	local fill = Instance.new("Frame")
	fill.Name, fill.Size, fill.BorderSizePixel = "Fill", UDim2.fromScale(0.04, 1), 0
	fill.BackgroundColor3, fill.Parent = Color3.fromRGB(115, 233, 228), track
	local enter = Instance.new("TextButton")
	enter.Name, enter.Text, enter.Visible = "Enter", "", false
	enter.Size, enter.Position = UDim2.fromOffset(160, 44), UDim2.new(1, -192, 1, -100)
	enter.BackgroundTransparency = 1
	enter.TextColor3, enter.Font, enter.TextSize = Color3.fromRGB(255, 211, 127), Enum.Font.GothamBold, 14
	enter.Parent = canvas
	enter:GetPropertyChangedSignal("Text"):Connect(function()
		enter.Visible = enter.Text == "RETRY LOADING"
	end)
	local alive, viewport = true, Vector2.new(1280, 720)
	local started = os.clock()
	local connection = Run.RenderStepped:Connect(function()
		if not alive then
			return
		end
		local player = game.Players.LocalPlayer
		local reduced = player and player:GetAttribute("ReducedMotion")
		local time = os.clock() - started
		local angle = -0.10 + (reduced and 0 or math.sin(time * 0.12) * 0.045)
		local portrait = viewport.X < viewport.Y
		local radius = portrait and 245 or 175
		camera.CFrame = CFrame.lookAt(
			Vector3.new(
				math.sin(angle) * radius,
				66 + (reduced and 0 or math.sin(time * 0.16) * 1.2),
				math.cos(angle) * radius
			),
			Vector3.new(0, 37, 0)
		)
	end)
	gui.Destroying:Connect(function()
		alive = false
		connection:Disconnect()
	end)
	local api = { gui = gui, status = status, enter = enter }
	local progressTween
	function api:Stage(current)
		phase.Text = ({ "CONNECTING", "PREPARING WORLD", "LOADING ASSETS", "READY" })[current] or ""
		if progressTween then
			progressTween:Cancel()
		end
		progressTween = Tween:Create(
			fill,
			TweenInfo.new(0.35, Enum.EasingStyle.Quad),
			{ Size = UDim2.fromScale(({ 0.08, 0.25, 0.55, 1 })[current] or 0, 1) }
		)
		progressTween:Play()
	end
	function api:Resize(size)
		if viewport == size and title.Size.X.Scale ~= 0 then
			return
		end
		viewport = size
		local small = size.X < 650
		local margin = small and 24 or 48
		title.Position, title.Size =
			UDim2.fromOffset(margin, small and 38 or 46), UDim2.new(1, -margin * 2, 0, 86)
		title.TextSize = small and 52 or 74
		subtitle.Position, subtitle.Size =
			UDim2.fromOffset(margin + 3, small and 112 or 132), UDim2.new(1, -margin * 2, 0, 24)
		status.Position, status.Size = UDim2.new(0, margin, 1, -93), UDim2.new(0.72, -margin, 0, 40)
		phase.Position, phase.Size = UDim2.new(0.72, 0, 1, -86), UDim2.new(0.28, -margin, 0, 24)
		phase.TextSize = small and 9 or 11
		phase.Visible = not enter.Visible
		enter.Position = UDim2.new(1, -160 - margin, 1, -94)
		status.Size = enter.Visible and UDim2.new(1, -184 - margin * 2, 0, 40)
			or UDim2.new(0.72, -margin, 0, 40)
		track.Position, track.Size = UDim2.new(0, margin, 1, -37), UDim2.new(1, -margin * 2, 0, 4)
	end
	enter:GetPropertyChangedSignal("Visible"):Connect(function()
		local size = viewport
		viewport = Vector2.zero
		api:Resize(size)
	end)
	function api:Exit()
		phase.Text = "ENTERING THE LAB"
		local fade =
			Tween:Create(canvas, TweenInfo.new(0.65, Enum.EasingStyle.Quad), { GroupTransparency = 1 })
		fade:Play()
		fade.Completed:Wait()
	end
	gui.Parent = parent
	api:Resize(workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or viewport)
	api:Stage(1)
	return api
end
return V
