-- Live-state adapter for the shared HUD view. Existing gameplay controllers retain authority.
local M = {}
function M.Build(gui, player, remote, openEquipment, equip, openJournal, openSkills)
	local Shared = script.Parent
	local UIS = game:GetService("UserInputService")
	local Http = game:GetService("HttpService")
	local Catalog = require(Shared.DiscoveryCatalog)
	local Skills = require(Shared.SkillCatalog)
	local Phase = require(Shared.ExpeditionPhase)
	local State = Shared.RoundState
	gui:SetAttribute("CoreHUDManaged", true)
	gui.ResetOnSpawn, gui.ScreenInsets = false, Enum.ScreenInsets.CoreUISafeInsets
	local ui, belt, skillAction
	local menuOpen, detailsOpen, showHelp, dismissed = false, false, false, false
	local lastHint
	local function setMenu(open)
		menuOpen = open
		player:SetAttribute("CoreMenuOpen", open)
		if ui then
			ui.Drawer.Visible = open
			ui.More.Label.Text = open and "CLOSE" or "MORE"
		end
	end
	ui = require(Shared.ExcavationHUDView).Build(gui, {
		More = function()
			setMenu(not menuOpen)
		end,
		EggDetails = function()
			detailsOpen = not detailsOpen
		end,
		Upgrades = function()
			setMenu(false)
			openEquipment("TOOLS")
		end,
		Creatures = function()
			setMenu(false)
			openEquipment("ARCHIVE")
		end,
		Sell = function()
			setMenu(false)
			remote:FireServer("Sell")
		end,
		Progression = function()
			setMenu(false)
			openSkills()
		end,
		ChargedSwing = function()
			if skillAction then
				skillAction()
			end
		end,
		Training = function()
			setMenu(false)
			remote:FireServer("Training")
		end,
		Dismiss = function()
			dismissed, showHelp = true, false
			local step = player:GetAttribute("TutorialStep")
			if step and step <= 7 then
				remote:FireServer("TutorialSkip")
			end
		end,
	})
	local materialBag = require(Shared.MaterialBag).Attach(gui, player, remote, ui.Bucket.Frame)
	local entries = {
		{
			"Journal",
			"Journal & discoveries",
			function()
				openJournal(true)
			end,
		},
		{
			"Equipment",
			"Equipment & upgrades",
			function()
				openEquipment("TOOLS")
			end,
		},
		{
			"Creatures",
			"My creatures",
			function()
				openEquipment("ARCHIVE")
			end,
		},
		{
			"Home",
			"Go to my room",
			function()
				remote:FireServer("Home")
			end,
		},
		{
			"Decorate",
			"Room collection",
			function()
				openEquipment("ROOM")
			end,
		},
		{
			"Settings",
			"Settings",
			function()
				openEquipment("OPTIONS")
			end,
		},
		{
			"Help",
			"Controls & guidance",
			function()
				showHelp, dismissed = true, false
			end,
		},
		{
			"EggResults",
			"Last egg results",
			function()
				player:SetAttribute(
					"EggResultsRequested",
					(player:GetAttribute("EggResultsRequested") or 0) + 1
				)
			end,
		},
	}
	for index, entry in entries do
		local button = ui:AddEntry(entry[1], entry[2], function()
			setMenu(false)
			entry[3]()
		end)
		button.LayoutOrder = index
	end
	local trainEntry = ui:AddEntry("Train", "Training / optional", function()
		setMenu(false)
		remote:FireServer("Training")
	end)
	trainEntry.LayoutOrder = 9
	local contract = Instance.new("TextLabel")
	contract.Name, contract.BackgroundTransparency, contract.Font = "Contract", 1, Enum.Font.GothamBold
	contract.TextSize, contract.TextColor3, contract.TextWrapped = 14, Color3.fromRGB(37, 56, 64), true
	contract.Size, contract.LayoutOrder, contract.ZIndex, contract.Parent =
		UDim2.new(1, -4, 0, 96), 10, 22, ui.List
	local function number(value)
		if typeof(value) ~= "number" then
			return "..."
		end
		return tostring(math.floor(value)):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
	end
	local function compact(value)
		if typeof(value) ~= "number" then
			return "..."
		end
		if value >= 1000000 then
			return string.format("%.2fM", value / 1000000)
		end
		if value >= 10000 then
			return string.format("%.1fK", value / 1000)
		end
		return number(value)
	end
	local function ownedTraining()
		local ch = player.Character
		local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
		local lab = workspace:FindFirstChild("VesperLab")
		local rooms = lab and lab:FindFirstChild("Rooms")
		if not hrp or not rooms then
			return false
		end
		for _, room in rooms:GetChildren() do
			if room:GetAttribute("OwnerUserId") == player.UserId then
				local device = room:FindFirstChild("TrainingStation")
				local spot = device and device:FindFirstChild("TrainingSpot")
				return spot ~= nil and (hrp.Position - spot.Position).Magnitude < 18
			end
		end
		return false
	end
	player.CharacterAdded:Connect(function()
		setMenu(false)
		showHelp, detailsOpen = false, false
	end)
	UIS.InputBegan:Connect(function(input, processed)
		if
			not processed and (input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.ButtonB)
		then
			setMenu(false)
			showHelp, detailsOpen = false, false
		end
	end)
	local api = {}
	function api:SetToolbelt(controller)
		belt = controller
	end
	function api:SetSkillAction(callback)
		skillAction = callback
	end
	function api:Update()
		local ready = player:GetAttribute("LabReady") == true and player:GetAttribute("ProfileReady") == true
		local modal = player:GetAttribute("SkillTreeOpen")
			or gui.Station.Visible
			or player:GetAttribute("EggResultsOpen")
			or player:GetAttribute("ResearchModal")
			or player:GetAttribute("DiscoveryCinematic")
		local bagOpen = player:GetAttribute("MaterialBagOpen") == true
		if not ready or modal or bagOpen then
			setMenu(false)
			detailsOpen = false
		end
		ui.Root.Visible = ready and not modal and not bagOpen
		materialBag.Update(modal or not ready)
		for _, name in
			{ "Status", "Shop", "Help", "Bag", "Tools", "Tutorial", "Guidance", "ResearchRank", "FieldGuide" }
		do
			local old = gui:FindFirstChild(name)
			if old and old:IsA("GuiObject") then
				old.Visible = false
			end
		end
		local w, h = gui.AbsoluteSize.X, gui.AbsoluteSize.Y
		local touch = UIS.PreferredInput == Enum.PreferredInput.Touch
		ui:Layout(w, h, touch)
		local phone = ui.Phone
		ui.Cash.Value.Text, ui.Relics.Value.Text =
			compact(player:GetAttribute("Cash")), compact(player:GetAttribute("Relics"))
		local used, cap = player:GetAttribute("BucketUsed"), player:GetAttribute("BucketCapacity")
		local full = typeof(used) == "number" and typeof(cap) == "number" and used >= cap
		local pending = player:GetAttribute("PendingMaterials") or 0
		ui.Bucket.Value.Text = compact(used) .. "/" .. compact(cap)
		ui.Bucket.Caption.Text = pending > 0 and (compact(pending) .. " PENDING")
			or full and "FULL / SELL"
			or "BUCKET"
		ui.Sell.Button.Interactable = ready and typeof(used) == "number" and used > 0
		ui.Sell.Button.Selectable = ui.Sell.Button.Interactable
		ui.Sell.Button.BackgroundTransparency = ui.Sell.Button.Interactable and 0 or 0.25
		local phase = Phase.Read(State)
		local progress, layer = State:GetAttribute("Progress"), State:GetAttribute("ActiveLayer")
		ui.Egg.Label.Text = State:GetAttribute("EggName") or "Loading egg..."
		ui.EggPercent.Text = typeof(progress) == "number" and string.format("%.0f%%", progress * 100) or "..."
		ui.EggFill.Size = UDim2.fromScale(typeof(progress) == "number" and math.clamp(progress, 0, 1) or 0, 1)
		local personal, total =
			player:GetAttribute("MiningContribution"), State:GetAttribute("EffectiveDamage")
		local share = typeof(personal) == "number"
			and typeof(total) == "number"
			and player:GetAttribute("ContributionRound") == State:GetAttribute("RoundId")
		local phaseCaption = phase == "Excavating" and ("Layer " .. number(layer) .. " of 3")
			or phase == "Selecting" and "Choosing the next egg"
			or phase == "Delivering" and "Next egg arriving"
			or phase == "Hatching" and "Hatching!"
			or "Discovery complete"
		ui.DetailText.Text = phaseCaption
			.. "\n"
			.. (share and string.format(
				"Your contribution: %.1f%% / %s damage",
				total > 0 and personal / total * 100 or 0,
				number(personal)
			) or "Synchronizing contribution...")
			.. "\nYour share of all damage dealt so far."
		ui.Details.Visible = detailsOpen and not menuOpen
		local index, done = player:GetAttribute("ContractIndex"), player:GetAttribute("ContractProgress")
		if index and done then
			local item = Catalog.Contract(index)
			contract.Text = "CURRENT CONTRACT\n"
				.. item.Title
				.. "\n"
				.. number(done)
				.. " / "
				.. number(item.Goal)
				.. "  /  "
				.. number(item.Reward)
				.. " credits"
		else
			contract.Text = "Loading contract..."
		end
		local level, xp, points =
			player:GetAttribute("ResearchLevel"),
			player:GetAttribute("ResearchXP"),
			player:GetAttribute("SkillPoints")
		ui.Progress.Label.Text = level and ("LV " .. level) or "LV ..."
		ui.Points.Text = "SKILLS\n" .. (points and (number(points) .. " PT") or "... PT")
		if typeof(level) == "number" and typeof(xp) == "number" then
			local current, needed =
				xp - Skills.Threshold(level),
				level < 100 and Skills.Threshold(level + 1) - Skills.Threshold(level) or 0
			ui.XP.Text = level == 100 and "MAX LEVEL"
				or (compact(current) .. " / " .. compact(needed) .. " XP")
			ui.XPFill.Size =
				UDim2.fromScale(level == 100 and 1 or math.clamp(current / math.max(1, needed), 0, 1), 1)
		else
			ui.XP.Text, ui.XPFill.Size = "Loading XP...", UDim2.fromScale(0, 1)
		end
		local ch = player.Character
		local tool = ch and ch:FindFirstChildOfClass("Tool")
		local human = ch and ch:FindFirstChildOfClass("Humanoid")
		local alive = human ~= nil and human.Health > 0
		local running = player:GetAttribute("Training") == true
		local blocked = not ui.Root.Visible or menuOpen or not alive
		if belt then
			belt:Update(ui.BeltWidth, ui.BeltHeight, ui.BeltPosition, blocked or running)
		end
		ui.Use.Visible = not blocked and not running and phase == "Excavating"
		local family = player:GetAttribute("ToolFamily")
		ui.UseLabel.Text = not tool and "EQUIP"
			or family == "Drill" and (player:GetAttribute("DrillRunning") and "STOP" or "DRILL")
			or family == "Explosive" and "BLAST"
			or "STRIKE"
		ui.UseHint.Text = not tool and "SELECT TOOL"
			or touch and (family == "Drill" and "TAP TO TOGGLE" or "HOLD")
			or UIS.PreferredInput == Enum.PreferredInput.Gamepad and "RT / R2"
			or "CLICK / E"
		if tool and family == "Drill" and player:GetAttribute("DrillRunning") then
			ui.UseHint.Text = player:GetAttribute("DrillContact") and "CONTACT" or "NO CONTACT"
		end
		local ok, loadout = pcall(Http.JSONDecode, Http, player:GetAttribute("SkillLoadout") or "[]")
		ui.Charged.Button.Visible = ui.Use.Visible
			and family == "Pickaxe"
			and ok
			and table.find(loadout, "impact.charged_swing") ~= nil
		local now = workspace:GetServerTimeNow()
		local remaining = math.max(0, (player:GetAttribute("ChargedUntil") or 0) - now)
		ui.Charged.Label.Text = remaining > 0 and string.format("%.1fs", remaining)
			or touch and "CHARGED"
			or UIS.PreferredInput == Enum.PreferredInput.Gamepad and "CHARGED / Y"
			or "CHARGED / Q"
		ui.Charged.Button.Interactable = remaining <= 0
		local rok, ranks = pcall(Http.JSONDecode, Http, player:GetAttribute("SkillRanks") or "{}")
		local flowRank = rok and ranks["technique.core_drill"] or 0
		flowRank = flowRank or 0
		ui.Flow.Visible = not blocked and family == "Drill" and flowRank > 0
		local boost, readyUntil =
			player:GetAttribute("FlowUntil") or 0, player:GetAttribute("FlowReadyUntil") or 0
		local build = now - (player:GetAttribute("FlowLastContact") or 0) > 2 and 0
			or player:GetAttribute("FlowBuild")
			or 0
		ui.Flow.Text = boost > now
				and string.format("FLOW x%.2f / %.1fs", flowRank == 1 and 1.25 or 1.35, boost - now)
			or readyUntil > now and "FLOW READY"
			or string.format("FLOW %.1f / 4.0s", build)
		local sprint = gui:FindFirstChild("SprintToggle")
		if sprint then
			sprint.Size, sprint.Position = UDim2.fromOffset(64, 32), UDim2.fromOffset(80, 96)
			sprint.BackgroundColor3, sprint.TextColor3 =
				Color3.fromRGB(255, 246, 220), Color3.fromRGB(37, 56, 64)
		end
		trainEntry.Visible = menuOpen and alive and ownedTraining()
		ui.Training.Button.Visible = not blocked and running
		local step = player:GetAttribute("TutorialStep")
		local hint = (full or pending > 0) and "Bucket full? Sell to make room."
			or showHelp and (touch and "Aim at the shell. Hold STRIKE." or "Click / E: strike. 1-3: tools. Shift: sprint.")
			or step and step <= 1 and "Aim at the egg and strike!"
			or step and step <= 4 and "Break shell. Collect materials."
			or step and step <= 6 and "Sell your materials for credits."
			or step and step == 7 and "Open TOOLS to upgrade your gear."
			or nil
		if hint ~= lastHint then
			dismissed = false
			lastHint = hint
		end
		ui.Guide.Visible = not blocked
			and not running
			and not dismissed
			and hint ~= nil
			and phase == "Excavating"
			and gui.Toast.Text == ""
			and not ui.Flow.Visible
		ui.Hint.Text, ui.Hint.TextWrapped = hint or "", not phone
		local target = gui:FindFirstChild("TargetStatus")
		gui:SetAttribute("CoreTargetSuppressed", false)
		if target then
			target.Position = UDim2.new(0.5, 0, 1, -ui.BeltHeight - 112)
			target.Visible = target.Visible and not blocked and not running and gui.Toast.Text == ""
		end
		gui.Toast.AnchorPoint = Vector2.new(0.5, 0)
		gui.Toast.Position, gui.Toast.Size =
			UDim2.new(0.5, 0, 0, phone and 66 or 86),
			UDim2.fromOffset(math.min(phone and 300 or 420, w - 24), 36)
		gui.Toast.Visible = ready and not modal and not bagOpen and gui.Toast.Text ~= ""
		gui.Toast.TextWrapped, gui.Toast.TextSize = true, phone and 13 or 16
	end
	return api
end
return M
