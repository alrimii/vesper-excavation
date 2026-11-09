-- Presentation and input only. Server owns all amounts, mining and transactions.
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Run = game:GetService("RunService")
local player = Players.LocalPlayer
player:SetAttribute("OuterFracturesClientReady", false)
player:SetAttribute("GameplayClientReady", false)
local Shared = game.ReplicatedStorage:WaitForChild("VesperShared")
while not Shared:GetAttribute("OuterFracturesReady") do
	Shared:GetAttributeChangedSignal("OuterFracturesReady"):Wait()
end
-- Wait for the generated descendants as well as the readiness attribute.
for row = 10, 39 do
	local name = string.format("L1_R%02d", row)
	local library = Shared:WaitForChild("FractureLibrary")
	while true do
		local group = library:FindFirstChild(name)
		local count = group and group:GetAttribute("FragmentCount")
		if count and #group:GetChildren() == count then
			break
		end
		task.wait()
	end
end
player:SetAttribute("OuterFracturesClientReady", true)
local C = require(Shared:WaitForChild("ExcavationConfig"))
local Action = Shared.Remotes:WaitForChild("Action")
local Feedback = Shared.Remotes:WaitForChild("Feedback")
local State = Shared:WaitForChild("RoundState")
local Egg = workspace:WaitForChild("VesperLab"):WaitForChild("Egg")
local gui = player:WaitForChild("PlayerGui"):WaitForChild("ExcavationHUD")
local panel = gui.Status
local Layout = require(Shared:WaitForChild("HUDLayout"))
Layout.Style(gui)
local DiscoveryHUD = require(Shared:WaitForChild("DiscoveryHUD")).Attach(gui, player)
local shopOpen = false
local workshop = require(Shared.WorkshopUI).Build(gui, player, C, Action)
require(Shared.RoomTerminalHints).Start(player, gui)
local uiMotion = require(Shared:WaitForChild("UIMotion")).Attach(gui, C.UIMotion)
local Motion = require(Shared:WaitForChild("ToolMotion"))
Motion.Start()
require(Shared:WaitForChild("ExcavationCamera")).Start(player, gui, C)
require(Shared:WaitForChild("MovementControls")).Start(player, gui)
local ShellMotion = require(Shared:WaitForChild("ShellMotion")).Start(Egg, C)
require(Shared:WaitForChild("LabAtmosphere")).Start()
require(Shared.EggLifecycle).Start(gui, State, Egg)
local ImpactFX = require(Shared.ImpactFX).Start()
local held = false
local lastUse = -math.huge
local toastUntil = 0
local sequence = 0
local currentTool = nil
local fullNotified = false
local function notice(t)
	gui.Toast.Text = t
	toastUntil = os.clock() + 3.2
end
local recoveryShown = false
local function recoveredClaim()
	if recoveryShown or not player:GetAttribute("LabReady") or not player:GetAttribute("ProfileReady") then return end
	local amount = player:GetAttribute("RecoveredMaterialClaim")
	local delivered, pending = player:GetAttribute("RecoveredMaterialDelivered"), player:GetAttribute("RecoveredMaterialPending")
	if typeof(amount) ~= "number" or typeof(delivered) ~= "number" or typeof(pending) ~= "number" then return end
	recoveryShown = true
	notice(string.format("Recovered %d earned materials: %d in bucket / %d pending", amount, delivered, pending))
end
for _, attribute in { "LabReady", "ProfileReady", "RecoveredMaterialClaim", "RecoveredMaterialDelivered", "RecoveredMaterialPending" } do
	player:GetAttributeChangedSignal(attribute):Connect(recoveredClaim)
end
recoveredClaim()
local function equipped()
	local ch = player.Character
	local tool = ch and ch:FindFirstChildOfClass("Tool")
	if tool and tool:GetAttribute("OwnerUserId") == player.UserId then
		return tool, tool:GetAttribute("ToolKind")
	end
