-- Phase 5: one presentation vocabulary and one modal owner. No gameplay mutations here.
local K = table.clone(require(script.Parent.InterfaceTheme))
local active, bound = nil, false
local atlas = "rbxassetid://132558544808738"
local keys = {
	"Pickaxe",
	"Drill",
	"Explosive",
	"Journal",
	"Explore",
	"Equipment",
	"Settings",
	"Skills",
	"Storage",
	"Research",
	"Creatures",
	"Home",
	"Sound",
	"Motion",
	"Results",
	"Credits",
	"Speed",
	"Precision",
	"Yield",
	"Value",
}
function K.Make(class, parent, props)
	local o = Instance.new(class)
	for k, v in props or {} do
		o[k] = v
	end
	o.Parent = parent
	return o
end
function K.Rect(o, x, y, w, h)
	o.Position = UDim2.fromOffset(x, y)
	o.Size = UDim2.fromOffset(math.max(0, w), math.max(0, h))
end
function K.Round(o, r)
	return K.Make("UICorner", o, { CornerRadius = UDim.new(0, r or 16) })
end
function K.Outline(o, color, thickness)
	return K.Make("UIStroke", o, {
		Name = "Outline",
		Color = color or K.Ink,
		Thickness = thickness or 3,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end
function K.Shine(o)
	return K.Make(
		"UIGradient",
		o,
		{ Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(195, 215, 241)), Rotation = 90 }
	)
end
function K.Surface(parent, name, color)
	local o =
		K.Make("Frame", parent, { Name = name, BackgroundColor3 = color or K.Card, BorderSizePixel = 0 })
	K.Round(o)
	K.Outline(o)
	return o
end
function K.Text(parent, name, value, size, color, bold)
	return K.Make("TextLabel", parent, {
		Name = name,
		Text = value or "",
		TextSize = size or 16,
		Font = bold and K.Bold or K.Font,
		TextColor3 = color or K.Ink,
		BackgroundTransparency = 1,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
	})
end
function K.Button(parent, name, value, callback, secondary)
	local b = K.Make("TextButton", parent, {
		Name = name,
		Text = value or "",
		TextSize = 16,
		Font = K.Bold,
		TextColor3 = secondary and K.Ink or K.Card,
		BackgroundColor3 = secondary and K.Line or K.Green,
		BorderSizePixel = 0,
		AutoButtonColor = true,
		Selectable = true,
	})
	K.Round(b, 12)
	K.Outline(b)
	K.Shine(b)
	local scale = K.Make("UIScale", b, { Scale = 1 })
	local function pulse(targetScale)
		local player = game:GetService("Players").LocalPlayer
		if player and player:GetAttribute("ReducedMotion") then
			return
		end
		game:GetService("TweenService")
			:Create(scale, TweenInfo.new(0.1, Enum.EasingStyle.Quad), { Scale = targetScale })
			:Play()
	end
	b.MouseEnter:Connect(function()
		pulse(1.025)
	end)
	b.MouseLeave:Connect(function()
		pulse(1)
	end)
	b.MouseButton1Down:Connect(function()
		pulse(0.96)
	end)
	b.MouseButton1Up:Connect(function()
		pulse(1)
	end)
	if callback then
		b.Activated:Connect(callback)
	end
	return b
end
function K.Enabled(b, on, label)
	b.Interactable = on
	b.Selectable = on
	b.BackgroundColor3 = on and K.Green or K.Line
	b.TextColor3 = on and K.Card or K.Muted
	if label then
		b.Text = label
	end
end
function K.Icon(parent, key, _color)
	local icon = K.Make("ImageLabel", parent, {
		Name = key .. "Icon",
		BackgroundTransparency = 1,
		Image = atlas,
		ScaleType = Enum.ScaleType.Fit,
		ImageColor3 = Color3.new(1, 1, 1),
	})
	K.SetIcon(icon, key)
	return icon
end
function K.SetIcon(icon, key)
	local i = (table.find(keys, key) or 5) - 1
	icon.Image = atlas
	local row = math.floor(i / 5) + 1
	local y = ({ 0, 310, 585, 845 })[row]
	local height = ({ 305, 270, 260, 275 })[row]
	icon.ImageRectOffset = Vector2.new(math.floor(i % 5 * 204.8), math.floor(y * 1024 / 1402))
	icon.ImageRectSize = Vector2.new(204, math.floor(height * 1024 / 1402))
	icon.ImageColor3 = Color3.new(1, 1, 1)
end
function K.Scroll(parent, name)
	return K.Make("ScrollingFrame", parent, {
		Name = name,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = K.Green,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ClipsDescendants = true,
	})
end
function K.Stack(parent, gap)
	return K.Make(
		"UIListLayout",
		parent,
		{ Padding = UDim.new(0, gap or 10), SortOrder = Enum.SortOrder.LayoutOrder }
	)
end
function K.Paragraph(parent, name, value, size, color)
	local t = K.Text(parent, name, value, size, color)
	t.Size = UDim2.new(1, -12, 0, 0)
	t.AutomaticSize = Enum.AutomaticSize.Y
	t.TextYAlignment = Enum.TextYAlignment.Top
	return t
end
function K.Number(n)
	return tostring(math.floor(n or 0)):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end
function K.Decode(raw)
	local ok, v =
		pcall(game:GetService("HttpService").JSONDecode, game:GetService("HttpService"), raw or "{}")
	return ok and type(v) == "table" and v or {}
end
function K.Shell(player, name, title, attribute, close, maxWidth)
	local pg = player.PlayerGui
	local old = pg:FindFirstChild(name)
	if old then
		old:Destroy()
	end
	local screen = K.Make("ScreenGui", pg, {
		Name = name,
		ResetOnSpawn = false,
		DisplayOrder = 60,
		ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Enabled = false,
	})
	local shade = K.Make("ScreenGui", pg, {
		Name = name .. "Backdrop",
		ResetOnSpawn = false,
		DisplayOrder = 59,
		ScreenInsets = Enum.ScreenInsets.None,
		SafeAreaCompatibility = Enum.SafeAreaCompatibility.None,
		ClipToDeviceSafeArea = false,
		Enabled = false,
	})
	local cover = K.Button(shade, "InputShield", "", nil)
	cover.Size = UDim2.fromScale(1, 1)
	cover.BackgroundColor3 = K.Dark
	cover.BackgroundTransparency = 0.42
	cover.Selectable = false
	cover.AutoButtonColor = false
	cover.Modal = true
	local root = K.Surface(screen, "Panel", K.Paper)
	root.AnchorPoint = Vector2.new(0.5, 0.5)
	root.Position = UDim2.fromScale(0.5, 0.5)
	root.Active = true
	root.ClipsDescendants = true
	local head = K.Surface(root, "Header", K.Purple)
	K.Shine(head)
	local cap = K.Text(head, "Title", title, 30, K.Paper)
	cap.Font = K.Title
	local tag = K.Text(head, "Kicker", "", 10, K.Gold, true)
	local body = K.Make("Frame", root, { Name = "Body", BackgroundTransparency = 1, ClipsDescendants = true })
	local changed = Instance.new("BindableEvent")
	local api =
		{ Screen = screen, Root = root, Body = body, Title = cap, Changed = changed.Event, Open = false }
	local prior
	function api:SetOpen(open)
		if self.Open == open then
			return
		end
		if open then
			if active and active ~= self then
				active:SetOpen(false)
			end
			active = self
			prior = game:GetService("GuiService").SelectedObject
			player:SetAttribute("CoreMenuOpen", false)
		elseif active == self then
			active = nil
		end
		self.Open = open
		screen.Enabled = open
		shade.Enabled = open
		if attribute then
			player:SetAttribute(attribute, open)
		end
		if not open then
			if close then
				close()
			end
			local gs = game:GetService("GuiService")
			if gs.SelectedObject and gs.SelectedObject:IsDescendantOf(root) then
				gs.SelectedObject = prior and prior.Parent and prior or nil
			end
		else
			self:Layout()
			if game:GetService("UserInputService").PreferredInput == Enum.PreferredInput.Gamepad then
				game:GetService("GuiService").SelectedObject = self.Close
			end
		end
	end
	api.Close = K.Button(head, "Close", "X", function()
		api:SetOpen(false)
	end)
	api.Close.BackgroundColor3 = K.Error
	api.Close.TextSize = 26
	function api:Layout()
		local s = screen.AbsoluteSize
		local w = math.min(self.WidthCap or maxWidth or 1040, math.max(100, s.X - 24))
		local h = math.min(self.HeightCap or 700, math.max(100, s.Y - 24))
		K.Rect(root, 0, 0, w, h)
		root.Position = UDim2.fromScale(0.5, 0.5)
		K.Rect(head, 0, 0, w, 64)
		K.Rect(tag, 20, 8, w - 120, 14)
		K.Rect(cap, 20, 8, w - 100, 48)
		K.Rect(self.Close, w - 61, 10, 46, 44)
		K.Rect(body, 18, 78, w - 36, h - 96)
		self.Width = w - 36
		self.Height = h - 96
		self.Narrow = w < 660
		changed:Fire(self.Width, self.Height, self.Narrow)
	end
	screen:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		api:Layout()
	end)
	player.CharacterRemoving:Connect(function()
		api:SetOpen(false)
	end)
	player:GetAttributeChangedSignal("DiscoveryCinematic"):Connect(function()
		if player:GetAttribute("DiscoveryCinematic") then
			api:SetOpen(false)
		end
	end)
	screen.Destroying:Once(function()
		if active == api then
			active = nil
		end
		shade:Destroy()
		changed:Destroy()
	end)
	if not bound then
		bound = true
		game:GetService("UserInputService").InputBegan:Connect(function(i)
			if
				active
				and not game:GetService("UserInputService"):GetFocusedTextBox()
				and (i.KeyCode == Enum.KeyCode.Escape or i.KeyCode == Enum.KeyCode.ButtonB)
			then
				active:SetOpen(false)
			end
		end)
	end
	api:Layout()
	return api
