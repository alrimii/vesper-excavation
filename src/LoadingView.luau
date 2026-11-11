-- Early readiness presentation. The joining pipeline and retry behavior remain unchanged.
local V = {}
function V.Build(parent)
	local T = require(script.Parent.InterfaceTheme)
	local function make(class, p, props)
		local o = Instance.new(class)
		for k, v in props do
			o[k] = v
		end
		o.Parent = p
		return o
	end
	local gui = make("ScreenGui", parent, {
		Name = "LabEntry",
		DisplayOrder = 1000,
		ResetOnSpawn = false,
		ScreenInsets = Enum.ScreenInsets.None,
		SafeAreaCompatibility = Enum.SafeAreaCompatibility.None,
	})
	local bg = make(
		"Frame",
		gui,
		{ Size = UDim2.fromScale(1, 1), BackgroundColor3 = T.Dark, BorderSizePixel = 0, Active = true }
	)
	local card = make("Frame", bg, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, -48, 0, 280),
		BackgroundTransparency = 1,
	})
	make("UISizeConstraint", card, { MaxSize = Vector2.new(640, 280) })
	make("ImageLabel", card, {
		Name = "Treasure",
		Image = "rbxassetid://132558544808738",
		ImageRectOffset = Vector2.new(0, 617),
		ImageRectSize = Vector2.new(204, 200),
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 0, -24),
		Size = UDim2.fromOffset(120, 120),
		BackgroundTransparency = 1,
	})
	local function text(name, value, y, height, size, color, font)
		return make("TextLabel", card, {
			Name = name,
			Text = value,
			Position = UDim2.fromOffset(0, y),
			Size = UDim2.new(1, 0, 0, height),
			TextColor3 = color,
			Font = font or T.Font,
			TextSize = size,
			TextWrapped = true,
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
		})
	end
	text("Brand", "VESPER EXCAVATION", 0, 22, 12, T.Gold, T.Bold)
	local title = text("Title", "Treasure awaits!", 34, 64, 44, T.Gold, T.Title)
	local status = text("Status", "Connecting to the laboratory…", 113, 56, 16, T.Line)
	local stages = {}
	for i, label in { "CONNECT", "SYNC", "ASSETS", "READY" } do
		local t = text("Stage" .. i, label, 190, 28, 11, T.Muted, T.Bold)
		t.Position = UDim2.new((i - 1) / 4, 0, 0, 190)
		t.Size = UDim2.new(0.25, -8, 0, 28)
		local rule = make("Frame", card, {
			Position = UDim2.new((i - 1) / 4, 0, 0, 182),
			Size = UDim2.new(0.25, -12, 0, 8),
			BackgroundColor3 = T.Muted,
			BorderSizePixel = 0,
		})
		stages[i] = { text = t, line = rule }
	end
	local enter = make("TextButton", card, {
		Name = "Enter",
		Text = "",
		Visible = false,
		Position = UDim2.fromOffset(0, 232),
		Size = UDim2.fromOffset(200, 44),
		BackgroundColor3 = T.Green,
		TextColor3 = T.Card,
		Font = T.Bold,
		TextSize = 15,
		BorderSizePixel = 0,
	})
	make("UICorner", enter, { CornerRadius = UDim.new(0, 7) })
	enter:GetPropertyChangedSignal("Text"):Connect(function()
		enter.Visible = enter.Text == "RETRY LOADING"
	end)
	local api = { gui = gui, status = status, enter = enter }
	function api:Stage(index)
		for i, s in stages do
			s.text.TextColor3 = i <= index and T.Paper or T.Muted
			s.line.BackgroundColor3 = i <= index and T.Gold or T.Muted
		end
	end
	function api:Failure(heading, message)
		title.Text = "Unable to join"
		status.Text = heading .. "\n" .. message
		status.TextColor3 = T.Paper
		enter.Visible = false
	end
	function api:Resize(size)
		title.TextSize = size.X < 500 and 30 or 40
	end
	return api
end
return V
