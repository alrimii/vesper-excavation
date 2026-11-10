-- A graph canvas, not an upgrade list. Selection never purchases a node.
local M = {}
function M.Build(player, remote, feedback)
	local C = require(script.Parent.SkillCatalog)
	local Art = require(script.Parent.SkillArt)
	local UIS = game:GetService("UserInputService")
	local GS = game:GetService("GuiService")
	local Http = game:GetService("HttpService")
	local Run = game:GetService("RunService")
	local cream = Color3.fromRGB(250, 237, 206)
	local ink = Color3.fromRGB(18, 32, 46)
	local colors = {
		Impact = Color3.fromRGB(255, 192, 109),
		Collection = Color3.fromRGB(115, 227, 184),
		Technique = Color3.fromRGB(173, 164, 255),
	}
	local ui = Instance.new("ScreenGui")
	ui.Name = "ExcavationSkillTree"
	ui.ResetOnSpawn = false
	ui.DisplayOrder = 60
	ui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
	ui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ui.Parent = player.PlayerGui
	local function make(class, parent, properties)
		local o = Instance.new(class)
		for k, v in properties do
			o[k] = v
		end
		o.Parent = parent
		return o
	end
	local function image(parent, id, pos, size, z)
		return make("ImageLabel", parent, {
			BackgroundTransparency = 1,
			Image = Art[id] or "",
			Position = pos,
			Size = size,
			ScaleType = Enum.ScaleType.Fit,
			ZIndex = z or 2,
		})
	end
	local function label(parent, text, size, pos, bounds, z)
		return make("TextLabel", parent, {
			BackgroundTransparency = 1,
			Text = text,
			TextColor3 = cream,
			Font = Enum.Font.GothamMedium,
			TextSize = size,
			Position = pos,
			Size = bounds,
			TextWrapped = true,
			ZIndex = z or 3,
		})
	end
	local function button(parent, text, pos, bounds, callback)
		local b = make("ImageButton", parent, {
			BackgroundTransparency = 1,
			Image = Art.panel or "",
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(74, 74, 438, 438),
			SliceScale = 0.24,
			Position = pos,
			Size = bounds,
			ZIndex = 8,
			AutoButtonColor = true,
		})
		label(b, text, 14, UDim2.fromOffset(6, 3), UDim2.new(1, -12, 1, -6), 9)
		b.Name = text:gsub("[^%w]", "_")
		b.Activated:Connect(callback)
		return b
	end
	local root = make("Frame", ui, {
		Name = "Root",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = ink,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = false,
		Active = true,
	})
	require(script.Parent.ModalLayout).Backdrop(
		ui,
		root,
		{ Color = ink, Image = Art.background, ImageTransparency = 0.62 }
	)
	local header = label(root, "", 18, UDim2.fromOffset(12, 6), UDim2.new(1, -80, 0, 54), 4)
	header.TextXAlignment = Enum.TextXAlignment.Left
	local canvas = make(
		"Frame",
		root,
		{ Name = "Canvas", BackgroundTransparency = 1, ClipsDescendants = true, Active = true, ZIndex = 2 }
	)
	local panel = image(root, "panel", UDim2.new(), UDim2.new(), 5)
	panel.Name = "Details"
	panel.ScaleType = Enum.ScaleType.Slice
	panel.SliceCenter = Rect.new(74, 74, 438, 438)
	panel.SliceScale = 0.28
	local body = make("ScrollingFrame", panel, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(18, 34),
		Size = UDim2.new(1, -36, 1, -48),
		CanvasSize = UDim2.fromOffset(0, 750),
		ScrollBarThickness = 5,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Selectable = true,
		ZIndex = 6,
	})
	local portrait = image(body, "journal_hub", UDim2.new(0, 0, 0, 0), UDim2.fromOffset(58, 58), 7)
	local title = label(body, "Select a node", 19, UDim2.fromOffset(68, 0), UDim2.new(1, -72, 0, 58), 7)
	local details = label(body, "", 15, UDim2.fromOffset(4, 72), UDim2.new(1, -8, 0, 340), 7)
	details.TextXAlignment = Enum.TextXAlignment.Left
	details.TextYAlignment = Enum.TextYAlignment.Top
	local receipt = label(body, "", 14, UDim2.fromOffset(4, 684), UDim2.new(1, -8, 0, 64), 7)
	local selected = nil
	local detailsFocused = false
	local lastNavigation
	local ranks, loadout = {}, {}
	local zoom = 0.9
	local pan = Vector2.zero
	local nodes, lines, emblems = {}, {}, {}
	local lastDrag = 0
	local refresh, draw, recenter, setOpen, selectNode
	local purchase = button(
		body,
		"LEARN NEXT RANK",
		UDim2.fromOffset(0, 510),
		UDim2.new(1, 0, 0, 48),
		function()
			if selected then
				remote:FireServer("SkillPurchase", selected)
			end
		end
	)
	local slot1 = button(
		body,
		"EQUIP / CLEAR SLOT 1",
		UDim2.fromOffset(0, 564),
		UDim2.new(1, 0, 0, 48),
		function()
			if selected then
				remote:FireServer("SkillLoadout", 1, loadout[1] == selected and "" or selected)
			end
		end
	)
	local slot2 = button(
		body,
		"EQUIP / CLEAR SLOT 2",
		UDim2.fromOffset(0, 618),
		UDim2.new(1, 0, 0, 48),
		function()
			if selected then
				remote:FireServer("SkillLoadout", 2, loadout[2] == selected and "" or selected)
			end
		end
	)
	local latch = button(
		body,
		"TOGGLE SALE LATCH",
		UDim2.fromOffset(0, 564),
		UDim2.new(1, 0, 0, 48),
		function()
			remote:FireServer("SkillToggle", not player:GetAttribute("SaleLatchEnabled"))
		end
	)
	local collapse = true
	local fold = button(
		panel,
		"DETAILS / EXPAND",
		UDim2.new(0.5, -90, 0, 0),
		UDim2.fromOffset(180, 48),
		function()
			collapse = not collapse
			if draw then
				draw()
			end
		end
	)
	local positions = {
		["impact.fault_survey"] = Vector2.new(-300, 0),
		["collection.batch_unload"] = Vector2.new(0, 0),
		["technique.precision_relay"] = Vector2.new(300, 0),
		["impact.charged_swing"] = Vector2.new(-390, 240),
		["impact.steady_aim"] = Vector2.new(-210, 240),
		["collection.sale_latch"] = Vector2.new(0, 240),
		["technique.chain_lightning"] = Vector2.new(210, 240),
		["technique.core_drill"] = Vector2.new(390, 240),
	}
	local function point(x, y)
		return canvas.AbsoluteSize / 2 + pan + Vector2.new(x * 1.25, y) * zoom
	end
	local hub = image(canvas, "journal_hub", UDim2.new(), UDim2.fromOffset(90, 90), 3)
	local function connector(from, to)
		local f = make("Frame", canvas, {
			BackgroundColor3 = Color3.fromRGB(75, 107, 119),
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5),
			ZIndex = 2,
		})
		table.insert(lines, { frame = f, from = from, to = to })
	end
	for _, id in C.Order do
		local n = C.Nodes[id]
		if not n.Implemented then
			continue
		end
		local b = make("ImageButton", canvas, {
			Name = id:gsub("%.", "_"),
			BackgroundTransparency = 1,
			Image = Art.node_frame or "",
			ZIndex = 4,
			AutoButtonColor = false,
			AnchorPoint = Vector2.new(0.5, 0.5),
		})
		local icon = image(
			b,
			n.Implemented and id:match("%.(.+)$") or "journal_hub",
			UDim2.fromScale(0.19, 0.19),
			UDim2.fromScale(0.62, 0.62),
			5
		)
		local focus = image(b, "node_frame", UDim2.fromScale(-0.08, -0.08), UDim2.fromScale(1.16, 1.16), 3)
		focus.Visible = false
		local name = label(b, n.Name, 14, UDim2.new(0.5, -58, 1, 1), UDim2.fromOffset(116, 34), 5)
		local status = label(b, "", 14, UDim2.new(0.5, -68, 1, 33), UDim2.fromOffset(136, 20), 5)
		local sockets = {}
		for i = 1, math.max(1, n.MaxRank) do
			local gem = make("Frame", b, {
				Size = UDim2.fromOffset(8, 8),
				Position = UDim2.new(0.5, (i - (n.MaxRank + 1) / 2) * 14 - 4, 0.88, -4),
				Rotation = 45,
				BorderSizePixel = 0,
				BackgroundColor3 = ink,
				ZIndex = 6,
			})
			make("UIStroke", gem, { Thickness = 1.5, Color = cream })
			sockets[i] = gem
		end
		nodes[id] =
			{ button = b, icon = icon, focus = focus, name = name, status = status, sockets = sockets }
		b.Activated:Connect(function()
			if os.clock() - lastDrag > 0.15 then
				selectNode(id, false)
			end
		end)
		b.SelectionGained:Connect(function()
			selectNode(id, true)
		end)
		if #n.Prerequisites == 0 then
			connector(nil, id)
		else
			for _, req in n.Prerequisites do
				connector(req, id)
			end
		end
	end
	for branch, x in { Impact = -300, Collection = 0, Technique = 300 } do
		local emblem = image(canvas, "branch_" .. branch:lower(), UDim2.new(), UDim2.fromOffset(48, 48), 3)
		local caption = label(canvas, branch:upper(), 14, UDim2.new(), UDim2.fromOffset(150, 22), 3)
		caption.TextColor3 = colors[branch]
		emblems[branch] = { image = emblem, label = caption, x = x }
	end
	local function centerOn(x, y)
		pan = -Vector2.new(x * 1.25, y) * zoom
		draw()
	end
	recenter = function()
		draw()
		zoom = math.clamp(
			math.min((canvas.AbsoluteSize.X - 136) / 1000, (canvas.AbsoluteSize.Y - 112) / 430),
			0.45,
			1
		)
		centerOn(0, 80)
	end
	local function setZoom(value, anchor)
		anchor = anchor or canvas.AbsoluteSize / 2
		local old = zoom
		zoom = math.clamp(value, 0.45, 1.4)
		pan = anchor - canvas.AbsoluteSize / 2 - (anchor - canvas.AbsoluteSize / 2 - pan) * (zoom / old)
		draw()
	end
	local zoomOut = button(root, "-", UDim2.new(0, 8, 1, -54), UDim2.fromOffset(48, 48), function()
		setZoom(zoom - 0.1)
	end)
	local zoomIn = button(root, "+", UDim2.new(0, 60, 1, -54), UDim2.fromOffset(48, 48), function()
		setZoom(zoom + 0.1)
	end)
	button(root, "RECENTER", UDim2.new(0, 112, 1, -54), UDim2.fromOffset(84, 48), recenter)
	local confirmRespec = false
	local respec = button(
		root,
		"FREE RESPEC",
		UDim2.new(1, -116, 1, -54),
		UDim2.fromOffset(108, 48),
		function()
			if confirmRespec then
				remote:FireServer("SkillRespec")
				confirmRespec = false
			else
				confirmRespec = true
				receipt.Text =
					"Free respec clears all learned ranks and active slots. Tools and currency stay. Press CONFIRM again in your room after 10s without mining."
			end
			refresh()
		end
	)
	button(root, "CLOSE", UDim2.new(1, -72, 0, 8), UDim2.fromOffset(64, 48), function()
		setOpen(false)
	end)
	local branchButtons = {}
	for i, branch in { "Impact", "Collection", "Technique" } do
		branchButtons[i] = button(root, branch:upper(), UDim2.new(), UDim2.new(), function()
			collapse = true
			centerOn((i - 2) * 300, 70)
		end)
	end
	draw = function()
		local w, h = root.AbsoluteSize.X, root.AbsoluteSize.Y
		local narrow = h >= 440 and (w < 600 or (w < 760 and h >= 500))
		header.TextSize = narrow and 14 or 18
		local panelHeight = collapse and 56 or math.max(180, math.floor((h - 120) * 0.42))
		if narrow then
			panel.Position = UDim2.new(0, 8, 1, -panelHeight - 58)
			panel.Size = UDim2.new(1, -16, 0, panelHeight)
			canvas.Position = UDim2.fromOffset(4, 116)
			canvas.Size = UDim2.new(1, -8, 1, -174 - panelHeight)
		else
			local panelWidth = math.min(w < 900 and 260 or 346, math.max(180, w * 0.42))
			panel.Position = UDim2.new(1, -panelWidth - 8, 0, 66)
			panel.Size = UDim2.new(0, panelWidth, 1, -124)
			canvas.Position = UDim2.fromOffset(4, 66)
			canvas.Size = UDim2.new(1, -panelWidth - 20, 1, -124)
		end
		for i, control in branchButtons do
			control.Visible = narrow
			control.Position = UDim2.new((i - 1) / 3, 6, 0, 64)
			control.Size = UDim2.new(1 / 3, -12, 0, 44)
			control:FindFirstChildOfClass("TextLabel").TextSize = 12
		end
		fold.Visible = narrow
		body.Visible = not (narrow and collapse)
		body.Position = UDim2.fromOffset(18, narrow and 52 or 26)
		body.Size = UDim2.new(1, -36, 1, narrow and -66 or -40)
		pan = Vector2.new(
			math.clamp(pan.X, -650 * zoom, 650 * zoom),
			math.clamp(pan.Y, -1600 * zoom, 400 * zoom)
		)
		local hp = point(0, -190)
		hub.Position = UDim2.fromOffset(hp.X - 45 * zoom, hp.Y - 45 * zoom)
		hub.Size = UDim2.fromOffset(90 * zoom, 90 * zoom)
		for _, em in emblems do
			local pos = point(em.x, -130)
			em.image.Position = UDim2.fromOffset(pos.X - 24, pos.Y - 24)
			em.label.Position = UDim2.fromOffset(pos.X - 75, pos.Y + 23)
		end
		for id, view in nodes do
			local n = C.Nodes[id]
			local layout = positions[id]
			local pos = point(layout.X, layout.Y)
			view.button.Position = UDim2.fromOffset(pos.X, pos.Y)
			view.button.Size = UDim2.fromOffset(math.max(66, 108 * zoom), math.max(66, 108 * zoom))
		end
		for _, edge in lines do
			local a = edge.from and C.Nodes[edge.from]
			local b = C.Nodes[edge.to]
			local from = edge.from and positions[edge.from] or Vector2.new(0, -190)
			local to = positions[edge.to]
			local first = point(from.X, from.Y)
			local last = point(to.X, to.Y)
			local d = last - first
			local middle = (first + last) / 2
			edge.frame.Position = UDim2.fromOffset(middle.X, middle.Y)
			edge.frame.Size = UDim2.fromOffset(d.Magnitude, 3)
			edge.frame.Rotation = math.deg(math.atan2(d.Y, d.X))
			edge.frame.BackgroundColor3 = (ranks[edge.to] or 0) > 0 and colors[b.Branch]
				or Color3.fromRGB(69, 91, 107)
		end
	end
	selectNode = function(id, bringIntoView)
		selected = id
		detailsFocused = false
		if root.AbsoluteSize.X < 760 then
			collapse = false
			bringIntoView = true
		end
		body.CanvasPosition = Vector2.zero
		confirmRespec = false
		receipt.Text = ""
		if bringIntoView then
			local n = C.Nodes[id]
			centerOn(positions[id].X, positions[id].Y)
		end
		refresh()
	end
	refresh = function()
		local level, xp, points =
			player:GetAttribute("ResearchLevel"),
			player:GetAttribute("ResearchXP"),
			player:GetAttribute("SkillPoints")
		local ok, value = pcall(Http.JSONDecode, Http, player:GetAttribute("SkillRanks") or "{}")
		ranks = ok and value or {}
		local lok, lv = pcall(Http.JSONDecode, Http, player:GetAttribute("SkillLoadout") or "[]")
		loadout = lok and lv or {}
		header.Text = level
				and string.format(
					"SKILL TREE   /   LEVEL %d\n%s   /   %d POINTS",
					level,
					level == 100 and "MAX XP"
						or string.format(
							"%.2f / %d XP",
							(xp or 0) - C.Threshold(level),
							C.Threshold(level + 1) - C.Threshold(level)
						),
					points or 0
				)
			or "Synchronizing progression..."
		for id, view in nodes do
			local n = C.Nodes[id]
			local rank = ranks[id] or 0
			local reason = n.Implemented and C.PurchaseReason(level or 0, ranks, id)
			local state = not n.Implemented and "PLANNED"
				or rank == n.MaxRank and "COMPLETE"
				or rank > 0 and "PARTIAL"
				or not reason and "AVAILABLE"
				or "LOCKED"
			view.status.Text = state .. (n.Implemented and (" " .. rank .. "/" .. n.MaxRank) or "")
			view.status.TextColor3 = (state == "LOCKED" or state == "PLANNED")
					and Color3.fromRGB(160, 174, 185)
				or colors[n.Branch]
			-- Muted art is supplemented by literal states and filled/empty diamond sockets.
			view.icon.ImageTransparency = state == "PLANNED" and 0.45 or 0
			view.focus.Visible = selected == id
			view.focus.ImageColor3 = colors[n.Branch]
			for i, gem in view.sockets do
				gem.BackgroundColor3 = i <= rank and colors[n.Branch] or ink
			end
		end
		local n = selected and C.Nodes[selected]
		purchase.Visible = n ~= nil and n.Implemented
		slot1.Visible = false
		slot2.Visible = false
		latch.Visible = false
		if n then
			local rank = ranks[selected] or 0
			portrait.Image = Art[n.Implemented and selected:match("%.(.+)$") or "journal_hub"] or ""
			title.Text = n.Name
			local req = {}
			for _, id in n.Prerequisites do
				table.insert(req, C.Nodes[id].Name)
			end
			details.Text = not n.Implemented
					and "PLANNED\nThis later node is not implemented and cannot consume points.\n\nThis is an unpublished development checkpoint, not the complete progression release."
				or string.format(
					"%s / Rank %d of %d\n\nCURRENT: %s\n\nNEXT: %s\n\nRequires: %s\nNext level: %s / Cost: %s\n\n%s",
					n.Tool,
					rank,
					n.MaxRank,
					rank > 0 and n.Effects[rank] or "Not learned",
					n.Effects[rank + 1] or "Complete",
					#req > 0 and table.concat(req, ", ") or "Field Journal",
					tostring(n.Levels[rank + 1] or "Complete"),
					rank < n.MaxRank and (n.Cost .. " point(s)") or "0",
					C.PurchaseReason(level or 0, ranks, selected) or "Available to learn."
				)
			purchase.Interactable = level ~= nil and C.PurchaseReason(level, ranks, selected) == nil
			purchase.ImageTransparency = purchase.Interactable and 0 or 0.45
			purchase:FindFirstChildOfClass("TextLabel").Text = purchase.Interactable and "LEARN NEXT RANK"
				or rank == n.MaxRank and "COMPLETE"
				or "LOCKED / SEE REQUIREMENTS"
			if n.Active and rank > 0 then
				slot1.Visible = true
				slot2.Visible = (level or 0) >= 30
				details.Text ..= "\nSlots: " .. tostring(loadout[1] or "empty") .. " / " .. tostring(
					loadout[2] or "locked/empty"
				) .. "\nEquip/clear only in your room after 10s without mining."
			end
			if selected == "collection.sale_latch" and rank > 0 then
				latch.Visible = true
				details.Text ..= "\nLatch: " .. (player:GetAttribute("SaleLatchEnabled") and "ON" or "OFF")
			end
		else
			details.Text =
				"Eight skills across three connected branches. Drag to explore. Select a node to inspect it; LEARN spends points only after server confirmation.\n\nMouse wheel or +/- to zoom. Touch drag/pinch. Gamepad D-pad selects, X focuses details, Y recenters, LB/RB zoom, B closes.\n\nRebirth is not implemented. XP multiplier: 1."
		end
		respec:FindFirstChildOfClass("TextLabel").Text = confirmRespec and "CONFIRM RESPEC" or "FREE RESPEC"
		draw()
		-- Text grows inside a scrolling detail panel; no collision with purchase/loadout controls.
		local height = game:GetService("TextService"):GetTextSize(
			details.Text,
			details.TextSize,
			details.Font,
			Vector2.new(math.max(100, body.AbsoluteSize.X - 8), 10000)
		).Y + 12
		details.Size = UDim2.new(1, -8, 0, height)
		local y = 72 + height + 8
		for _, control in { purchase, slot1, slot2, latch } do
			if control.Visible then
				control.Position = UDim2.fromOffset(0, y)
				y += 54
			end
		end
		receipt.Position = UDim2.fromOffset(4, y + 8)
		body.CanvasSize = UDim2.fromOffset(0, y + 100)
	end
	setOpen = function(open)
		if
			open
			and (
				not player:GetAttribute("ProfileReady")
				or not player:GetAttribute("LabReady")
				or player:GetAttribute("Training")
				or player:GetAttribute("DiscoveryCinematic")
				or player:GetAttribute("EggResultsOpen")
				or player:GetAttribute("ResearchModal")
				or player:GetAttribute("MaterialBagOpen")
				or (
					player.PlayerGui:FindFirstChild("ExcavationHUD")
					and player.PlayerGui.ExcavationHUD.Station.Visible
				)
			)
		then
			return
		end
		root.Visible = open
		player:SetAttribute("SkillTreeOpen", open)
		remote:FireServer("SkillMenu", open)
		if open then
			collapse = true
			refresh()
			recenter()
			if UIS.PreferredInput == Enum.PreferredInput.Gamepad then
				GS.SelectedObject = nodes["technique.precision_relay"].button
			end
		else
			if GS.SelectedObject and GS.SelectedObject:IsDescendantOf(root) then
				GS.SelectedObject = nil
			end
		end
	end
	-- Directional graph links, independent of layout pixel positions.
	for id, v in nodes do
		for property, direction in
			{
				NextSelectionUp = Vector2.new(0, -1),
				NextSelectionDown = Vector2.new(0, 1),
				NextSelectionLeft = Vector2.new(-1, 0),
				NextSelectionRight = Vector2.new(1, 0),
			}
		do
			local best, score = nil, math.huge
			local n = C.Nodes[id]
			for other, w in nodes do
				if other ~= id then
					local m = C.Nodes[other]
					local delta = positions[other] - positions[id]
					local forward = delta:Dot(direction)
					if forward > 1 then
						local candidate = delta.Magnitude + math.abs(delta:Cross(direction)) * 2
						if candidate < score then
							score = candidate
							best = w.button
						end
					end
				end
			end
			v.button[property] = best
		end
	end
	local drag, startPan, startPos
	local function beginDrag(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			drag = input
			startPan = pan
			startPos = Vector2.new(input.Position.X, input.Position.Y)
		end
	end
	canvas.InputBegan:Connect(beginDrag)
	for _, v in nodes do
		v.button.InputBegan:Connect(beginDrag)
	end
	UIS.InputChanged:Connect(function(input)
		if not root.Visible then
			return
		end
		if drag and (input == drag or input.UserInputType == Enum.UserInputType.MouseMovement) then
			local delta = Vector2.new(input.Position.X, input.Position.Y) - startPos
			if delta.Magnitude > 8 then
				lastDrag = os.clock()
				pan = startPan + delta
				draw()
			end
		elseif input.UserInputType == Enum.UserInputType.MouseWheel then
			local cursor = UIS:GetMouseLocation() - GS:GetGuiInset() - canvas.AbsolutePosition
			if
				cursor.X >= 0
				and cursor.Y >= 0
				and cursor.X <= canvas.AbsoluteSize.X
				and cursor.Y <= canvas.AbsoluteSize.Y
			then
				setZoom(zoom + input.Position.Z * 0.1, cursor)
			end
		end
	end)
	UIS.InputEnded:Connect(function(input)
		if input == lastNavigation then
			lastNavigation = nil
		end
		if input == drag or input.UserInputType == Enum.UserInputType.MouseButton1 then
			drag = nil
		end
	end)
	local pinchStart = 1
	UIS.TouchPinch:Connect(function(touches, scale, _, state)
		if not root.Visible or #touches < 2 then
			return
		end
		local center = (touches[1] + touches[2]) / 2 - canvas.AbsolutePosition
		if
			center.X < 0
			or center.Y < 0
			or center.X > canvas.AbsoluteSize.X
			or center.Y > canvas.AbsoluteSize.Y
		then
			return
		end
		if state == Enum.UserInputState.Begin then
			pinchStart = zoom
		end
		drag = nil
		lastDrag = os.clock()
		setZoom(pinchStart * scale, center)
	end)
	local navigate
	UIS.InputBegan:Connect(function(input, processed)
		if UIS:GetFocusedTextBox() then
			return
		end
		if
			(input.KeyCode == Enum.KeyCode.K or input.KeyCode == Enum.KeyCode.ButtonSelect) and not processed
		then
			setOpen(not root.Visible)
			return
		end
		if not root.Visible then
			return
		end
		if input.KeyCode == Enum.KeyCode.ButtonB or input.KeyCode == Enum.KeyCode.Escape then
			setOpen(false)
		elseif input.KeyCode == Enum.KeyCode.ButtonY then
			recenter()
		elseif input.KeyCode == Enum.KeyCode.ButtonL1 then
			setZoom(zoom - 0.1)
		elseif input.KeyCode == Enum.KeyCode.ButtonR1 then
			setZoom(zoom + 0.1)
		elseif input.KeyCode == Enum.KeyCode.ButtonX then
			if detailsFocused and selected then
				detailsFocused = false
				GS.SelectedObject = nodes[selected].button
			else
				collapse = false
				detailsFocused = true
				draw()
				GS.SelectedObject = body
				body.CanvasPosition = Vector2.zero
			end
		elseif navigate then
			navigate(input)
		end
	end)
	-- Own tree navigation before Roblox's default GUI navigation moves focus.
	local directions = {
		[Enum.KeyCode.Up] = "NextSelectionUp",
		[Enum.KeyCode.DPadUp] = "NextSelectionUp",
		[Enum.KeyCode.Down] = "NextSelectionDown",
		[Enum.KeyCode.DPadDown] = "NextSelectionDown",
		[Enum.KeyCode.Left] = "NextSelectionLeft",
		[Enum.KeyCode.DPadLeft] = "NextSelectionLeft",
		[Enum.KeyCode.Right] = "NextSelectionRight",
		[Enum.KeyCode.DPadRight] = "NextSelectionRight",
	}
	navigate = function(input)
		local direction = directions[input.KeyCode]
		if not direction or lastNavigation == input then
			return
		end
		lastNavigation = input
		if detailsFocused then
			local step = direction == "NextSelectionDown" and 64
				or direction == "NextSelectionUp" and -64
				or 0
			local target = math.clamp(
				body.CanvasPosition.Y + step,
				0,
				math.max(0, body.AbsoluteCanvasSize.Y - body.AbsoluteSize.Y)
			)
			task.defer(function()
				if root.Visible and detailsFocused then
					GS.SelectedObject = body
					body.CanvasPosition = Vector2.new(0, target)
				end
			end)
		else
			local current = selected and nodes[selected].button or nodes["technique.precision_relay"].button
			GS.SelectedObject = current[direction] or current
		end
	end
	game:GetService("ContextActionService"):BindActionAtPriority(
		"VesperTreeNavigation",
		function(_, state, input)
			if not root.Visible then
				return Enum.ContextActionResult.Pass
			end
			if state == Enum.UserInputState.Begin then
				navigate(input)
			end
			return Enum.ContextActionResult.Sink
		end,
		false,
		3000,
		Enum.KeyCode.Up,
		Enum.KeyCode.Down,
		Enum.KeyCode.Left,
		Enum.KeyCode.Right,
		Enum.KeyCode.DPadUp,
		Enum.KeyCode.DPadDown,
		Enum.KeyCode.DPadLeft,
		Enum.KeyCode.DPadRight
	)
	feedback.OnClientEvent:Connect(function(kind, ok, message)
		if kind ~= "SkillReceipt" then
			return
		end
		collapse = false
		refresh()
		receipt.Text = message
		body.CanvasPosition =
			Vector2.new(0, math.max(0, receipt.Position.Y.Offset + 72 - body.AbsoluteSize.Y))
		receipt.TextColor3 = ok and Color3.fromRGB(125, 240, 186) or Color3.fromRGB(255, 190, 144)
		if ok and selected and not player:GetAttribute("ReducedMotion") then
			local focus = nodes[selected].focus
			focus.ImageTransparency = 0.45
			game:GetService("TweenService")
				:Create(focus, TweenInfo.new(0.25), { ImageTransparency = 0 })
				:Play()
		end
	end)
	for _, key in
		{ "SkillRanks", "SkillLoadout", "ResearchLevel", "ResearchXP", "SkillPoints", "SaleLatchEnabled" }
	do
		player:GetAttributeChangedSignal(key):Connect(function()
			if root.Visible then
				refresh()
			end
		end)
	end
	for _, key in { "DiscoveryCinematic", "EggResultsOpen", "ResearchModal", "MaterialBagOpen", "Training" } do
		player:GetAttributeChangedSignal(key):Connect(function()
			if player:GetAttribute(key) and root.Visible then
				setOpen(false)
			end
		end)
	end
	player.CharacterRemoving:Connect(function()
		setOpen(false)
	end)
	root:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		if root.Visible then
			refresh()
			recenter()
		end
	end)
	return {
		Toggle = function()
			setOpen(not root.Visible)
		end,
		Open = function()
			setOpen(true)
		end,
	}
end
return M
