-- Owned-tool selection. Purchase and server-confirmed equip remain separate.
local M = {}
function M.Build(gui, player, selectTool)
	local Rules = require(script.Parent.ProgressionRules)
	local Preview = require(script.Parent.EquipmentPreview)
	local UIS = game:GetService("UserInputService")
	local Tween = game:GetService("TweenService")
	local root = Instance.new("Frame")
	root.Name = "Toolbelt"
	root.BackgroundTransparency = 1
	root.AnchorPoint = Vector2.new(0.5, 1)
	root.Position = UDim2.new(0.5, 0, 1, -18)
	root.Size = UDim2.fromOffset(278, 87)
	root.ZIndex = 5
	root.Parent = gui
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Padding = UDim.new(0, 7)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = root
	local cards = {}
	for index, id in Rules.ToolOrder do
		local b = Instance.new("TextButton")
		b.Name, b.Text = id, ""
		b.Size = UDim2.fromOffset(86, 82)
		b.BackgroundColor3 = Color3.fromRGB(24, 33, 48)
		b.AutoButtonColor = false
		b.BorderSizePixel = 0
		b.LayoutOrder = index
		b.ZIndex = 5
		b.Parent = root
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 13)
		corner.Parent = b
		local stroke = Instance.new("UIStroke")
		stroke.Thickness = 1.5
		stroke.Color = Color3.fromRGB(73, 88, 109)
		stroke.Parent = b
		local scale = Instance.new("UIScale")
		scale.Parent = b
		local function label(name, value, pos, size, textSize)
			local t = Instance.new("TextLabel")
			t.Name, t.Text = name, value
			t.Position, t.Size = pos, size
			t.BackgroundTransparency = 1
			t.TextColor3 = Color3.fromRGB(230, 239, 250)
			t.Font = Enum.Font.GothamBold
			t.TextSize = textSize
			t.ZIndex = 7
			t.Parent = b
			return t
		end
		local key = label("Key", tostring(index), UDim2.fromOffset(5, 3), UDim2.fromOffset(18, 18), 11)
		local name = label(
			"Name",
			id == "Explosive" and "CHARGE" or id:upper(),
			UDim2.new(0, 0, 1, -24),
			UDim2.new(1, 0, 0, 18),
			10
		)
		local state = label("State", "", UDim2.new(1, -56, 0, 5), UDim2.fromOffset(50, 14), 8)
		local view = Preview.Create(b, script.Parent.EquipmentAssets:FindFirstChild(id))
		if view then
			view.Position, view.Size = UDim2.fromOffset(7, 12), UDim2.new(1, -14, 1, -32)
			view.ZIndex = 6
		end
		b.Activated:Connect(function()
			selectTool(id)
		end)
		b.MouseEnter:Connect(function()
			Tween:Create(scale, TweenInfo.new(0.12), { Scale = 1.04 }):Play()
		end)
		b.MouseLeave:Connect(function()
			Tween:Create(scale, TweenInfo.new(0.12), { Scale = 1 }):Play()
		end)
		cards[id] = { button = b, stroke = stroke, key = key, state = state, view = view, title = name }
	end
	local function refresh()
		local selected = player:GetAttribute("ToolFamily") or "Pickaxe"
		for id, card in cards do
			local owned = player:GetAttribute("OwnsTool_" .. id) or id == "Pickaxe"
			local trial = id == "Drill" and player:GetAttribute("DrillTrialEndsAt") ~= nil
			local available = owned or trial
			local active = selected == id
			card.button.Interactable, card.button.Selectable = available, available
			card.stroke.Color = active and Rules.Tools[id].Color or Color3.fromRGB(73, 88, 109)
			card.stroke.Thickness = active and 2.5 or 1.5
			card.button.BackgroundColor3 = active and Color3.fromRGB(38, 53, 65) or Color3.fromRGB(24, 33, 48)
			card.state.Text = not available and "LOCKED"
				or trial and not owned and "TRIAL"
				or active and "ACTIVE"
				or ""
			card.state.TextColor3 = active and Rules.Tools[id].Color or Color3.fromRGB(159, 175, 193)
			card.title.TextTransparency = available and 0 or 0.45
			if card.view then
				card.view.ImageTransparency = available and 0 or 0.62
			end
			card.key.Visible = UIS.PreferredInput == Enum.PreferredInput.KeyboardAndMouse
		end
		root.Visible = player:GetAttribute("LabReady") == true
			and not player:GetAttribute("ResearchModal")
			and not player:GetAttribute("DiscoveryCinematic")
			and not player:GetAttribute("Training")
	end
	local function resize()
		local small = gui.AbsoluteSize.X < 600
		root.Size = UDim2.fromOffset(small and 224 or 278, small and 74 or 87)
		root.Position = UDim2.new(0.5, 0, 1, small and -9 or -18)
		for _, c in cards do
			c.button.Size = UDim2.fromOffset(small and 70 or 86, small and 70 or 82)
		end
	end
	for _, id in Rules.ToolOrder do
		player:GetAttributeChangedSignal("OwnsTool_" .. id):Connect(refresh)
	end
	for _, name in
		{ "ToolFamily", "DrillTrialEndsAt", "LabReady", "ResearchModal", "DiscoveryCinematic", "Training" }
	do
		player:GetAttributeChangedSignal(name):Connect(refresh)
	end
	UIS:GetPropertyChangedSignal("PreferredInput"):Connect(refresh)
	gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
	resize()
	refresh()
	return root
end
return M
