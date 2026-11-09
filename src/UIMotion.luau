-- Client-only presentation. Does not activate tools or send gameplay requests.
local Spring = require(script.Parent.Packages.spr)
local Input = game:GetService("UserInputService")
local UIMotion = {}

function UIMotion.Attach(gui, settings)
	local connections = {}
	local scales = {}
	local pressed = {}
	local alive = true
	local station = gui.Station
	local open = false
	local home = station.Position
	local function connect(signal, callback)
		table.insert(connections, signal:Connect(callback))
	end
	for _, button in gui:GetDescendants() do
		if not button:IsA("GuiButton") then
			continue
		end
		button.AutoButtonColor = false
		local scale = Instance.new("UIStroke")
		scale.Name = "InteractionMotion"
		scale.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		scale.Color = Color3.fromRGB(255, 219, 153)
		scale.Thickness = 1.5
		scale.Transparency = 1
		scale.Parent = button
		table.insert(scales, scale)
		local hovered, selected = false, false
		local lastAmount
		local function update()
			local amount = 1
			if button.Interactable and button.Active then
				amount = pressed[button] and 0 or ((hovered or selected) and 0.3 or 1)
			end
			if amount == lastAmount then
				return
			end
			lastAmount = amount
			Spring.target(scale, 1, settings.Frequency, { Transparency = amount })
		end
		connect(button.MouseEnter, function()
			hovered = true
			update()
		end)
		connect(button.MouseLeave, function()
			hovered = false
			update()
		end)
		connect(button.SelectionGained, function()
			selected = true
			update()
		end)
		connect(button.SelectionLost, function()
			selected = false
			update()
		end)
		connect(button.InputBegan, function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
				or input.KeyCode == Enum.KeyCode.ButtonA
			then
				pressed[button] = input
				update()
			end
		end)
		connect(Input.InputEnded, function(input)
			if pressed[button] == input then
				pressed[button] = nil
				update()
			end
		end)
		connect(Input.WindowFocusReleased, function()
			pressed[button] = nil
			hovered = false
			update()
		end)
		connect(button:GetPropertyChangedSignal("Interactable"), update)
	end
	local controller = {}
	function controller:SetShopVisible(visible)
		if not alive or open == visible then
			return
		end
		open = visible
		Spring.stop(station, "Position")
		station.Visible = visible
		if visible then
			if Input.PreferredInput == Enum.PreferredInput.Gamepad then
				local first = station.WorkshopContent:FindFirstChild("TabRIG")
				game:GetService("GuiService").SelectedObject = first or station.Close
			end
			station.Position = home + UDim2.fromOffset(0, settings.PanelOffset)
			Spring.target(station, settings.Damping, settings.Frequency, { Position = home })
		else
			station.Position = home
			local selected = game:GetService("GuiService").SelectedObject
			if selected and selected:IsDescendantOf(station) then
				game:GetService("GuiService").SelectedObject = nil
			end
		end
	end
	function controller:Destroy()
		if not alive then
			return
		end
		alive = false
		for _, connection in connections do
			connection:Disconnect()
		end
		for _, scale in scales do
			Spring.stop(scale)
			scale:Destroy()
		end
		Spring.stop(station)
		table.clear(pressed)
	end
	connect(gui.Destroying, function()
		controller:Destroy()
	end)
	return controller
end

return UIMotion
