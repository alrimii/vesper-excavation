-- Treasure counters and compact illustrated edge navigation.
local V = {}
function V.Build(gui, callbacks)
	local K = require(script.Parent.InterfaceKit)
	local root = K.Make(
		"Frame",
		gui,
		{ Name = "FieldHUD", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false }
	)
	local ui = { Root = root }
	local function button(name, label, key)
		local b = K.Button(root, name, "", callbacks[name], true)
		return {
			Button = b,
			Label = K.Text(b, "Label", label, 14, K.Ink, true),
			Icon = key and K.Icon(b, key),
		}
	end
	local function counter(name, key, caption)
		local f = K.Surface(root, name, K.Dark)
		return {
			Frame = f,
			Plate = f,
			Icon = K.Icon(f, key, K.Gold),
			Value = K.Text(f, "Value", "", 28, K.Card, true),
			Caption = K.Text(f, "Caption", caption, 10, K.Paper),
		}
	end
	ui.Cash = counter("Credits", "Credits", "CREDITS")
	ui.Relics = counter("Relics", "Research", "RELICS")
	ui.Bucket = counter("Storage", "Storage", "MATERIALS")
	for _, c in { ui.Cash, ui.Relics, ui.Bucket } do
		c.Value.TextScaled = true
		K.Make("UITextSizeConstraint", c.Value, { MinTextSize = 14, MaxTextSize = 28 })
	end
	local function bar(parent, color)
		local track =
			K.Make("Frame", parent, { Name = "Track", BorderSizePixel = 0, BackgroundColor3 = K.Muted })
		local fill = K.Make(
			"Frame",
			track,
			{ Name = "Fill", BorderSizePixel = 0, Size = UDim2.fromScale(0, 1), BackgroundColor3 = color }
		)
		return track, fill
	end
	ui.BucketTrack, ui.BucketFill = bar(ui.Bucket.Frame, K.Gold)
	ui.Sell = button("Sell", "SELL")
	ui.Sell.Button.BackgroundColor3 = K.Green
	ui.Sell.Label.TextColor3 = K.Card
	ui.Egg = button("EggDetails", "CURRENT EGG", "Research")
	ui.Egg.Button.BackgroundColor3 = K.Dark
	ui.Egg.Label.TextColor3 = K.Paper
	ui.EggPercent = K.Text(ui.Egg.Button, "Percent", "", 13, K.Paper)
	ui.EggTrack, ui.EggFill = bar(ui.Egg.Button, K.Gold)
	ui.EggCaption = K.Text(ui.Egg.Button, "Caption", "EXCAVATION", 10, K.Paper)
	ui.Details = K.Surface(root, "EggDetailsPanel", K.Card)
	ui.Details.Visible = false
	ui.Details.ZIndex = 20
	ui.DetailText = K.Text(ui.Details, "Text", "", 14, K.Ink)
	ui.DetailText.ZIndex = 21
	ui.Skills = button("Progression", "SKILLS", "Skills")
	ui.Equipment = button("Upgrades", "TOOLS", "Pickaxe")
	ui.More = button("More", "EXPLORE", "Explore")
	ui.Skills.Button.BackgroundColor3 = K.Purple
	ui.Equipment.Button.BackgroundColor3 = K.Cyan
	ui.More.Button.BackgroundColor3 = K.Orange
	for _, b in { ui.Skills, ui.Equipment, ui.More } do
		b.Label.TextColor3 = K.Card
	end
	ui.Progress = button("ProgressionStrip", "LV 0")
	ui.Progress.Button.Activated:Connect(callbacks.Progression)
	ui.XP = K.Text(ui.Progress.Button, "XP", "", 12, K.Muted)
	ui.Points = K.Text(ui.Skills.Button, "Points", "", 12, K.Green, true)
	ui.XPTrack, ui.XPFill = bar(ui.Progress.Button, K.Green)
	ui.Guide = K.Surface(root, "ContextHint", K.Dark)
	ui.Hint = K.Text(ui.Guide, "Text", "", 14, K.Paper)
	ui.Dismiss = K.Button(ui.Guide, "Dismiss", "×", callbacks.Dismiss, true)
	ui.Drawer = K.Surface(root, "NavigationFolio", K.Paper)
	ui.Drawer.Visible = false
	ui.Drawer.ZIndex = 20
	ui.Drawer.Active = true
	local heading = K.Text(ui.Drawer, "Heading", "Explore!", 26, K.Ink)
	heading.Font = K.Title
	heading.ZIndex = 21
	K.Rect(heading, 16, 8, 250, 34)
	ui.List = K.Scroll(ui.Drawer, "Destinations")
	ui.List.ZIndex = 21
	K.Make("UIGridLayout", ui.List, {
		CellSize = UDim2.new(0.5, -5, 0, 64),
		CellPadding = UDim2.fromOffset(8, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	ui.Contract = K.Text(ui.Drawer, "Contract", "", 13, K.Muted)
	ui.Contract.ZIndex = 21
	local entryKeys = {
		Journal = "Journal",
		Equipment = "Equipment",
		Creatures = "Creatures",
		Home = "Home",
		Decorate = "Storage",
		Settings = "Settings",
		Help = "Research",
		EggResults = "Results",
		Train = "Precision",
	}
	local short = {
		Journal = "Journal",
		Equipment = "Equipment",
		Creatures = "Creatures",
		Home = "My room",
		Decorate = "Room collection",
		Settings = "Settings",
		Help = "Field guide",
		EggResults = "Egg results",
		Train = "Training",
	}
	function ui:AddEntry(name, label, callback)
		local b = K.Button(self.List, name, "", callback, true)
		b.ZIndex = 22
		b.BackgroundColor3 = K.Card
		local icon = K.Icon(b, entryKeys[name] or "Explore")
		K.Rect(icon, 8, 12, 34, 34)
		icon.ZIndex = 23
		local t = K.Text(b, "Label", short[name] or label, 14, K.Ink, true)
		t.Position = UDim2.fromOffset(48, 4)
		t.Size = UDim2.new(1, -54, 1, -8)
		t.ZIndex = 23
		return b
	end
	local old = gui:FindFirstChild("Use")
	if old then
		old:Destroy()
	end
	ui.Use = K.Button(gui, "Use", "")
	ui.Use.BackgroundColor3 = K.Green
	ui.UseLabel = K.Text(ui.Use, "Action", "STRIKE", 17, K.Card, true)
	ui.UseHint = K.Text(ui.Use, "Hint", "", 11, K.Paper)
	ui.Charged = button("ChargedSwing", "CHARGED", "Skills")
	ui.Flow = K.Text(root, "Flow", "", 14, K.Paper, true)
	ui.Flow.BackgroundTransparency = 0.1
	ui.Flow.BackgroundColor3 = K.Dark
	ui.Training = button("Training", "STOP TRAINING")
	function ui:Layout(w, h, _touch)
		local phone = w < 700 or h < 420
		self.Phone = phone
		local m = 10
		local cw = w < 450 and 105 or 158
		for i, c in { self.Cash, self.Relics } do
			K.Rect(c.Frame, m + (i - 1) * (cw + 6), m, cw, 52)
			local iconSize = w < 450 and 32 or 46
			local textX = w < 450 and 38 or 50
			K.Rect(c.Icon, 3, (52 - iconSize) / 2, iconSize, iconSize)
			K.Rect(c.Value, textX, 0, cw - textX - 4, 34)
			K.Rect(c.Caption, textX, 33, cw - textX - 4, 14)
		end
		local bw = w < 450 and 116 or 160
		K.Rect(self.Bucket.Frame, w - bw - m, m, bw, 52)
		K.Rect(self.Bucket.Icon, 3, 4, 42, 42)
		K.Rect(self.Bucket.Value, 46, 0, bw - 50, 32)
		K.Rect(self.Bucket.Caption, 46, 30, bw - 50, 13)
		K.Rect(self.BucketTrack, 46, 46, bw - 54, 4)
		K.Rect(self.Sell.Button, w - 90 - m, 70, 90, 42)
		K.Rect(self.Sell.Label, 0, 0, 90, 42)
		K.Rect(self.Progress.Button, m, 70, cw * 2 + 6, 36)
		K.Rect(self.Progress.Label, 8, 2, 45, 25)
		K.Rect(self.XP, 60, 2, cw * 2 - 62, 24)
		K.Rect(self.XPTrack, 60, 29, cw * 2 - 66, 3)
		local ew = w >= 850 and math.min(280, w - 2 * cw - 2 * bw - 60) or math.min(300, w - 20)
		local ey = w >= 1000 and 10 or 120
		K.Rect(self.Egg.Button, (w - ew) / 2, ey, ew, 48)
		K.Rect(self.Egg.Icon, 3, 3, 40, 40)
		self.Egg.Icon.ImageRectSize = Vector2.zero
		self.Egg.Icon.ImageRectOffset = Vector2.zero
		self.Egg.Icon.ImageColor3 = Color3.new(1, 1, 1)
		K.Rect(self.Egg.Label, 48, 2, ew - 90, 24)
		K.Rect(self.EggPercent, ew - 44, 10, 42, 25)
		K.Rect(self.EggTrack, 48, 34, ew - 100, 4)
		self.EggCaption.Visible = false
		K.Rect(self.Details, math.max(10, (w - ew) / 2), ey + 54, ew, 110)
		K.Rect(self.DetailText, 12, 8, ew - 24, 94)
		local navY = w >= 1000 and 128 or 180
		local nw = w < 450 and 70 or 80
		for i, b in { self.More, self.Equipment, self.Skills } do
			K.Rect(b.Button, m, navY + (i - 1) * 86, nw, 76)
			K.Rect(b.Icon, (nw - 46) / 2, 2, 46, 46)
			K.Rect(b.Label, 0, 49, nw, 24)
			b.Label.TextSize = 13
			b.Label.TextXAlignment = Enum.TextXAlignment.Center
		end
		K.Rect(self.Points, nw - 22, -6, 26, 24)
		self.Points.BackgroundTransparency = 0
		self.Points.BackgroundColor3 = K.Gold
		local dw = math.min(414, w - 20)
		local dy = navY
		local dh = math.min(436, h - dy - 12)
		K.Rect(self.Drawer, w < 600 and 10 or nw + 24, dy, dw, math.max(130, dh))
		K.Rect(self.List, 12, 50, dw - 24, math.max(60, dh - 128))
		K.Rect(self.Contract, 16, dh - 70, dw - 32, 64)
		self.BeltWidth, self.BeltHeight = phone and 204 or 252, phone and 58 or 68
		self.BeltPosition = UDim2.new(0.5, 0, 1, -10)
		K.Rect(self.Use, w - 94 - m, h - 98, 94, 76)
		K.Rect(self.UseLabel, 0, 13, 94, 30)
		self.UseLabel.TextXAlignment = Enum.TextXAlignment.Center
		K.Rect(self.UseHint, 0, 45, 94, 20)
		self.UseHint.TextXAlignment = Enum.TextXAlignment.Center
		K.Rect(self.Charged.Button, w - 94 - m, h - 151, 94, 44)
		K.Rect(self.Charged.Label, 4, 0, 86, 44)
		self.Charged.Label.TextSize = 12
		self.Charged.Icon.Visible = false
		local gw = math.min(310, w - 24)
		K.Rect(self.Guide, (w - gw) / 2, h - self.BeltHeight - 64, gw, 36)
		K.Rect(self.Hint, 10, 0, gw - 50, 36)
		K.Rect(self.Dismiss, gw - 38, 0, 38, 36)
		K.Rect(self.Flow, (w - 220) / 2, h - self.BeltHeight - 54, 220, 32)
		self.Flow.TextXAlignment = Enum.TextXAlignment.Center
		K.Rect(self.Training.Button, (w - 180) / 2, h - 70, 180, 44)
		K.Rect(self.Training.Label, 0, 0, 180, 44)
	end
	return ui
end
return V
