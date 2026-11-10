-- Shared presentation bounds. Backgrounds cover the viewport; controls retain core safe insets.
local M = {}

function M.Backdrop(contentScreen, visibilitySource, style)
	local screen = Instance.new("ScreenGui")
	screen.Name = contentScreen.Name .. "Backdrop_" .. visibilitySource.Name
	screen.ResetOnSpawn = false
	screen.DisplayOrder = contentScreen.DisplayOrder - 1
	screen.ScreenInsets = Enum.ScreenInsets.None
	screen.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
	screen.ClipToDeviceSafeArea = false
	screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	local background = Instance.new("Frame")
	background.Name = "ViewportBackground"
	background.Size = UDim2.fromScale(1, 1)
	background.BorderSizePixel = 0
	background.BackgroundColor3 = style.Color
	background.BackgroundTransparency = style.Transparency or 0
	background.Active = false
	background.Parent = screen
	if style.Image then
		local art = Instance.new("ImageLabel")
		art.Name = "ExistingBackgroundArt"
		art.Size = UDim2.fromScale(1, 1)
		art.BackgroundTransparency = 1
		art.Image = style.Image
		art.ImageTransparency = style.ImageTransparency or 0
		art.ScaleType = Enum.ScaleType.Crop
		art.Parent = background
	end
	local property = visibilitySource:IsA("ScreenGui") and "Enabled" or "Visible"
	local function sync()
		screen.Enabled = contentScreen.Enabled and visibilitySource[property]
		screen.DisplayOrder = contentScreen.DisplayOrder - 1
	end
	local connections = {
		contentScreen:GetPropertyChangedSignal("Enabled"):Connect(sync),
		contentScreen:GetPropertyChangedSignal("DisplayOrder"):Connect(sync),
	}
	if visibilitySource ~= contentScreen then
		table.insert(connections, visibilitySource:GetPropertyChangedSignal(property):Connect(sync))
	end
	contentScreen.Destroying:Once(function()
		for _, connection in connections do
			connection:Disconnect()
		end
		screen:Destroy()
	end)
	sync()
	screen.Parent = contentScreen.Parent
	return background
end

function M.FitPanel(panel, available, minimum, maximum, padding, scaleName)
	local usable = Vector2.new(math.max(1, available.X - padding.X), math.max(1, available.Y - padding.Y))
	local scale = math.min(1, usable.X / minimum.X, usable.Y / minimum.Y)
	local width, height = math.min(maximum.X, usable.X / scale), math.min(maximum.Y, usable.Y / scale)
	local fit = panel:FindFirstChild(scaleName or "ModalFit")
	if not fit then
		fit = Instance.new("UIScale")
		fit.Name = scaleName or "ModalFit"
		fit.Parent = panel
	end
	fit.Scale = scale
	panel.Size = UDim2.fromOffset(width, height)
	return width, height
end

return M
