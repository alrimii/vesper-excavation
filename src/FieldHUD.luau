-- Compact field instruments and a two-column navigation folio.
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
			Value = K.Text(f, "Value", "", 17, K.Paper, true),
			Caption = K.Text(f, "Caption", caption, 10, K.Line),
		}
	end
	ui.Cash = counter("Credits", "Credits", "CREDITS")
	ui.Relics = counter("Relics", "Research", "RELICS")
	ui.Bucket = counter("Storage", "Storage", "MATERIALS")
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
	ui.Egg = button("EggDetails", "CURRENT EGG", "Research")
	ui.Egg.Button.BackgroundColor3 = K.Dark
	ui.Egg.Label.TextColor3 = K.Paper
	ui.EggPercent = K.Text(ui.Egg.Button, "Percent", "", 13, K.Paper)
	ui.EggTrack, ui.EggFill = bar(ui.Egg.Button, K.Gold)
	ui.EggCaption = K.Text(ui.Egg.Button, "Caption", "EXCAVATION", 10, K.Line)
	ui.Details = K.Surface(root, "EggDetailsPanel", K.Card)
	ui.Details.Visible = false
	ui.Details.ZIndex = 20
	ui.DetailText = K.Text(ui.Details, "Text", "", 14, K.Ink)
	ui.DetailText.ZIndex = 21
	ui.Skills = button("Progression", "SKILLS", "Skills")
	ui.Equipment = button("Upgrades", "TOOLS", "Equipment")
	ui.More = button("More", "EXPLORE", "Explore")
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
	local heading = K.Text(ui.Drawer, "Heading", "Field journal", 26, K.Ink)
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
		local cw = w < 450 and 94 or 112
		for i, c in { self.Cash, self.Relics } do
			K.Rect(c.Frame, m + (i - 1) * (cw + 6), m, cw, 42)
			K.Rect(c.Icon, 5, 5, 30, 30)
			K.Rect(c.Value, 40, 3, cw - 44, 23)
			K.Rect(c.Caption, 40, 25, cw - 44, 12)
		end
		local bw = w < 450 and 104 or 134
		K.Rect(self.Bucket.Frame, w - bw - m, m, bw, 42)
		K.Rect(self.Bucket.Icon, 3, 4, 30, 30)
		K.Rect(self.Bucket.Value, 36, 1, bw - 40, 22)
		K.Rect(self.Bucket.Caption, 36, 22, bw - 40, 13)
		K.Rect(self.BucketTrack, 36, 37, bw - 44, 3)
		K.Rect(self.Sell.Button, w - 74 - m, 58, 74, 36)
		K.Rect(self.Sell.Label, 0, 0, 74, 36)
		K.Rect(self.Progress.Button, m, 58, cw * 2 + 6, 36)
		K.Rect(self.Progress.Label, 8, 2, 45, 25)
		K.Rect(self.XP, 60, 2, cw * 2 - 62, 24)
		K.Rect(self.XPTrack, 60, 29, cw * 2 - 66, 3)
		local ew = w >= 850 and math.min(280, w - 2 * cw - 2 * bw - 60) or math.min(300, w - 20)
		local ey = w >= 850 and 10 or 104
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
		local navY = w >= 850 and 106 or 162
		local nw = w < 450 and 94 or 104
		for i, b in { self.More, self.Equipment, self.Skills } do
			K.Rect(b.Button, m + (i - 1) * (nw + 6), navY, nw, 44)
			K.Rect(b.Icon, 5, 8, 28, 28)
			K.Rect(b.Label, 35, 0, nw - 39, 44)
			b.Label.TextSize = 12
		end
		K.Rect(self.Points, nw - 16, -5, 22, 18)
		local dw = math.min(414, w - 20)
		local dy = navY + 52
		local dh = math.min(436, h - dy - 12)
		K.Rect(self.Drawer, 10, dy, dw, math.max(130, dh))
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
