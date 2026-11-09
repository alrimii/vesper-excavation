-- Existing owned equipment, selected through the original server-validated callback.
local M = {}
function M.Build(gui, player, selectTool)
	local Rules = require(script.Parent.ProgressionRules)
	local Preview = require(script.Parent.EquipmentPreview)
	local Style = require(script.Parent.InterfaceStyle)
	local UIS = game:GetService("UserInputService")
	local root = Instance.new("Frame")
	root.Name, root.BackgroundTransparency, root.AnchorPoint, root.ZIndex =
		"Toolbelt", 1, Vector2.new(0.5, 1), 5
	root.Visible, root.Parent = false, gui
	local layout = Instance.new("UIListLayout")
	layout.FillDirection, layout.HorizontalAlignment =
		Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Center
	layout.Padding, layout.SortOrder, layout.Parent = UDim.new(0, 6), Enum.SortOrder.LayoutOrder, root
	local cards = {}
	for index, id in Rules.ToolOrder do
		local b = Instance.new("TextButton")
		b.Name, b.Text, b.LayoutOrder, b.ZIndex = id, "", index, 5
		b.BackgroundColor3, b.BorderSizePixel, b.Parent = Color3.fromRGB(255, 246, 220), 0, root
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 12)
		local stroke = Instance.new("UIStroke")
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Thickness, stroke.Color, stroke.Parent = 1.5, Color3.fromRGB(84, 112, 119), b
		Style.Button(b)
		local function label(name, text, pos, size)
			local t = Instance.new("TextLabel")
			t.Name, t.Text, t.Position, t.Size = name, text, pos, size
			t.BackgroundTransparency, t.TextColor3, t.TextSize = 1, Color3.fromRGB(37, 56, 64), 12
			t.Font, t.ZIndex, t.Parent = Enum.Font.FredokaOne, 7, b
			return t
		end
		local key = label("Key", tostring(index), UDim2.fromOffset(3, 2), UDim2.fromOffset(16, 16))
		local name = label(
			"Name",
			id == "Explosive" and "CHARGE" or id:upper(),
			UDim2.new(0, 0, 1, -19),
			UDim2.new(1, 0, 0, 18)
		)
		local state = label("State", "", UDim2.new(1, -42, 0, 2), UDim2.fromOffset(40, 15))
		state.TextSize = 10
		local view = Preview.Create(b, script.Parent.EquipmentAssets:FindFirstChild(id))
		if view then
			view.Position, view.Size, view.ZIndex = UDim2.fromOffset(3, 2), UDim2.new(1, -6, 1, -20), 6
		end
		b.Activated:Connect(function()
			selectTool(id)
		end)
		cards[id] = { button = b, key = key, state = state, stroke = stroke, name = name }
	end
	local api = {}
	function api:Update(width, height, position, blocked)
		root.Size, root.Position = UDim2.fromOffset(width, height), position
		root.Visible = not blocked and player:GetAttribute("ProfileReady") == true
		local ch = player.Character
		local tool = ch and ch:FindFirstChildOfClass("Tool")
		local family = tool and tool:GetAttribute("ToolFamily")
		for id, card in cards do
			local expires = player:GetAttribute("DrillTrialEndsAt")
			local trial = id == "Drill"
				and typeof(expires) == "number"
				and expires > workspace:GetServerTimeNow()
			local owned = player:GetAttribute("OwnsTool_" .. id) == true
			local available = owned or trial
			local active = tool and tool:GetAttribute("OwnerUserId") == player.UserId and family == id
			card.button.Visible, card.button.Interactable, card.button.Selectable =
				available, available and not blocked, available and not blocked
			card.button.Size = UDim2.fromOffset(math.floor((width - 12) / 3), height)
			card.button.BackgroundColor3 = active and Color3.fromRGB(113, 232, 187)
				or Color3.fromRGB(255, 246, 220)
			card.stroke.Color, card.stroke.Thickness =
				active and Color3.fromRGB(29, 118, 91) or Color3.fromRGB(56, 84, 87), active and 3 or 2
			card.name.TextSize = height < 64 and 11 or 13
			card.state.Text = active and "HELD" or trial and not owned and "TRIAL" or ""
			card.key.Visible = UIS.PreferredInput == Enum.PreferredInput.KeyboardAndMouse
		end
	end
	return api
end
return M
