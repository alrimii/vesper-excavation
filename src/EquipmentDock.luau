-- Owned tool selection uses the same Phase 4 models as the equipment catalogue.
local M = {}
function M.Build(gui, player, selectTool)
	local K = require(script.Parent.InterfaceKit)
	local root = K.Make(
		"Frame",
		gui,
		{ Name = "EquipmentDock", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 1), Visible = false }
	)
	local cards = {}
	for i, id in require(script.Parent.ProgressionRules).ToolOrder do
		local b = K.Button(root, id, "", function()
			selectTool(id)
		end, true)
		local view = require(script.Parent.EquipmentPreview).Create(b, script.Parent.EquipmentAssets[id])
		view.Position = UDim2.fromOffset(14, 0)
		view.Size = UDim2.new(1, -28, 1, -18)
		local label = K.Text(b, "Label", id == "Explosive" and "CHARGE" or id:upper(), 11, K.Ink, true)
		label.Position = UDim2.new(0, 0, 1, -20)
		label.Size = UDim2.new(1, 0, 0, 20)
		label.TextXAlignment = Enum.TextXAlignment.Center
		local key = K.Text(b, "Key", tostring(i), 11, K.Muted)
		K.Rect(key, 4, 2, 14, 16)
		local edge = K.Make(
			"UIStroke",
			b,
			{ Thickness = 1, Color = K.Gold, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }
		)
		cards[id] = { b = b, key = key, edge = edge }
	end
	return {
		Update = function(_, w, h, pos, blocked)
			root.Size = UDim2.fromOffset(w, h)
			root.Position = pos
			root.Visible = not blocked and player:GetAttribute("ProfileReady") == true
			local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
			for i, id in require(script.Parent.ProgressionRules).ToolOrder do
				local c = cards[id]
				local trial = id == "Drill"
					and (player:GetAttribute("DrillTrialEndsAt") or 0) > workspace:GetServerTimeNow()
				c.b.Visible = player:GetAttribute("OwnsTool_" .. id) == true or trial
				c.b.Interactable = not blocked
				c.b.Selectable = not blocked
				K.Rect(c.b, (i - 1) * (w + 6) / 3, 0, (w - 12) / 3, h)
				local active = tool
					and tool:GetAttribute("OwnerUserId") == player.UserId
					and tool:GetAttribute("ToolFamily") == id
				c.b.BackgroundColor3 = active and K.Paper or K.Line
				c.edge.Thickness = active and 3 or 0
				c.key.Visible = game:GetService("UserInputService").PreferredInput
					== Enum.PreferredInput.KeyboardAndMouse
			end
		end,
	}
end
return M
