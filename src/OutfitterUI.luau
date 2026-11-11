-- Field equipment catalogue. Quotes, receipts and server actions retain authority.
local M = {}
function M.Build(shell, player, base, remote, feedback)
	local K = require(script.Parent.InterfaceKit)
	local A = require(script.Parent.SimulatorStyle)
	local Rules = require(script.Parent.ProgressionRules)
	local E = require(script.Parent.UpgradeEconomy)
	local P = require(script.Parent.UpgradePresentation)
	local Preview = require(script.Parent.EquipmentPreview)
	local root = K.Make(
		"Frame",
		shell.Body,
		{ Name = "Equipment", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 }
	)
	local page, selected, quantity = "TOOLS", "Pickaxe", 1
	local dirty, pending, lastSize = true, nil, Vector2.zero
	local tab1 = A.Button(root, "EquipmentTab", "Equipment", function()
		page = "TOOLS"
		dirty = true
	end, A.Blue)
	local tab2 = A.Button(root, "UpgradesTab", "Upgrades", function()
		page = "RIG"
		dirty = true
	end, A.Blue)
	local wallet = A.Text(root, "Balance", "", 26, A.Gold)
	local selectors = {}
	for _, id in Rules.ToolOrder do
		local b = A.Button(root, "Select" .. id, "", function()
			selected = id
			dirty = true
		end, A.Blue)
		selectors[id] = {
			b = b,
			icon = K.Icon(b, id),
			title = A.Text(b, "Name", id == "Explosive" and "Charge" or id, 22),
			state = A.Text(b, "State", "", 12),
		}
	end
	local scroll = K.Scroll(root, "EquipmentContent")
	local stage = A.Card(scroll, "ToolStage", A.Blue)
	A.Pattern(stage)
	local views = {}
	for _, id in Rules.ToolOrder do
		views[id] = Preview.Create(stage, script.Parent.EquipmentAssets[id])
	end
	local detail = A.Card(scroll, "ToolDetails", A.Teal)
	local name = A.Text(stage, "Name", "", 30)
	name.ZIndex = 5
	name.TextXAlignment = Enum.TextXAlignment.Center
	name.Font = K.Title
	local role = A.Text(detail, "Role", "", 18, A.Gold)
	local stats = A.Text(detail, "Stats", "", 20)
	local powerLabel = A.Text(detail, "Power", "", 64, A.Gold)
	local hint = A.Text(detail, "Availability", "", 14)
	local receipt = A.Text(root, "Receipt", "", 14)
	local function attr(k)
		return player:GetAttribute(k)
	end
	local function send(kind, a, b)
		if pending then
			return
		end
		pending = { id = game:GetService("HttpService"):GenerateGUID(false), at = os.clock() }
		remote:FireServer(kind, a, b, pending.id, selected)
		receipt.Text = "Waiting for confirmation…"
		dirty = true
	end
	local action = A.Button(root, "PrimaryAction", "", function()
		send(attr("OwnsTool_" .. selected) and "EquipTool" or "BuyTool", selected)
	end)
	local trial = A.Button(detail, "Trial", "Try drill · 90 seconds", function()
		remote:FireServer("TryDrill")
		dirty = true
	end, A.Blue)
	local quantityHost = K.Make("Frame", scroll, { Name = "Quantity", BackgroundTransparency = 1 })
	local qtyLabel = A.Text(quantityHost, "Label", "BUY RANKS", 14)
	local qty = {}
	for i, v in { 1, 5, "Max" } do
		qty[i] = A.Button(quantityHost, "Quantity" .. v, tostring(v), function()
			quantity = v
			dirty = true
		end, A.Blue)
	end
	local rows = {}
	local names = {
		Power = "Impact",
		Speed = "Tempo",
		Capacity = "Storage",
		Precision = "Precision",
		Yield = "Extraction",
		Value = "Refining",
		Critical = "Resonance",
	}
	local descriptions = {
		Power = "Damage per contact",
		Speed = "Time between attacks",
		Capacity = "Material capacity",
		Precision = "Accurate contact bonus",
		Yield = "Extra material at full share",
		Value = "Material sale multiplier",
		Critical = "Chance of a 1.5× hit",
	}
	for index, key in E.Order do
		local row = A.Card(scroll, key, ({ A.Blue, A.Purple, A.Teal })[(index - 1) % 3 + 1])
		rows[key] = {
			root = row,
			icon = K.Icon(row, "Storage"),
			title = A.Text(row, "Name", names[key], 22),
			rank = A.Text(row, "Rank", "", 13),
			value = A.Text(row, "Comparison", "", 24, A.Gold),
			why = A.Text(row, "Benefit", descriptions[key], 13),
			buy = A.Button(row, "Upgrade", "", function()
				send("Upgrade", key, quantity)
			end),
		}
	end
	local roles = {
		Pickaxe = "Make every swing count!",
		Drill = "Keep the treasure flowing!",
		Explosive = "Set it. Step back. BOOM!",
	}
	local function effect(key, rank, config)
		if key == "Power" then
			return K.Number(
				math.floor(
					(config.Mining.Power + rank * config.Upgrades.Power.Step) * (attr("PowerBonus") or 1)
				)
			)
		end
		if key == "Speed" then
			return string.format(
				"%.3fs",
				math.max(
					config.Mining.MinimumCooldown,
					config.Mining.Cooldown - rank * config.Upgrades.Speed.Step
				)
			)
		end
		if key == "Yield" then
			return "+" .. rank
		end
		return E.Effect(key, rank, config):match("^%S+") or ""
	end
	feedback.OnClientEvent:Connect(function(kind, id, ok, message)
		if kind == "ShopReceipt" and pending and id == pending.id then
			pending = nil
			if ok and not attr("ReducedMotion") then
				local scale = receipt:FindFirstChildOfClass("UIScale")
					or K.Make("UIScale", receipt, { Scale = 1 })
				scale.Scale = 0.96
				game:GetService("TweenService")
					:Create(scale, TweenInfo.new(0.18, Enum.EasingStyle.Back), { Scale = 1 })
					:Play()
			end
			receipt.Text = message or (ok and "Confirmed" or "Please try again")
			receipt.TextColor3 = ok and A.Gold or A.Pink
			dirty = true
		end
	end)
	player.AttributeChanged:Connect(function()
		dirty = true
	end)
	local api = { Root = root }
	function api:Select(p)
		page = p == "RIG" and "RIG" or "TOOLS"
		selected = attr("ToolFamily") or "Pickaxe"
		dirty = true
		scroll.CanvasPosition = Vector2.zero
	end
	function api:Update()
		if not root.Visible then
			return
		end
		if root.AbsoluteSize ~= lastSize then
			lastSize = root.AbsoluteSize
			dirty = true
		end
		if pending and os.clock() - pending.at > 12 then
			receipt.Text = "Still waiting for the server. Your request has not been repeated."
		end
		if not dirty then
			return
		end
		dirty = false
		shell.Title.Text = page == "TOOLS" and "Equipment" or "Tool upgrades"
		local w, h = root.AbsoluteSize.X, root.AbsoluteSize.Y
		local narrow = w < 660
		local tw = narrow and 128 or 160
		K.Rect(tab1, 0, 0, tw, 40)
		K.Rect(tab2, tw + 8, 0, tw, 40)
		tab1.TextSize = narrow and 19 or 23
		tab2.TextSize = tab1.TextSize
		wallet.Visible = w >= 500
		K.Rect(wallet, tw * 2 + 30, 0, w - tw * 2 - 32, 40)
		wallet.Text = K.Number(attr("Cash")) .. " credits"
		wallet.TextXAlignment = Enum.TextXAlignment.Right
		tab1.BackgroundColor3 = page == "TOOLS" and A.Gold or A.Teal
		tab2.BackgroundColor3 = page == "RIG" and A.Gold or A.Teal
		local sw = (w - 16) / 3
		local cash = attr("Cash") or 0
		for i, id in Rules.ToolOrder do
			local s = selectors[id]
			K.Rect(s.b, (i - 1) * (sw + 8), 60, sw, 64)
			K.Rect(s.icon, narrow and 0 or 6, -15, narrow and 44 or 82, 82)
			local x = narrow and 40 or 88
			K.Rect(s.title, x, 5, sw - x - 2, 28)
			s.title.TextSize = narrow and 14 or 23
			K.Rect(s.state, x, 34, sw - x - 2, 22)
			s.state.TextSize = narrow and 10 or 13
			s.state.Text = attr("ToolFamily") == id and "Equipped"
				or attr("OwnsTool_" .. id) and "Owned"
				or cash >= Rules.Tools[id].Cost and "Available"
				or "Locked"
			s.b.BackgroundColor3 = selected == id and A.Gold or A.Teal
			s.b.Outline.Color = selected == id and A.White or A.Ink
		end
		K.Rect(scroll, 0, 140, w, h - 224)
		K.Rect(action, 0, h - 72, w, 48)
		action.TextSize = 25
		K.Rect(receipt, 0, h - 22, w, 22)
		local owned = attr("OwnsTool_" .. selected) == true
		local equipped = attr("ToolFamily") == selected
		local ready = attr("LabReady") == true and attr("Cash") ~= nil
		local config = Rules.ToolConfig(selected, base)
		local power, cd = P.ToolStats(selected, player, Rules, base)
		powerLabel.Text = K.Number(power)
		local price = Rules.Tools[selected].Cost
		name.Text = Rules.Tools[selected].Name
		role.Text = roles[selected]
		stats.Text = selected == "Drill"
				and string.format("DAMAGE / TICK\n%.3fs interval · %.1f DPS", cd, power / cd)
			or selected == "Explosive" and string.format(
				"CENTER DAMAGE\n%.2fs cooldown · %g stud radius\n%d%% damage at edge",
				cd,
				base.Tools.Explosive.Radius,
				base.Tools.Explosive.EdgeMultiplier * 100
			)
			or string.format("DAMAGE / STRIKE\n%.2fs between swings", cd)
		hint.Text = not ready and "Loading equipment…"
			or not owned and (cash < price and "Need " .. K.Number(price - cash) .. " more credits." or "One-time purchase. Each tool keeps its own upgrades.")
			or not equipped and "Ready to equip."
			or "Equipped · bonuses included."
		A.State(
			action,
			ready and not pending and not equipped and (owned or cash >= price),
			pending and "Confirming…"
				or equipped and "Equipped"
				or owned and "Equip tool"
				or "Buy · " .. K.Number(price)
		)
		trial.Visible = page == "TOOLS"
			and selected == "Drill"
			and not owned
			and not attr("DrillTrialUsed")
			and ready
		stage.Visible = page == "TOOLS"
		stage.BackgroundColor3 = selected == "Pickaxe" and A.Purple
			or selected == "Drill" and A.Blue
			or A.Gold
		detail.Visible = true
		quantityHost.Visible = page == "RIG"
		local cw = w - 8
		local needAction = page == "TOOLS" or not owned or not equipped
		action.Visible = needAction
		if not needAction then
			K.Rect(scroll, 0, 140, w, h - 170)
		end
		if page == "TOOLS" then
			local sh = narrow and 260 or math.max(290, h - 230)
			local swidth = narrow and cw or cw * 0.57
			local dw = narrow and cw or cw * 0.41
			K.Rect(stage, 3, 3, swidth - 6, sh)
			for id, v in views do
				v.Visible = id == selected
				v.Position = UDim2.fromOffset(10, 50)
				v.Size = UDim2.new(1, -20, 1, -62)
			end
			K.Rect(name, 10, 8, swidth - 26, 40)
			name.TextSize = narrow and 25 or 30
			K.Rect(detail, narrow and 3 or cw * 0.59, narrow and sh + 16 or 3, dw - 6, narrow and 260 or sh)
			K.Rect(role, 16, 12, dw - 38, 44)
			K.Rect(powerLabel, 16, 58, dw - 38, 80)
			powerLabel.TextXAlignment = Enum.TextXAlignment.Center
			K.Rect(stats, 16, 138, dw - 38, 76)
			stats.TextSize = 18
			stats.TextXAlignment = Enum.TextXAlignment.Center
			K.Rect(hint, 16, 218, dw - 38, 42)
			K.Rect(trial, 16, 270, dw - 38, 44)
			trial.TextSize = 16
			if trial.Visible then
				detail.Size = UDim2.fromOffset(dw - 6, 320)
			end
		else
			detail.Visible = false
			K.Rect(quantityHost, 0, 0, cw, 44)
			K.Rect(qtyLabel, 2, 0, 100, 40)
			for i, b in qty do
				K.Rect(b, 106 + (i - 1) * 60, 0, 54, 40)
				b.TextSize = 18
				b.BackgroundColor3 = quantity == ({ 1, 5, "Max" })[i] and A.Gold or A.Teal
			end
		end
		name.Visible = page == "TOOLS"
		role.Visible = page == "TOOLS"
		stats.Visible = page == "TOOLS"
		powerLabel.Visible = page == "TOOLS"
		local cols = narrow and 1 or w >= 850 and 3 or 2
		local rw = (cw - (cols - 1) * 12) / cols
		for i, key in E.Order do
			local r = rows[key]
			r.root.Visible = page == "RIG"
			if page ~= "RIG" then
				continue
			end
			K.Rect(
				r.root,
				((i - 1) % cols) * (rw + 12) + 3,
				60 + math.floor((i - 1) / cols) * 222,
				rw - 6,
				208
			)
			K.SetIcon(
				r.icon,
				key == "Power" and selected
					or key == "Capacity" and "Storage"
					or key == "Critical" and "Skills"
					or key
			)
			K.Rect(r.icon, 10, 4, 82, 82)
			K.Rect(r.title, 96, 12, rw - 110, 30)
			K.Rect(r.rank, 96, 44, rw - 110, 38)
			K.Rect(r.value, 14, 88, rw - 34, 34)
			r.value.TextSize = rw < 300 and 20 or 24
			K.Rect(r.why, 14, 123, rw - 34, 24)
			K.Rect(r.buy, 14, 157, rw - 34, 40)
			r.buy.TextSize = 20
			local level = attr("ToolLevel_" .. selected .. "_" .. key) or 0
			local max = config.Upgrades[key].MaxLevel
			local testMode = attr("OwnerTestMode") == true
			local count, cost = E.Quote(key, level, testMode and math.huge or cash, quantity, config)
			local nextRank = math.min(max, level + math.max(1, count))
			r.rank.Text = selected .. " · rank " .. level .. " / " .. max
			r.value.Text = effect(key, level, config)
				.. (level < max and "  →  " .. effect(key, nextRank, config) or "")
			local on = ready
				and owned
				and equipped
				and not pending
				and count > 0
				and level < max
				and (attr("DrillTrialEndsAt") or 0) <= workspace:GetServerTimeNow()
			A.State(
				r.buy,
				on,
				level >= max and "Fully upgraded"
					or not equipped and "Equip this tool first"
					or count == 0 and "Need " .. K.Number(E.Price(key, level, config) - cash) .. " credits"
					or pending and "Confirming…"
					or testMode and "+" .. count .. " rank - free test upgrade"
					or "+" .. count .. " rank · " .. K.Number(cost) .. " credits"
			)
		end
	end
	return api
end
return M
