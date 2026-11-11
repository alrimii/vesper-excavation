-- Field equipment catalogue. Quotes, receipts and server actions retain authority.
local M = {}
function M.Build(shell, player, base, remote, feedback)
	local K = require(script.Parent.InterfaceKit)
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
	local tab1 = K.Button(root, "EquipmentTab", "Equipment", function()
		page = "TOOLS"
		dirty = true
	end, true)
	local tab2 = K.Button(root, "UpgradesTab", "Upgrades", function()
		page = "RIG"
		dirty = true
	end, true)
	local wallet = K.Text(root, "Balance", "", 24, K.Ink, true)
	local selectors = {}
	for _, id in Rules.ToolOrder do
		local b = K.Button(root, "Select" .. id, "", function()
			selected = id
			dirty = true
		end, true)
		selectors[id] = {
			b = b,
			icon = K.Icon(b, id),
			title = K.Text(b, "Name", id == "Explosive" and "Charge" or id, 17, K.Ink, true),
			state = K.Text(b, "State", "", 12, K.Muted),
		}
	end
	local scroll = K.Scroll(root, "EquipmentContent")
	local stage = K.Surface(scroll, "ToolStage", K.Dark)
	K.Shine(stage)
	local views = {}
	for _, id in Rules.ToolOrder do
		views[id] = Preview.Create(stage, script.Parent.EquipmentAssets[id])
	end
	local detail = K.Make("Frame", scroll, { Name = "ToolDetails", BackgroundTransparency = 1 })
	local name = K.Text(detail, "Name", "", 30, K.Ink)
	name.Font = K.Title
	local role = K.Text(detail, "Role", "", 16, K.Green, true)
	local stats = K.Text(detail, "Stats", "", 24)
	local powerLabel = K.Text(detail, "Power", "", 44, K.Purple, true)
	local hint = K.Text(detail, "Availability", "", 14, K.Muted)
	local receipt = K.Text(root, "Receipt", "", 14, K.Green)
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
	local action = K.Button(root, "PrimaryAction", "", function()
		send(attr("OwnsTool_" .. selected) and "EquipTool" or "BuyTool", selected)
	end)
	local trial = K.Button(detail, "Trial", "Try drill · 90 seconds", function()
		remote:FireServer("TryDrill")
		dirty = true
	end, true)
	local quantityHost = K.Make("Frame", scroll, { Name = "Quantity", BackgroundTransparency = 1 })
	local qtyLabel = K.Text(quantityHost, "Label", "Ranks to buy", 14, K.Muted)
	local qty = {}
	for i, v in { 1, 5, "Max" } do
		qty[i] = K.Button(quantityHost, "Quantity" .. v, tostring(v), function()
			quantity = v
			dirty = true
		end, true)
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
	for _, key in E.Order do
		local row = K.Surface(scroll, key)
		rows[key] = {
			root = row,
			icon = K.Icon(row, "Storage"),
			title = K.Text(row, "Name", names[key], 18, K.Ink, true),
			rank = K.Text(row, "Rank", "", 13, K.Muted),
			value = K.Text(row, "Comparison", "", 22, K.Ink, true),
			why = K.Text(row, "Benefit", descriptions[key], 13, K.Muted),
			buy = K.Button(row, "Upgrade", "", function()
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
			) .. (selected == "Drill" and " / tick" or selected == "Explosive" and " center damage" or " / strike")
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
			return "+" .. rank .. " at full share"
		end
		return E.Effect(key, rank, config)
	end
	feedback.OnClientEvent:Connect(function(kind, id, ok, message)
		if kind == "ShopReceipt" and pending and id == pending.id then
			pending = nil
			receipt.Text = message or (ok and "Confirmed" or "Please try again")
			receipt.TextColor3 = ok and K.Green or K.Error
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
		K.Rect(tab1, 0, 0, 120, 44)
		K.Rect(tab2, 128, 0, 120, 44)
		wallet.Visible = w >= 470
		K.Rect(wallet, 270, 0, w - 270, 44)
		wallet.Text = K.Number(attr("Cash")) .. " credits"
		wallet.TextXAlignment = Enum.TextXAlignment.Right
		tab1.BackgroundColor3 = page == "TOOLS" and K.Green or K.Line
		tab1.TextColor3 = page == "TOOLS" and K.Card or K.Ink
		tab2.BackgroundColor3 = page == "RIG" and K.Green or K.Line
		tab2.TextColor3 = page == "RIG" and K.Card or K.Ink
		local sw = (w - 16) / 3
		local cash = attr("Cash") or 0
		for i, id in Rules.ToolOrder do
			local s = selectors[id]
			K.Rect(s.b, (i - 1) * (sw + 8), 54, sw, 64)
			K.Rect(s.icon, 6, 10, narrow and 30 or 44, narrow and 30 or 44)
			local x = narrow and 38 or 56
			K.Rect(s.title, x, 8, sw - x - 4, 24)
			s.title.TextSize = narrow and 14 or 18
			K.Rect(s.state, x, 32, sw - x - 4, 22)
			s.state.TextSize = narrow and 11 or 12
			s.state.Text = attr("ToolFamily") == id and "Equipped"
				or attr("OwnsTool_" .. id) and "Owned"
				or cash >= Rules.Tools[id].Cost and "Available"
				or "Locked"
			s.b.BackgroundColor3 = selected == id and K.Gold or K.Card
		end
		K.Rect(scroll, 0, 130, w, h - 230)
		K.Rect(action, 0, h - 88, w, 50)
		K.Rect(receipt, 0, h - 30, w, 28)
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
		K.Enabled(
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
		detail.Visible = true
		quantityHost.Visible = page == "RIG"
		local cw = w - 8
		if page == "TOOLS" then
			local sh = narrow and 180 or math.max(190, math.min(320, h - 170))
			local dw = narrow and cw or cw * 0.48
			K.Rect(stage, 0, 0, narrow and cw or cw * 0.49, sh)
			for id, v in views do
				v.Visible = id == selected
				v.Position = UDim2.fromOffset(16, 12)
				v.Size = UDim2.new(1, -32, 1, -24)
			end
			K.Rect(detail, narrow and 0 or cw * 0.52, narrow and sh + 12 or 0, dw, 270)
			K.Rect(name, 0, 0, dw, 42)
			K.Rect(role, 0, 46, dw, 28)
			K.Rect(powerLabel, 0, 80, 100, 62)
			K.Rect(stats, 108, 80, dw - 108, 76)
			stats.TextSize = 16
			K.Rect(hint, 0, 166, dw, 32)
			K.Rect(trial, 0, 210, dw, 44)
			detail.Size = UDim2.fromOffset(dw, trial.Visible and 258 or 202)
		else
			K.Rect(detail, 0, 0, cw, 52)
			K.Rect(hint, 0, 0, math.max(0, cw - 180), 48)
			K.Rect(quantityHost, 0, 60, cw, 48)
			K.Rect(qtyLabel, 0, 0, 100, 44)
			for i, b in qty do
				K.Rect(b, 106 + (i - 1) * 58, 0, 52, 44)
				b.BackgroundColor3 = quantity == ({ 1, 5, "Max" })[i] and K.Gold or K.Line
			end
		end
		name.Visible = page == "TOOLS"
		role.Visible = page == "TOOLS"
		stats.Visible = page == "TOOLS"
		powerLabel.Visible = page == "TOOLS"
		local cols = narrow and 1 or 2
		local rw = (cw - (cols - 1) * 12) / cols
		for i, key in E.Order do
			local r = rows[key]
			r.root.Visible = page == "RIG"
			if page ~= "RIG" then
				continue
			end
			K.Rect(r.root, ((i - 1) % cols) * (rw + 12), 120 + math.floor((i - 1) / cols) * 184, rw, 172)
			K.SetIcon(
				r.icon,
				key == "Power" and selected
					or key == "Capacity" and "Storage"
					or key == "Critical" and "Skills"
					or key
			)
			K.Rect(r.icon, 12, 10, 46, 46)
			K.Rect(r.title, 70, 10, rw - 82, 24)
			K.Rect(r.rank, 70, 36, rw - 82, 22)
			K.Rect(r.value, 14, 66, rw - 28, 26)
			K.Rect(r.why, 14, 94, rw - 28, 22)
			K.Rect(r.buy, 14, 122, rw - 28, 40)
			local level = attr("ToolLevel_" .. selected .. "_" .. key) or 0
			local max = config.Upgrades[key].MaxLevel
			local count, cost = E.Quote(key, level, cash, quantity, config)
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
			K.Enabled(
				r.buy,
				on,
				level >= max and "Fully upgraded"
					or not equipped and "Equip this tool first"
					or count == 0 and "Need " .. K.Number(E.Price(key, level, config) - cash) .. " credits"
					or pending and "Confirming…"
					or "+" .. count .. " rank · " .. K.Number(cost) .. " credits"
			)
		end
	end
	return api
end
return M
