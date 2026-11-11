-- Illustrated edge navigation and real level/XP progression. No invented stats.
local V = {}
function V.Build(gui, callbacks)
	local K = require(script.Parent.InterfaceKit)
	local A = require(script.Parent.SimulatorStyle)
	local root = K.Make(
		"Frame",
		gui,
		{ Name = "FieldHUD", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false }
	)
	local ui = { Root = root }
	local function button(name, label, key, color)
		if key then
			return A.Nav(root, name, label, key, callbacks[name], color)
		end
		local b = A.Button(root, name, "", callbacks[name], color)
		return { Button = b, Label = A.Text(b, "Label", label, 18) }
	end
	local function counter(name, key, caption)
		local f = K.Make("Frame", root, { Name = name, BackgroundTransparency = 1 })
		local c = {
			Frame = f,
			Plate = f,
			Icon = K.Icon(f, key),
			Value = A.Text(f, "Value", "", 34),
			Caption = A.Text(f, "Caption", caption, 12),
		}
		c.Value.TextScaled = true
		K.Make("UITextSizeConstraint", c.Value, { MinTextSize = 18, MaxTextSize = 36 })
		return c
	end
	local function bar(parent, color)
		local t = K.Surface(parent, "Track", A.Ink)
		t.ClipsDescendants = true
		local f = K.Make(
			"Frame",
			t,
			{ Name = "Fill", BorderSizePixel = 0, Size = UDim2.fromScale(0, 1), BackgroundColor3 = color }
		)
		K.Round(f, 12)
		K.Shine(f)
		return t, f
	end
	ui.Cash = counter("Credits", "Credits", "CREDITS")
	ui.Relics = counter("Relics", "Research", "RELICS")
	ui.Bucket = counter("Storage", "Storage", "MATERIALS")
	ui.BucketTrack, ui.BucketFill = bar(ui.Bucket.Frame, A.Gold)
	ui.Sell = button("Sell", "SELL", nil, A.Green)
	ui.Egg = button("EggDetails", "CURRENT EGG", nil, A.Teal)
	ui.Egg.Icon = K.Icon(ui.Egg.Button, "Research")
	ui.EggPercent = A.Text(ui.Egg.Button, "Percent", "", 20)
	ui.EggTrack, ui.EggFill = bar(ui.Egg.Button, A.Gold)
	ui.EggCaption = A.Text(ui.Egg.Button, "Caption", "EXCAVATION", 10)
	ui.EggCaption.Visible = false
	ui.Details = A.Card(root, "EggDetailsPanel", A.Teal)
	ui.Details.Visible = false
	ui.Details.ZIndex = 20
	ui.DetailText = A.Text(ui.Details, "Text", "", 14)
	ui.DetailText.ZIndex = 21
	ui.Equipment = button("Upgrades", "TOOLS", "Equipment", A.Gold)
	ui.Skills = button("Progression", "SKILLS", "Skills", A.Purple)
	ui.Journal = button("Journal", "JOURNAL", "Journal", A.Blue)
	ui.Creatures = button("Creatures", "CREATURES", "Creatures", A.Green)
	ui.More = button("More", "MENU", "Explore", A.Blue)
	ui.Progress = button("ProgressionStrip", "LV 0", nil, A.Teal)
	ui.Progress.Button.Activated:Connect(callbacks.Progression)
	ui.XPTrack, ui.XPFill = bar(ui.Progress.Button, A.Green)
	ui.XP = A.Text(ui.Progress.Button, "XP", "", 22)
	ui.XP.ZIndex = 4
	ui.Progress.Label.ZIndex = 4
	ui.Points = A.Text(ui.Skills.Button, "Points", "", 18, A.Gold)
	ui.Points.ZIndex = 5
	ui.Guide = A.Card(root, "ContextHint", A.Teal)
	ui.Hint = A.Text(ui.Guide, "Text", "", 14)
	ui.Dismiss = A.Button(ui.Guide, "Dismiss", "×", callbacks.Dismiss, A.Pink)
	ui.Drawer = K.Make(
		"Frame",
		root,
		{ Name = "UtilityRow", BackgroundTransparency = 1, Visible = false, ZIndex = 20, Active = true }
	)
	ui.List = K.Scroll(ui.Drawer, "Destinations")
	ui.List.ZIndex = 21
	ui.List.ScrollBarThickness = 0
	local grid = K.Make("UIGridLayout", ui.List, {
		CellSize = UDim2.fromOffset(72, 84),
		CellPadding = UDim2.fromOffset(10, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	ui.Contract = A.Text(ui.Drawer, "Contract", "", 12)
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
		Equipment = "Tools",
		Creatures = "Creatures",
		Home = "My room",
		Decorate = "Collection",
		Settings = "Settings",
		Help = "Help",
		EggResults = "Results",
		Train = "Training",
	}
	function ui:AddEntry(name, label, callback)
		local n = A.Nav(self.List, name, short[name] or label, entryKeys[name] or "Explore", callback, A.Teal)
		n.Button.ZIndex = 22
		n.Badge.ZIndex = 22
		n.Icon.ZIndex = 23
		n.Label.ZIndex = 24
		A.NavLayout(n, 68, 78)
		n.Label.TextSize = 13
		return n.Button
	end
	local old = gui:FindFirstChild("Use")
	if old then
		old:Destroy()
	end
	ui.Use = A.Button(gui, "Use", "", nil, A.Green)
	ui.UseLabel = A.Text(ui.Use, "Action", "STRIKE", 20)
	ui.UseHint = A.Text(ui.Use, "Hint", "", 11)
	ui.Charged = button("ChargedSwing", "CHARGED", nil, A.Purple)
	ui.Flow = A.Text(root, "Flow", "", 16, A.Gold)
	ui.Training = button("Training", "STOP TRAINING", nil, A.Pink)
	function ui:Layout(w, h, _touch)
		local narrow = w < 700
		local compact = narrow or h < 450
		self.Phone = compact
		local cwidth = narrow and 147 or 224
		local cs = narrow and 42 or 54
		for i, c in { self.Cash, self.Relics } do
			K.Rect(c.Frame, 12, 4 + (i - 1) * (cs + 2), cwidth, cs)
			K.Rect(c.Icon, 0, -2, cs, cs)
			K.Rect(c.Value, cs + 2, -2, cwidth - cs - 2, cs * 0.7)
			K.Rect(c.Caption, cs + 4, cs * 0.65, cwidth - cs, 16)
		end
		local bw = narrow and 148 or 208
		K.Rect(self.Bucket.Frame, w - bw - 12, 4, bw, 60)
		K.Rect(self.Bucket.Icon, 0, 0, 48, 48)
		K.Rect(self.Bucket.Value, 50, 0, bw - 50, 32)
		K.Rect(self.Bucket.Caption, 52, 31, bw - 52, 16)
		K.Rect(self.BucketTrack, 52, 52, bw - 56, 5)
		K.Rect(self.Sell.Button, w - 100, 70, 88, 38)
		K.Rect(self.Sell.Label, 0, 0, 88, 38)
		self.Sell.Label.TextXAlignment = Enum.TextXAlignment.Center
		local ew = narrow and 210 or 268
		local ey = narrow and 116 or 4
		K.Rect(self.Egg.Button, (w - ew) / 2, ey, ew, 52)
		K.Rect(self.Egg.Icon, -6, -6, 58, 58)
		self.Egg.Icon.ImageRectSize = Vector2.zero
		self.Egg.Icon.ImageRectOffset = Vector2.zero
		K.Rect(self.Egg.Label, 52, 2, ew - 112, 28)
		self.Egg.Label.TextSize = narrow and 12 or 14
		K.Rect(self.EggPercent, ew - 49, 4, 46, 28)
		K.Rect(self.EggTrack, 56, 36, ew - 70, 7)
		K.Rect(self.Details, (w - ew) / 2, ey + 60, ew, 108)
		K.Rect(self.DetailText, 10, 8, ew - 20, 92)
		local nw = narrow and 68 or 86
		local nh = narrow and 78 or 96
		local ny = narrow and 184 or 140
		for i, n in { self.Equipment, self.Skills, self.Journal, self.Creatures } do
			n.Button.Visible = not narrow or i <= 2
			local column = not narrow and (i - 1) % 2 or 0
			local row = not narrow and math.floor((i - 1) / 2) or i - 1
			K.Rect(n.Button, 12 + column * (nw + 12), ny + row * (nh + 14) + column * 12, nw, nh)
			A.NavLayout(n, nw, nh)
			n.Label.TextSize = narrow and 15 or 18
		end
		K.Rect(self.Points, nw - 15, -3, 30, 28)
		K.Rect(
			self.More.Button,
			w - (narrow and 66 or 76) - 12,
			120 + (narrow and 55 or 0),
			narrow and 66 or 76,
			narrow and 72 or 82
		)
		A.NavLayout(self.More, narrow and 66 or 76, narrow and 72 or 82)
		self.More.Label.TextSize = 13
		local dw = narrow and math.min(318, w - 24) or math.min(680, w - 240)
		local rows = narrow and 3 or math.max(1, math.ceil(grid.AbsoluteContentSize.Y / 90))
		local dy = narrow and 250 or 112
		K.Rect(self.Drawer, w - dw - 12, dy, dw, rows * 88 + 60)
		K.Rect(self.List, 4, 0, dw - 8, rows * 88)
		grid.FillDirectionMaxCells = narrow and 4 or 8
		K.Rect(self.Contract, 8, rows * 88 + 2, dw - 16, 56)
		self.Contract.TextXAlignment = Enum.TextXAlignment.Right
		local pw = math.min(650, w - 24)
		local ph = 36
		K.Rect(self.Progress.Button, (w - pw) / 2, h - ph - 8, pw, ph)
		K.Rect(self.XPTrack, 3, 3, pw - 6, ph - 6)
		K.Rect(self.Progress.Label, 10, 0, 90, ph)
		self.Progress.Label.TextSize = narrow and 18 or 24
		K.Rect(self.XP, 100, 0, pw - 110, ph)
		self.XP.TextXAlignment = Enum.TextXAlignment.Right
		self.XP.TextSize = narrow and 17 or 22
		self.BeltWidth, self.BeltHeight = compact and 204 or 252, compact and 58 or 68
		self.BeltPosition = UDim2.new(0.5, 0, 1, -54)
		K.Rect(self.Use, w - 102, h - 142, 90, 76)
		K.Rect(self.UseLabel, 0, 10, 90, 32)
		K.Rect(self.UseHint, 0, 43, 90, 22)
		self.UseLabel.TextXAlignment = Enum.TextXAlignment.Center
		self.UseHint.TextXAlignment = Enum.TextXAlignment.Center
		K.Rect(self.Charged.Button, w - 104, h - 194, 94, 42)
		K.Rect(self.Charged.Label, 2, 0, 90, 42)
		self.Charged.Label.TextSize = 12
		local gw = math.min(330, w - 24)
		K.Rect(self.Guide, (w - gw) / 2, h - self.BeltHeight - (narrow and 150 or 104), gw, 36)
		K.Rect(self.Hint, 10, 0, gw - 52, 36)
		K.Rect(self.Dismiss, gw - 35, 3, 30, 30)
		K.Rect(self.Flow, (w - 240) / 2, h - self.BeltHeight - 100, 240, 30)
		K.Rect(self.Training.Button, (w - 184) / 2, h - 104, 184, 44)
		K.Rect(self.Training.Label, 0, 0, 184, 44)
	end
	return ui
end
return V
