-- Production presentation shared with Edit-mode previews. No remotes, saves or game loops.
local V = {}
local ink = Color3.fromRGB(37, 56, 64)
local cream = Color3.fromRGB(255, 246, 220)
local mint = Color3.fromRGB(113, 232, 187)
local gold = Color3.fromRGB(255, 194, 75)
local purple = Color3.fromRGB(182, 153, 244)
local function make(class, parent, props)
	local o = Instance.new(class)
	for k, v in props do
		o[k] = v
	end
	o.Parent = parent
	return o
end
local function surface(o, color, radius)
	o.BackgroundColor3, o.BorderSizePixel = color, 0
	local c = o:FindFirstChildOfClass("UICorner") or Instance.new("UICorner", o)
	c.CornerRadius = UDim.new(0, radius or 16)
	local s = o:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke", o)
	s.Color, s.Thickness, s.ApplyStrokeMode = Color3.fromRGB(56, 84, 87), 2, Enum.ApplyStrokeMode.Border
	local g = o:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient", o)
	g.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(229, 239, 227))
	g.Rotation = 90
end
local function text(parent, name, value, size, bold)
	return make("TextLabel", parent, {
		Name = name,
		Text = value,
		TextSize = size,
		Font = bold and Enum.Font.FredokaOne or Enum.Font.GothamBold,
		TextColor3 = ink,
		BackgroundTransparency = 1,
		TextWrapped = false,
		ZIndex = 8,
	})
end
local function rect(o, x, y, w, h)
	o.Position, o.Size = UDim2.fromOffset(x, y), UDim2.fromOffset(w, h)
