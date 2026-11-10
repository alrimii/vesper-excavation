local H = {}
function H.Attach(gui, player)
	local Shared = game.ReplicatedStorage.VesperShared
	local Catalog = require(Shared.DiscoveryCatalog)
	local Preview = require(Shared.SpecimenPreview)
	local State = Shared.RoundState
	require(Shared.ExpeditionResults).Attach(gui, player)
	local UIS = game:GetService("UserInputService")
	local Tween = game:GetService("TweenService")
	local teal = Color3.fromRGB(113, 236, 210)
	local gold = Color3.fromRGB(255, 213, 138)
	local muted = Color3.fromRGB(157, 180, 193)
	local function frame(parent, name, size, pos)
		local f = Instance.new("Frame")
		f.Name = name
		f.Size = size
		f.Position = pos
		f.BackgroundColor3 = Color3.fromRGB(14, 24, 36)
		f.BorderSizePixel = 0
		f.Parent = parent
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, 12)
		c.Parent = f
		local s = Instance.new("UIStroke")
		s.Color = Color3.fromRGB(58, 81, 99)
		s.Transparency = 0.25
		s.Parent = f
		return f
	end
	local function text(parent, name, value, size, pos, fs, color)
		local t = Instance.new("TextLabel")
		t.Name = name
		t.Text = value
		t.Size = size
		t.Position = pos
		t.BackgroundTransparency = 1
		t.Font = Enum.Font.GothamMedium
		t.TextColor3 = color or Color3.fromRGB(238, 246, 249)
		t.TextSize = fs or 14
		t.TextXAlignment = Enum.TextXAlignment.Left
		t.Parent = parent
		return t
	end
	local function button(parent, name, value, size, pos)
		local b = Instance.new("TextButton")
		b.Name = name
		b.Size = size
		b.Position = pos
		b.Text = value
		b.TextSize = 13
		b.Font = Enum.Font.GothamBold
		b.TextColor3 = teal
		b.BackgroundColor3 = Color3.fromRGB(27, 51, 65)
		b.BorderSizePixel = 0
		b.Parent = parent
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, 9)
		c.Parent = b
		b.AutoButtonColor = false
		return b
	end
	local dim = Instance.new("TextButton")
	dim.Name = "JournalShade"
	dim.Size = UDim2.fromScale(1, 1)
	dim.BackgroundColor3 = Color3.new()
	dim.BackgroundTransparency = 1
	dim.Text = ""
	dim.Visible = false
	dim.ZIndex = 39
	dim.Parent = gui
	local journal = frame(gui, "Journal", UDim2.fromOffset(650, 510), UDim2.fromScale(0.5, 0.5))
	journal.AnchorPoint = Vector2.new(0.5, 0.5)
	journal.Visible = false
	journal.Active = true
	journal.ZIndex = 40
	require(Shared.ModalLayout).Backdrop(gui, journal, { Color = Color3.new(), Transparency = 0.35 })
	local fit = Instance.new("UIScale")
	fit.Parent = journal
	text(
		journal,
		"Kicker",
		"VESPER  /  RESEARCH DIVISION",
		UDim2.fromOffset(550, 20),
		UDim2.fromOffset(24, 18),
		11,
		teal
	)
	text(journal, "Title", "The living archive", UDim2.fromOffset(560, 36), UDim2.fromOffset(24, 44), 28).Font =
		Enum.Font.GothamBold
	local sub = text(journal, "Subtitle", "", UDim2.fromOffset(580, 25), UDim2.fromOffset(24, 84), 13, muted)
	local close = button(journal, "Close", "X", UDim2.fromOffset(38, 38), UDim2.new(1, -54, 0, 20))
	local cards = {}
	for i, entry in Catalog.Specimens do
		local card = frame(
			journal,
			entry.Id,
			UDim2.fromOffset(190, 165),
			UDim2.fromOffset(24 + ((i - 1) % 3) * 206, 123 + math.floor((i - 1) / 3) * 181)
		)
		local view = Instance.new("ViewportFrame")
		view.Size = UDim2.new(1, -16, 0, 108)
		view.Position = UDim2.fromOffset(8, 5)
		view.BackgroundTransparency = 1
		view.Ambient = Color3.fromRGB(180, 190, 210)
		view.LightColor = Color3.fromRGB(255, 246, 220)
		view.Parent = card
		local preview = Preview.Create(view, entry.Id, entry.Color)
		local name = text(
			card,
			"Name",
			entry.Name,
			UDim2.new(1, -20, 0, 23),
			UDim2.fromOffset(10, 116),
			14,
			entry.Color
		)
		local count = text(
			card,
			"Count",
			"UNDISCOVERED",
			UDim2.new(1, -20, 0, 18),
			UDim2.fromOffset(10, 141),
			10,
			muted
		)
		table.insert(
			cards,
			{ root = card, view = view, name = name, count = count, entry = entry, preview = preview }
		)
	end
	for _, v in journal:GetDescendants() do
		if v:IsA("GuiObject") then
			v.ZIndex = 41
		end
	end
	local function toggle(open)
		if open and player:GetAttribute("SkillTreeOpen") then
			return
		end
		journal.Visible = open
		dim.Visible = open
		player:SetAttribute("ResearchModal", open)
		if open and UIS.PreferredInput == Enum.PreferredInput.Gamepad then
			game:GetService("GuiService").SelectedObject = close
		end
		if not open and game:GetService("GuiService").SelectedObject == close then
			game:GetService("GuiService").SelectedObject = nil
		end
	end
	close.Activated:Connect(function()
		toggle(false)
	end)
	dim.Activated:Connect(function()
		toggle(false)
	end)
	UIS.InputBegan:Connect(function(input, processed)
		if processed or player:GetAttribute("SkillTreeOpen") then
			return
		end
		if input.KeyCode == Enum.KeyCode.J or input.KeyCode == Enum.KeyCode.ButtonX then
			toggle(not journal.Visible)
		elseif input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.ButtonB then
			toggle(false)
		end
	end)
	local reward = frame(gui, "ResearchReward", UDim2.fromOffset(390, 132), UDim2.fromScale(0.5, 0.28))
	reward.AnchorPoint = Vector2.new(0.5, 0.5)
	reward.Visible = false
	reward.ZIndex = 30
	local rewardScale = Instance.new("UIScale")
	rewardScale.Parent = reward
	local rTitle = text(reward, "Title", "", UDim2.new(1, -32, 0, 22), UDim2.fromOffset(16, 14), 12, teal)
	local rName = text(reward, "Name", "", UDim2.new(1, -32, 0, 38), UDim2.fromOffset(16, 39), 23)
	rName.Font = Enum.Font.GothamBold
	local rValue = text(reward, "Value", "", UDim2.new(1, -32, 0, 24), UDim2.fromOffset(16, 88), 15, gold)
	for _, v in reward:GetDescendants() do
		if v:IsA("GuiObject") then
			v.ZIndex = 31
		end
	end
	local queue = {}
	local presenting = false
	local function showNext()
		if presenting or #queue == 0 then
			return
		end
		presenting = true
		local item = table.remove(queue, 1)
		rTitle.Text = item[1]
		rName.Text = item[2]
		rValue.Text = "+" .. item[3] .. " credits  /  Research updated"
		reward.Visible = true
		rewardScale.Scale = 0.9
		Tween:Create(
			rewardScale,
			TweenInfo.new(0.3, Enum.EasingStyle.Back),
			{ Scale = math.min(1, (workspace.CurrentCamera.ViewportSize.X - 28) / 390) }
		):Play()
		task.delay(3, function()
			reward.Visible = false
			presenting = false
			showNext()
		end)
	end
	Shared.Remotes.Feedback.OnClientEvent:Connect(function(kind, a, b, c)
		if kind == "ResearchReward" then
			local function enqueue()
				table.insert(queue, { a, b, c })
				showNext()
			end
			if
				a == "NEW DISCOVERY"
				or a == "SPECIMEN RECOVERED"
				or a == "RARE CREATURE ACQUIRED"
				or a == "EXPEDITION COMPLETE"
			then
				task.delay(5.7, enqueue)
			else
				enqueue()
			end
		elseif
			kind == "Reveal"
			and player:GetAttribute("LabReady") == true
			and b == State:GetAttribute("RoundId")
			and typeof(c) == "number"
			and c > (player:GetAttribute("GameplayArrivalAt") or math.huge)
		then
			for _, entry in Catalog.Specimens do
				if entry.Id == a then
					toggle(false)
					require(Shared.DiscoveryCinematic).Start(player, entry, c)
					break
				end
			end
		end
	end)
	local gallery = workspace.VesperLab:WaitForChild("ResearchGallery")
	local function updateGallery()
		for _, entry in Catalog.Specimens do
			local pod = gallery:FindFirstChild(entry.Id)
			local discovered = (player:GetAttribute("Discovery_" .. entry.Id) or 0) > 0
			if pod then
				pod.Plaque.Title.Text = entry.Class .. "\n" .. (discovered and entry.Name or "UNDISCOVERED")
				for _, p in pod:GetDescendants() do
					if p:IsA("BasePart") and p:GetAttribute("OriginalColor") then
						p.Color = discovered and p:GetAttribute("OriginalColor") or Color3.fromRGB(28, 45, 60)
					end
				end
			end
		end
	end
	for _, entry in Catalog.Specimens do
		player:GetAttributeChangedSignal("Discovery_" .. entry.Id):Connect(updateGallery)
	end
	updateGallery()
	require(Shared.SpecimenMotion).Start(workspace.VesperLab.Egg.ContainedSpecimen, State)
	local api = {}
	local researchJournal = require(Shared.ResearchJournal).Attach(journal, cards, player)
	-- The new HUD owns navigation; this retained controller owns journal/reveal only.
	api.Toggle = toggle
	function api.Update(_kind)
		local v = gui.AbsoluteSize
		local narrow = v.X < 800
		local portrait = v.X < 600 and v.Y > v.X
		local journalWidth, journalHeight = portrait and 440 or 650, portrait and 690 or 510
		local short = v.Y < 450
		if short then
			journalHeight = 350
		end
		journal.Size = UDim2.fromOffset(journalWidth, journalHeight)
		journal.Title.Size = UDim2.new(1, -48, 0, 36)
		journal.Subtitle.Size = UDim2.new(1, -48, 0, 25)
		journal.Subtitle.TextSize = portrait and 12 or 13
		fit.Scale = math.min(1, (v.X - 24) / journalWidth, (v.Y - 26) / journalHeight)
		for i, card in cards do
			local columns = portrait and 2 or 3
			card.root.Position = UDim2.fromOffset(
				24 + ((i - 1) % columns) * 206,
				(short and 112 or 123) + math.floor((i - 1) / columns) * (short and 116 or 181)
			)
			card.root.Size = UDim2.fromOffset(190, short and 110 or 165)
			card.view.Size = UDim2.new(1, -16, 0, short and 64 or 108)
			card.name.Position = UDim2.fromOffset(10, short and 70 or 116)
			card.count.Position = UDim2.fromOffset(10, short and 92 or 141)
			card.count.TextSize = (portrait or short) and 12 or 10
			if #cards == 1 then
				card.root.Position = UDim2.fromOffset(24, short and 112 or 123)
				card.root.Size = UDim2.new(1, -48, 1, short and -132 or -145)
				card.view.Size = UDim2.new(1, -32, 1, -66)
				card.view.Position = UDim2.fromOffset(16, 5)
				card.name.Position = UDim2.new(0, 16, 1, -52)
				card.name.TextSize = 20
				card.count.Position = UDim2.new(0, 16, 1, -27)
				card.count.TextSize = 12
			end
		end
		if journal.Visible then
			sub.Text = (player:GetAttribute("DiscoveryCount") or 0)
				.. " / "
				.. #Catalog.Specimens
				.. " species documented  |  "
				.. (player:GetAttribute("SaveStatus") or "LOADING")
			for _, card in cards do
				local count = player:GetAttribute("Discovery_" .. card.entry.Id) or 0
				card.preview:SetUnlocked(count > 0)
				card.name.Text = count > 0 and card.entry.Name or "Unknown lifeform"
				card.count.Text = count > 0 and "RECOVERED  x" .. count or card.entry.Class .. "  /  LOCKED"
			end
		end
		researchJournal.Update()
	end
	return api
end
return H
