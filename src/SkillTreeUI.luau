-- A connected three-region map, backed by the unchanged SkillCatalog and server receipts.
local M = {}
function M.Build(player, remote, feedback)
	local K = require(script.Parent.InterfaceKit)
	local C = require(script.Parent.SkillCatalog)
	local Art = require(script.Parent.SkillArt)
	local UIS = game:GetService("UserInputService")
	local shell
	shell = K.Shell(player, "FieldSkills", "Skills & specializations", "SkillTreeOpen", function()
		remote:FireServer("SkillMenu", false)
	end, 1180)
	local body = shell.Body
	local summary = K.Text(body, "Progress", "", 22, K.Purple, true)
	local canvas = K.Scroll(body, "SkillMap")
	canvas.AutomaticCanvasSize = Enum.AutomaticSize.None
	canvas.ScrollingDirection = Enum.ScrollingDirection.XY
	canvas.BackgroundTransparency = 0
	canvas.BackgroundColor3 = K.Dark
	K.Round(canvas)
	local map = K.Make(
		"Frame",
		canvas,
		{ Name = "Map", Size = UDim2.fromOffset(1000, 1120), BackgroundTransparency = 1 }
	)
	local scale = K.Make("UIScale", map, { Scale = 1 })
	local inspector = K.Scroll(body, "Details")
	K.Stack(inspector, 10)
	local portrait = K.Make("ImageLabel", inspector, {
		Name = "Portrait",
		Size = UDim2.fromOffset(70, 70),
		BackgroundTransparency = 1,
		ScaleType = Enum.ScaleType.Fit,
	})
	local title = K.Paragraph(inspector, "Name", "Choose a skill", 26, K.Ink)
	title.Font = K.Title
	local description = K.Paragraph(
		inspector,
		"Description",
		"Explore three disciplines. Select a node to read its requirements and effects.",
		16,
		K.Muted
	)
	local purchase = K.Button(inspector, "Learn", "Learn next rank", function() end)
	purchase.Size = UDim2.new(1, -8, 0, 44)
	local slot1 = K.Button(inspector, "Slot1", "", nil, true)
	slot1.Size = UDim2.new(1, -8, 0, 44)
	local slot2 = K.Button(inspector, "Slot2", "", nil, true)
	slot2.Size = UDim2.new(1, -8, 0, 44)
	local latch = K.Button(inspector, "SaleLatch", "", nil, true)
	latch.Size = UDim2.new(1, -8, 0, 44)
	local receipt = K.Paragraph(inspector, "Receipt", "", 14, K.Green)
	local selected, ranks, loadout = nil, {}, {}
	local zoom, detailsMode = 0.8, false
	local colors = {
		Impact = K.Orange,
		Collection = K.Green,
		Technique = K.Cyan,
	}
	local positions = {
		["impact.fault_survey"] = Vector2.new(180, 120),
		["impact.charged_swing"] = Vector2.new(90, 290),
		["impact.steady_aim"] = Vector2.new(285, 270),
		["impact.crosscut"] = Vector2.new(190, 460),
		["impact.overbreak"] = Vector2.new(90, 640),
		["impact.fault_mark"] = Vector2.new(250, 820),
		["impact.fault_collapse"] = Vector2.new(130, 1000),
		["collection.batch_unload"] = Vector2.new(500, 170),
		["collection.sale_latch"] = Vector2.new(405, 350),
		["collection.sample_packing"] = Vector2.new(600, 350),
		["collection.claim_priorities"] = Vector2.new(500, 530),
		["collection.clean_extraction"] = Vector2.new(590, 700),
		["collection.refinery_link"] = Vector2.new(415, 850),
		["collection.expedition_harness"] = Vector2.new(520, 1030),
		["technique.precision_relay"] = Vector2.new(825, 120),
		["technique.chain_lightning"] = Vector2.new(720, 290),
		["technique.core_drill"] = Vector2.new(920, 290),
		["technique.shaped_charge"] = Vector2.new(710, 480),
		["technique.pulse_drill"] = Vector2.new(920, 520),
		["technique.arc_routing"] = Vector2.new(800, 700),
		["technique.storm_circuit"] = Vector2.new(870, 930),
	}
	local nodes, edges = {}, {}
	for _, id in C.Order do
		local n = C.Nodes[id]
		local pos = positions[id]
		for _, req in n.Prerequisites do
			local a = positions[req]
			local delta = pos - a
			local e = K.Make("Frame", map, {
				Name = "Link",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromOffset((a.X + pos.X) / 2, (a.Y + pos.Y) / 2),
				Size = UDim2.fromOffset(delta.Magnitude, 6),
				Rotation = math.deg(math.atan2(delta.Y, delta.X)),
				BorderSizePixel = 0,
				BackgroundColor3 = K.Muted,
				ZIndex = 1,
			})
			table.insert(edges, { root = e, from = req, to = id })
		end
	end
	for i, branch in { "Impact", "Collection", "Technique" } do
		local t = K.Text(map, branch, branch:upper(), 18, colors[branch], true)
		K.Rect(t, (i - 1) * 325 + 60, 18, 250, 30)
		t.TextXAlignment = Enum.TextXAlignment.Center
	end
	local refresh, layout
	for _, id in C.Order do
		local n = C.Nodes[id]
		local p = positions[id]
		local b = K.Button(map, id:gsub("%.", "_"), "", function()
			selected = id
			detailsMode = true
			receipt.Text = ""
			inspector.CanvasPosition = Vector2.zero
			refresh()
			layout()
		end, true)
		b.AnchorPoint = Vector2.new(0.5, 0.5)
		b.Position = UDim2.fromOffset(p.X, p.Y)
		b.Size = UDim2.fromOffset(96, 96)
		b.ZIndex = 3
		b:FindFirstChildOfClass("UICorner").CornerRadius = UDim.new(1, 0)
		local edge = K.Make(
			"UIStroke",
			b,
			{ Thickness = 2, Color = colors[n.Branch], ApplyStrokeMode = Enum.ApplyStrokeMode.Border }
		)
		local icon = K.Make("ImageLabel", b, {
			Name = "Art",
			Position = UDim2.fromOffset(8, 8),
			Size = UDim2.fromOffset(80, 80),
			BackgroundTransparency = 1,
			Image = "",
			ScaleType = Enum.ScaleType.Fit,
			ZIndex = 4,
		})
		Art.Apply(icon, id, n.Branch)
		local label = K.Text(b, "Name", n.Name, 18, K.Paper, true)
		K.Rect(label, -38, 100, 172, 28)
		label.TextXAlignment = Enum.TextXAlignment.Center
		label.ZIndex = 4
		local state = K.Text(b, "Rank", "", 16, colors[n.Branch], true)
		K.Rect(state, -38, 128, 172, 22)
		state.TextXAlignment = Enum.TextXAlignment.Center
		state.ZIndex = 4
		nodes[id] = { button = b, edge = edge, icon = icon, state = state }
	end
	local branchButtons = {}
	for i, branch in { "Impact", "Collection", "Technique" } do
		branchButtons[i] = K.Button(body, "Focus" .. branch, branch, function()
			detailsMode = false
			layout()
			canvas.CanvasPosition = Vector2.new(math.max(0, ((i - 1) * 325) * zoom), 0)
		end, true)
	end
	local minus = K.Button(body, "ZoomOut", "−", function()
		zoom = math.max(0.65, zoom - 0.15)
		layout()
	end, true)
	local plus = K.Button(body, "ZoomIn", "+", function()
		zoom = math.min(1.3, zoom + 0.15)
		layout()
	end, true)
	local back = K.Button(body, "Map", "Map", function()
		detailsMode = false
		layout()
	end, true)
	local respec = K.Button(body, "Respec", "Free respec", function()
		K.Confirm(
			shell,
			"Reset your skills?",
			"Refund all spent skill points and clear your active slots. Tools and credits stay. Available in your own room after 10 seconds without mining.",
			function()
				remote:FireServer("SkillRespec")
			end
		)
	end, true)
	purchase.Activated:Connect(function()
		if selected then
			remote:FireServer("SkillPurchase", selected)
		end
	end)
	slot1.Activated:Connect(function()
		if selected then
			remote:FireServer("SkillLoadout", 1, loadout[1] == selected and "" or selected)
		end
	end)
	slot2.Activated:Connect(function()
		if selected then
			remote:FireServer("SkillLoadout", 2, loadout[2] == selected and "" or selected)
		end
	end)
	latch.Activated:Connect(function()
		remote:FireServer("SkillToggle", not player:GetAttribute("SaleLatchEnabled"))
	end)
	layout = function()
		local w, h = shell.Width, shell.Height
		local narrow = w < 700
		K.Rect(summary, 0, 0, w, 32)
		local bw = math.min(150, (w - 16) / 3)
		for i, b in branchButtons do
			K.Rect(b, (i - 1) * (bw + 8), 40, bw, 42)
		end
		local iw = narrow and w or math.min(300, w * 0.33)
		K.Rect(canvas, 0, 94, narrow and w or w - iw - 20, h - 150)
		K.Rect(inspector, narrow and 0 or w - iw, 94, iw, h - 150)
		canvas.Visible = not narrow or not detailsMode
		inspector.Visible = not narrow or detailsMode
		scale.Scale = zoom
		canvas.CanvasSize = UDim2.fromOffset(1000 * zoom, 1120 * zoom)
		K.Rect(minus, 0, h - 44, 44, 44)
		K.Rect(plus, 52, h - 44, 44, 44)
		K.Rect(back, 104, h - 44, 60, 44)
		back.Visible = narrow and detailsMode
		K.Rect(respec, w - 134, h - 44, 134, 44)
	end
	refresh = function()
		local level = player:GetAttribute("ResearchLevel") or 0
		local xp = player:GetAttribute("ResearchXP") or 0
		ranks = K.Decode(player:GetAttribute("SkillRanks"))
		loadout = K.Decode(player:GetAttribute("SkillLoadout"))
		summary.Text = string.format(
			"Level %d  ·  %d skill points  ·  %s",
			level,
			player:GetAttribute("SkillPoints") or 0,
			level == 100 and "Maximum level"
				or string.format(
					"%.1f / %d XP",
					xp - C.Threshold(level),
					C.Threshold(level + 1) - C.Threshold(level)
				)
		)
		for id, v in nodes do
			local n = C.Nodes[id]
			local rank = ranks[id] or 0
			local reason = C.PurchaseReason(level, ranks, id)
			local available = n.Implemented and reason == nil
			v.state.Text = not n.Implemented and "PLANNED"
				or rank == n.MaxRank and rank .. "/" .. n.MaxRank .. " · complete"
				or available and rank .. "/" .. n.MaxRank .. " · available"
				or rank .. "/" .. n.MaxRank .. " · locked"
			v.button.BackgroundColor3 = rank > 0 and K.Green or available and K.Gold or K.Dark
			v.edge.Color = selected == id and K.Paper or colors[n.Branch]
			v.edge.Thickness = selected == id and 4 or available and 3 or 1
			v.icon.ImageTransparency = n.Implemented and (available or rank > 0) and 0 or 0.42
		end
		for _, e in edges do
			e.root.BackgroundColor3 = (ranks[e.to] or 0) > 0 and colors[C.Nodes[e.to].Branch] or K.Muted
			e.root.BackgroundTransparency = C.Nodes[e.to].Implemented and 0.1 or 0.5
		end
		local n = selected and C.Nodes[selected]
		purchase.Visible = n ~= nil and n.Implemented
		slot1.Visible = false
		slot2.Visible = false
		latch.Visible = false
		portrait.Visible = n ~= nil
		if n then
			local rank = ranks[selected] or 0
			Art.Apply(portrait, selected, n.Branch)
			title.Text = n.Name
			local req = {}
			for _, id in n.Prerequisites do
				table.insert(req, C.Nodes[id].Name)
			end
			description.Text = not n.Implemented
					and "Planned specialization\n\nThis skill is not available yet."
				or string.format(
					"%s  •  %d / %d\n%s\n\nNEXT: %s\n\nRequires %s\nLevel %s  •  %s points",
					n.Tool,
					rank,
					n.MaxRank,
					rank > 0 and n.Effects[rank] or "Not yet learned.",
					n.Effects[rank + 1] or "All ranks learned.",
					#req > 0 and table.concat(req, " + ") or "no earlier skill",
					tostring(n.Levels[rank + 1] or "complete"),
					tostring(n.Cost)
				)
			if n.Implemented then
				local reason = C.PurchaseReason(level, ranks, selected)
				K.Enabled(purchase, reason == nil, reason or "Learn rank · " .. n.Cost .. " points")
				purchase.TextSize = 14
				if n.Active and rank > 0 then
					slot1.Visible = true
					slot2.Visible = level >= 30
					slot1.Text = loadout[1] == selected and "Clear active slot 1" or "Equip in slot 1"
					slot2.Text = loadout[2] == selected and "Clear active slot 2" or "Equip in slot 2"
					description.Text ..= "\n\nChange active slots in your room after 10 seconds without mining."
				end
				latch.Visible = selected == "collection.sale_latch" and rank > 0
				latch.Text = player:GetAttribute("SaleLatchEnabled") and "Sale latch on · disable"
					or "Sale latch off · enable"
			end
		end
	end
	local function open(v)
		if
			v
			and (
				not player:GetAttribute("ProfileReady")
				or not player:GetAttribute("LabReady")
				or player:GetAttribute("Training")
				or player:GetAttribute("DiscoveryCinematic")
			)
		then
			return
		end
		shell:SetOpen(v)
		remote:FireServer("SkillMenu", v)
		if v then
			refresh()
			layout()
		end
	end
	shell.Changed:Connect(layout)
	feedback.OnClientEvent:Connect(function(kind, ok, message)
		if kind == "SkillReceipt" then
			refresh()
			receipt.Text = message or ""
			receipt.TextColor3 = ok and K.Green or K.Error
		end
	end)
	for _, key in
		{ "SkillRanks", "SkillLoadout", "ResearchLevel", "ResearchXP", "SkillPoints", "SaleLatchEnabled" }
	do
		player:GetAttributeChangedSignal(key):Connect(function()
			if shell.Open then
				refresh()
			end
		end)
	end
	UIS.InputBegan:Connect(function(i, processed)
		if
			not processed
			and not UIS:GetFocusedTextBox()
			and (i.KeyCode == Enum.KeyCode.K or i.KeyCode == Enum.KeyCode.ButtonSelect)
		then
			open(not shell.Open)
		end
	end)
	player:GetAttributeChangedSignal("Training"):Connect(function()
		if player:GetAttribute("Training") then
			open(false)
		end
	end)
	return {
		Toggle = function()
			open(not shell.Open)
		end,
		Open = function()
			open(true)
		end,
	}
end
return M