end
function V.Build(gui, callbacks)
	callbacks = callbacks or {}
	local Nav = require(script.Parent.NavigationArtwork)
	local Art = require(script.Parent.SkillArt)
	local root = make(
		"Frame",
		gui,
		{ Name = "CoreHUD", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Visible = false }
	)
	local ui = { Root = root }
	local function icon(parent, kind)
		if kind == "Coins" or kind == "Equipment" or kind == "Creatures" or kind == "Home" then
			return Nav.Icon(parent, kind)
		end
		return make("ImageLabel", parent, {
			Name = "Illustration",
			BackgroundTransparency = 1,
			Image = Art[kind],
			ScaleType = Enum.ScaleType.Fit,
			ZIndex = 7,
		})
	end
	local function button(name, caption, color, kind)
		local b = make("TextButton", root, { Name = name, Text = "", AutoButtonColor = false, ZIndex = 6 })
		surface(b, color)
		local title = text(b, "Label", caption, 16, true)
		local art = kind and icon(b, kind)
		if callbacks[name] then
			b.Activated:Connect(callbacks[name])
		end
		require(script.Parent.InterfaceStyle).Button(b)
		return { Button = b, Label = title, Icon = art }
	end
	local function counter(name, kind, label, color)
		local f = make("Frame", root, { Name = name, ZIndex = 4 })
		surface(f, cream)
		local art = icon(f, kind)
		local value = text(f, "Value", "...", 21, true)
		local caption = text(f, "Caption", label, 12, false)
		caption.TextColor3 = color
		value.TextXAlignment, caption.TextXAlignment = Enum.TextXAlignment.Left, Enum.TextXAlignment.Left
		return { Frame = f, Icon = art, Value = value, Caption = caption }
	end
	ui.Cash = counter("Currency", "Coins", "CREDITS", Color3.fromRGB(146, 95, 30))
	ui.Relics = counter("Relics", "Coins", "RELICS", Color3.fromRGB(111, 78, 154))
	-- Existing original atlas: its teal crystal is a distinct relic-counter illustration.
	ui.Relics.Icon.ImageRectOffset = Vector2.new(775, 820)
	ui.Relics.Icon.ImageRectSize = Vector2.new(235, 195)
	ui.Egg = button("EggDetails", "CURRENT EGG", cream, "Creatures")
	ui.Egg.Icon.ImageRectOffset = Vector2.new(512, 0)
	ui.EggPercent = text(ui.Egg.Button, "Percent", "...", 14, false)
	local track = make(
		"Frame",
		ui.Egg.Button,
		{
			Name = "ProgressTrack",
			BackgroundColor3 = Color3.fromRGB(205, 211, 186),
			BorderSizePixel = 0,
			ZIndex = 7,
		}
	)
	make("UICorner", track, { CornerRadius = UDim.new(1, 0) })
	ui.EggFill = make(
		"Frame",
		track,
		{
			Name = "Fill",
			Size = UDim2.fromScale(0, 1),
			BackgroundColor3 = gold,
			BorderSizePixel = 0,
			ZIndex = 8,
		}
	)
	make("UICorner", ui.EggFill, { CornerRadius = UDim.new(1, 0) })
	ui.EggTrack = track
	ui.Details = make("Frame", root, { Name = "EggDetailsPanel", Visible = false, ZIndex = 20 })
	surface(ui.Details, cream)
	ui.DetailText = text(ui.Details, "Text", "", 15, false)
	ui.DetailText.ZIndex = 21
	ui.DetailText.TextWrapped = true
	ui.DetailText.TextXAlignment = Enum.TextXAlignment.Left
	ui.Equipment = button("Upgrades", "TOOLS", mint, "Equipment")
	ui.Creatures = button("Creatures", "CREATURES", purple, "Creatures")
	ui.More = button("More", "MORE", cream, "journal_hub")
	ui.Bucket = counter("Bucket", "batch_unload", "BUCKET", Color3.fromRGB(32, 121, 94))
	ui.Sell = button("Sell", "SELL", gold, nil)
	ui.Progress = button("Progression", "LEVEL ...", cream, nil)
	ui.XP = text(ui.Progress.Button, "XP", "...", 13, false)
	ui.Points = text(ui.Progress.Button, "Points", "", 12, false)
	ui.Points.TextColor3 = Color3.fromRGB(104, 65, 157)
	local xpTrack = make(
		"Frame",
		ui.Progress.Button,
		{
			Name = "XPTrack",
			BackgroundColor3 = Color3.fromRGB(211, 211, 228),
			BorderSizePixel = 0,
			ZIndex = 7,
		}
	)
	make("UICorner", xpTrack, { CornerRadius = UDim.new(1, 0) })
	ui.XPFill = make(
		"Frame",
		xpTrack,
		{
			Name = "Fill",
			BackgroundColor3 = purple,
			Size = UDim2.fromScale(0, 1),
			BorderSizePixel = 0,
			ZIndex = 8,
		}
	)
	make("UICorner", ui.XPFill, { CornerRadius = UDim.new(1, 0) })
	ui.XPTrack = xpTrack
	ui.Guide = make("Frame", root, { Name = "ContextHint", Visible = false, ZIndex = 5 })
	surface(ui.Guide, cream, 12)
	ui.Hint = text(ui.Guide, "Hint", "", 14, false)
	ui.Hint.TextXAlignment = Enum.TextXAlignment.Left
	ui.Dismiss = make("TextButton", ui.Guide, {
		Name = "Dismiss",
		Text = "X",
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = ink,
		BackgroundTransparency = 1,
		ZIndex = 9,
	})
	ui.Dismiss.Activated:Connect(function()
		if callbacks.Dismiss then
			callbacks.Dismiss()
		end
	end)
	ui.Drawer = make("Frame", root, { Name = "MoreActions", Visible = false, ZIndex = 20 })
	surface(ui.Drawer, cream)
	ui.List = make("ScrollingFrame", ui.Drawer, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 5,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),
		Size = UDim2.new(1, -20, 1, -20),
		Position = UDim2.fromOffset(10, 10),
		ZIndex = 21,
	})
	make("UIListLayout", ui.List, { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder })
	ui.Use = gui:FindFirstChild("Use") or make("TextButton", gui, { Name = "Use", Text = "" })
	ui.Use.BackgroundTransparency, ui.Use.TextTransparency, ui.Use.ZIndex = 0, 1, 6
	ui.Use.AnchorPoint = Vector2.zero
	surface(ui.Use, gold, 28)
	for _, child in ui.Use:GetChildren() do
		if child:IsA("TextLabel") or child:IsA("UIPadding") then
			child:Destroy()
		end
	end
	ui.UseLabel = text(ui.Use, "ActionLabel", "STRIKE", 20, true)
	ui.UseHint = text(ui.Use, "InputHint", "", 13, false)
	ui.Charged = button("ChargedSwing", "CHARGED", purple, nil)
	ui.Flow = text(root, "Flow", "", 14, true)
	ui.Flow.Visible = false
	ui.Flow.BackgroundTransparency = 0
	surface(ui.Flow, cream, 10)
	ui.Training = button("Training", "STOP TRAINING", mint, nil)
	function ui:AddEntry(name, label, callback)
		local b = make("TextButton", self.List, {
			Name = name,
			Text = label,
			Font = Enum.Font.GothamBold,
			TextSize = 15,
			TextColor3 = ink,
			Size = UDim2.new(1, -4, 0, 44),
			ZIndex = 22,
			AutoButtonColor = true,
		})
		surface(b, Color3.fromRGB(227, 238, 220), 10)
		b.Activated:Connect(callback)
		return b
	end
	function ui:Layout(width, height, touch)
		local phone = touch or width < 850
		self.Phone = phone
		local margin = phone and 8 or 14
		local cw, ch = phone and 116 or 170, phone and 34 or 48
		for i, c in { self.Cash, self.Relics } do
			rect(c.Frame, margin, margin + (i - 1) * (ch + 7), cw, ch)
			rect(c.Icon, 2, -3, ch + 6, ch + 6)
			rect(c.Value, ch + 8, 1, cw - ch - 14, phone and 19 or 27)
			rect(c.Caption, ch + 8, phone and 18 or 28, cw - ch - 14, phone and 14 or 16)
			c.Value.TextSize = phone and 16 or 23
			c.Caption.TextSize = phone and 10 or 12
		end
		local ew = phone and math.min(236, width - 2 * cw - 48) or 342
		ew = math.max(170, ew)
		local eh = phone and 48 or 62
		rect(self.Egg.Button, (width - ew) / 2, margin, ew, eh)
		rect(self.Egg.Icon, 3, -4, phone and 46 or 62, phone and 46 or 62)
		rect(self.Egg.Label, phone and 48 or 64, 4, ew - (phone and 76 or 100), phone and 18 or 24)
		self.Egg.Label.TextSize = phone and 15 or 20
		self.Egg.Label.TextXAlignment = Enum.TextXAlignment.Left
		rect(self.EggPercent, ew - 50, phone and 22 or 31, 44, 16)
		rect(
			self.EggTrack,
			phone and 48 or 64,
			phone and 28 or 39,
			ew - (phone and 105 or 126),
			phone and 9 or 11
		)
		rect(
			self.Details,
			(width - math.min(340, width - 24)) / 2,
			margin + eh + 8,
			math.min(340, width - 24),
			94
		)
		rect(self.DetailText, 12, 6, self.Details.Size.X.Offset - 24, 82)
		rect(self.Bucket.Frame, width - cw - margin, margin, cw, ch)
		rect(self.Bucket.Icon, 2, -3, ch + 6, ch + 6)
		rect(self.Bucket.Value, ch + 8, 1, cw - ch - 14, phone and 19 or 27)
		rect(self.Bucket.Caption, ch + 8, phone and 18 or 28, cw - ch - 14, phone and 14 or 16)
		self.Bucket.Value.TextSize = phone and 15 or 21
		self.Bucket.Caption.TextSize = phone and 10 or 12
		rect(self.Sell.Button, width - cw - margin, margin + ch + 8, cw, phone and 34 or 40)
		rect(self.Sell.Label, 0, 0, cw, self.Sell.Button.Size.Y.Offset)
		local navY = phone and 90 or 132
		local nw, nh = phone and 64 or 90, phone and 44 or 76
		for i, b in { self.Equipment, self.Creatures, self.More } do
			b.Button.Visible = not phone or i ~= 2
			local row = phone and (i == 3 and 1 or 0) or (i - 1)
			rect(b.Button, margin, navY + row * (nh + 8), nw, nh)
			rect(b.Icon, phone and 2 or 10, phone and -5 or -8, phone and 32 or 70, phone and 32 or 64)
			rect(b.Label, 0, phone and 25 or 54, nw, phone and 16 or 20)
			if phone then
				rect(b.Icon, (nw - 36) / 2, -5, 36, 36)
			end
			b.Label.TextSize = phone and 12 or 14
		end
		self.BeltWidth, self.BeltHeight = phone and 218 or 282, phone and 58 or 76
		self.BeltPosition = UDim2.new(0.5, 0, 1, -8)
		local pw = phone and 250 or 306
		rect(self.Progress.Button, (width - pw) / 2, height - self.BeltHeight - 50, pw, 34)
		rect(self.Progress.Label, 6, 1, 64, 21)
		self.Progress.Label.TextSize = 15
		rect(self.XP, 74, 0, pw - 134, 18)
		self.XP.TextSize = phone and 11 or 13
		rect(self.Points, pw - 62, 1, 58, 30)
		self.Points.TextSize = 10
		rect(self.XPTrack, 74, 23, pw - 142, 5)
		local gw = phone and 238 or 270
		rect(
			self.Guide,
			phone and (width - gw) / 2 or margin,
			phone and height - self.BeltHeight - 81 or height - 65,
			gw,
			phone and 26 or 48
		)
		rect(self.Hint, 10, 0, gw - 42, self.Guide.Size.Y.Offset)
		self.Hint.TextSize = phone and 12 or 14
		rect(self.Dismiss, gw - 34, 0, 34, self.Guide.Size.Y.Offset)
		local attackY = phone and math.max(92, height - 184) or height - 94
		rect(
			self.Use,
			width - (phone and 92 or 144) - margin,
			attackY,
			phone and 92 or 144,
			phone and 64 or 80
		)
		rect(self.UseLabel, 0, phone and 11 or 16, self.Use.Size.X.Offset, 28)
		self.UseLabel.TextSize = phone and 18 or 24
		rect(self.UseHint, 0, phone and 39 or 49, self.Use.Size.X.Offset, 20)
		rect(
			self.Charged.Button,
			width - (phone and 174 or 144) - margin,
			phone and attackY + 10 or attackY - 50,
			phone and 76 or 144,
			42
		)
		rect(self.Charged.Label, 0, 0, self.Charged.Button.Size.X.Offset, 42)
		self.Charged.Label.TextSize = 12
		rect(self.Flow, (width - 220) / 2, height - self.BeltHeight - 78, 220, 24)
		rect(self.Training.Button, (width - 170) / 2, height - 64, 170, 44)
		rect(self.Training.Label, 0, 0, 170, 44)
		rect(
			self.Drawer,
			margin + nw + 10,
			phone and 82 or 132,
			math.min(270, width - nw - 32),
			math.max(100, height - (phone and 90 or 144))
		)
	end
	return ui
end
return V
