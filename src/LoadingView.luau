-- Minimal readiness screen. No camera, 3D scene, progress percentage or entry gate.
local V = {}
function V.Build(parent)
	local gui = Instance.new("ScreenGui")
	gui.Name, gui.DisplayOrder, gui.ResetOnSpawn = "LabEntry", 1000, false
	gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
	local background = Instance.new("Frame")
	background.Size, background.BackgroundColor3 = UDim2.fromScale(1, 1), Color3.fromRGB(22, 36, 47)
	background.BorderSizePixel, background.Active, background.Parent = 0, true, gui
	local card = Instance.new("Frame")
	card.AnchorPoint, card.Position = Vector2.new(0.5, 0.5), UDim2.fromScale(0.5, 0.5)
	card.Size, card.BackgroundTransparency, card.Parent = UDim2.new(1, -32, 0, 180), 1, background
	local limit = Instance.new("UISizeConstraint")
	limit.MaxSize, limit.Parent = Vector2.new(460, 180), card
	local function label(name, value, y, height, size, color)
		local t = Instance.new("TextLabel")
		t.Name, t.Text, t.TextSize = name, value, size
		t.Position, t.Size = UDim2.fromOffset(0, y), UDim2.new(1, 0, 0, height)
		t.BackgroundTransparency, t.Font, t.TextColor3 = 1, Enum.Font.GothamBold, color
		t.TextWrapped, t.Parent = true, card
		return t
	end
	label("Title", "Joining the excavation", 0, 36, 24, Color3.fromRGB(249, 239, 211))
	local stage = label("Stage", "CONNECTING", 44, 24, 13, Color3.fromRGB(122, 232, 193))
	local status = label("Status", "Waiting for the current server state...", 76, 48, 15, Color3.fromRGB(220, 231, 237))
	local enter = Instance.new("TextButton")
	enter.Name, enter.Text, enter.Visible = "Enter", "", false
	enter.AnchorPoint, enter.Position = Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, 134)
	enter.Size, enter.BackgroundColor3 = UDim2.fromOffset(180, 44), Color3.fromRGB(122, 232, 193)
	enter.TextColor3, enter.Font, enter.TextSize = Color3.fromRGB(22, 36, 47), Enum.Font.GothamBold, 14
	enter.Parent = card
	Instance.new("UICorner", enter).CornerRadius = UDim.new(0, 12)
	enter:GetPropertyChangedSignal("Text"):Connect(function() enter.Visible = enter.Text == "RETRY LOADING" end)
	local api = { gui = gui, status = status, enter = enter }
	function api:Stage(index)
		stage.Text = ({ "CONNECTING", "SYNCHRONIZING", "LOADING ASSETS", "READY" })[index] or ""
	end
	function api:Resize(_size) end -- Constraints own layout; retained caller interface.
	gui.Parent = parent
	return api
end
return V
