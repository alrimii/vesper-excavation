-- Actual owned tool models, one selection callback; no parallel inventory or combat input.
local M = {}
function M.Build(gui, player, selectTool)
	local C = require(script.Parent.ExcavationChrome)
	local Rules = require(script.Parent.ProgressionRules)
	local Preview = require(script.Parent.EquipmentPreview)
	local UIS = game:GetService("UserInputService")
	local root = C.Make(
		"Frame",
		gui,
		{ Name = "EquipmentDock", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 1), ZIndex = 5, Visible = false }
	)
	C.Make(
		"UIListLayout",
		root,
		{
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}
	)
	local cards = {}
	for i, id in Rules.ToolOrder do
		local b = C.Button(root, id, function()
			selectTool(id)
		end, C.White, 18)
		b.LayoutOrder = i
		local view = Preview.Create(b, script.Parent.EquipmentAssets:FindFirstChild(id))
		if view then
			view.Position, view.Size, view.ZIndex = UDim2.fromOffset(7, 1), UDim2.new(1, -14, 1, -19), 7
		end
		local name = C.Text(b, "Label", id == "Explosive" and "CHARGE" or id:upper(), 13)
		name.Position, name.Size = UDim2.new(0, 0, 1, -20), UDim2.new(1, 0, 0, 20)
		local key = C.Text(b, "Key", tostring(i), 12)
		C.Rect(key, 4, 2, 16, 16)
		local flag = C.Text(b, "State", "", 10)
		flag.AnchorPoint, flag.Position, flag.Size =
			Vector2.new(1, 0), UDim2.new(1, -3, 0, 3), UDim2.fromOffset(30, 13)
		cards[id] =
			{ button = b, name = name, key = key, flag = flag, stroke = b:FindFirstChildOfClass("UIStroke") }
	end
	local api = {}
	function api:Update(w, h, pos, blocked)
		root.Size, root.Position = UDim2.fromOffset(w, h), pos
		root.Visible = not blocked and player:GetAttribute("ProfileReady") == true
		local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
		for id, card in cards do
			local trial = id == "Drill"
				and (player:GetAttribute("DrillTrialEndsAt") or 0) > workspace:GetServerTimeNow()
			local owned = player:GetAttribute("OwnsTool_" .. id) == true
			local active = tool
				and tool:GetAttribute("OwnerUserId") == player.UserId
				and tool:GetAttribute("ToolFamily") == id
			card.button.Visible = owned or trial
			card.button.Interactable, card.button.Selectable = not blocked, not blocked
			card.button.Size = UDim2.fromOffset(math.floor((w - 16) / 3), h)
			card.button.BackgroundColor3 = active and C.Gold or C.White
			card.stroke.Thickness = active and 3 or 2
			card.key.Visible = UIS.PreferredInput == Enum.PreferredInput.KeyboardAndMouse
			card.flag.Text = active and "ON" or trial and not owned and "TRIAL" or ""
			card.name.TextSize = h < 65 and 11 or 14
		end
	end
	return api
end
return M
