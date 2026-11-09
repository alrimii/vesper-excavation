local M = {}
function M.Attach(gui, player)
	local Shared = game.ReplicatedStorage.VesperShared
	local Rules = require(Shared.ProgressionRules)
	local Http = game:GetService("HttpService")
	local Tween = game:GetService("TweenService")
	local Run = game:GetService("RunService")
	local panel = Instance.new("CanvasGroup")
	panel.Name = "ExpeditionResults"
	panel.Size = UDim2.fromOffset(440, 500)
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.5)
	panel.BackgroundColor3 = Color3.fromRGB(13, 23, 34)
	panel.BorderSizePixel, panel.ZIndex, panel.Visible = 0, 70, false
	panel.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 18)
	corner.Parent = panel
	local stroke = Instance.new("UIStroke")
	stroke.Color, stroke.Transparency = Color3.fromRGB(113, 236, 210), 0.3
	stroke.Parent = panel
	local fit = Instance.new("UIScale")
	fit.Parent = panel
	local function label(name, y, height, size, color)
		local t = Instance.new("TextLabel")
		t.Name, t.Position, t.Size = name, UDim2.fromOffset(24, y), UDim2.new(1, -48, 0, height)
		t.BackgroundTransparency, t.Font, t.TextSize = 1, Enum.Font.GothamMedium, size
		t.TextColor3 = color or Color3.fromRGB(233, 241, 247)
		t.TextWrapped, t.ZIndex, t.Parent = true, 71, panel
		return t
	end
	local kicker = label("Kicker", 18, 20, 11, Color3.fromRGB(113, 236, 210))
	local title = label("Title", 42, 30, 24)
	title.Font = Enum.Font.GothamBold
	local previewHost = Instance.new("Frame")
	previewHost.Name, previewHost.BackgroundTransparency = "Specimen", 1
	previewHost.Position, previewHost.Size = UDim2.fromOffset(24, 77), UDim2.new(1, -48, 0, 110)
	previewHost.ZIndex, previewHost.Parent = 71, panel
	local outcome = label("Outcome", 191, 43, 15)
	local benefits = label("Benefits", 237, 28, 12, Color3.fromRGB(164, 185, 202))
	local earnings = label("Earnings", 269, 30, 18, Color3.fromRGB(255, 213, 138))
	local contribution = label("Contribution", 303, 36, 12, Color3.fromRGB(113, 236, 210))
	local chance = label("Chance", 342, 36, 13, Color3.fromRGB(255, 213, 138))
	local recovery = label("Recovery", 405, 24, 11, Color3.fromRGB(113, 236, 210))
	local nextRound = label("Next", 382, 20, 11, Color3.fromRGB(164, 185, 202))
	local close = Instance.new("TextButton")
	close.Name, close.Text = "Continue", "CONTINUE EXPLORING"
	close.Size, close.Position = UDim2.fromOffset(288, 42), UDim2.fromOffset(76, 438)
	close.BackgroundColor3, close.TextColor3 = Color3.fromRGB(113, 236, 210), Color3.fromRGB(13, 23, 34)
	close.Font, close.TextSize, close.BorderSizePixel = Enum.Font.GothamBold, 13, 0
	close.ZIndex, close.Parent = 71, panel
	local c = Instance.new("UICorner")
	c.CornerRadius, c.Parent = UDim.new(0, 10), close
	local previous, following = close:Clone(), close:Clone()
	previous.Name, previous.Text, previous.Position, previous.Size =
		"Previous", "<", UDim2.fromOffset(24, 438), UDim2.fromOffset(44, 42)
	following.Name, following.Text, following.Position, following.Size =
		"Following", ">", UDim2.fromOffset(372, 438), UDim2.fromOffset(44, 42)
	previous.Parent, following.Parent = panel, panel
	local history, shown, index, opened = {}, {}, 0, 0
	local manual, requested, recoveredShown = false, false, false
	local animation
	local function hide()
		panel.Visible = false
		player:SetAttribute("EggResultsOpen", false)
		manual = false
		if animation then
			animation:Cancel()
		end
		local service = game:GetService("GuiService")
		if
			service.SelectedObject == close
			or service.SelectedObject == previous
			or service.SelectedObject == following
		then
			service.SelectedObject = nil
		end
	end
	local function receive()
		local raw = player:GetAttribute("ExpeditionResultHistory")
		if type(raw) ~= "string" then
			return
		end
		local ok, values = pcall(Http.JSONDecode, Http, raw)
		if not ok or type(values) ~= "table" then
			return
		end
		history = {}
		for _, value in ipairs(values) do
			if type(value) == "table" and type(value.settlementId) == "string" then
				table.insert(history, value)
			end
		end
		if panel.Visible then
			hide()
		end
	end
	local function show(selected)
		if animation then
			animation:Cancel()
		end
		index, opened = selected, os.clock()
		local data = history[index]
		if data then
			shown[data.settlementId] = true
		end
		recoveredShown = true
		previous.Interactable, previous.Selectable = index > 1, index > 1
		following.Interactable, following.Selectable = index < #history, index < #history
		if not data then
			kicker.Text, title.Text, outcome.Text =
				"EGG RESULTS", "NO COMPLETED EGG", "Finish an egg to see your personal result here."
			previewHost:ClearAllChildren()
			benefits.Text, earnings.Text, contribution.Text, chance.Text = "", "", "", ""
			panel.Visible, panel.GroupTransparency = true, 0
			player:SetAttribute("EggResultsOpen", true)
			if game:GetService("UserInputService").PreferredInput == Enum.PreferredInput.Gamepad then
				game:GetService("GuiService").SelectedObject = close
			end
			return
		end
		local entry = Rules.Creature(data.creatureId)
		local won = data.outcome == "Won"
		local accent = entry and entry.Color or Color3.fromRGB(113, 236, 210)
		stroke.Color, kicker.TextColor3 = accent, accent
		kicker.Text = data.eggName .. " / EGG " .. data.round .. " / " .. index .. " OF " .. #history
		title.Text = won and "CREATURE RECOVERED" or "EGG DISCOVERED"
		previewHost:ClearAllChildren()
		if entry then
			local view = require(Shared.EquipmentPreview).Create(
				previewHost,
				Shared.SpecimenAssets:FindFirstChild("crownback"),
				entry.Color
			)
			if view then
				view.Position, view.Size, view.ZIndex = UDim2.fromOffset(0, 0), UDim2.fromScale(1, 1), 71
			end
		else
			local mark = Instance.new("TextLabel")
			mark.Size, mark.BackgroundTransparency = UDim2.fromScale(1, 1), 1
			mark.Text, mark.Font, mark.TextSize = "EXPEDITION COMPLETE", Enum.Font.GothamBold, 21
			mark.TextColor3, mark.ZIndex, mark.Parent = accent, 71, previewHost
		end
		outcome.Text = entry
				and (entry.Name .. "\n" .. (data.delivered and "Added to your collection" or "Earned / pending profile delivery"))
			or (
				data.outcome == "NoRoll" and "No creature roll: no effective damage."
				or "No creature on your personal roll."
			)
		benefits.Text = entry
				and string.format(
					"+%d%% mining power when active%s",
					math.floor(entry.Power * 100 + 0.5),
					won and " / Choose displays in Archive" or ""
				)
			or "Your collected materials remain yours."
		earnings.Text = string.format("AWARDED: %d CREDITS / %.3f XP ALREADY EARNED", data.credits, data.xp)
		if (data.pendingCredits or 0) > 0 then
			benefits.Text = string.format(
				"Pending profile delivery: %d credits. Damage XP is already credited.",
				data.pendingCredits
			)
		elseif not entry and data.credits == 0 then
			benefits.Text = "Stipend requires contribution and being loaded online at reveal."
		end
		chance.Text = string.format(
			"YOUR CREATURE CHANCE: %.6g%%\nSolo %.6g%% x final contribution %.6g%%",
			data.personalChance * 100,
			data.soloChance * 100,
			data.contributionShare * 100
		)
		local personal, allDamage = data.damage or 0, data.totalDamage or 0
		contribution.Text = string.format(
			"Your effective damage: %d / %.1f%%\nYour damage divided by all damage dealt to this egg",
			personal,
			allDamage > 0 and personal / allDamage * 100 or 0
		)
		panel.Visible, panel.GroupTransparency = true, 1
		player:SetAttribute("EggResultsOpen", true)
		animation = Tween:Create(
			panel,
			TweenInfo.new(player:GetAttribute("ReducedMotion") and 0 or 0.3),
			{ GroupTransparency = 0 }
		)
		animation:Play()
		if game:GetService("UserInputService").PreferredInput == Enum.PreferredInput.Gamepad then
			game:GetService("GuiService").SelectedObject = close
		end
	end
	local connections = {}
	table.insert(connections, close.Activated:Connect(hide))
	table.insert(
		connections,
		previous.Activated:Connect(function()
			if index > 1 then
				manual = true
				show(index - 1)
			end
		end)
	)
	table.insert(
		connections,
		following.Activated:Connect(function()
			if index < #history then
				manual = true
				show(index + 1)
			end
		end)
	)
	table.insert(connections, player:GetAttributeChangedSignal("ExpeditionResultHistory"):Connect(receive))
	table.insert(
		connections,
		player:GetAttributeChangedSignal("EggResultsRequested"):Connect(function()
			requested = true
		end)
	)
	table.insert(
		connections,
		game:GetService("UserInputService").InputBegan:Connect(function(input)
			if
				panel.Visible
				and (input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.ButtonB)
			then
				hide()
			end
		end)
	)
	table.insert(
		connections,
		Run.Heartbeat:Connect(function()
			local state, now = Shared.RoundState, workspace:GetServerTimeNow()
			local ready = player:GetAttribute("LabReady") and player:GetAttribute("ProfileReady")
			local obstructed = player:GetAttribute("DiscoveryCinematic")
				or player:GetAttribute("ResearchModal")
				or player:GetAttribute("MaterialBagOpen")
				or player:GetAttribute("CoreMenuOpen")
				or player:GetAttribute("Training")
				or gui.Station.Visible
			local human = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
			if not ready or obstructed or not human or human.Health <= 0 then
				if panel.Visible then
					hide()
				end
				return
			end
			local latest = history[#history]
			if requested then
				requested, manual = false, true
				show(#history)
			elseif not panel.Visible and latest and not shown[latest.settlementId] then
				local currentReveal = state:GetAttribute("RoundId") == latest.round
					and state:GetAttribute("Status") == "Revealed"
				local recovered = not recoveredShown
					and (player:GetAttribute("RecoveredEggCreatures") or 0) > 0
				if
					(currentReveal and now >= latest.revealedAt + 7.7) or (recovered and not currentReveal)
				then
					manual = false
					show(#history)
				end
			end
			if panel.Visible then
				local data = history[index]
				local currentReveal = data
					and state:GetAttribute("RoundId") == data.round
					and state:GetAttribute("Status") == "Revealed"
				local size = gui.AbsoluteSize
				fit.Scale = math.min(1, (size.X - 28) / 440, (size.Y - 28) / 500)
				nextRound.Text = currentReveal
						and string.format(
							"Next egg in %ds / Result already resolved",
							math.max(0, math.ceil(data.nextAt - now))
						)
					or "This server's recorded results / Opening never rerolls"
				local recovered = player:GetAttribute("RecoveredEggCreatures") or 0
				recovery.Text = recovered > 0
						and string.format("%d earned creature(s) delivered on this rejoin", recovered)
					or ""
				if
					not manual
					and (
						os.clock() - opened > 14
						or (data and state:GetAttribute("RoundId") == data.round and not currentReveal)
					)
				then
					hide()
				end
			end
		end)
	)
	gui.Destroying:Connect(function()
		hide()
		for _, connection in connections do
			connection:Disconnect()
		end
	end)
	receive()
end
return M
