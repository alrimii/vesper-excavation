-- Existing creature/room/settings presentation, pending its own replacement milestone. No equipment/upgrade pages.
local W = {}
function W.Build(gui, player, base, remote)
	local shared = script.Parent
	local Rules = require(shared.ProgressionRules)
	local Preview = require(shared.EquipmentPreview)
	local Style = require(shared.InterfaceStyle)
	local panel = gui.Station
	for _, child in panel:GetChildren() do
		if child:IsA("GuiObject") and child.Name ~= "Close" then
			if child.Name == "WorkshopContent" or child.Name == "InventoryMenu" then
				child:Destroy()
			else
				child.Visible = false
			end
		end
	end
	local C = {
		ink = Color3.fromRGB(28, 42, 68),
		muted = Color3.fromRGB(93, 110, 137),
		blue = Color3.fromRGB(53, 137, 237),
		gold = Color3.fromRGB(255, 201, 77),
		paper = Color3.fromRGB(244, 248, 255),
		mint = Color3.fromRGB(93, 226, 156),
	}
	panel.BackgroundColor3 = C.paper
	panel.BackgroundTransparency = 0
	panel.BorderSizePixel = 0
	local round = panel:FindFirstChildOfClass("UICorner") or Instance.new("UICorner", panel)
	round.CornerRadius = UDim.new(0, 20)
	local edge = panel:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke", panel)
	edge.Color, edge.Thickness = C.ink, 3
	local function frame(parent, name, color)
		local f = Instance.new("Frame")
		f.Name, f.BackgroundColor3, f.BorderSizePixel = name, color or C.paper, 0
		f.Parent = parent
		local r = Instance.new("UICorner", f)
		r.CornerRadius = UDim.new(0, 14)
		return f
	end
	local function label(parent, name, size, color)
		local t = Instance.new("TextLabel")
		t.Name, t.BackgroundTransparency = name, 1
		t.Text, t.TextColor3, t.TextSize = "", color or C.ink, size
		t.Font, t.TextXAlignment = Enum.Font.GothamBold, Enum.TextXAlignment.Left
		t.Parent = parent
		return t
	end
	local function button(parent, name, value, color)
		local b = Instance.new("TextButton")
		b.Name, b.Text = name, value
		b.BackgroundColor3, b.TextColor3 = color or C.mint, C.ink
		b.Font, b.TextSize, b.BorderSizePixel = Enum.Font.GothamBold, 14, 0
		b.Parent = parent
		local r = Instance.new("UICorner", b)
		r.CornerRadius = UDim.new(0, 12)
		local e = Instance.new("UIStroke", b)
		e.Color, e.Thickness = C.ink, 1.5
		e.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		Style.Button(b)
		return b
	end
	local root = frame(panel, "InventoryMenu")
	root.Size, root.BackgroundTransparency = UDim2.fromScale(1, 1), 1
	local header = frame(root, "Header", C.blue)
	header.Size, header.Position = UDim2.new(1, -12, 0, 65), UDim2.fromOffset(6, 6)
	Style.Surface(header, Color3.fromRGB(149, 218, 255), Color3.fromRGB(83, 147, 237))
	local title = label(header, "Title", 28, Color3.new(1, 1, 1))
	title.Position, title.Size = UDim2.fromOffset(20, 4), UDim2.new(1, -90, 0, 36)
	title.TextStrokeColor3, title.TextStrokeTransparency = C.ink, 0.55
	local wallet = label(header, "Wallet", 12, Color3.fromRGB(226, 243, 255))
	wallet.Position, wallet.Size = UDim2.fromOffset(22, 40), UDim2.new(1, -90, 0, 18)
	local close = panel.Close
	close.Visible, close.ZIndex = true, 20
	close.Size, close.Position = UDim2.fromOffset(44, 44), UDim2.new(1, -58, 0, 16)
	close.BackgroundColor3, close.TextColor3, close.TextSize =
		Color3.fromRGB(244, 102, 112), Color3.new(1, 1, 1), 24
	Style.Button(close)
	local active, selected = "ARCHIVE", nil
	local pages = { ARCHIVE = {}, ROOM = {}, OPTIONS = {} }
	local tabs, tabOrder = {}, { "ARCHIVE", "ROOM", "OPTIONS" }
	local titles = {
		ARCHIVE = "Creatures",
		ROOM = "My Room",
		OPTIONS = "Settings",
	}
	local list = Instance.new("ScrollingFrame")
	list.Name, list.BackgroundColor3, list.BorderSizePixel = "ItemGrid", Color3.fromRGB(220, 232, 248), 0
	list.ScrollBarThickness, list.ScrollBarImageColor3 = 4, C.blue
	list.Parent = root
	local lr = Instance.new("UICorner", list)
	lr.CornerRadius = UDim.new(0, 14)
	local inspector = frame(root, "SelectedItem", Color3.new(1, 1, 1))
	local badge = label(inspector, "Rarity", 11, C.blue)
	badge.Position, badge.Size = UDim2.fromOffset(18, 12), UDim2.new(1, -36, 0, 18)
	local itemTitle = label(inspector, "ItemName", 22)
	itemTitle.Position, itemTitle.Size = UDim2.fromOffset(18, 33), UDim2.new(1, -36, 0, 32)
	itemTitle.TextWrapped = true
	local previewHost = frame(inspector, "PreviewStage", Color3.fromRGB(229, 240, 255))
	previewHost.Position, previewHost.Size = UDim2.fromOffset(14, 76), UDim2.new(1, -28, 0, 150)
	local previewText = label(previewHost, "Fallback", 28, C.blue)
	previewText.Size, previewText.TextXAlignment = UDim2.fromScale(1, 1), Enum.TextXAlignment.Center
	local descriptionScroll = Instance.new("ScrollingFrame")
	descriptionScroll.Name = "DescriptionScroll"
	descriptionScroll.BackgroundTransparency, descriptionScroll.BorderSizePixel = 1, 0
	descriptionScroll.ScrollBarThickness = 3
	descriptionScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	descriptionScroll.CanvasSize = UDim2.new()
	descriptionScroll.Parent = inspector
	local details = label(descriptionScroll, "Details", 14, C.muted)
	details.Size = UDim2.new(1, -6, 0, 0)
	details.AutomaticSize = Enum.AutomaticSize.Y
	details.TextWrapped, details.TextYAlignment = true, Enum.TextYAlignment.Top
	details.Font = Enum.Font.GothamMedium
	local action = button(inspector, "PrimaryAction", "SELECT AN ITEM")
	action.Size, action.Position = UDim2.new(1, -28, 0, 46), UDim2.new(0, 14, 1, -60)
	local extras = frame(inspector, "ExtraActions")
	extras.BackgroundTransparency = 1
	extras.Size, extras.Position = UDim2.new(1, -28, 0, 38), UDim2.new(0, 14, 1, -106)
	local extraButtons = {}
	for i = 1, 3 do
		local b = button(extras, "Choice" .. i, "", Color3.fromRGB(221, 232, 249))
		b.Size, b.Position = UDim2.new(1 / 3, -6, 1, 0), UDim2.new((i - 1) / 3, 3, 0, 0)
		b.TextSize = 12
		extraButtons[i] = b
		b.Activated:Connect(function()
			if active == "ARCHIVE" and selected then
				remote:FireServer(
					"DisplayCreature",
					i,
					player:GetAttribute("DisplaySlot" .. i) == selected.id and "" or selected.id
				)
			end
		end)
	end
	local empty = label(list, "Empty", 15, C.muted)
	empty.Text, empty.Size, empty.Position =
		"Nothing here yet. Keep exploring!", UDim2.new(1, -24, 0, 60), UDim2.fromOffset(12, 12)
	local footer = label(root, "Footer", 11, C.muted)
	footer.Position, footer.Size = UDim2.new(0, 20, 1, -28), UDim2.new(1, -40, 0, 20)
	local function number(n)
		return n >= 1e6 and string.format("%.1fM", n / 1e6)
			or n >= 1000 and string.format("%.1fK", n / 1000)
			or tostring(math.floor(n))
	end
	local previewSelection
	local function select(item)
		selected = item
		if previewSelection == item then
			return
		end
		previewSelection = item
		descriptionScroll.CanvasPosition = Vector2.zero
		local old = previewHost:FindFirstChild("EquipmentPreview")
		if old then
			old:Destroy()
		end
		if item and item.source then
			local v = Preview.Create(previewHost, item.source, item.tint)
			if v then
				v.Position, v.Size = UDim2.new(), UDim2.fromScale(1, 1)
			end
		end
		previewText.Visible = not (item and item.source)
		previewText.Text = item and (item.symbol or item.name) or ""
	end
	for i, key in tabOrder do
		local b = button(root, "Tab" .. key, titles[key], Color3.fromRGB(220, 232, 248))
		b.Position, b.Size = UDim2.new((i - 1) / #tabOrder, 8, 0, 82), UDim2.new(1 / #tabOrder, -16, 0, 44)
		b.Activated:Connect(function()
			active = key
			list.CanvasPosition = Vector2.zero
			select(pages[key][1])
		end)
		tabs[key] = b
	end
	local function add(page, id, name, color, source, tint, read, perform, symbol)
		local item = {
			id = id,
			name = name,
			color = color or C.blue,
			source = source,
			tint = tint,
			read = read,
			perform = perform,
			symbol = symbol,
		}
		local tile = button(list, id, "", Color3.new(1, 1, 1))
		tile.ClipsDescendants = true
		local cap = label(tile, "Name", 12)
		cap.Text, cap.TextWrapped, cap.TextXAlignment = name, true, Enum.TextXAlignment.Center
		cap.Size, cap.Position = UDim2.new(1, -10, 0, 32), UDim2.new(0, 5, 1, -54)
		local state = label(tile, "State", 10, C.blue)
		state.Size, state.Position, state.TextXAlignment =
			UDim2.new(1, -8, 0, 18), UDim2.new(0, 4, 1, -20), Enum.TextXAlignment.Center
		if source then
			local view = Preview.Create(tile, source, tint)
			if view then
				view.Position, view.Size = UDim2.fromOffset(6, 6), UDim2.new(1, -12, 1, -63)
			end
		else
			local glyph = label(tile, "Symbol", 28, item.color)
			glyph.Text, glyph.TextXAlignment = symbol or name:sub(1, 1), Enum.TextXAlignment.Center
			glyph.Position, glyph.Size = UDim2.fromOffset(6, 6), UDim2.new(1, -12, 1, -63)
		end
		item.tile, item.caption, item.state = tile, cap, state
		tile.Activated:Connect(function()
			select(item)
		end)
		table.insert(pages[page], item)
		return item
	end
	for _, d in Rules.CreatureVariants do
		add(
			"ARCHIVE",
			d.Id,
			d.Name,
			d.Color,
			shared.SpecimenAssets:FindFirstChild("crownback"),
			d.Color,
			function()
				local owned = player:GetAttribute("Creature_" .. d.Id) or 0
				local chosen = player:GetAttribute("EquippedCreature") == d.Id
				local solo = shared.RoundState:GetAttribute("EggDropChance")
				local personal = player:GetAttribute("MiningContribution")
				local total = shared.RoundState:GetAttribute("EffectiveDamage")
				local odds = "Synchronizing creature chances..."
				if typeof(solo) == "number" and typeof(personal) == "number" and typeof(total) == "number"
					and player:GetAttribute("ContributionRound") == shared.RoundState:GetAttribute("RoundId") then
					local share = total > 0 and personal / total or 0
					local chance = solo * share
					local weight = 0
					for _, variant in Rules.CreatureVariants do weight += variant.Weight end
					odds = string.format("Egg solo chance: %.6g%%\nYour contribution so far: %.6g%%\nAny creature: %.6g%% / This variant: %.6g%%\nProvisional until completion. Zero damage means no roll.",
						solo * 100, share * 100, chance * 100, chance * d.Weight / weight * 100)
				end
				return d.Rarity .. "  /  " .. owned .. " OWNED",
					string.format("+%d%% mining power\n\n%s\nChoose a shelf below to display this creature.", math.floor(d.Power * 100 + 0.5), odds),
					chosen and "BUFF ACTIVE" or owned > 0 and "ACTIVATE BUFF" or "NOT DISCOVERED",
					owned > 0 and not chosen
			end,
			function()
				remote:FireServer("Creature", d.Id)
			end
		)
	end
	for _, d in Rules.RoomThemes do
		add("ROOM", d.Id, d.Name, d.Color, nil, nil, function()
			local owned = player:GetAttribute("OwnsTheme_" .. d.Id)
			local chosen = player:GetAttribute("RoomTheme") == d.Id
			return chosen and "ACTIVE" or owned and "OWNED" or "LOCKED",
				"Personalize your shelf lighting and room accents.",
				chosen and "APPLIED" or owned and "APPLY THEME" or "UNLOCK  /  " .. number(d.Cost),
				not chosen and (owned or (player:GetAttribute("Cash") or 0) >= d.Cost)
		end, function()
			remote:FireServer("RoomTheme", d.Id)
		end, "+")
	end
	add("OPTIONS", "Sound", "Sound effects", C.gold, nil, nil, function()
		local on = (player:GetAttribute("SFXVolume") or 1) > 0
		return on and "ON" or "OFF", "Impact and collection sound effects.", on and "MUTE" or "ENABLE", true
	end, function()
		player:SetAttribute("SFXVolume", (player:GetAttribute("SFXVolume") or 1) > 0 and 0 or 1)
	end, "+")
	add("OPTIONS", "Motion", "Reduced motion", C.blue, nil, nil, function()
		local on = player:GetAttribute("ReducedMotion")
		return on and "ON" or "OFF",
			"Reduce camera movement, impact effects, and interface motion.",
			on and "TURN OFF" or "TURN ON",
			true
	end, function()
		player:SetAttribute("ReducedMotion", not player:GetAttribute("ReducedMotion"))
	end, "+")
	add("OPTIONS", "Training", "Training", C.mint, nil, nil, function()
		local on = player:GetAttribute("Training")
		return on and "TRAINING" or "READY",
			"Use the practice device in your room to gain permanent strength.",
			on and "STOP TRAINING" or "START AT YOUR DEVICE",
			true
	end, function()
		remote:FireServer("Training")
	end, "+")
	action.Activated:Connect(function()
		if selected then
			local _, _, _, enabled = selected.read()
			if enabled then
				selected.perform()
			end
		end
	end)
	select(pages.ARCHIVE[1])
	local api = {}
	function api:Select(page)
		if pages[page] then
			active = page
			list.CanvasPosition = Vector2.zero
			select(pages[page][1])
		end
	end
	function api:Update()
		if not panel.Visible then
			return
		end
		local available = gui.AbsoluteSize
		local fit = math.min(1, (available.Y - 24) / 560)
		local width, height = math.min(940, (available.X - 24) / fit), math.min(640, (available.Y - 24) / fit)
		local compact = width < 650
		panel.Size = UDim2.fromOffset(width, height)
		panel.Fit.Scale = fit
		local bodyHeight = height - 170
		local gridWidth = compact and width - 32 or math.floor(width * 0.54) - 24
		local gridHeight = compact and 104 or bodyHeight
		list.Position, list.Size = UDim2.fromOffset(16, 138), UDim2.fromOffset(gridWidth, gridHeight)
		inspector.Position = compact and UDim2.fromOffset(16, 148 + gridHeight)
			or UDim2.fromOffset(gridWidth + 30, 138)
		inspector.Size = compact and UDim2.fromOffset(width - 32, bodyHeight - gridHeight - 10)
			or UDim2.fromOffset(width - gridWidth - 46, bodyHeight)
		local ih = inspector.Size.Y.Offset
		local previewHeight = compact and 48 or 150
		previewHost.Position, previewHost.Size =
			UDim2.fromOffset(14, compact and 60 or 76), UDim2.new(1, -28, 0, previewHeight)
		itemTitle.TextSize = compact and 17 or 22
		badge.Position = UDim2.fromOffset(18, compact and 6 or 12)
		itemTitle.Position = UDim2.fromOffset(18, compact and 23 or 33)
		local extra = active == "ARCHIVE"
		extras.Visible = extra
		descriptionScroll.Position = UDim2.fromOffset(18, (compact and 68 or 86) + previewHeight)
		descriptionScroll.Size = UDim2.new(
			1,
			-36,
			0,
			math.max(0, ih - descriptionScroll.Position.Y.Offset - (extra and 112 or 65))
		)
		details.TextSize = compact and 12 or 14
		for _, key in tabOrder do
			tabs[key].BackgroundColor3 = key == active and C.gold or Color3.fromRGB(220, 232, 248)
			tabs[key].TextSize = compact and 10 or 14
		end
		title.Text = titles[active]
		wallet.Text = number(player:GetAttribute("Cash") or 0)
			.. " COINS  /  "
			.. number(player:GetAttribute("Strength") or 0)
			.. " STRENGTH"
		local count = 0
		local columns = compact and 3 or 3
		local tileWidth = (gridWidth - 28 - (columns - 1) * 10) / columns
		local tileHeight = compact and 120 or 156
		for key, items in pages do
			for _, item in items do
				local visible = key == active and not (item.hidden and item.hidden())
				item.tile.Visible = visible
				if visible then
					item.tile.Size = UDim2.fromOffset(tileWidth, tileHeight)
					item.tile.Position = UDim2.fromOffset(
						10 + (count % columns) * (tileWidth + 10),
						10 + math.floor(count / columns) * (tileHeight + 10)
					)
					count += 1
					item.state.Text = item.read()
					item.tile.BackgroundColor3 = item == selected and Color3.fromRGB(255, 237, 179)
						or Color3.new(1, 1, 1)
				end
			end
		end
		empty.Visible = count == 0
		list.CanvasSize = UDim2.fromOffset(0, 20 + math.ceil(count / columns) * (tileHeight + 10))
		if selected then
			local state, description, cta, enabled = selected.read()
			badge.Text, itemTitle.Text, details.Text, action.Text = state, selected.name, description, cta
			action.Interactable = enabled
			action.BackgroundColor3 = enabled and C.mint or Color3.fromRGB(207, 219, 235)
			for i, b in extraButtons do
				b.Text = "SHELF " .. i
				local chosen = active == "ARCHIVE" and player:GetAttribute("DisplaySlot" .. i) == selected.id
				b.BackgroundColor3 = chosen and C.gold or Color3.fromRGB(221, 232, 249)
				b.Interactable = active ~= "ARCHIVE"
					or (player:GetAttribute("Creature_" .. selected.id) or 0) > 0
			end
		end
		footer.Text = active == "ARCHIVE" and "Choose one active buff. Display up to three creatures in your room."
			or "Select an item to see its details."
	end
	return api
end
return W
