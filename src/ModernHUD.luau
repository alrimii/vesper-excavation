-- Gameplay layout owner. Existing journal, workshop, inventory and input controllers are reused.
local M = {}
function M.Build(gui, player, remote, openEquipment, equip, openJournal)
	local UIS = game:GetService("UserInputService")
	local Shared = script.Parent
	local Style = require(Shared.InterfaceStyle)
	local Catalog = require(Shared.DiscoveryCatalog)
	local Config = require(Shared.ExcavationConfig)
	local Phase = require(Shared.ExpeditionPhase)
	local State = Shared.RoundState
	local ink, cream = Color3.fromRGB(27, 44, 57), Color3.fromRGB(248, 242, 223)
	local mint, gold = Color3.fromRGB(119, 230, 188), Color3.fromRGB(255, 206, 100)
	gui:SetAttribute("CoreHUDManaged", true)
	gui.ResetOnSpawn, gui.ScreenInsets = false, Enum.ScreenInsets.CoreUISafeInsets
	local root = Instance.new("Frame")
	root.Name, root.Size, root.BackgroundTransparency, root.Visible = "CoreHUD", UDim2.fromScale(1, 1), 1, false
	root.Parent = gui
	local function round(object, radius)
		local c = object:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
		c.CornerRadius, c.Parent = UDim.new(0, radius), object
	end
	local function card(name, parent, color)
		local f = Instance.new("Frame")
		f.Name, f.BackgroundColor3, f.BorderSizePixel = name, color or ink, 0
		f.Parent = parent or root
		round(f, 14)
		local s = Instance.new("UIStroke")
		s.Color, s.Thickness, s.Transparency, s.Parent = Color3.fromRGB(84, 112, 119), 1.5, 0.2, f
		return f
	end
	local function text(parent, name, size, pos, bounds, color)
		local t = Instance.new("TextLabel")
		t.Name, t.Text, t.Font, t.TextSize = name, "", Enum.Font.GothamBold, size
		t.Position, t.Size, t.BackgroundTransparency = pos, bounds, 1
		t.TextColor3, t.TextXAlignment = color or cream, Enum.TextXAlignment.Left
		t.TextTruncate, t.Parent = Enum.TextTruncate.AtEnd, parent
		return t
	end
	local function button(parent, name, caption, color, action)
		local b = Instance.new("TextButton")
		b.Name, b.Text, b.Font, b.TextSize = name, caption, Enum.Font.GothamBold, 14
		b.BackgroundColor3, b.TextColor3, b.BorderSizePixel, b.ZIndex = color, ink, 0, 8
		b.Parent = parent
		round(b, 12)
		Style.Button(b)
		b.Activated:Connect(action)
		return b
	end
	local wallet = card("Wallet")
	local cash = text(wallet, "Cash", 20, UDim2.fromOffset(12, 4), UDim2.new(1, -24, 0, 25), gold)
	local relics = text(wallet, "Relics", 13, UDim2.fromOffset(12, 30), UDim2.new(1, -24, 0, 18))
	local bag = card("Bucket")
	local bucket = text(bag, "Amount", 19, UDim2.fromOffset(12, 4), UDim2.new(1, -24, 0, 25), mint)
	local bagCaption = text(bag, "Caption", 12, UDim2.fromOffset(12, 30), UDim2.new(1, -24, 0, 18))
	local materialBag = require(Shared.MaterialBag).Attach(gui, player, remote, bag)
	bagCaption.Text = "BUCKET / OPEN"
	local egg = card("CurrentEgg")
	local eggName = text(egg, "Name", 17, UDim2.fromOffset(12, 5), UDim2.new(1, -24, 0, 23))
	local progress = text(egg, "Progress", 13, UDim2.fromOffset(12, 29), UDim2.new(1, -24, 0, 18), mint)
	local contribution = text(egg, "Contribution", 12, UDim2.fromOffset(12, 64), UDim2.new(1, -24, 0, 18), cream)
	local track = card("Track", egg, Color3.fromRGB(51, 72, 80))
	track.Position, track.Size = UDim2.fromOffset(12, 53), UDim2.new(1, -24, 0, 6)
	local fill = Instance.new("Frame")
	fill.Size, fill.BackgroundColor3, fill.BorderSizePixel, fill.Parent = UDim2.fromScale(0, 1), gold, 0, track
	round(fill, 6)
	local drawer = card("MoreActions")
	drawer.Visible, drawer.ZIndex, drawer.Active = false, 10, true
	local list = Instance.new("ScrollingFrame")
	list.Position, list.Size, list.BackgroundTransparency = UDim2.fromOffset(8, 8), UDim2.new(1, -16, 1, -16), 1
	list.CanvasSize, list.AutomaticCanvasSize, list.ScrollBarThickness = UDim2.new(), Enum.AutomaticSize.Y, 4
	list.BorderSizePixel, list.ZIndex, list.Parent = 0, 11, drawer
	local layout = Instance.new("UIListLayout")
	layout.Padding, layout.SortOrder, layout.Parent = UDim.new(0, 6), Enum.SortOrder.LayoutOrder, list
	local menuOpen, showHelp, belt = false, false, nil
	local more
	local function setMenu(open)
		menuOpen, drawer.Visible = open, open
		player:SetAttribute("CoreMenuOpen", open)
		if more then more.Text = open and "CLOSE" or "MORE" end
	end
	more = button(root, "More", "MORE", cream, function() setMenu(not menuOpen) end)
	local upgrade = button(root, "Upgrades", "UPGRADES", mint, function() setMenu(false); openEquipment("RIG") end)
	local sell = button(root, "Sell", "SELL", gold, function() setMenu(false); remote:FireServer("Sell") end)
	local entries = {
		{ "Journal", "Journal & discoveries", function() openJournal(true) end },
		{ "Equipment", "Equipment", function() openEquipment("TOOLS") end },
		{ "Creatures", "Creatures", function() openEquipment("ARCHIVE") end },
		{ "Home", "Go to my room", function() remote:FireServer("Home") end },
		{ "Decorate", "Room collection", function() openEquipment("ROOM") end },
		{ "Settings", "Settings", function() openEquipment("OPTIONS") end },
		{ "Help", "Controls & guidance", function() showHelp = not showHelp end },
	}
	for index, entry in entries do
		local b = button(list, entry[1], entry[2], cream, function() setMenu(false); entry[3]() end)
		b.Size, b.LayoutOrder, b.ZIndex = UDim2.new(1, -6, 0, 44), index, 12
	end
	local contract = text(list, "Contract", 14, UDim2.new(), UDim2.new(1, -6, 0, 120), mint)
	contract.LayoutOrder, contract.TextWrapped, contract.TextTruncate, contract.ZIndex = 9, true, Enum.TextTruncate.None, 12
	local guide = card("ContextHint")
	guide.BackgroundTransparency = 0.08
	local hint = text(guide, "Text", 14, UDim2.fromOffset(10, 4), UDim2.new(1, -58, 1, -8))
	hint.TextWrapped, hint.TextTruncate = true, Enum.TextTruncate.None
	local dismiss = button(guide, "Dismiss", "OK", cream, function()
		if showHelp then showHelp = false else remote:FireServer("TutorialSkip") end
	end)
	dismiss.Size, dismiss.Position = UDim2.fromOffset(44, 44), UDim2.new(1, -48, 0.5, -22)
	local training = button(root, "Training", "TRAIN", cream, function() setMenu(false); remote:FireServer("Training") end)
	local toolName = text(root, "Equipped", 14, UDim2.new(), UDim2.fromOffset(260, 22), cream)
	toolName.TextXAlignment, toolName.TextStrokeTransparency = Enum.TextXAlignment.Center, 0.4
	local prompt = text(gui.Use, "InputHint", 12, UDim2.new(0, 2, 1, -21), UDim2.new(1, -4, 0, 18), ink)
	-- The existing Use button retains its one desktop/touch input route.
	gui.Use.TextTransparency, gui.Use.TextColor3, gui.Use.TextSize = 0, ink, 18
	gui.Use.BackgroundColor3 = gold
	round(gui.Use, 16)
	local originalCaption = gui.Use:FindFirstChild("ActionCaption")
	if originalCaption then originalCaption:Destroy() end
	gui.Use.TextYAlignment = Enum.TextYAlignment.Top
	local usePadding = Instance.new("UIPadding")
	usePadding.PaddingTop, usePadding.Parent = UDim.new(0, 9), gui.Use
	local function number(value)
		if typeof(value) ~= "number" then return "Syncing..." end
		return tostring(math.floor(value)):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
	end
	local function ownedTraining()
		local ch = player.Character
		local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
		if not hrp then return false end
		for _, room in workspace.VesperLab.Rooms:GetChildren() do
			if room:GetAttribute("OwnerUserId") == player.UserId then
				local device = room:FindFirstChild("TrainingStation")
				local spot = device and device:FindFirstChild("TrainingSpot")
				return spot ~= nil and (hrp.Position - spot.Position).Magnitude < 18
			end
		end
		return false
	end
	player.CharacterAdded:Connect(function() setMenu(false); showHelp = false end)
	UIS.InputBegan:Connect(function(input, processed)
		if not processed and (input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.ButtonB) then
			setMenu(false)
			showHelp = false
		end
	end)
	local api = {}
	function api:SetToolbelt(controller) belt = controller end
	function api:Update()
		local ready = player:GetAttribute("LabReady") == true and player:GetAttribute("ProfileReady") == true
		local externalModal = gui.Station.Visible or player:GetAttribute("ResearchModal") or player:GetAttribute("DiscoveryCinematic")
		local bagOpen = player:GetAttribute("MaterialBagOpen") == true
		if not ready or externalModal or bagOpen then setMenu(false) end
		root.Visible = ready and not externalModal and not bagOpen
		materialBag.Update(externalModal or not ready)
		for _, name in { "Status", "Shop", "Help", "Bag", "Tools", "Tutorial", "Guidance", "ResearchRank" } do
			local old = gui:FindFirstChild(name)
			if old then old.Visible = false end
		end
		local w, h = gui.AbsoluteSize.X, gui.AbsoluteSize.Y
		local portrait = w < 600 and h > w
		local compactPortrait = portrait and h < 620
		local short = h < 480 and not portrait
		local stacked = w < 800 and not short
		local side = short and 124 or math.min(166, (w - 30) / 2)
		wallet.Size, wallet.Position = UDim2.fromOffset(side, 54), UDim2.fromOffset(10, 8)
		bag.Size, bag.Position = UDim2.fromOffset(side, 54), UDim2.new(1, -side - 10, 0, 8)
		local eggWidth = stacked and math.min(400, w - 20) or math.min(360, w - 2 * side - 48)
		egg.AnchorPoint, egg.Position = Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, stacked and 70 or 8)
		egg.Size = UDim2.fromOffset(math.max(160, eggWidth), 86)
		local actionY = stacked and 164 or 102
		more.Size, more.Position = UDim2.fromOffset(92, 44), UDim2.fromOffset(10, actionY)
		upgrade.Size, upgrade.Position = UDim2.fromOffset(100, 44), UDim2.fromOffset(110, actionY)
		sell.Size, sell.Position = UDim2.fromOffset(92, 44), UDim2.new(1, -102, 0, actionY)
		drawer.Position, drawer.Size = UDim2.fromOffset(10, actionY + 50), UDim2.fromOffset(math.min(340, w - 20), math.max(100, math.min(386, h - actionY - 62)))
		cash.Text, relics.Text = "$" .. number(player:GetAttribute("Cash")), "Relics  " .. number(player:GetAttribute("Relics"))
		local used, cap = player:GetAttribute("BucketUsed"), player:GetAttribute("BucketCapacity")
		bucket.Text = number(used) .. " / " .. number(cap)
		local full = typeof(used) == "number" and typeof(cap) == "number" and used >= cap
		local pending = player:GetAttribute("PendingMaterials") or 0
		local noRoom = full or pending > 0
		bagCaption.Text = pending > 0 and string.format("%d PENDING / OPEN", pending)
			or full and "FULL / SELL" or "BUCKET / OPEN"
		bucket.TextColor3 = noRoom and gold or mint
		local personal, allDamage = player:GetAttribute("MiningContribution"), State:GetAttribute("EffectiveDamage")
		if typeof(personal) == "number" and typeof(allDamage) == "number"
			and player:GetAttribute("ContributionRound") == State:GetAttribute("RoundId") then
			contribution.Text = string.format("Your damage: %.1f%% / %s HP", allDamage > 0 and personal / allDamage * 100 or 0, number(personal))
		else contribution.Text = "Synchronizing contribution..." end
		sell.Interactable, sell.Selectable = ready and typeof(used) == "number" and used > 0, ready and typeof(used) == "number" and used > 0
		sell.BackgroundTransparency = sell.Interactable and 0 or 0.4
		local phase = Phase.Read(State)
		local sharedProgress, layer = State:GetAttribute("Progress"), State:GetAttribute("ActiveLayer")
		eggName.Text = State:GetAttribute("EggName") or "Synchronizing egg..."
		if typeof(sharedProgress) == "number" and typeof(layer) == "number" then
			progress.Text = phase == "Excavating" and string.format("%.1f%% excavated / Layer %d of 3", sharedProgress * 100, layer)
				or phase == "Selecting" and "Selecting the next egg"
				or phase == "Delivering" and "Next egg arriving"
				or phase == "Hatching" and "Shell complete / Hatching"
				or "Discovery complete"
			fill.Size = UDim2.fromScale(math.clamp(sharedProgress, 0, 1), 1)
		else
			progress.Text, fill.Size = "Synchronizing progress...", UDim2.fromScale(0, 1)
		end
		local index, done = player:GetAttribute("ContractIndex"), player:GetAttribute("ContractProgress")
		if index and done then
			local item = Catalog.Contract(index)
			contract.Text = "Your % = your damage / all egg damage so far.\nCURRENT CONTRACT\n" .. item.Title .. "\n" .. number(done) .. " / " .. number(item.Goal) .. "  |  Reward $" .. number(item.Reward)
		else contract.Text = "Synchronizing contract..." end
		local ch = player.Character
		local actualTool = ch and ch:FindFirstChildOfClass("Tool")
		local human = ch and ch:FindFirstChildOfClass("Humanoid")
		local alive = human ~= nil and human.Health > 0
		local running = player:GetAttribute("Training") == true
		local blocked = not root.Visible or menuOpen or not alive
		local beltY = portrait and 172 or 12
		local beltHeight, beltWidth = portrait and 66 or 72, short and 228 or portrait and 216 or 252
		if belt then belt:Update(beltWidth, beltHeight, UDim2.new(0.5, 0, 1, -beltY), blocked or running) end
		toolName.Size, toolName.Position = UDim2.fromOffset(beltWidth + 50, 22), UDim2.new(0.5, -(beltWidth + 50) / 2, 1, -beltY - beltHeight - 24)
		toolName.Visible, toolName.Text = not blocked and not running and not compactPortrait, actualTool and ("Equipped: " .. actualTool.Name) or "Select a tool"
		local trialEnd = player:GetAttribute("DrillTrialEndsAt")
		if actualTool and actualTool:GetAttribute("ToolFamily") == "Drill" and typeof(trialEnd) == "number"
			and trialEnd > workspace:GetServerTimeNow() and not player:GetAttribute("OwnsTool_Drill") then
			toolName.Text ..= " / trial " .. math.ceil(trialEnd - workspace:GetServerTimeNow()) .. "s"
		end
		if actualTool and actualTool:GetAttribute("ToolFamily") == "Drill" and player:GetAttribute("DrillRunning") then
			toolName.Text ..= player:GetAttribute("DrillContact") and " / CONTACT" or " / NO CONTACT"
		end
		local touch = UIS.PreferredInput == Enum.PreferredInput.Touch
		gui.Use.Visible = not blocked and not running and phase == "Excavating"
		gui.Use.Size = UDim2.fromOffset(touch and 106 or 130, 64)
		gui.Use.Position = UDim2.new(1, touch and -116 or -140, 1, touch and -100 or -16)
		gui.Use.Text = not actualTool and "EQUIP" or player:GetAttribute("ToolFamily") == "Drill"
			and (player:GetAttribute("DrillRunning") and "STOP DRILL" or "START DRILL")
			or player:GetAttribute("ToolFamily") == "Explosive" and "DETONATE" or "STRIKE"
		prompt.Text = not actualTool and "SELECT TOOL" or touch and (player:GetAttribute("ToolFamily") == "Drill" and "TAP TO TOGGLE" or "HOLD")
			or UIS.PreferredInput == Enum.PreferredInput.Gamepad and "RT / R2" or "CLICK / E"
		if actualTool and actualTool:GetAttribute("ToolFamily") == "Drill" and player:GetAttribute("DrillRunning") then
			prompt.Text = player:GetAttribute("DrillContact") and "CONTACT" or "NO CONTACT"
		end
		-- Equip behavior is owned by the original input controller.
		local sprint = gui:FindFirstChild("SprintToggle")
		if sprint then
			sprint.Size, sprint.Position = UDim2.fromOffset(compactPortrait and 64 or 84, 44), UDim2.fromOffset(10, actionY + (portrait and 116 or 54))
		end
		training.Parent = running and root or list
		training.LayoutOrder = 8
		training.Visible = root.Visible and alive and (running or (menuOpen and ownedTraining()))
		training.AnchorPoint = running and Vector2.new(0.5, 1) or Vector2.zero
		training.Size, training.Position = running and UDim2.fromOffset(160, 44) or UDim2.new(1, -6, 0, 44), UDim2.new(0.5, 0, 1, -14)
		training.ZIndex = running and 8 or 12
		training.Text = running and "STOP TRAINING" or "TRAIN / OPTIONAL"
		local step = player:GetAttribute("TutorialStep")
		local guideText = noRoom and "Tap SELL to make room. Earned pending materials refill your bucket."
			or showHelp and (touch and "Aim at the shell and hold STRIKE. Materials collect automatically." or "Click / E to strike. 1-3 select tools. Shift sprints; Ctrl locks aim.")
			or step and step <= 1 and "Select your pickaxe, aim at the egg and strike."
			or step and step <= 4 and "Break a shell section. Materials collect automatically."
			or step and step <= 6 and "Tap SELL to empty your bucket and earn credits."
			or step and step == 7 and "Open UPGRADES to improve your equipped tool."
			or nil
		guide.Visible = not blocked and not running and guideText ~= nil and phase == "Excavating" and gui.Toast.Text == ""
		hint.Text = guideText or ""
		dismiss.Visible = not noRoom and (showHelp or (step ~= nil and step <= 7))
		hint.Size = UDim2.new(1, dismiss.Visible and -58 or -20, 1, -8)
		if short then
			guide.Size, guide.Position = UDim2.fromOffset(math.min(380, math.max(180, w - 330)), 54), UDim2.fromOffset(218, actionY)
		else
			guide.Size, guide.Position = UDim2.fromOffset(math.min(380, w - 20), 54), UDim2.new(0.5, -math.min(380, w - 20) / 2, 0, actionY + 54)
		end
		local target = gui:FindFirstChild("TargetStatus")
		gui:SetAttribute("CoreTargetSuppressed", compactPortrait and guide.Visible)
		if target then
			target.Position = UDim2.new(0.5, 0, 1, -beltY - beltHeight - 48)
			target.Visible = target.Visible and not blocked and not running and gui.Toast.Text == "" and not gui:GetAttribute("CoreTargetSuppressed")
		end
		gui.Toast.AnchorPoint = Vector2.new(0.5, 0)
		gui.Toast.Position, gui.Toast.Size = UDim2.new(0.5, 0, 1, -beltY - beltHeight - 90), UDim2.fromOffset(math.min(420, w - 24), 40)
		if compactPortrait then gui.Toast.Position = UDim2.new(0.5, 0, 0, actionY + 54) end
		gui.Toast.Visible = ready and not externalModal and not bagOpen and gui.Toast.Text ~= ""
		gui.Toast.TextWrapped, gui.Toast.TextSize = true, 14
	end
	return api
end
return M