end
function K.Active()
	return active
end
function K.CloseAll()
	if active then
		active:SetOpen(false)
	end
end
function K.Confirm(shell, title, message, accept)
	local old = shell.Root:FindFirstChild("Confirmation")
	if old then
		old:Destroy()
	end
	local shield = K.Button(shell.Root, "Confirmation", "", nil, true)
	shield.Size = UDim2.fromScale(1, 1)
	shield.BackgroundColor3 = K.Dark
	shield.BackgroundTransparency = 0.15
	shield.ZIndex = 30
	shield.Selectable = false
	local card = K.Surface(shield, "Dialog", K.Card)
	card.AnchorPoint = Vector2.new(0.5, 0.5)
	card.Position = UDim2.fromScale(0.5, 0.5)
	card.Size = UDim2.new(1, -32, 0, 260)
	card.ZIndex = 31
	K.Make("UISizeConstraint", card, { MaxSize = Vector2.new(480, 260) })
	local t = K.Text(card, "Title", title, 25, K.Ink, true)
	t.Position = UDim2.fromOffset(18, 14)
	t.Size = UDim2.new(1, -36, 0, 38)
	t.ZIndex = 32
	local m = K.Text(card, "Message", message, 16, K.Muted)
	m.Position = UDim2.fromOffset(18, 58)
	m.Size = UDim2.new(1, -36, 0, 112)
	m.ZIndex = 32
	local cancel = K.Button(card, "Cancel", "Keep my build", function()
		shield:Destroy()
	end, true)
	cancel.Position = UDim2.new(0, 18, 1, -64)
	cancel.Size = UDim2.new(0.5, -24, 0, 44)
	cancel.ZIndex = 32
	local yes = K.Button(card, "Confirm", "Reset skills", function()
		shield:Destroy()
		accept()
	end)
	yes.Position = UDim2.new(0.5, 6, 1, -64)
	yes.Size = UDim2.new(0.5, -24, 0, 44)
	yes.ZIndex = 32
	local connection
	connection = shell.Screen:GetPropertyChangedSignal("Enabled"):Connect(function()
		if not shell.Screen.Enabled then
			shield:Destroy()
		end
	end)
	shield.Destroying:Once(function()
		connection:Disconnect()
	end)
	game:GetService("GuiService").SelectedObject = cancel
end
return K