end
local toolFeedback
local cancelledThrough = 0
local drillConfirmedTarget, drillConfirmedUntil = nil, 0
local lastDrillStop = -math.huge
local drillingTarget
local drillLatched = false
local function cancel()
	held = false
	drillLatched = false
	drillingTarget = nil
	drillConfirmedTarget, drillConfirmedUntil = nil, 0
	cancelledThrough = sequence
	player:SetAttribute("DrillRunning", false)
	player:SetAttribute("DrillContact", false)
	if toolFeedback then toolFeedback:Cancel(player.UserId) end
	Motion.Cancel(player)
	Action:FireServer("Cancel")
end
State:GetAttributeChangedSignal("Status"):Connect(function()
	if State:GetAttribute("Status") ~= "Excavating" then cancel() end
end)
State:GetAttributeChangedSignal("RoundId"):Connect(function()
	cancel()
	if toolFeedback then toolFeedback:Clear() end
end)
player:GetAttributeChangedSignal("CoreMenuOpen"):Connect(cancel)
player:GetAttributeChangedSignal("ResearchModal"):Connect(cancel)
player:GetAttributeChangedSignal("EggResultsOpen"):Connect(cancel)
player:GetAttributeChangedSignal("Training"):Connect(cancel)
player:GetAttributeChangedSignal("MaterialBagOpen"):Connect(cancel)
player:GetAttributeChangedSignal("DiscoveryCinematic"):Connect(function()
	if player:GetAttribute("DiscoveryCinematic") then
		cancel()
		shopOpen = false
	end
end)
local function equip(kind)
	cancel()
	local ch = player.Character
	local hum = ch and ch:FindFirstChildOfClass("Humanoid")
	local pack = player:FindFirstChildOfClass("Backpack")
	if not hum or not pack then
		return
	end
	local _, actual = equipped()
	if actual == kind then
		hum:UnequipTools()
		currentTool = nil
		return
	end
	for _, tool in pack:GetChildren() do
		if
			tool:IsA("Tool")
			and tool:GetAttribute("ToolKind") == kind
			and tool:GetAttribute("OwnerUserId") == player.UserId
		then
			hum:EquipTool(tool)
			currentTool = equipped()
			return
		end
	end
end
local modern = require(Shared.ModernHUD).Build(gui, player, Action, function(page)
	cancel()
	shopOpen = true
	workshop:Select(page)
end, function()
	equip("Pickaxe")
end, DiscoveryHUD.Toggle)
local function selectTool(id)
	if
		player:GetAttribute("LabReady") ~= true
		or player:GetAttribute("DiscoveryCinematic")
		or player:GetAttribute("EggResultsOpen") or player:GetAttribute("ResearchModal")
		or player:GetAttribute("MaterialBagOpen")
		or player:GetAttribute("CoreMenuOpen")
	then
		return
	end
	local trial = id == "Drill"
		and (player:GetAttribute("DrillTrialEndsAt") or 0) > workspace:GetServerTimeNow()
	if not player:GetAttribute("OwnsTool_" .. id) and id ~= "Pickaxe" and not trial then
		return
	end
	local current = equipped()
	if current and current:GetAttribute("ToolFamily") == id then
		return
	end
	cancel()
	Action:FireServer("EquipTool", id)
