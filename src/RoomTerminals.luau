local M = {}
function M.Build(rooms)
	local entries = {}
	for _, room in rooms:GetChildren() do
		for _, terminal in room:GetChildren() do
			if terminal.Name ~= "Terminal" or not terminal:IsA("BasePart") then
				continue
			end
			local archive = room:GetPivot():PointToObjectSpace(terminal.Position).X < 0
			local page = archive and "ARCHIVE" or "ROOM"
			terminal:SetAttribute("RoomTerminalPage", page)
			local original = terminal:FindFirstChild("Display")
			if original and original:IsA("SurfaceGui") then
				original.Enabled = false
			end
			local display = terminal:FindFirstChild("RoomTerminalDisplay")
			if not display then
				display = Instance.new("SurfaceGui")
				display.Name = "RoomTerminalDisplay"
				display.Face = original and original.Face or Enum.NormalId.Front
				display.CanvasSize = Vector2.new(640, 400)
				display.LightInfluence, display.AlwaysOnTop = 0, false
				display.Parent = terminal
				local panel = Instance.new("Frame")
				panel.Name, panel.Size = "Panel", UDim2.fromScale(1, 1)
				panel.BackgroundColor3, panel.BorderSizePixel = Color3.fromRGB(12, 24, 34), 0
				panel.Parent = display
				local accent = archive and Color3.fromRGB(238, 188, 103) or Color3.fromRGB(113, 236, 210)
				local function label(name, y, height, value, size, color)
					local text = Instance.new("TextLabel")
					text.Name, text.Text, text.TextSize = name, value, size
					text.Position, text.Size = UDim2.fromOffset(36, y), UDim2.new(1, -72, 0, height)
					text.BackgroundTransparency, text.Font = 1, Enum.Font.GothamBold
					text.TextColor3, text.TextXAlignment, text.TextWrapped =
						color, Enum.TextXAlignment.Left, true
					text.Parent = panel
				end
				label(
					"Kicker",
					28,
					35,
					"PERSONAL LAB / " .. tostring(room:GetAttribute("RoomNumber")),
					23,
					accent
				)
				label(
					"Title",
					95,
					65,
					archive and "CREATURE ARCHIVE" or "ROOM STYLE",
					38,
					Color3.fromRGB(238, 246, 251)
				)
				label(
					"Purpose",
					178,
					90,
					archive and "Choose collection favorites\nActivate a mining companion"
						or "Choose your lighting theme\nPersonalize your laboratory",
					27,
					Color3.fromRGB(157, 180, 193)
				)
				label("Owner", 313, 60, "ROOM OWNER ACCESS", 24, accent)
			end
			local prompt = terminal:FindFirstChild("RoomTerminalPrompt")
			if not prompt then
				prompt = Instance.new("ProximityPrompt")
				prompt.Name = "RoomTerminalPrompt"
				prompt.ActionText = archive and "Manage collection" or "Customize room"
				prompt.ObjectText = archive and "Personal archive" or "Room style"
				prompt.KeyboardKeyCode = Enum.KeyCode.E
				prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
				prompt.HoldDuration, prompt.MaxActivationDistance = 0.2, 11
				prompt.RequiresLineOfSight = true
				prompt.Parent = terminal
			end
			table.insert(
				entries,
				{ room = room, terminal = terminal, prompt = prompt, page = page, display = display }
			)
		end
	end
	return entries
end
return M
