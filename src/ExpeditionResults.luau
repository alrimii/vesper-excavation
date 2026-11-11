-- Read-only presentation of server-settled expedition history. Opening never awards or rerolls.
local M = {}
function M.Attach(gui, player)
	local K = require(script.Parent.InterfaceKit)
	local Shared = script.Parent
	local Rules = require(Shared.ProgressionRules)
	local shell = K.Shell(player, "FieldResults", "Egg rewards!", "EggResultsOpen", nil, 780)
	local scroll = K.Scroll(shell.Body, "Result")
	scroll.Size = UDim2.new(1, 0, 1, -56)
	K.Stack(scroll, 12)
	local kicker = K.Paragraph(scroll, "Egg", "", 13, K.Green)
	local title = K.Paragraph(scroll, "OutcomeTitle", "", 34)
	title.Font = K.Title
	local previewHost = K.Make(
		"Frame",
		scroll,
		{ Name = "Specimen", BackgroundTransparency = 1, Size = UDim2.new(1, -8, 0, 160) }
	)
	local outcome = K.Paragraph(scroll, "Outcome", "", 19, K.Ink)
	local earnings = K.Paragraph(scroll, "Earnings", "", 32, K.Green)
	local benefits = K.Paragraph(scroll, "Benefits", "", 15, K.Muted)
	local contribution = K.Paragraph(scroll, "Contribution", "", 15, K.Muted)
	local chance = K.Paragraph(scroll, "Chance", "", 15, K.Muted)
	local nextRound = K.Paragraph(scroll, "Next", "", 14, K.Muted)
	local recovery = K.Paragraph(scroll, "Recovery", "", 14, K.Green)
	local history, shown, index, opened = {}, {}, 0, 0
	local manual, requested, recoveredShown = false, false, false
	local previous, following
	local close = K.Button(shell.Body, "Continue", "Continue exploring", function()
		shell:SetOpen(false)
		manual = false
	end)
	local show
	previous = K.Button(shell.Body, "Previous", "‹", function()
		if index > 1 then
			manual = true
			show(index - 1)
		end
	end, true)
	following = K.Button(shell.Body, "Following", "›", function()
		if index < #history then
			manual = true
			show(index + 1)
		end
	end, true)
	shell.Changed:Connect(function(w, h)
		K.Rect(previous, 0, h - 44, 44, 44)
		K.Rect(following, w - 44, h - 44, 44, 44)
		K.Rect(close, 52, h - 44, w - 104, 44)
	end)
	show = function(selected)
		index, opened = selected, os.clock()
		local d = history[index]
		if d then
			shown[d.settlementId] = true
		end
		recoveredShown = true
		K.Enabled(previous, index > 1)
		K.Enabled(following, index < #history)
		previewHost:ClearAllChildren()
		scroll.CanvasPosition = Vector2.zero
		if not d then
			kicker.Text = "EGG RESULTS"
			title.Text = "Your next discovery starts here"
			previewHost.Visible = false
			outcome.Text = "Complete an egg to see your contribution, rewards and creature result."
			earnings.Text = ""
			benefits.Text = ""
			contribution.Text = ""
			chance.Text = ""
			nextRound.Text = ""
			recovery.Text = ""
			shell.HeightCap = 360
			shell:SetOpen(true)
			shell:Layout()
			return
		end
		shell.HeightCap = 680
		local entry = Rules.Creature(d.creatureId)
		local won = d.outcome == "Won"
		kicker.Text = tostring(d.eggName)
			.. " · egg "
			.. tostring(d.round)
			.. " · "
			.. index
			.. " of "
			.. #history
		title.Text = won and "Creature recovered" or "Expedition complete"
		previewHost.Visible = entry ~= nil
		if entry then
			local v = require(Shared.EquipmentPreview).Create(
				previewHost,
				Shared.SpecimenAssets.crownback,
				entry.Color
			)
			if v then
				v.Size = UDim2.fromScale(1, 1)
			end
		end
		outcome.Text = entry and entry.Name .. " · " .. entry.Rarity
			or d.outcome == "NoRoll" and "No creature roll — no effective damage."
			or "No creature on your personal roll."
		benefits.Text = entry
				and string.format(
					"+%d%% mining power when active. %s",
					math.floor(entry.Power * 100 + 0.5),
					d.delivered and "Added to your collection." or "Earned; awaiting profile delivery."
				)
			or "Your collected materials remain yours."
		earnings.Text =
			string.format("%d credits awarded · %.3f damage XP earned", d.credits or 0, d.xp or 0)
		if (d.pendingCredits or 0) > 0 then
			benefits.Text ..= " " .. d.pendingCredits .. " credits awaiting profile delivery."
		end
		contribution.Text = string.format(
			"Your effective damage: %d · %.1f%% of all damage",
			(d.damage or 0),
			(d.totalDamage or 0) > 0 and (d.damage or 0) / d.totalDamage * 100 or 0
		)
		chance.Text = string.format(
			"Creature chance: %.6g%%\nSolo chance %.6g%% × final contribution %.6g%%",
			(d.personalChance or 0) * 100,
			(d.soloChance or 0) * 100,
			(d.contributionShare or 0) * 100
		)
		shell:SetOpen(true)
		shell:Layout()
	end
	local function receive()
		history = {}
		for _, d in K.Decode(player:GetAttribute("ExpeditionResultHistory")) do
			if type(d) == "table" and type(d.settlementId) == "string" then
				table.insert(history, d)
			end
		end
		if shell.Open then
			shell:SetOpen(false)
		end
	end
	player:GetAttributeChangedSignal("ExpeditionResultHistory"):Connect(receive)
	player:GetAttributeChangedSignal("EggResultsRequested"):Connect(function()
		requested = true
	end)
	local connection = game:GetService("RunService").Heartbeat:Connect(function()
		local state = Shared.RoundState
		local now = workspace:GetServerTimeNow()
		local human = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if
			not player:GetAttribute("LabReady")
			or not player:GetAttribute("ProfileReady")
			or not human
			or human.Health <= 0
			or player:GetAttribute("DiscoveryCinematic")
			or player:GetAttribute("Training")
		then
			shell:SetOpen(false)
			return
		end
		local blocked = (K.Active() and K.Active() ~= shell)
			or player:GetAttribute("CoreMenuOpen")
			or gui.Station.Visible
		if requested and not blocked then
			requested = false
			manual = true
			show(#history)
		elseif not shell.Open and not blocked then
			local latest = history[#history]
			if latest and not shown[latest.settlementId] then
				local current = state:GetAttribute("RoundId") == latest.round
					and state:GetAttribute("Status") == "Revealed"
				if
					(current and now >= latest.revealedAt + 7.7)
					or (
						not recoveredShown
						and (player:GetAttribute("RecoveredEggCreatures") or 0) > 0
						and not current
					)
				then
					manual = false
					show(#history)
				end
			end
		end
		if shell.Open then
			local d = history[index]
			local current = d
				and state:GetAttribute("RoundId") == d.round
				and state:GetAttribute("Status") == "Revealed"
			nextRound.Text = current
					and string.format("Next egg in %ds", math.max(0, math.ceil(d.nextAt - now)))
				or ""
			local recovered = player:GetAttribute("RecoveredEggCreatures") or 0
			recovery.Text = recovered > 0 and recovered .. " earned creature(s) delivered on this join" or ""
			if
				not manual
				and (
					os.clock() - opened > 14
					or (d and state:GetAttribute("RoundId") == d.round and not current)
				)
			then
				shell:SetOpen(false)
			end
		end
	end)
	gui.Destroying:Once(function()
		connection:Disconnect()
		shell.Screen:Destroy()
	end)
	receive()
end
return M
