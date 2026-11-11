-- Cosmetic screen geometry and server-clock countdown; no authority or damage.
local M = {}
M.BackContact = Vector3.new(0.553454, 0.245960, 0.368089)
M.ScreenCenter = Vector3.new(0.5525, 0.306, -0.30685)
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
	text.Font, text.TextScaled = Enum.Font.Code, true
	text.TextColor3, text.Text = Color3.fromRGB(90, 249, 248), "--"
	text.Parent = gui
	return screen
end
local started = false
function M.Start()
	if started then
		return
	end
	started = true
	local folder = workspace:WaitForChild("PlacedExcavationCharges")
	game:GetService("RunService").RenderStepped:Connect(function()
		local now = workspace:GetServerTimeNow()
		for _, model in folder:GetChildren() do
			local deadline = model:GetAttribute("DetonatesAt")
			local screen = model:FindFirstChild("ChargeScreen")
			local gui = screen and screen:FindFirstChild("CountdownScreen")
			local digits = gui and gui:FindFirstChild("Digits")
			if deadline and digits then
				digits.Text = string.format("%.2f", math.max(0, deadline - now))
				model:SetAttribute("DisplayedCountdown", digits.Text)
			end
		end
	end)
end
return M
