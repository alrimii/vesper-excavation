-- Personal collections, room choices, preferences and controls share the field journal shell.
local M = {}
function M.Build(shell, player, _base, remote, feedback)
	local K = require(script.Parent.InterfaceKit)
	local Rules = require(script.Parent.ProgressionRules)
	local Preview = require(script.Parent.EquipmentPreview)
	local root = K.Make(
		"Frame",
		shell.Body,
		{ Name = "PersonalMenus", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false }
	)
	local scroll = K.Scroll(root, "Content")
	scroll.Size = UDim2.fromScale(1, 1)
	local active, selected = "ARCHIVE", nil
	local pages = {}
	local function attr(k)
		return player:GetAttribute(k)
	end
	local function page(id)
		local p = K.Make("Frame", scroll, {
			Name = id,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -8, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Visible = false,
		})
		pages[id] = p
		return p
	end
	local archive = page("ARCHIVE")
	local owner = K.Text(archive, "Owner", player.DisplayName .. "'s collection", 18, K.Green, true)
	local tabs = {}
	for _, d in Rules.CreatureVariants do
		local b = K.Button(archive, "Creature_" .. d.Id, "", function()
			selected = d.Id
		end, true)
		local view = Preview.Create(b, require(script.Parent.SpecimenBuilder).Source(d.Id), d.Color)
		tabs[d.Id] = {
			root = b,
			view = view,
			name = K.Text(b, "Name", "", 16, K.Ink, true),
			state = K.Text(b, "State", "", 13, K.Muted),
		}
	end
	local detail = K.Surface(archive, "CreatureDetails")
	local dname = K.Text(detail, "Name", "", 28)
	dname.Font = K.Title
	local desc = K.Text(detail, "Description", "", 15, K.Muted)
	local odds = K.Text(detail, "Chance", "", 14, K.Muted)
	local equip = K.Button(detail, "Activate", "", function()
		if selected then
			remote:FireServer("Creature", selected)
		end
	end)
	local slotsLabel = K.Text(detail, "DisplayLabel", "Featured room shelves", 15, K.Ink, true)
	local slots = {}
	for i = 1, 3 do
		slots[i] = K.Button(detail, "Shelf" .. i, "Shelf " .. i, function()
			if selected then
				remote:FireServer(
					"DisplayCreature",
					i,
					attr("DisplaySlot" .. i) == selected and "" or selected
				)
			end
		end, true)
	end
	local room = page("ROOM")
	K.Stack(room, 12)
	local rt = K.Paragraph(room, "RoomIntro", "Your room", 28, K.Ink)
	rt.Font = K.Title
	K.Paragraph(room, "RoomDescription", "Give your collection a home that feels like you.", 16, K.Muted)
	local home = K.Button(room, "GoHome", "Go to my room", function()
		shell:SetOpen(false)
		remote:FireServer("Home")
	end)
	home.Size = UDim2.new(1, -8, 0, 44)
	local themes = {}
	for _, d in Rules.RoomThemes do
		local r = K.Surface(room, "Theme_" .. d.Id)
		r.Size = UDim2.new(1, -8, 0, 96)
		local swatch = K.Surface(r, "MaterialSample", d.Color)
		K.Rect(swatch, 12, 12, 56, 72)
		local title = K.Text(r, "Name", d.Name, 21, K.Ink, true)
		title.Position = UDim2.fromOffset(82, 8)
		title.Size = UDim2.new(1, -98, 0, 28)
		local b = K.Button(r, "Apply", "", function()
			remote:FireServer("RoomTheme", d.Id)
		end)
		b.Position = UDim2.fromOffset(82, 42)
		b.Size = UDim2.new(1, -98, 0, 42)
		themes[d.Id] = b
	end
	local options = page("OPTIONS")
	K.Stack(options, 14)
	local ot = K.Paragraph(options, "Intro", "Play your way!", 28, K.Ink)
	ot.Font = K.Title
	K.Paragraph(options, "Subheading", "Your choices are saved automatically.", 15, K.Muted)
	local settingButtons = {}
	for _, entry in
		{
			{ "Sound", "Sound effects", "Impact, tool and collection sounds.", "SFXVolume" },
			{
				"Motion",
				"Reduced motion",
				"Reduce camera movement and interface animation.",
				"ReducedMotion",
			},
		}
	do
		local r = K.Surface(options, entry[1])
		r.Size = UDim2.new(1, -8, 0, 114)
		local icon = K.Icon(r, entry[1])
		K.Rect(icon, 12, 12, 58, 58)
		local title = K.Text(r, "Name", entry[2], 19, K.Ink, true)
		title.Position = UDim2.fromOffset(82, 10)
		title.Size = UDim2.new(1, -96, 0, 28)
		local body = K.Text(r, "Description", entry[3], 14, K.Muted)
		body.Position = UDim2.fromOffset(82, 38)
		body.Size = UDim2.new(1, -96, 0, 28)
		local b = K.Button(r, "Toggle", "", function()
			local current = entry[4] == "SFXVolume" and (attr("SFXVolume") or 1) > 0
				or entry[4] == "ReducedMotion" and attr("ReducedMotion") == true
			remote:FireServer(
				"InterfacePreference",
				entry[4],
				entry[4] == "SFXVolume" and (current and 0 or 1) or not current
			)
		end)
		b.Position = UDim2.fromOffset(82, 68)
		b.Size = UDim2.new(1, -96, 0, 36)
		settingButtons[entry[4]] = b
	end
	local saveStatus = K.Paragraph(options, "SaveFeedback", "", 14, K.Green)
	feedback.OnClientEvent:Connect(function(kind, ok, message)
		if kind == "PreferenceReceipt" then
			saveStatus.Text = message
			saveStatus.TextColor3 = ok and K.Green or K.Error
		end
	end)
	local training = K.Button(options, "Training", "", function()
		remote:FireServer("Training")
	end, true)
	training.Size = UDim2.new(1, -8, 0, 44)
	K.Paragraph(options, "TrainingHint", "Training begins at the device in your own room.", 14, K.Muted)
	local help = K.Button(options, "Controls", "How to play", function()
		active = "HELP"
	end, true)
	help.Size = UDim2.new(1, -8, 0, 44)
	K.Paragraph(
		options,
		"Attribution",
		"Original illustrated UI. Pickaxe: Kay Lousberg (CC0). Sticky charge: owner-supplied Rodin. Full asset credits are recorded in the project.",
		12,
		K.Muted
	)
	local guide = page("HELP")
	K.Stack(guide, 12)
	local gt = K.Paragraph(guide, "Title", "Let's dig in!", 28)
	gt.Font = K.Title
	for _, row in
		{
			{
				"Excavate",
				"Aim at an exposed shell section. Click or hold E to use your tool. Touch: hold STRIKE; tap DRILL to start or stop. Controller: RT / R2.",
			},
			{
				"Equipment",
				"1–3 selects an owned tool. Controller: cycle tools with the directional controls. Use Equipment to buy tools and upgrade the equipped tool.",
			},
			{
				"Move & explore",
				"WASD to move, Space to jump, Shift to sprint. Ctrl toggles mouse lock. Touch uses the movement stick and sprint button.",
			},
			{
				"Skills",
				"K opens the skill tree. Select a node before learning it. Q uses Charged Swing when it is equipped. Active skills and free respec require your own room and 10 seconds without mining.",
			},
			{
				"Research & collection",
				"J opens your journal. Materials fill the bag; sell them for credits. Your contribution determines your personal creature chance. Choose one active creature bonus and three featured shelf displays.",
			},
			{
				"Training",
				"Enter the training station in your own room. Leave the area to stop. No training takes place while a blocking menu is open.",
			},
		}
	do
		local f = K.Surface(guide, row[1])
		f.Size = UDim2.new(1, -8, 0, 0)
		f.AutomaticSize = Enum.AutomaticSize.Y
		K.Make("UIPadding", f, {
			PaddingTop = UDim.new(0, 14),
			PaddingBottom = UDim.new(0, 14),
			PaddingLeft = UDim.new(0, 16),
			PaddingRight = UDim.new(0, 16),
		})
		K.Stack(f, 7)
		local t = K.Paragraph(f, "Heading", row[1], 19, K.Green)
		t.Font = K.Bold
		K.Paragraph(f, "Description", row[2], 15, K.Ink)
	end
	local titles = {
		ARCHIVE = "Creature collection",
		ROOM = "My room",
		OPTIONS = "Settings",
		HELP = "Controls & guidance",
	}
	local api = { Root = root }
	function api:Select(p)
		active = pages[p] and p or "ARCHIVE"
		selected = selected or Rules.CreatureVariants[1].Id
		scroll.CanvasPosition = Vector2.zero
	end
	function api:Update()
		if not root.Visible then
			return
		end
		shell.Title.Text = titles[active]
		for id, p in pages do
			p.Visible = id == active
		end
		local w = root.AbsoluteSize.X - 8
		if active == "OPTIONS" then
			settingButtons.SFXVolume.Text = (attr("SFXVolume") or 1) > 0 and "Sound on · mute"
				or "Sound off · enable"
			settingButtons.ReducedMotion.Text = attr("ReducedMotion") and "Reduced motion on · disable"
				or "Reduced motion off · enable"
			K.Enabled(
				training,
				attr("Training") == true,
				attr("Training") and "Stop training" or "Enter your training station"
			)
		elseif active == "ROOM" then
			for _, d in Rules.RoomThemes do
				local chosen = attr("RoomTheme") == d.Id
				local owned = attr("OwnsTheme_" .. d.Id)
				K.Enabled(
					themes[d.Id],
					not chosen and (owned or (attr("Cash") or 0) >= d.Cost),
					chosen and "Applied"
						or owned and "Apply theme"
						or "Unlock · " .. K.Number(d.Cost) .. " credits"
				)
			end
		elseif active == "ARCHIVE" then
			K.Rect(owner, 0, 0, w, 32)
			local cols = w < 600 and 2 or 3
			local cw = (w - (cols - 1) * 10) / cols
			for i, d in Rules.CreatureVariants do
				local v = tabs[d.Id]
				local count = attr("Creature_" .. d.Id) or 0
				K.Rect(v.root, ((i - 1) % cols) * (cw + 10), 42 + math.floor((i - 1) / cols) * 178, cw, 168)
				K.Rect(v.view, 8, 4, cw - 16, 106)
				K.Rect(v.name, 10, 112, cw - 20, 24)
				K.Rect(v.state, 10, 138, cw - 20, 20)
				v.root.BackgroundColor3 = selected == d.Id and K.Card or K.Line
				v.name.Text = count > 0 and d.Name or "Undiscovered"
				v.state.Text = count > 0 and d.Rarity .. " · ×" .. count or "Not yet recovered"
				v.view.ImageColor3 = count > 0 and Color3.new(1, 1, 1) or Color3.new(0.015, 0.02, 0.017)
			end
			local y = 42 + math.ceil(#Rules.CreatureVariants / cols) * 178
			K.Rect(detail, 0, y, w, 354)
			local d = Rules.Creature(selected)
			local count = d and (attr("Creature_" .. selected) or 0) or 0
			K.Rect(dname, 16, 12, w - 32, 40)
			K.Rect(desc, 16, 56, w - 32, 50)
			K.Rect(odds, 16, 112, w - 32, 70)
			K.Rect(equip, 16, 194, w - 32, 44)
			K.Rect(slotsLabel, 16, 252, w - 32, 24)
			for i, b in slots do
				K.Rect(b, 16 + (i - 1) * (w - 24) / 3, 288, (w - 48) / 3, 44)
				K.Enabled(
					b,
					count > 0,
					attr("DisplaySlot" .. i) == selected and "Clear shelf " .. i or "Shelf " .. i
				)
			end
			dname.Text = count > 0 and d.Name or "Undiscovered creature"
			desc.Text = count > 0
					and string.format(
						"%s · %d owned\n+%d%% mining power when active",
						d.Rarity,
						count,
						math.floor(d.Power * 100 + 0.5)
					)
				or "Recover this creature from an egg to add it to your collection."
			local state = script.Parent.RoundState
			local solo, total, personal =
				state:GetAttribute("EggDropChance"),
				state:GetAttribute("EffectiveDamage"),
				attr("MiningContribution")
			odds.Text = ""
			if
				count > 0
				and typeof(solo) == "number"
				and typeof(total) == "number"
				and typeof(personal) == "number"
				and attr("ContributionRound") == state:GetAttribute("RoundId")
			then
				local weight = 0
				for _, v in Rules.CreatureVariants do
					weight += v.Weight
				end
				local chance = solo * (total > 0 and personal / total or 0)
				odds.Text = string.format(
					"Current chance: %.6g%% any creature · %.6g%% this variant\nBased on your contribution so far; final odds settle at completion.",
					chance * 100,
					chance * d.Weight / weight * 100
				)
			end
			local chosen = attr("EquippedCreature") == selected
			if d and d.TestOnly then
				odds.Text = "Owner test access only. Normal acquisition is not configured."
			end
			K.Enabled(
				equip,
				count > 0 and not chosen,
				chosen and "Bonus active" or count > 0 and "Activate creature bonus" or "Not discovered"
			)
		end
	end
	return api
end
return M
