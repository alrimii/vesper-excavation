local M = {}
function M.Attach(gui, player)
	local Shared = game.ReplicatedStorage.VesperShared
	local Rules = require(Shared.ProgressionRules)
	local Http = game:GetService("HttpService")
	local Tween = game:GetService("TweenService")
	local Run = game:GetService("RunService")
	local panel = Instance.new("CanvasGroup")
	panel.Name = "ExpeditionResults"
	panel.Size = UDim2.fromOffset(440, 398)
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
	local benefits = label("Benefits", 237, 24, 12, Color3.fromRGB(164, 185, 202))
	local earnings = label("Earnings", 269, 30, 18, Color3.fromRGB(255, 213, 138))
	local nextRound = label("Next", 306, 20, 11, Color3.fromRGB(164, 185, 202))
	local close = Instance.new("TextButton")
	close.Name, close.Text = "Continue", "CONTINUE EXPLORING"
	close.Size, close.Position = UDim2.new(1, -48, 0, 42), UDim2.fromOffset(24, 337)
	close.BackgroundColor3, close.TextColor3 = Color3.fromRGB(113, 236, 210), Color3.fromRGB(13, 23, 34)
	close.Font, close.TextSize, close.BorderSizePixel = Enum.Font.GothamBold, 13, 0
	close.ZIndex, close.Parent = 71, panel
	local c = Instance.new("UICorner")
	c.CornerRadius, c.Parent = UDim.new(0, 10), close
	local pending, shown, opened = nil, nil, 0
	local animation
	local function hide()
		panel.Visible = false
		if animation then
			animation:Cancel()
		end
		local service = game:GetService("GuiService")
		if service.SelectedObject == close then
			service.SelectedObject = nil
		end
	end
	local function receive()
		local raw = player:GetAttribute("LastExpeditionResult")
		if type(raw) ~= "string" then
			return
		end
		local ok, value = pcall(Http.JSONDecode, Http, raw)
		if ok and type(value) == "table" and type(value.round) == "number" then
			pending = value
		end
	end
	local function show(data)
		shown, opened = data.round, os.clock()
		local entry = Rules.Creature(data.creatureId)
		local won = data.winnerId == player.UserId
		local accent = entry and entry.Color or Color3.fromRGB(113, 236, 210)
		stroke.Color, kicker.TextColor3 = accent, accent
		kicker.Text = "EXPEDITION " .. data.round .. " / " .. (entry and entry.Rarity or "RESEARCH COMPLETE")
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
				and (entry.Name .. "\n" .. (won and "Added to your collection" or ("Recovered by " .. data.winnerName)))
			or "No collectible recovered this time."
		benefits.Text = entry
				and string.format(
					"+%d%% mining power when active%s",
					math.floor(entry.Power * 100 + 0.5),
					won and " / Choose displays in Archive" or ""
				)
			or "Your collected materials remain yours."
		earnings.Text = data.credits > 0 and string.format("+%d CREDITS    +%d XP", data.credits, data.xp)
			or "Contribute to earn the completion stipend"
		panel.Visible, panel.GroupTransparency = true, 1
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
	table.insert(connections, player:GetAttributeChangedSignal("LastExpeditionResult"):Connect(receive))
	table.insert(
		connections,
		Run.Heartbeat:Connect(function()
			local data = pending
			if not data then
				return
			end
			local state = Shared.RoundState
			local valid = state:GetAttribute("RoundId") == data.round
				and state:GetAttribute("Status") == "Revealed"
			local now = workspace:GetServerTimeNow()
			local obstructed = player:GetAttribute("DiscoveryCinematic")
				or player:GetAttribute("ResearchModal")
				or gui.Station.Visible
			if not valid or obstructed then
				if panel.Visible then
					hide()
				end
				return
			end
			if shown ~= data.round and now >= data.revealedAt + 7.7 and player:GetAttribute("LabReady") then
				show(data)
			end
			if panel.Visible then
				local size = gui.AbsoluteSize
				fit.Scale = math.min(1, (size.X - 28) / 440, (size.Y - 28) / 398)
				nextRound.Text = string.format(
					"Next expedition in %ds / Rewards already added",
					math.max(0, math.ceil(data.nextAt - now))
				)
				if os.clock() - opened > 14 then
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
