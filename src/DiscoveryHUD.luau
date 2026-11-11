-- Journal, discoveries and rewards. Existing reveal/gallery behavior is retained below.
local H = {}
function H.Attach(gui, player)
	local Shared = script.Parent
	local K = require(Shared.InterfaceKit)
	local Catalog = require(Shared.DiscoveryCatalog)
	local State = Shared.RoundState
	require(Shared.ExpeditionResults).Attach(gui, player)
	local shell = K.Shell(player, "FieldJournal", "Research journal", "ResearchModal", nil, 900)
	local active = "RESEARCH"
	local b1 = K.Button(shell.Body, "ResearchTab", "Research", function()
		active = "RESEARCH"
	end, true)
	local b2 = K.Button(shell.Body, "SpeciesTab", "Discoveries", function()
		active = "SPECIES"
	end, true)
	K.Rect(b1, 0, 0, 130, 44)
	K.Rect(b2, 138, 0, 130, 44)
	local research = K.Scroll(shell.Body, "Research")
	K.Stack(research, 14)
	local species = K.Scroll(shell.Body, "Discoveries")
	K.Stack(species, 14)
	local level = K.Paragraph(research, "Level", "", 28)
	level.Font = K.Title
	local xp = K.Paragraph(research, "XP", "", 16, K.Green)
	local contract = K.Surface(research, "Contract")
	contract.Size = UDim2.new(1, -8, 0, 0)
	contract.AutomaticSize = Enum.AutomaticSize.Y
	K.Make(
		"UIPadding",
		contract,
		{
			PaddingTop = UDim.new(0, 16),
			PaddingBottom = UDim.new(0, 16),
			PaddingLeft = UDim.new(0, 18),
			PaddingRight = UDim.new(0, 18),
		}
	)
	K.Stack(contract, 10)
	K.Paragraph(contract, "Caption", "ACTIVE CONTRACT", 12, K.Green)
	local ct = K.Paragraph(contract, "Title", "", 23, K.Ink)
	ct.Font = K.Bold
	local hint = K.Paragraph(contract, "Hint", "", 16, K.Muted)
	local progress = K.Paragraph(contract, "Progress", "", 18, K.Green)
	local upcoming = {}
	for i = 1, 3 do
		upcoming[i] = K.Paragraph(research, "Upcoming" .. i, "", 16, K.Muted)
	end
	local cards = {}
	for _, entry in Catalog.Specimens do
		local card = K.Surface(species, entry.Id)
		card.Size = UDim2.new(1, -8, 0, 280)
		local view = K.Make(
			"ViewportFrame",
			card,
			{
				Name = "Specimen",
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(12, 8),
				Size = UDim2.new(1, -24, 0, 202),
				Ambient = Color3.fromRGB(180, 190, 180),
				LightColor = Color3.fromRGB(255, 246, 220),
			}
		)
		local preview = require(Shared.SpecimenPreview).Create(view, entry.Id, entry.Color)
		local name = K.Text(card, "Name", "", 23, K.Ink, true)
		name.Position = UDim2.fromOffset(18, 212)
		name.Size = UDim2.new(1, -36, 0, 30)
		local count = K.Text(card, "Count", "", 14, K.Muted)
		count.Position = UDim2.fromOffset(18, 246)
		count.Size = UDim2.new(1, -36, 0, 24)
		table.insert(cards, { entry = entry, preview = preview, name = name, count = count })
	end
	local function toggle(open)
		if open and (not player:GetAttribute("LabReady") or player:GetAttribute("DiscoveryCinematic")) then
			return
		end
		shell:SetOpen(open)
	end
	game:GetService("UserInputService").InputBegan:Connect(function(i, processed)
		if
			not processed
			and not game:GetService("UserInputService"):GetFocusedTextBox()
			and (i.KeyCode == Enum.KeyCode.J or i.KeyCode == Enum.KeyCode.ButtonX)
			and not player:GetAttribute("SkillTreeOpen")
		then
			toggle(not shell.Open)
		end
	end)
	local reward = K.Surface(gui, "ResearchReward", K.Dark)
	reward.AnchorPoint = Vector2.new(1, 1)
	reward.Position = UDim2.new(1, -16, 1, -120)
	reward.Size = UDim2.new(0.8, 0, 0, 110)
	reward.Visible = false
	K.Make("UISizeConstraint", reward, { MaxSize = Vector2.new(360, 110) })
	local rTitle = K.Text(reward, "Title", "", 12, K.Gold, true)
	rTitle.Position = UDim2.fromOffset(14, 10)
	rTitle.Size = UDim2.new(1, -28, 0, 18)
	local rName = K.Text(reward, "Name", "", 21, K.Paper, true)
	rName.Position = UDim2.fromOffset(14, 32)
	rName.Size = UDim2.new(1, -28, 0, 36)
	local rValue = K.Text(reward, "Value", "", 14, K.Line)
	rValue.Position = UDim2.fromOffset(14, 74)
	rValue.Size = UDim2.new(1, -28, 0, 24)
	local queue, presenting = {}, false
	local function showNext()
		if presenting or #queue == 0 or not gui.Parent then
			return
		end
		presenting = true
		local item = table.remove(queue, 1)
		rTitle.Text = item[1]
		rName.Text = item[2]
		rValue.Text = "+" .. item[3] .. " credits"
		reward.Visible = true
		task.delay(3, function()
			if reward.Parent then
				reward.Visible = false
				presenting = false
				showNext()
			end
		end)
	end
	Shared.Remotes.Feedback.OnClientEvent:Connect(function(kind, a, b, c)
		if kind == "ResearchReward" then
			local function enqueue()
				if gui.Parent then
					table.insert(queue, { a, b, c })
					showNext()
				end
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

	local hints = {
		Break = "Finish breaking plates on the active layer.",
		Collect = "Collect materials from broken plates. Keep space in your bag.",
		Sell = "Sell a non-empty bag of materials.",
		Upgrade = "Buy upgrade ranks for your equipped tool.",
	}
	return {
		Toggle = toggle,
		Update = function()
			if not shell.Open then
				return
			end
			local w, h = shell.Width, shell.Height
			K.Rect(research, 0, 58, w, h - 58)
			K.Rect(species, 0, 58, w, h - 58)
			research.Visible = active == "RESEARCH"
			species.Visible = active == "SPECIES"
			for i, b in { b1, b2 } do
				local on = (i == 1) == (active == "RESEARCH")
				b.BackgroundColor3 = on and K.Green or K.Line
				b.TextColor3 = on and K.Card or K.Ink
			end
			local lv = player:GetAttribute("ResearchLevel") or 0
			local amount = player:GetAttribute("ResearchXP") or 0
			local Skills = require(Shared.SkillCatalog)
			level.Text = "Researcher " .. lv
			xp.Text = lv == 100 and "Maximum research level"
				or string.format(
					"%.2f / %d XP · %d skill points",
					amount - Skills.Threshold(lv),
					Skills.Threshold(lv + 1) - Skills.Threshold(lv),
					player:GetAttribute("SkillPoints") or 0
				)
			local index = player:GetAttribute("ContractIndex") or 1
			local c = Catalog.Contract(index)
			local done = math.clamp(player:GetAttribute("ContractProgress") or 0, 0, c.Goal)
			ct.Text = c.Title
			hint.Text = hints[c.Kind] or ""
			progress.Text = string.format("%d / %d complete · %d credits", done, c.Goal, c.Reward)
			for i, t in upcoming do
				local n = Catalog.Contract(index + i)
				t.Text = "Next " .. i .. "   " .. n.Title .. "  ·  " .. n.Reward .. " credits"
			end
			for _, v in cards do
				local count = player:GetAttribute("Discovery_" .. v.entry.Id) or 0
				v.preview:SetUnlocked(count > 0)
				v.name.Text = count > 0 and v.entry.Name or "Unknown lifeform"
				v.count.Text = count > 0 and "Recovered ×" .. count .. " · " .. v.entry.Class
					or "Undiscovered"
			end
		end,
	}
end
return H
