-- Production HUD composition. Pure view; same factory is used for temporary Edit previews.
local V = {}
function V.Build(gui, callbacks)
	local C = require(script.Parent.ExcavationChrome)
	local make, rect, text = C.Make, C.Rect, C.Text
	local root = make(
		"Frame",
		gui,
		{ Name = "FieldHUD", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false }
	)
	local ui = { Root = root }
	local function button(name, label, key, color, round)
		local b = C.Button(root, name, callbacks[name], color, round)
		local t = text(b, "Label", label, 18)
		return { Button = b, Label = t, Icon = key and C.Icon(b, key) }
	end
	local function counter(name, key, caption)
		local f = make("Frame", root, { Name = name, BackgroundTransparency = 1, ZIndex = 5 })
		local pill = make("Frame", f, { Name = "ValuePlate", ZIndex = 5 })
		C.Surface(pill, C.White, 16)
		local icon = C.Icon(f, key)
		return {
			Frame = f,
			Plate = pill,
			Icon = icon,
			Value = text(f, "Value", "...", 22),
			Caption = text(f, "Caption", caption, 11),
		}
	end
	ui.Cash = counter("Credits", "credits", "CREDITS")
	ui.Relics = counter("Relics", "relic", "RELICS")
	ui.Bucket = counter("Storage", "bucket", "STORAGE")
	ui.BucketTrack = make(
		"Frame",
		ui.Bucket.Frame,
		{ Name = "Track", BorderSizePixel = 0, BackgroundColor3 = C.Ink, ZIndex = 7 }
	)
	make("UICorner", ui.BucketTrack, { CornerRadius = UDim.new(1, 0) })
	ui.BucketFill = make("Frame", ui.BucketTrack, {
		Name = "Fill",
		Size = UDim2.fromScale(0, 1),
		BorderSizePixel = 0,
		BackgroundColor3 = C.Blue,
		ZIndex = 8,
	})
	make("UICorner", ui.BucketFill, { CornerRadius = UDim.new(1, 0) })
	ui.Sell = button("Sell", "SELL", nil, C.Gold, 18)
	ui.Egg = button("EggDetails", "CURRENT EGG", "bronze", C.White, 24)
	ui.EggPercent = text(ui.Egg.Button, "Percent", "...", 14)
	ui.EggTrack = make(
		"Frame",
		ui.Egg.Button,
		{ Name = "Track", BackgroundColor3 = C.Ink, BorderSizePixel = 0, ZIndex = 7 }
	)
	make("UICorner", ui.EggTrack, { CornerRadius = UDim.new(1, 0) })
	ui.EggFill = make("Frame", ui.EggTrack, {
		Name = "Fill",
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = C.Gold,
		BorderSizePixel = 0,
		ZIndex = 8,
	})
	make("UICorner", ui.EggFill, { CornerRadius = UDim.new(1, 0) })
	ui.EggCaption = text(ui.Egg.Button, "Caption", "EXCAVATION", 10)
	ui.Details = make("Frame", root, { Name = "EggDetailsPanel", Visible = false, ZIndex = 20 })
	C.Surface(ui.Details, C.White, 16)
	ui.DetailText = text(ui.Details, "Text", "", 15)
	ui.DetailText.ZIndex = 21
	ui.DetailText.TextWrapped = true
	ui.Skills = button("Progression", "SKILLS", "skills", C.Purple, 100)
	ui.Equipment = button("Upgrades", "TOOLS", "equipment", C.Orange, 100)
	ui.More = button("More", "EXPLORE", "explore", C.Blue, 100)
	ui.Progress = button("ProgressionStrip", "LV ...", nil, C.White, 16)
	ui.Progress.Button.Activated:Connect(callbacks.Progression)
	ui.XP = text(ui.Progress.Button, "XP", "...", 13)
	ui.Points = text(ui.Skills.Button, "Points", "0", 13)
	ui.Points.BackgroundTransparency = 0
	ui.Points.BackgroundColor3 = C.White
	make("UICorner", ui.Points, { CornerRadius = UDim.new(1, 0) })
	ui.XPTrack = make(
		"Frame",
		ui.Progress.Button,
		{ Name = "Track", BackgroundColor3 = C.Ink, BorderSizePixel = 0, ZIndex = 7 }
	)
	make("UICorner", ui.XPTrack, { CornerRadius = UDim.new(1, 0) })
	ui.XPFill = make("Frame", ui.XPTrack, {
		Name = "Fill",
		BackgroundColor3 = C.Purple,
		Size = UDim2.fromScale(0, 1),
		BorderSizePixel = 0,
		ZIndex = 8,
	})
	make("UICorner", ui.XPFill, { CornerRadius = UDim.new(1, 0) })
	ui.Guide = make("Frame", root, { Name = "ContextHint", Visible = false, ZIndex = 5 })
	C.Surface(ui.Guide, C.White, 12)
	ui.Hint = text(ui.Guide, "Text", "", 14)
	ui.Hint.TextWrapped = true
	ui.Dismiss = make("TextButton", ui.Guide, {
		Name = "Dismiss",
		Text = "X",
		TextSize = 16,
		Font = Enum.Font.FredokaOne,
		TextColor3 = C.Ink,
		BackgroundTransparency = 1,
		ZIndex = 9,
	})
	ui.Dismiss.Activated:Connect(callbacks.Dismiss)
	ui.Drawer = make("Frame", root, { Name = "ExploreDrawer", Visible = false, ZIndex = 20 })
	C.Surface(ui.Drawer, C.White, 20)
	ui.List = make("ScrollingFrame", ui.Drawer, {
		Name = "Actions",
		Size = UDim2.new(1, -20, 1, -20),
		Position = UDim2.fromOffset(10, 10),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 5,
		ZIndex = 21,
	})
	make("UIListLayout", ui.List, { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder })
	local old = gui:FindFirstChild("Use")
	if old then
		old:Destroy()
	end
	ui.Use = C.Button(gui, "Use", nil, C.Orange, 100)
	ui.UseLabel = text(ui.Use, "Action", "STRIKE", 20)
	ui.UseHint = text(ui.Use, "Hint", "", 12)
	ui.Charged = button("ChargedSwing", "CHARGED", nil, C.Purple, 18)
	ui.Flow = text(root, "Flow", "", 14)
	ui.Flow.Visible = false
	C.Surface(ui.Flow, C.White, 10)
	ui.Training = button("Training", "STOP TRAINING", nil, C.Blue, 18)
	function ui:AddEntry(name, label, callback)
		local b = C.Button(self.List, name, callback, Color3.fromRGB(229, 239, 255), 12)
		b.Text, b.Font, b.TextSize, b.TextColor3 = label, Enum.Font.FredokaOne, 16, C.Ink
		b.Size, b.ZIndex = UDim2.new(1, -4, 0, 44), 22
		return b
	end
	function ui:Layout(w, h, touch)
		local phone = touch or w < 850 or h < 430
		self.Phone = phone
		local m = phone and 10 or 22
		local cw, ch = phone and 92 or 130, phone and 34 or 48
		for i, c in { self.Cash, self.Relics } do
			rect(c.Frame, m + (i - 1) * (cw + 6), m, cw, ch)
			rect(c.Plate, 18, 2, cw - 18, ch - 3)
			rect(c.Icon, -5, -6, ch + 9, ch + 9)
			rect(c.Value, ch - 1, 0, cw - ch, phone and 23 or 31)
			c.Value.TextSize = phone and 16 or 22
			rect(c.Caption, ch - 1, phone and 21 or 30, cw - ch, 12)
			c.Caption.TextSize = 11
		end
		local pw = phone and 190 or 266
		rect(self.Progress.Button, m, m + ch + 8, pw, phone and 32 or 38)
		rect(self.Progress.Label, 4, 0, 54, phone and 24 or 27)
		self.Progress.Label.TextSize = phone and 15 or 18
		rect(self.XP, 58, 0, pw - 64, 20)
		self.XP.TextSize = phone and 12 or 13
		rect(self.XPTrack, 58, phone and 24 or 27, pw - 70, 5)
		local ew = phone and math.min(236, math.max(180, w - 2 * pw - 50)) or 370
		local ex = (w - ew) / 2 + (phone and 20 or 0)
		rect(self.Egg.Button, ex, m, ew, phone and 54 or 72)
		rect(self.Egg.Icon, -12, -10, phone and 66 or 88, phone and 66 or 88)
		local left = phone and 54 or 78
		rect(self.Egg.Label, left, phone and 7 or 9, ew - left - 12, 24)
		self.Egg.Label.TextSize = phone and 15 or 21
		self.Egg.Label.TextXAlignment = Enum.TextXAlignment.Left
		rect(self.EggTrack, left, phone and 36 or 45, ew - left - 51, phone and 10 or 13)
		rect(self.EggPercent, ew - 47, phone and 29 or 40, 44, 22)
		self.EggPercent.TextSize = phone and 12 or 15
		rect(self.EggCaption, left, phone and 24 or 31, ew - left - 10, 10)
		self.EggCaption.Visible = not phone
		rect(self.Details, ex, m + (phone and 64 or 84), ew, 100)
		rect(self.DetailText, 12, 8, ew - 24, 84)
		local bw = phone and 112 or 176
		rect(self.Bucket.Frame, w - bw - m, m, bw, phone and 48 or 68)
		rect(self.Bucket.Plate, 20, 5, bw - 20, phone and 41 or 59)
		rect(self.Bucket.Icon, -8, -6, phone and 57 or 80, phone and 57 or 80)
		local bl = phone and 48 or 68
		rect(self.Bucket.Value, bl, phone and 4 or 8, bw - bl - 4, 24)
		self.Bucket.Value.TextSize = phone and 15 or 21
		rect(self.Bucket.Caption, bl, phone and 24 or 33, bw - bl - 4, 13)
		self.Bucket.Caption.TextSize = 11
		rect(self.BucketTrack, bl, phone and 40 or 52, bw - bl - 8, 5)
		rect(
			self.Sell.Button,
			w - bw - m + (phone and 34 or 48),
			m + (phone and 53 or 74),
			bw - (phone and 34 or 48),
			32
		)
		rect(self.Sell.Label, 0, 0, self.Sell.Button.Size.X.Offset, 32)
		self.Sell.Label.TextSize = 16
		local ns = phone and 46 or 66
		for i, b in { self.Skills, self.Equipment, self.More } do
			local x = phone and (m + (i - 1) * 66) or m
			local y = phone and m + ch + 49 or 156 + (i - 1) * 96
			rect(b.Button, x, y, ns, ns)
			rect(b.Icon, phone and -2 or -5, phone and -5 or -8, ns + 4, ns + 4)
			rect(b.Label, -7, ns - 1, ns + 14, phone and 19 or 24)
			b.Label.TextSize = phone and 12 or 16
			b.Label.TextColor3 = C.White
			b.Label.TextStrokeColor3 = C.Ink
			b.Label.TextStrokeTransparency = 0
		end
		rect(self.Points, ns - 12, -6, 24, 24)
		self.BeltWidth, self.BeltHeight = phone and 216 or 300, phone and 58 or 82
		self.BeltPosition = UDim2.new(0.5, 0, 1, -8)
		local gw = phone and 210 or 260
		rect(self.Guide, phone and ex or w - gw - m, phone and m + 62 or m + 120, gw, phone and 28 or 42)
		rect(self.Hint, 8, 0, gw - 40, self.Guide.Size.Y.Offset)
		self.Hint.TextSize = phone and 12 or 14
		rect(self.Dismiss, gw - 32, 0, 32, self.Guide.Size.Y.Offset)
		local size = phone and 78 or 94
		local uy = phone and math.max(142, h - 174) or h - size - 24
		rect(self.Use, w - size - m, uy, size, size)
		rect(self.UseLabel, 0, phone and 21 or 29, size, 26)
		self.UseLabel.TextSize = phone and 18 or 21
		rect(self.UseHint, 0, phone and 47 or 56, size, 18)
		self.UseHint.TextSize = phone and 10 or 12
		rect(self.Charged.Button, w - size - m - 86, uy + 12, 76, 48)
		rect(self.Charged.Label, 0, 0, 76, 48)
		self.Charged.Label.TextSize = 12
		rect(self.Flow, w - (phone and 180 or 230) - m, m + (phone and 92 or 175), phone and 180 or 230, 24)
		rect(self.Training.Button, (w - 170) / 2, h - 64, 170, 44)
		rect(self.Training.Label, 0, 0, 170, 44)
		rect(
			self.Drawer,
			phone and m or 108,
			phone and 158 or 140,
			math.min(280, w - 24),
			math.max(100, h - (phone and 168 or 154))
		)
	end
	return ui
end
return V