end
modern:SetToolbelt(require(Shared.Toolbelt).Build(gui, player, selectTool))
local function cycleTool(direction)
	local order = require(Shared.ProgressionRules).ToolOrder
	local index = table.find(order, player:GetAttribute("ToolFamily")) or 1
	for step = 1, #order - 1 do
		local id = order[(index - 1 + step * direction) % #order + 1]
		if
			player:GetAttribute("OwnsTool_" .. id)
			or id == "Pickaxe"
			or (id == "Drill" and player:GetAttribute("DrillTrialEndsAt"))
		then
			selectTool(id)
			return
		end
	end
end
require(Shared.RoomAnimation).Start(player)
local targeter = require(Shared:WaitForChild("Targeting")).new(player, gui, Egg, C)
local function aimedSection()
	return targeter:Get()
end
local function use()
	if
		player:GetAttribute("LabReady") ~= true
		or State:GetAttribute("Status") ~= "Excavating"
		or not State:GetAttribute("Ready")
		or player:GetAttribute("EggResultsOpen") or player:GetAttribute("ResearchModal")
		or player:GetAttribute("MaterialBagOpen")
		or player:GetAttribute("CoreMenuOpen")
		or player:GetAttribute("DiscoveryCinematic")
		or shopOpen
		or player:GetAttribute("Training")
	then
		return
	end
	local _, kind = equipped()
	local now = os.clock()
	local family = player:GetAttribute("ToolFamily")
	if kind == "Pickaxe" then
		if
			(family ~= "Drill" and Motion.Busy(player))
			or now - lastUse < (player:GetAttribute("StrikeCooldown") or C.Mining.Cooldown)
		then
			return
		end
		local section, pos = aimedSection()
		if family ~= "Pickaxe" and not section then
			return
		end
		if (player:GetAttribute("BucketUsed") or 0) >= (player:GetAttribute("BucketCapacity") or 40)
			or (player:GetAttribute("PendingMaterials") or 0) > 0
		then
			if not fullNotified then
				notice("Bucket full or materials pending. Tap SELL to make room.")
				fullNotified = true
			end
			cancel()
			return
		end
		lastUse = now
		sequence += 1
		if family ~= "Drill" then
			Motion.Begin(player, family == "Explosive" and C.Tools.Explosive.Fuse
				or (player:GetAttribute("StrikeCooldown") or C.Mining.Cooldown), sequence, pos)
		end
		if section then
			Action:FireServer("Mine", section, pos, State:GetAttribute("RoundId"), sequence)
		else
			Action:FireServer("Swing", sequence)
		end
	else
		equip("Pickaxe")
	end
end
-- No Tool.Activated handlers: manual activation and one GUI-aware input route.
local function overControl(position)
	for _, object in player.PlayerGui:GetGuiObjectsAtPosition(position.X, position.Y) do
		if object:IsA("GuiButton") or (object:IsA("Frame") and object.Active) then
			return true
		end
	end
	return false
end
UIS.InputBegan:Connect(function(input, processed)
	if processed or UIS:GetFocusedTextBox() or player:GetAttribute("LabReady") ~= true then
		return
	end
	if input.KeyCode == Enum.KeyCode.One then
		selectTool("Pickaxe")
	elseif input.KeyCode == Enum.KeyCode.Two then
		selectTool("Drill")
	elseif input.KeyCode == Enum.KeyCode.Three then
		selectTool("Explosive")
	elseif input.KeyCode == Enum.KeyCode.ButtonL1 then
		cycleTool(-1)
	elseif input.KeyCode == Enum.KeyCode.ButtonR1 then
		cycleTool(1)
	elseif input.KeyCode == Enum.KeyCode.ButtonL2 then
		cancel()
		shopOpen = not shopOpen
	elseif input.KeyCode == Enum.KeyCode.ButtonB then
		shopOpen = false
	elseif input.KeyCode == Enum.KeyCode.F then
		cancel()
	elseif
		input.KeyCode == Enum.KeyCode.E
		or input.KeyCode == Enum.KeyCode.ButtonR2
		or (input.UserInputType == Enum.UserInputType.MouseButton1 and not overControl(input.Position))
	then
		held = true
		use()
	end
end)
UIS.InputEnded:Connect(function(input)
	if
		input.KeyCode == Enum.KeyCode.E
		or input.KeyCode == Enum.KeyCode.ButtonR2
		or input.UserInputType == Enum.UserInputType.MouseButton1
	then
		if drillLatched then
			return
		end
		held = false
		if player:GetAttribute("ToolFamily") == "Drill" then
			cancel()
		end
	end
end)
UIS.WindowFocusReleased:Connect(cancel)
UIS.TextBoxFocused:Connect(cancel)
game:GetService("GuiService").MenuOpened:Connect(cancel)
local touchInput
gui.Use.InputBegan:Connect(function(input)
	if player:GetAttribute("ToolFamily") == "Drill" then
		return
	end
	if
		input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1
	then
		touchInput = input
		held = true
		use()
	end
end)
gui.Use.Activated:Connect(function()
	if player:GetAttribute("ToolFamily") ~= "Drill" then
		return
	end
	if drillLatched then
		cancel()
		return
	end
	if
		player:GetAttribute("LabReady") ~= true
		or shopOpen
		or player:GetAttribute("Training")
		or player:GetAttribute("DiscoveryCinematic")
		or player:GetAttribute("EggResultsOpen") or player:GetAttribute("ResearchModal")
		or player:GetAttribute("MaterialBagOpen")
		or player:GetAttribute("CoreMenuOpen")
	then
		return
	end
	drillLatched = true
	held = true
	use()
end)
UIS.InputEnded:Connect(function(input)
	if input == touchInput then
		touchInput = nil
		held = false
		if player:GetAttribute("ToolFamily") == "Drill" then
			cancel()
		end
	end
end)
gui.Tools.Pickaxe.Activated:Connect(function()
	equip("Pickaxe")
end)
gui.Tools.Bucket.Visible = false
for _, name in { "Sell", "Power", "Speed", "Capacity", "NextRound" } do
	gui.Station[name].Activated:Connect(function()
		cancel()
		Action:FireServer(name)
	end)
end
gui.Shop.Activated:Connect(function()
	cancel()
	shopOpen = not shopOpen
end)
gui.Station.Close.Activated:Connect(function()
	cancel()
	shopOpen = false
end)
gui.Bag.Activated:Connect(function()
	cancel()
	panel.Contents.Visible = not panel.Contents.Visible
	panel.Contribution.Visible = panel.Contents.Visible
end)
gui.Tutorial.Skip.Activated:Connect(function()
	cancel()
	Action:FireServer("TutorialSkip")
end)
gui.Help.Activated:Connect(function()
	cancel()
	-- Journal is controlled by DiscoveryHUD.
end)
game:GetService("ProximityPromptService").PromptButtonHoldBegan:Connect(cancel)
player.CharacterRemoving:Connect(cancel)
local deathConnection
local function bindDeath(character)
	if deathConnection then deathConnection:Disconnect() end
	local human = character:WaitForChild("Humanoid", 10)
	if human and character == player.Character then
		deathConnection = human.Died:Connect(cancel)
	end
end
player.CharacterAdded:Connect(bindDeath)
if player.Character then task.spawn(bindDeath, player.Character) end
local function disableBackpack()
	task.spawn(function()
		for _ = 1, 8 do
			local ok = pcall(function()
				game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
			end)
			if ok then
				return
			end
			task.wait(0.3)
		end
	end)
end
player.CharacterAdded:Connect(function()
	player:SetAttribute("GameplayArrivalAt", workspace:GetServerTimeNow())
	held = false
	currentTool = nil
	fullNotified = false
	shopOpen = false
	disableBackpack()
end)
disableBackpack()
local marker = Instance.new("BillboardGui")
marker.Name = "DepotObjective"
marker.Size = UDim2.fromOffset(175, 42)
marker.StudsOffset = Vector3.new(0, 7, 0)
marker.AlwaysOnTop = true
marker.MaxDistance = 500
marker.Parent = gui
local markerLabel = Instance.new("TextLabel")
markerLabel.Size = UDim2.fromScale(1, 1)
markerLabel.BackgroundColor3 = Color3.fromRGB(29, 46, 48)
markerLabel.BackgroundTransparency = 0.15
markerLabel.TextColor3 = Color3.fromRGB(255, 222, 153)
markerLabel.TextSize = 14
markerLabel.Font = Enum.Font.GothamBold
markerLabel.TextWrapped = true
markerLabel.Parent = marker
-- Anchored, noncolliding client fragments. Pooled visuals never own resource value.
local visualFolder = Instance.new("Folder")
visualFolder.Name = "LocalResourceVisuals"
visualFolder.Parent = workspace
local CollectionMotion =
	require(Shared:WaitForChild("CollectionMotion")).Start(visualFolder, ShellMotion, State)
local MiningFeedback = require(Shared:WaitForChild("MiningFeedback")).Start(visualFolder, State)
toolFeedback = require(Shared:WaitForChild("ToolFeedback")).Start(visualFolder, State)
local function burst(from, to, li, section)
	CollectionMotion:Burst(from, to, li, section)
end
local function soundAt(pos, volume)
	local holder = Instance.new("Part")
	holder.Size = Vector3.one
	holder.Transparency = 1
	holder.Anchored = true
	holder.CanCollide = false
	holder.CanQuery = false
	holder.CanTouch = false
	holder.Position = pos
	holder.Parent = visualFolder
	local s = Instance.new("Sound")
	s.SoundId = "rbxasset://sounds/action_jump_land.mp3"
	s.Volume = volume * (player:GetAttribute("SFXVolume") or 1)
	s.PlaybackSpeed = 1.5
	s.RollOffMaxDistance = 65
	s.Parent = holder
	s:Play()
	game:GetService("Debris"):AddItem(holder, 2)
end
Feedback.OnClientEvent:Connect(function(kind, a, b, c, d, e, damage, precise, critical, result)
	if kind == "TrainingPulse" then
		-- The shared training clock owns poses and reactions; no numeric toast.
	elseif kind == "TrialStarted" then
		cancel()
		shopOpen = false
	elseif kind == "OpenShop" then
		cancel()
		shopOpen = true
		workshop:Select((a == "TOOLS" or a == "ARCHIVE" or a == "ROOM") and a or "RIG")
	elseif kind == "Notice" then
		notice(a)
	elseif kind == "Windup" then
		local p = Players:GetPlayerByUserId(a)
		if p then
			Motion.Begin(p, b, c, d, e)
		end
	elseif kind == "Charge" then
		if a ~= player.UserId or b > cancelledThrough then toolFeedback:Charge(a, b, c, d, e, damage) end
	elseif kind == "ChargeCancel" then
		toolFeedback:Cancel(a, b)
	elseif kind == "Blast" then
		if toolFeedback:Blast(a, b, c, d, e) then
			ImpactFX.Emit(c, Color3.fromRGB(236, 209, 164), true, d, true, "Explosive")
		end
	elseif kind == "Cancel" then
		if a ~= player.UserId then toolFeedback:Cancel(a) end
		local p = Players:GetPlayerByUserId(a)
		if p and p ~= player then
			Motion.Cancel(p)
		end
	elseif kind == "Miss" then
		Motion.Miss(player, a)
		toolFeedback:Cancel(player.UserId, a)
		if a == sequence then
			toolFeedback:StopDrill(player.UserId)
			drillConfirmedTarget, drillConfirmedUntil = nil, 0
		end
		if a == sequence and player:GetAttribute("ToolFamily") ~= "Drill" then
			notice("No hit confirmed. Check your aim, range, or bucket.")
		end
	elseif kind == "Fragments" then
		burst(a, b, c, d)
	elseif kind == "Hit" then
		if not MiningFeedback:AcceptHit(a, e, result) then return end
		local attacker = Players:GetPlayerByUserId(a)
		if attacker then Motion.Confirm(attacker, e) end
		if result.Family ~= "Explosive" or result.Broken then
			ImpactFX.Emit(b, c, result.Broken, result.Normal, precise or critical, result.Family)
		end
		if result.Family == "Drill" then
			if a == player.UserId and held and currentTool and currentTool:GetAttribute("ToolFamily") == "Drill" then
				if result.Broken then drillConfirmedTarget, drillConfirmedUntil = nil, 0
				else drillConfirmedTarget, drillConfirmedUntil = d, os.clock() + result.Interval + C.Tools.Drill.ContactLeaseGrace end
				toolFeedback:Hit(a, b, d, result)
			elseif a ~= player.UserId then
				if attacker then Motion.DrillRun(attacker, true, b, not result.Broken, result.Interval + C.Tools.Drill.ContactLeaseGrace) end
				toolFeedback:Hit(a, b, d, result)
			end
		else toolFeedback:Hit(a, b, d, result) end
		if not result.Broken then ShellMotion:Impact(d, b, damage) end
		MiningFeedback:Hit(a, b, damage, precise, critical, result)
		if a == player.UserId then targeter:Confirm() end
	elseif kind == "UpgradeBought" then
		notice(C.Upgrades[a].Name .. " +" .. tostring(b) .. " levels")
	elseif kind == "Collected" then
		MiningFeedback:Award(a, b)
	elseif kind == "PendingDelivered" then
		notice(string.format("%d pending materials moved to bucket / %d still pending", a, b))
	elseif kind == "Sold" then
		notice((b or 0) > 0 and string.format("Sold +$%d / %d pending moved to bucket / %d remain", a, b, c or 0)
			or ("Unloaded resources  /  +$" .. a))
		-- Selling no longer requires an equipped bucket.
		local ch = player.Character
		local root = ch and ch:FindFirstChild("HumanoidRootPart")
		if root then
			soundAt(root.Position, 0.22)
		end
	end
end)
local specimen = Egg:WaitForChild("ContainedSpecimen")
local silhouette = {}
for _, p in specimen:GetChildren() do
	if p:IsA("BasePart") and p.Name ~= "ContainmentCore" then
		silhouette[p] = p.CFrame
	end
end
local elapsed = 0
Run.Heartbeat:Connect(function(dt)
	CollectionMotion:Step(dt)
	local selected = equipped()
	if selected ~= currentTool then
		if currentTool then
			cancel()
		end
		currentTool = selected
	end
	local human = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	local blocked = player:GetAttribute("LabReady") ~= true or State:GetAttribute("Status") ~= "Excavating"
		or not State:GetAttribute("Ready") or not human or human.Health <= 0 or shopOpen
		or player:GetAttribute("CoreMenuOpen") or player:GetAttribute("MaterialBagOpen")
		or player:GetAttribute("EggResultsOpen") or player:GetAttribute("ResearchModal") or player:GetAttribute("DiscoveryCinematic") or player:GetAttribute("Training")
	if held and blocked then cancel() end
	local running = held and not blocked and selected ~= nil and selected:GetAttribute("ToolFamily") == "Drill"
	local section, point
	if running then
		section, point = aimedSection()
		if drillingTarget and drillingTarget ~= section then
			toolFeedback:StopDrill(player.UserId)
			drillConfirmedTarget, drillConfirmedUntil = nil, 0
			if os.clock() - lastDrillStop >= C.Tools.Drill.InvalidUpdateInterval then
				lastDrillStop = os.clock()
				Action:FireServer("DrillStop")
			end
		end
	end
	drillingTarget = section
	local contact = running and section ~= nil and section == drillConfirmedTarget and os.clock() < drillConfirmedUntil
	if not player:GetAttribute("Training") then Motion.DrillRun(player, running, point, contact) end
	player:SetAttribute("DrillRunning", running)
	player:SetAttribute("DrillContact", contact)
	toolFeedback:Step(running, section)
	if held then use() end
	elapsed += dt
	if elapsed < 0.15 then
		return
	end
	elapsed = 0
	local drift = math.sin(workspace:GetServerTimeNow() * 0.7) * C.Appearance.IdleCoreDrift
	for p, base in silhouette do
		if p.Parent then
			p.CFrame = base + Vector3.new(0, drift, 0)
		end
	end
	local _, kind = equipped()
	local cash = player:GetAttribute("Cash") or 0
	local amount = player:GetAttribute("BucketUsed") or 0
	local cap = player:GetAttribute("BucketCapacity") or C.Collection.Capacity
	panel.Wallet.Cash.Text = "$"
		.. (tostring(math.floor(cash)):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
	panel.Equipped.Text = "Tool: " .. (kind or "none")
	panel.BagCard.Bucket.Text = string.format("%d / %d%s", amount, cap, amount >= cap and " FULL" or "")
	panel.BagCard.BucketTrack.Fill.Size = UDim2.fromScale(math.clamp(amount / cap, 0, 1), 1)
	panel.Contents.Text = string.format(
		"Shell %d  /  Membrane %d  /  Matrix %d",
		player:GetAttribute("Bucket_Shell") or 0,
		player:GetAttribute("Bucket_Membrane") or 0,
		player:GetAttribute("Bucket_Tissue") or 0
	)
	panel.Progress.Text = string.format("%.1f%% EXCAVATED", (State:GetAttribute("Progress") or 0) * 100)
	panel.ProgressTrack.Fill.Size = UDim2.fromScale(State:GetAttribute("Progress") or 0, 1)
	panel.Contribution.Text = string.format(
		"Mining %d | Sales $%d",
		player:GetAttribute("MiningContribution") or 0,
		player:GetAttribute("CollectionIncome") or 0
	)
	local layerIndex = State:GetAttribute("ActiveLayer") or 1
	panel.Round.Text = string.upper(C.Layers[layerIndex].Name)
		.. "  /  LAYER "
		.. layerIndex
		.. " / "
		.. #C.Layers
	panel.Progress.Text = string.format(
		"%d / %d PLATES LEFT",
		State:GetAttribute("LayerRemaining") or 0,
		State:GetAttribute("LayerTotal") or 0
	)
	local layerTotal = State:GetAttribute("LayerTotal") or 1
	panel.ProgressTrack.Fill.Size =
		UDim2.fromScale(1 - (State:GetAttribute("LayerRemaining") or layerTotal) / math.max(1, layerTotal), 1)
	gui.Use.Text = player:GetAttribute("ToolFamily") == "Drill"
			and (drillLatched and "STOP\nDRILL" or "START\nDRILL")
		or player:GetAttribute("ToolFamily") == "Explosive" and "DETONATE"
		or "STRIKE"
	gui.Tools.Pickaxe.BackgroundColor3 = kind == "Pickaxe" and Color3.fromRGB(95, 75, 43)
		or Color3.fromRGB(27, 42, 51)
	gui.Tools.Bucket.BackgroundColor3 = kind == "Bucket" and Color3.fromRGB(95, 75, 43)
		or Color3.fromRGB(27, 42, 51)
	if os.clock() > toastUntil then
		gui.Toast.Text = ""
	end
	local ch = player.Character
	local root = ch and ch:FindFirstChild("HumanoidRootPart")
	local depot = workspace.VesperLab.ResourceDepot
	uiMotion:SetShopVisible(shopOpen)

	if amount < cap then
		fullNotified = false
	end
	for _, name in { "Pickaxe" } do
		local button = gui.Tools[name]
		button.Selection.Color = kind == name and Color3.fromRGB(255, 204, 108) or Color3.fromRGB(76, 91, 97)
		button.Label.Text = (player:GetAttribute("ToolFamily") or "Pickaxe"):upper()
		local available = kind == name
		local pack = player:FindFirstChildOfClass("Backpack")
		if pack then
			for _, t in pack:GetChildren() do
				if t:GetAttribute("ToolKind") == name then
					available = true
				end
			end
		end
		button.Icon.ImageTransparency = available and 0 or 0.65
		button.Label.TextTransparency = available and 0 or 0.5
	end
	-- ModernHUD owns onboarding; suppress the retired seven-step overlay.
	gui.Tutorial.Visible = false
	gui.Guidance.Visible = false
	marker.Enabled = false
	-- ModernHUD alone owns gameplay layout; Workshop owns its modal layout.

	local waitTime =
		math.max(0, math.ceil((State:GetAttribute("ReadyAt") or 0) - workspace:GetServerTimeNow()))
	gui.Station.NextRound.Text = State:GetAttribute("Status") == "Revealed"
			and (waitTime > 0 and "REVEAL  /  " .. waitTime .. "s" or "NEXT SPECIMEN")
		or "NEXT: LOCKED"
	DiscoveryHUD.Update(kind)
	workshop:Update(workspace.CurrentCamera.ViewportSize)
	modern:Update()
end)

player:SetAttribute("GameplayClientReady", true)
