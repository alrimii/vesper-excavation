-- Sole authority: damage, shared material settlement, pending claims, sales and purchases.
local Players = game:GetService("Players")
local Shared = game.ReplicatedStorage:WaitForChild("VesperShared")
require(script.Parent:WaitForChild("ProgressiveFractureBuilder")).Prepare(Shared)
local C = require(Shared:WaitForChild("ExcavationConfig"))
local Clips = require(Shared:WaitForChild("MotionClips"))
local Economy = require(Shared.UpgradeEconomy)
local Rules = require(Shared.ProgressionRules)
local TrainingCycle = require(Shared.TrainingCycle)
local Delivery = require(Shared.DeliverySequence)
local Skills = require(Shared.SkillCatalog)
local Progress = require(script.Parent.PlayerProgression)
local sellLoads
local function skill(a, id)
	return Skills.Rank(a, id)
end
local giveTools
local cancelAttack
local trials = {}
local trialSelected = {}
local function effectiveTool(a)
	return trials[a] and trials[a] > os.clock() and trialSelected[a] ~= false and "Drill" or a.toolId
end
local function ownRoom(p)
	for _, room in workspace.VesperLab.Rooms:GetChildren() do
		if room:GetAttribute("OwnerUserId") == p.UserId then
			return room
		end
	end
end
local function practiceFor(p)
	local room = ownRoom(p)
	return room and room:FindFirstChild("TrainingStation")
end
local function training(p, s, enabled)
	local ch = p.Character
	local root = ch and ch:FindFirstChild("HumanoidRootPart")
	local hum = ch and ch:FindFirstChildOfClass("Humanoid")
	local device = practiceFor(p)
	if enabled and s.training then
		return true
	end
	if enabled then
		if
			not root
			or not hum
			or hum.Health <= 0
			or not device
			or (root.Position - device.TrainingSpot.Position).Magnitude > 18
		then
			return false
		end
		local tool = s.tools and s.tools.Pickaxe
		if not tool or not tool.Parent then
			return false
		end
		s.trainingRoot, s.trainingHumanoid = root, hum
		s.trainingAnchored, s.trainingAutoRotate = root.Anchored, hum.AutoRotate
		local floor = device.TrainingSpot.Position.Y + device.TrainingSpot.Size.Y * 0.5
		local height = hum.HipHeight + root.Size.Y * 0.5
		if hum.RigType == Enum.HumanoidRigType.R6 then
			height += 2
		end
		local position =
			Vector3.new(device.TrainingSpot.Position.X, floor + height, device.TrainingSpot.Position.Z)
		ch:PivotTo(
			CFrame.lookAt(
				position,
				Vector3.new(device.PracticeEgg.Position.X, position.Y, device.PracticeEgg.Position.Z)
			)
		)
		if tool.Parent ~= ch then
			hum:EquipTool(tool)
		end
		s.trainingStarted = workspace:GetServerTimeNow()
		s.trainingAward = 0
		local family = tool:GetAttribute("ToolFamily") or "Pickaxe"
		local target = TrainingCycle.ContactPoint(
			device.PracticeEgg:GetAttribute("RestCFrame") or device.PracticeEgg.CFrame,
			device.PracticeEgg:GetAttribute("RestSize") or device.PracticeEgg.Size,
			Vector3.new(position.X, device.PracticeEgg.Position.Y, position.Z)
		)
		p:SetAttribute("TrainingStartedAt", s.trainingStarted)
		p:SetAttribute("TrainingTarget", target)
		device:SetAttribute("TrainingStartedAt", s.trainingStarted)
		device:SetAttribute("TrainingFamily", family)
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
		root.Anchored = true
		hum.AutoRotate = false
		cancelAttack(p, s)
	else
		if s.trainingRoot and s.trainingRoot.Parent then
			s.trainingRoot.Anchored = s.trainingAnchored == true
		end
		if s.trainingHumanoid and s.trainingHumanoid.Parent then
			s.trainingHumanoid.AutoRotate = s.trainingAutoRotate ~= false
		end
		s.trainingRoot, s.trainingHumanoid = nil, nil
		p:SetAttribute("TrainingStartedAt", nil)
		p:SetAttribute("TrainingTarget", nil)
	end
	s.training = enabled
	p:SetAttribute("Training", enabled)
	if device then
		device:SetAttribute("TrainingActive", enabled)
	end
	return true
end
local currentEgg = Rules.Eggs[1]
local transitioning = false
local random = Random.new()
local Catalog = require(Shared:WaitForChild("DiscoveryCatalog"))
local Profiles = require(script.Parent.ResearchProfiles)
local Materials = require(script.Parent.MaterialRewards)
local EggRewards = require(script.Parent.EggRewards).new(random)
local Action = Shared.Remotes:WaitForChild("Action")
local Feedback = Shared.Remotes:WaitForChild("Feedback")
local State = Shared:WaitForChild("RoundState")
State:SetAttribute("Initialized", false)
State:SetAttribute("TransitionStartedAt", 0)
-- Remove obsolete single-winner state; rewards are personal completion receipts.
State:SetAttribute("LastWinner", nil)
State:SetAttribute("LastCreature", nil)
State:SetAttribute("DrawPlayers", nil)
local Piles = Shared:WaitForChild("ResourcePiles")
local Egg = workspace.VesperLab.Egg
local Sections = Egg.Sections
local Dormant = game.ServerStorage:WaitForChild("EggDormant")
local Depot = workspace.VesperLab.ResourceDepot
local Kit = game.ServerStorage.VesperKit
local sessions, accounts, sections = {}, {}, {}
local serverSkillGuards = {} -- retained by UserId across same-server reconnects, including Studio previews
cancelAttack = function(p, session)
	session.attack = (session.attack or 0) + 1
	session.pending = nil
	session.flow, session.relay = nil, nil
	session.inputUntil = 0
	p:SetAttribute("FlowBuild", 0)
	p:SetAttribute("FlowUntil", 0)
	p:SetAttribute("FlowReadyUntil", 0)
	if os.clock() - (session.lastCancelBroadcast or -math.huge) >= 0.1 then
		session.lastCancelBroadcast = os.clock()
		Feedback:FireAllClients("Cancel", p.UserId)
	end
end
local function toolLevel(a, key)
	return Rules.Level(a, effectiveTool(a), key)
end
local total, removed, deepRemoved = 0, 0, 0
local activeLayer = 1
local layerRemaining = {}
local layerTotals = {}
local round, status, readyAt = 0, "Excavating", 0
local specimenId = "lumen"
local eggDamage, serverClaims, eggXP = {}, {}, {}
local totalDamage = 0
local shuttingDown = false
local rebuildingShell = false
local function expose(s, visible)
	local data = sections[s]
	local p = data.part
	p.CanCollide = not data.broken and not rebuildingShell
	p.CanQuery = not data.broken and not rebuildingShell
	p.Transparency = (data.broken or rebuildingShell) and 1 or 0
	p.Name = "Plate"
	p.Parent = s
	s:SetAttribute("Exposed", visible and not data.permanent)
end
local function tutorial(p, event)
	local a = accounts[p.UserId]
	if not a then
		return
	end
	local expected =
		{ "EquipPickaxe", "BreakShell", "EquipBucket", "Collect", "AtDepot", "Sell", "AtUpgrade" }
	if expected[a.tutorial or 1] == event then
		a.tutorial = (a.tutorial or 1) + 1
		p:SetAttribute("TutorialStep", a.tutorial)
	end
end
local function note(p, t)
	Feedback:FireClient(p, "Notice", t)
end
local function stats(a)
	local config = Rules.ToolConfig(effectiveTool(a), C)
	return math.floor(
		(config.Mining.Power + toolLevel(a, "Power") * config.Upgrades.Power.Step) * Rules.PowerBonus(a)
	),
		math.max(
			config.Mining.MinimumCooldown,
			config.Mining.Cooldown - toolLevel(a, "Speed") * config.Upgrades.Speed.Step
		),
		C.Collection.Capacity + toolLevel(a, "Capacity") * config.Upgrades.Capacity.Step
end
local function used(a)
	local n = 0
	for _, l in C.Layers do
		n += a.contents[l.Id] or 0
	end
	return n
end
local function price(a, key)
	return Economy.Price(key, toolLevel(a, key), Rules.ToolConfig(effectiveTool(a), C))
end
-- Accounts are writable only while this Player owns a loaded, non-closing profile.
local function writablePlayer(userId)
	local p = Players:GetPlayerByUserId(userId)
	if
		not shuttingDown
		and p
		and p.Parent == Players
		and sessions[p]
		and accounts[userId]
		and Profiles.CanMutate(p)
	then
		return p, accounts[userId]
	end
end
local function drainPending(p, a, cap, quiet)
	local delivered = Materials.Drain(a, cap)
	if delivered > 0 and not quiet then
		Feedback:FireClient(p, "PendingDelivered", delivered, Materials.Count(a.pendingMaterials))
	end
	return delivered
end
local function syncPlayer(p)
	local a = accounts[p.UserId]
	if not a then
		return
	end
	local power, cd, cap = stats(a)
	if writablePlayer(p.UserId) == p then
		drainPending(p, a, cap)
	end
	local config = Rules.ToolConfig(effectiveTool(a), C)
	p:SetAttribute("ToolFamily", effectiveTool(a))
	p:SetAttribute("IntroStage", a.introStage)
	p:SetAttribute("DrillTrialUsed", a.drillTrialUsed)
	p:SetAttribute("ToolName", Rules.Tools[effectiveTool(a)].Name)
	p:SetAttribute("Strength", a.strength)
	p:SetAttribute("EquippedCreature", a.equippedCreature)
	for i = 1, 3 do
		p:SetAttribute("DisplaySlot" .. i, a.displaySlots[i])
	end
	p:SetAttribute("RoomTheme", a.roomTheme)
	p:SetAttribute("Relics", a.relics or 0)
	p:SetAttribute("PowerBonus", Rules.PowerBonus(a))
	for id, owned in a.ownedTools do
		p:SetAttribute("OwnsTool_" .. id, owned)
		for _, key in Rules.UpgradeKeys do
			local level = id == a.toolId and (a[key] or 0) or ((a.toolLevels[id] or {})[key] or 0)
			p:SetAttribute("ToolLevel_" .. id .. "_" .. key, level)
		end
	end
	for id, n in a.creatures do
		p:SetAttribute("Creature_" .. id, n)
	end
	for id, owned in a.roomThemes do
		p:SetAttribute("OwnsTheme_" .. id, owned)
	end
	for k, v in
		{
			Cash = a.cash,
			MiningContribution = eggDamage[p.UserId] or 0,
			ContributionRound = round,
			PendingMaterials = Materials.Count(a.pendingMaterials),
			CollectionIncome = a.income,
			BucketUsed = used(a),
			BucketCapacity = cap,
			StrikePower = power,
			StrikeCooldown = cd,
			YieldBonus = toolLevel(a, "Yield"),
			SaleMultiplier = 1 + toolLevel(a, "Value") * C.Upgrades.Value.Step,
			BucketBaseValue = a.materialValue,
			PrecisionMultiplier = C.Precision.Multiplier
				+ toolLevel(a, "Precision") * C.Upgrades.Precision.Step,
			CriticalChance = toolLevel(a, "Critical") * C.Upgrades.Critical.Step,
		}
	do
		p:SetAttribute(k, v)
	end
	for _, l in C.Layers do
		p:SetAttribute("Bucket_" .. l.Id, a.contents[l.Id] or 0)
		p:SetAttribute("Pending_" .. l.Id, Materials.Count(a.pendingMaterials, l.Id))
	end
	for key, u in config.Upgrades do
		p:SetAttribute(key .. "Level", toolLevel(a, key))
		p:SetAttribute(key .. "Price", toolLevel(a, key) < u.MaxLevel and price(a, key) or -1)
	end
	local prog = a.progression
	local level = Skills.Level(prog.xpUnits / Skills.XPScale)
	p:SetAttribute("ResearchXP", prog.xpUnits / Skills.XPScale)
	p:SetAttribute("ResearchLevel", level)
	p:SetAttribute("SkillPoints", Skills.Points(level) - Skills.Spent(prog.ranks))
	p:SetAttribute("SkillRanks", game:GetService("HttpService"):JSONEncode(prog.ranks))
	p:SetAttribute("SkillLoadout", game:GetService("HttpService"):JSONEncode(prog.loadout))
	p:SetAttribute("SaleLatchEnabled", prog.saleLatch)
	p:SetAttribute("ChargedUntil", prog.guards.chargedUntil or 0)
	p:SetAttribute(
		"PrecisionRadius",
		effectiveTool(a) ~= "Explosive" and ({ [0] = 0.75, 1, 1.2 })[skill(a, "impact.steady_aim")] or 0.75
	)
	p:SetAttribute("CoreSamples", a.samples)
	p:SetAttribute("ContractIndex", a.contract)
	p:SetAttribute("ContractProgress", a.contractProgress)
	local count = 0
	for id, n in a.discoveries do
		p:SetAttribute("Discovery_" .. id, n)
		if n > 0 then
			count += 1
		end
	end
	p:SetAttribute("DiscoveryCount", count)

	p:SetAttribute("TutorialStep", a.tutorial or 1)
end
local function deliverEggRewards(p)
	local owner, account = writablePlayer(p.UserId)
	if owner ~= p then
		return 0
	end
	return EggRewards:Deliver(p.UserId, account)
end
local function publishEggResults(p)
	local history = EggRewards:History(p.UserId)
	p:SetAttribute("ExpeditionResultHistory", game:GetService("HttpService"):JSONEncode(history))
	p:SetAttribute(
		"LastExpeditionResult",
		#history > 0 and game:GetService("HttpService"):JSONEncode(history[#history]) or nil
	)
end
local function advance(p, kind, amount)
	local a = accounts[p.UserId]
	if not a then
		return
	end
	local contract = Catalog.Contract(a.contract)
	if contract.Kind ~= kind then
		return
	end
	a.contractProgress += amount
	if a.contractProgress >= contract.Goal then
		a.cash += contract.Reward
		a.contract += 1
		a.contractProgress = 0
		Feedback:FireClient(p, "ResearchReward", "CONTRACT COMPLETE", contract.Title, contract.Reward)
	end
end
local function alive(p)
	local ch = p.Character
	local h = ch and ch:FindFirstChildOfClass("Humanoid")
	local root = ch and ch:FindFirstChild("HumanoidRootPart")
	local head = ch and ch:FindFirstChild("Head")
	if h and h.Health > 0 and root and head then
		return ch, root, head
	end
end
local function equipped(p, kind)
	local s = sessions[p]
	local t = s and s.tools[kind]
	return t and t.Parent == p.Character and t:GetAttribute("OwnerUserId") == p.UserId and t.Enabled
end
local function rayParams(ch)
	local p = RaycastParams.new()
	p.FilterType = Enum.RaycastFilterType.Exclude
	p.FilterDescendantsInstances = { ch }
	p.RespectCanCollide = false
	return p
end
local function finite(v)
	return typeof(v) == "Vector3"
		and v.X == v.X
		and v.Y == v.Y
		and v.Z == v.Z
		and math.abs(v.X) < 1e5
		and math.abs(v.Y) < 1e5
		and math.abs(v.Z) < 1e5
end
local function syncRound()
	for k, v in
		{
			EffectiveDamage = totalDamage,
			ActiveLayer = activeLayer,
			LayerRemaining = layerRemaining[activeLayer] or 0,
			LayerTotal = layerTotals[activeLayer] or 0,
			RoundId = round,
			Status = status,
			Removed = removed,
			TotalSections = total,
			Progress = total > 0 and math.clamp(removed / total, 0, 1) or 0,
			SamplesRequired = layerTotals[#C.Layers] or 0,
			SpecimenId = specimenId,
			SpecimenName = Catalog.ForRound(round).Name,
			Clue = Catalog.ForRound(round).Clue,
			DeepRemoved = deepRemoved,
			ReadyAt = readyAt,
		}
	do
		State:SetAttribute(k, v)
	end
	State:SetAttribute(
		"PhaseSnapshot",
		game:GetService("HttpService"):JSONEncode({
			status = status,
			transitionStarted = State:GetAttribute("TransitionStartedAt") or 0,
			started = State:GetAttribute("PhaseStartedAt") or workspace:GetServerTimeNow(),
		})
	)
end

local accessCollision = {}
for _, part in workspace.VesperLab.ExcavationAccess:GetDescendants() do
	if part:IsA("BasePart") then
		accessCollision[part] = { part.CanCollide, part.CanQuery }
	end
end
local function accessEnabled(enabled)
	for part, original in accessCollision do
		part.CanCollide = enabled and original[1]
		part.CanQuery = enabled and original[2]
	end
end
local function beginRound(nextEgg)
	rebuildingShell = true
	currentEgg = nextEgg or currentEgg
	State:SetAttribute("EggId", currentEgg.Id)
	State:SetAttribute("EggName", currentEgg.Name)
	State:SetAttribute("EggRarity", currentEgg.Rarity)
	State:SetAttribute("EggDropChance", currentEgg.DropChance)
	State:SetAttribute("Ready", false)
	for _, p in Players:GetPlayers() do
		local ch, root = alive(p)
		if
			ch
			and Vector3.new(root.Position.X, 0, root.Position.Z).Magnitude < C.Geometry.Radius + 4
			and root.Position.Y < C.Geometry.Base.Y + C.Geometry.Height + 4
		then
			local v = Vector3.new(root.Position.X, 0, root.Position.Z)
			local unit = v.Magnitude > 0.1 and v.Unit or Vector3.new(1, 0, 0)
			ch:PivotTo(
				CFrame.lookAt(unit * (C.Geometry.Radius + 20) + Vector3.new(0, 7, 0), Vector3.new(0, 6, 0))
			)
		end
	end
	round += 1
	specimenId = Catalog.ForRound(round).Id
	eggDamage, totalDamage, eggXP = {}, 0, {}
	-- EggRewards settlements/undelivered claims deliberately survive the next egg.
	State:SetAttribute("SpecimenColor", Catalog.ForRound(round).Color)
	removed = 0
	deepRemoved = 0
	status = "Excavating"
	readyAt = 0
	activeLayer = 1
	for li, n in layerTotals do
		layerRemaining[li] = n
	end
	local resetCount = 0
	for s, data in sections do
		resetCount += 1
		if resetCount % 400 == 0 then
			task.wait()
		end
		data.part.Transparency = 0
		data.part.Color = data.layer == 1 and currentEgg.Color or C.Layers[data.layer].Color
		local surface = data.part:FindFirstChildOfClass("SurfaceAppearance")
		if surface then
			surface.Color = data.layer == 1 and currentEgg.Color or Color3.new(1, 1, 1)
		end
		data.hp = math.floor(C.Layers[data.layer].Durability * currentEgg.Durability)
		s:SetAttribute("MaxHP", data.hp)
		data.broken = false
		data.contributions, data.settled = {}, false
		s:SetAttribute("HP", data.hp)
		s:SetAttribute("Intact", true)
		expose(s, data.layer == 1)
	end
	rebuildingShell = false
	for section, data in sections do
		expose(section, data.layer == 1)
	end
	for _, a in accounts do
		a.mining = 0
	end
	for _, p in Players:GetPlayers() do
		syncPlayer(p)
	end
	State:SetAttribute("PhaseStartedAt", workspace:GetServerTimeNow())
	syncRound()
	State:SetAttribute("Ready", true)
	State:SetAttribute("Initialized", true)
	accessEnabled(true)
	transitioning = false
end
local function nextExpedition(selectedEgg)
	if transitioning then
		return
	end
	transitioning = true
	for player, session in sessions do
		cancelAttack(player, session)
	end
	-- Clear moving access platforms before withdrawing them.
	for _, player in Players:GetPlayers() do
		local character, root = alive(player)
		if character and Vector3.new(root.Position.X, 0, root.Position.Z).Magnitude < 83 then
			local flat = Vector3.new(root.Position.X, 0, root.Position.Z)
			local outward = flat.Magnitude > 1 and flat.Unit or Vector3.xAxis
			local session = sessions[player]
			if session then
				training(player, session, false)
			end
			root.AssemblyLinearVelocity = Vector3.zero
			character:PivotTo(CFrame.lookAt(outward * 103 + Vector3.new(0, 4, 0), Vector3.new(0, 4, 0)))
		end
	end
	accessEnabled(false)
	local selected = selectedEgg or Rules.Choose(Rules.Eggs, random)
	State:SetAttribute("NextEggId", selected.Id)
	State:SetAttribute("Ready", false)
	status = "Selecting"
	State:SetAttribute("TransitionStartedAt", workspace:GetServerTimeNow())
	State:SetAttribute("PhaseStartedAt", workspace:GetServerTimeNow())
	syncRound()
	for _, data in sections do
		data.part.Transparency = 1
		data.part.CanCollide, data.part.CanQuery = false, false
	end
	task.delay(Delivery.SelectionDuration, function()
		status = "Delivering"
		State:SetAttribute("PhaseStartedAt", workspace:GetServerTimeNow())
		syncRound()
		task.delay(Delivery.DeliveryDuration, function()
			beginRound(selected)
		end)
	end)
end
local function completion()
	if status ~= "Excavating" or removed < total then
		return
	end
	for player, session in sessions do
		cancelAttack(player, session)
	end
	status = "Hatching"
	local completedAt = workspace:GetServerTimeNow()
	readyAt = completedAt + 2.2 + C.Completion.RevealSeconds
	State:SetAttribute("PhaseStartedAt", completedAt)
	local completed = round
	-- Frozen immediately at completion; reveal, rejoin and UI cannot reroll.
	EggRewards:Freeze(completed, currentEgg, eggDamage, totalDamage, completedAt, readyAt, eggXP)
	syncRound()
	task.delay(2.2, function()
		if round ~= completed or status ~= "Hatching" then
			return
		end
		status = "Revealed"
		local revealedAt = workspace:GetServerTimeNow()
		State:SetAttribute("PhaseStartedAt", revealedAt)
		local candidates, onlineLoaded = {}, {}
		for _, p in Players:GetPlayers() do
			if accounts[p.UserId] and sessions[p] then
				table.insert(candidates, p)
				table.insert(onlineLoaded, p.UserId)
			end
		end
		-- Same stipend roster/timing and amounts as before; creature eligibility is separate.
		EggRewards:Reveal(completed, onlineLoaded, revealedAt)
		for _, p in candidates do
			deliverEggRewards(p)
			syncPlayer(p)
			publishEggResults(p)
		end
		syncRound()
		Feedback:FireAllClients("Reveal", specimenId, completed, revealedAt)
		task.delay(C.Completion.RevealSeconds, function()
			if C.Completion.AutoReset and round == completed and status == "Revealed" then
				nextExpedition()
			end
		end)
	end)
end
-- One frozen section settlement. This and transfers below never yield.
local function settleMaterials(data, target, impact, sequence)
	if data.settled then
		return
	end
	data.settled = true
	local layer = C.Layers[data.layer]
	for _, share in Materials.Allocate(data, layer.Yield) do
		local amount = share.base + share.bonus
		local recipient, account = writablePlayer(share.userId)
		if recipient then
			local _, _, cap = stats(account)
			drainPending(recipient, account, cap)
			Materials.Add(account.pendingMaterials, layer.Id, layer.Value * currentEgg.Value, amount)
			local delivered = drainPending(recipient, account, cap, true)
			if amount > 0 and account.introStage <= 2 then
				account.introStage = 3
			end
			syncPlayer(recipient)
			Feedback:FireClient(recipient, "Collected", amount, {
				RoundId = round,
				Sequence = sequence,
				SectionId = target.Name,
				ResourceId = layer.Id,
				ResourceName = layer.Name,
				Position = impact.Position,
				Delivered = delivered,
				Pending = amount - delivered,
				Base = share.base,
				Bonus = share.bonus,
			})
		elseif amount > 0 then
			local claims = serverClaims[share.userId] or {}
			Materials.Add(claims, layer.Id, layer.Value * currentEgg.Value, amount)
			serverClaims[share.userId] = claims
		end
	end
end
-- All tools share this atomic effective-damage/settlement path. No yield occurs here.
local function applyDamage(
	p,
	target,
	impact,
	damage,
	precise,
	critical,
	sequence,
	family,
	interval,
	secondary
)
	local data = sections[target]
	local a = accounts[p.UserId]
	local _, root2 = alive(p)
	if
		writablePlayer(p.UserId) ~= p
		or not a
		or not root2
		or not data
		or data.broken
		or data.permanent
		or data.layer ~= activeLayer
		or not target:GetAttribute("Exposed")
	then
		return false
	end
	local _, _, capacity = stats(a)
	if used(a) >= capacity or Materials.Count(a.pendingMaterials) > 0 then
		return false, "Capacity"
	end
	if type(damage) ~= "number" or damage ~= damage or damage <= 0 or damage == math.huge then
		return false
	end
	damage = math.min(data.hp, math.floor(damage + 0.5))
	if damage <= 0 then
		return false
	end
	data.hp -= damage
	local xp, beforeLevel, afterLevel = Progress.Credit(a, damage, currentEgg.Id)
	eggXP[p.UserId] = (eggXP[p.UserId] or 0) + xp
	a.progression.guards.lastDamageAt = workspace:GetServerTimeNow()
	if afterLevel > beforeLevel then
		local session = sessions[p]
		if session.levelReceipt then
			session.levelReceipt.after = afterLevel
		else
			local receipt = { before = beforeLevel, after = afterLevel }
			session.levelReceipt = receipt
			task.delay(0.5, function()
				if sessions[p] ~= session then
					return
				end
				session.levelReceipt = nil
				Feedback:FireClient(
					p,
					"LevelUp",
					receipt.before,
					receipt.after,
					Skills.Points(receipt.after) - Skills.Points(receipt.before)
				)
			end)
		end
	end
	Materials.Record(data, p.UserId, damage, toolLevel(a, "Yield"))
	eggDamage[p.UserId] = (eggDamage[p.UserId] or 0) + damage
	totalDamage += damage
	a.mining = eggDamage[p.UserId]
	State:SetAttribute("EffectiveDamage", totalDamage)
	target:SetAttribute("HP", data.hp)
	Feedback:FireAllClients(
		"Hit",
		p.UserId,
		impact.Position,
		C.Layers[data.layer].Color,
		target,
		sequence,
		damage,
		precise,
		critical,
		{
			RoundId = round,
			Normal = impact.Normal,
			Broken = data.hp <= 0,
			SectionId = target.Name,
			Family = family,
			Interval = interval,
			Secondary = secondary == true,
		}
	)
	if data.hp <= 0 then
		data.broken = true
		target:SetAttribute("Intact", false)
		removed += 1
		if random:NextNumber() < 0.01 then
			a.relics = (a.relics or 0) + 1
			Feedback:FireClient(p, "Notice", "RARE FIND / Ancient relic recovered for your room.")
		end
		a.cash += data.layer
		advance(p, "Break", 1)
		layerRemaining[data.layer] -= 1
		if data.layer == #C.Layers then
			deepRemoved += 1
			a.samples += 1
			a.cash += 3
			advance(p, "Sample", 1)
		end
		local fragment = {
			CFrame = data.part.CFrame,
			Normal = impact.Normal,
			SectionId = target.Name,
			RoundId = round,
			CollectorUserId = 0, -- shared break debris does not imply final-hit material ownership
			Size = data.part.Size,
			Center = target:GetAttribute("Center"),
			Template = string.format("L%d_R%02d", data.layer, target:GetAttribute("Row")),
		}
		expose(target, false)
		-- Contract credit is deliberately unchanged: the final hitter still receives
		-- the old base + their current Yield Collect credit, independent of material shares.
		advance(p, "Collect", C.Layers[data.layer].Yield + toolLevel(a, "Yield"))
		settleMaterials(data, target, impact, sequence)
		Feedback:FireAllClients(
			"Fragments",
			target:GetAttribute("Center"),
			impact.Position,
			data.layer,
			fragment
		)
		if data.layer == 1 then
			tutorial(p, "BreakShell")
			tutorial(p, "EquipBucket")
			tutorial(p, "Collect")
		end
		if layerRemaining[activeLayer] == 0 and activeLayer < #C.Layers then
			activeLayer += 1
			for section, info in sections do
				expose(section, info.layer == activeLayer and not info.broken)
			end
			Feedback:FireAllClients(
				"Notice",
				C.Layers[activeLayer].Name .. " unlocked - the previous layer is fully cleared."
			)
		end
		syncRound()
		completion()
	end
	syncPlayer(p)
	return true
end
local function eligible(target, layer)
	local data = typeof(target) == "Instance" and sections[target]
	return data
		and target.Parent == Sections
		and data.part.Parent == target
		and not data.broken
		and not data.permanent
		and data.layer == layer
		and target:GetAttribute("Exposed") == true
end
local function contact(p, target, point, grace)
	local ch, root, head = alive(p)
	if not ch or not finite(point) then
		return
	end
	local delta = point - head.Position
	if
		delta.Magnitude < 0.01
		or delta.Magnitude > C.Mining.Reach + grace
		or (point - root.Position).Magnitude > C.Mining.Reach + grace + 3
	then
		return
	end
	local hit = workspace:Raycast(head.Position, delta.Unit * (delta.Magnitude + 0.7), rayParams(ch))
	if hit and hit.Instance.Parent == target and (hit.Position - point).Magnitude <= 1.3 then
		return hit
	end
end
local function damageRoll(a, session, target, point, power, ordinary)
	local radius = ordinary and ({ [0] = 0.75, 1, 1.2 })[skill(a, "impact.steady_aim")] or C.Precision.Radius
	local precise = (point - target:GetAttribute("Center")).Magnitude <= radius
	local chain = precise and (session.lastTarget == target and session.precisionChain or 0) or 0
	local relay = session.relay
	if ordinary and relay then
		session.relay = nil -- the next ordinary hit consumes the offer, precise or not
		if
			precise
			and workspace:GetServerTimeNow() <= relay.untilTime
			and target ~= relay.target
			and sections[target].layer == relay.layer
			and (point - relay.position).Magnitude <= 4
		then
			chain = math.max(chain, relay.chain)
		end
	end
	chain = precise and math.min(chain + 1, C.Precision.MaxChain) or 0
	session.lastTarget, session.precisionChain = target, chain
	local multiplier = precise
			and C.Precision.Multiplier + toolLevel(a, "Precision") * C.Upgrades.Precision.Step + math.max(
				0,
				chain - 1
			) * C.Precision.ChainStep
		or 1
	local critical = random:NextNumber() < toolLevel(a, "Critical") * C.Upgrades.Critical.Step
	return power * multiplier * (critical and 1.5 or 1), precise, critical
end
-- Secondary target snapshot is made before primary mutation. No new exposure can enter it.
local function lightningSnapshot(p, primary, impact)
	local ch, _, head = alive(p)
	if not ch then
		return {}
	end
	local layer, origin = sections[primary].layer, impact.Position
	local chosen, seen, previous = {}, { [primary] = true }, impact
	for _ = 1, 2 do
		local candidates = {}
		for section in sections do
			if not seen[section] and eligible(section, layer) then
				local center = section:GetAttribute("Center")
				local distance = (center - previous.Position).Magnitude
				if distance <= 4 and (center - origin).Magnitude <= 6 then
					local from = previous.Position + previous.Normal * 0.35
					local delta = center - from
					local ray = delta.Magnitude > 0.01
						and workspace:Raycast(from, delta.Unit * (delta.Magnitude + 0.7), rayParams(ch))
					local sight = ray and ray.Position - head.Position
					local visible = sight
						and sight.Magnitude > 0.01
						and sight.Magnitude <= C.Mining.Reach + 6
						and workspace:Raycast(
							head.Position,
							sight.Unit * (sight.Magnitude + 0.7),
							rayParams(ch)
						)
					if
						ray
						and ray.Instance.Parent == section
						and visible
						and visible.Instance.Parent == section
						and (ray.Position - previous.Position).Magnitude <= 4
						and (ray.Position - origin).Magnitude <= 6
					then
						table.insert(
							candidates,
							{ section = section, impact = ray, distance = distance, layer = layer }
						)
					end
				end
			end
		end
		table.sort(candidates, function(a, b)
			if a.distance == b.distance then
				return a.section.Name < b.section.Name
			end
			return a.distance < b.distance
		end)
		local item = candidates[1]
		if not item then
			break
		end
		table.insert(chosen, item)
		seen[item.section] = true
		previous = item.impact
	end
	return chosen
end
local function flowMultiplier(p, a, session, interval, now)
	local rank = skill(a, "technique.core_drill")
	if rank == 0 then
		return 1
	end
	local flow = session.flow or { build = 0, last = now }
	session.flow = flow
	if flow.boostUntil and now >= flow.boostUntil then
		flow.boostUntil = nil
		flow.build = 0
		flow.last = now
	end
	if flow.readyUntil and now > flow.readyUntil then
		flow.readyUntil = nil
		flow.build = 0
		flow.last = now
	end
	if flow.readyUntil then
		flow.boostUntil = now + 3
		flow.readyUntil = nil
		flow.build = 0
	end
	local multiplier = flow.boostUntil and (rank == 1 and 1.25 or 1.35) or 1
	if not flow.boostUntil then
		local elapsed = now - flow.last
		if elapsed > 2 then
			flow.build = 0
		else
			flow.build += math.min(interval, math.max(0, elapsed))
		end
		if flow.build >= 4 then
			flow.build = 4
			flow.readyUntil = now + 4
		end
	end
	flow.last = now
	p:SetAttribute("FlowBuild", flow.build)
	p:SetAttribute("FlowReadyUntil", flow.readyUntil or 0)
	p:SetAttribute("FlowUntil", flow.boostUntil or 0)
	p:SetAttribute("FlowLastContact", now)
	return multiplier
end
local function afterRoot(p, a, session)
	local now = workspace:GetServerTimeNow()
	local _, _, cap = stats(a)
	local guards = a.progression.guards
	if
		a.progression.saleLatch
		and skill(a, "collection.sale_latch") > 0
		and used(a) >= cap
		and now <= (session.inputUntil or 0)
		and now - (guards.lastDamageAt or 0) <= 3
		and now >= (guards.latchUntil or 0)
	then
		guards.latchUntil = now + 8
		sellLoads(p, 1, true) -- once after the entire root, never between blast/arc targets
	end
end
local function ordinaryHit(p, a, session, target, impact, power, sequence, family, interval, charged)
	local now = workspace:GetServerTimeNow()
	local guards = a.progression.guards
	local window = math.floor(now / 4)
	local opportunity = not charged
		and skill(a, "technique.chain_lightning") > 0
		and guards.lastWindow ~= window
	local neighbors = opportunity and now >= (guards.lightningUntil or 0) and lightningSnapshot(
		p,
		target,
		impact
	) or {}
	local relayWasReady = session.relay ~= nil
	local damage, precise, critical = damageRoll(a, session, target, impact.Position, power, not charged)
	if relayWasReady and not charged then
		Feedback:FireClient(p, "PrecisionRelay", impact.Position, 0)
	end
	-- All eligibility/capacity checks ran before this non-yielding path; only positive HP advances Flow.
	local _, _, cap = stats(a)
	if used(a) >= cap or Materials.Count(a.pendingMaterials) > 0 or not eligible(target, activeLayer) then
		return false
	end
	if charged then
		damage *= 1.6
	elseif family == "Drill" then
		damage *= flowMultiplier(p, a, session, interval, now)
	end
	local layer = sections[target].layer
	local ok = applyDamage(p, target, impact, damage, precise, critical, sequence, family, interval)
	if not ok then
		return false
	end
	if
		status == "Excavating"
		and not charged
		and sections[target].broken
		and skill(a, "technique.precision_relay") > 0
		and (session.precisionChain or 0) > 0
		and now >= (guards.relayUntil or 0)
	then
		guards.relayUntil = now + 6
		session.relay = {
			target = target,
			layer = layer,
			position = impact.Position,
			chain = session.precisionChain,
			untilTime = now + (skill(a, "technique.precision_relay") == 1 and 3 or 5),
		}
		Feedback:FireClient(p, "PrecisionRelay", impact.Position, session.relay.untilTime)
	end
	if opportunity then
		guards.lastWindow = window
		if now >= (guards.lightningUntil or 0) and random:NextNumber() < 0.25 then
			guards.lightningUntil = now + 8
			local points = { impact.Position }
			for index, item in neighbors do
				-- No replacement for disappeared candidates; range, life, capacity rechecked.
				local ch, _, head = alive(p)
				if
					status == "Excavating"
					and ch
					and eligible(item.section, layer)
					and (head.Position - item.impact.Position).Magnitude <= C.Mining.Reach + 6
				then
					local applied = applyDamage(
						p,
						item.section,
						item.impact,
						power * (index == 1 and 0.8 or 0.5),
						false,
						false,
						sequence,
						family,
						interval,
						true
					)
					if applied then
						table.insert(points, item.impact.Position)
					end
				end
			end
			Feedback:FireAllClients("SkillLightning", p.UserId, round, sequence, points)
		end
	end
	afterRoot(p, a, session)
	return true
end
local function blast(p, placement, sequence, interval)
	local cfg, layer = C.Tools.Explosive, placement.layer
	local target, impact = placement.target, placement.impact
	local origin = impact.Position + impact.Normal * 1
	local ch, _, head = alive(p)
	local candidates = {}
	-- Snapshot eligibility and all visibility rays BEFORE any damage or exposure changes.
	for section, data in sections do
		if eligible(section, layer) then
			local center = section:GetAttribute("Center")
			local distance = section == target and 0 or (center - impact.Position).Magnitude
			if distance <= cfg.Radius then
				local delta = center - origin
				local ray = section == target and impact
					or (
						delta.Magnitude > 0.01
						and workspace:Raycast(origin, delta.Unit * (delta.Magnitude + 0.7), rayParams(ch))
					)
				local sight = ray and ray.Position - head.Position
				local visible = sight
					and sight.Magnitude > 0.01
					and sight.Magnitude <= C.Mining.Reach + cfg.Radius
					and workspace:Raycast(head.Position, sight.Unit * (sight.Magnitude + 0.7), rayParams(ch))
				local surfaceDistance = ray and (ray.Position - impact.Position).Magnitude
				if
					ray
					and ray.Instance.Parent == section
					and visible
					and visible.Instance.Parent == section
					and surfaceDistance <= cfg.Radius
				then
					table.insert(candidates, { section = section, impact = ray, distance = surfaceDistance })
				end
			end
		end
	end
	table.sort(candidates, function(a, b)
		if a.distance == b.distance then
			return a.section.Name < b.section.Name
		end
		return a.distance < b.distance
	end)
	local centerDamage, precise, critical = placement.damage, placement.precise, placement.critical
	local applied, limited = 0, 0
	Feedback:FireAllClients("Blast", p.UserId, sequence, impact.Position, impact.Normal, round)
	for i = 1, math.min(#candidates, cfg.MaxSections) do
		local item = candidates[i]
		local falloff = 1 - (1 - cfg.EdgeMultiplier) * item.distance / cfg.Radius
		local ok, reason = applyDamage(
			p,
			item.section,
			item.impact,
			centerDamage * falloff,
			precise,
			critical,
			sequence,
			"Explosive",
			interval
		)
		if ok then
			applied += 1
		elseif reason == "Capacity" then
			limited += 1
		end
	end
	if limited > 0 then
		note(
			p,
			string.format(
				"Blast: %d sections hit; %d skipped for bucket space. SELL to make room.",
				applied,
				limited
			)
		)
	end
end
local function strike(p, target, point, requestRound, sequence, charged)
	if
		typeof(sequence) ~= "number"
		or sequence ~= sequence
		or sequence < 1
		or sequence > 2147483647
		or sequence % 1 ~= 0
	then
		return
	end
	local session, a = sessions[p], accounts[p.UserId]
	if
		not session
		or not a
		or not alive(p)
		or session.training
		or not equipped(p, "Pickaxe")
		or requestRound ~= round
		or status ~= "Excavating"
		or not State:GetAttribute("Ready")
		or not eligible(target, activeLayer)
	then
		return
	end
	local family = effectiveTool(a)
	local guards = a.progression.guards
	local serverNow = workspace:GetServerTimeNow()
	if session.blocking or serverNow < (guards.nextAttackAt or 0) then
		return
	end
	if
		charged
		and (
			family ~= "Pickaxe"
			or skill(a, "impact.charged_swing") == 0
			or not table.find(a.progression.loadout, "impact.charged_swing")
			or serverNow < (guards.chargedUntil or 0)
		)
	then
		note(p, "Charged Swing needs an equipped skill slot, pickaxe, and a ready 8s cooldown.")
		return
	end
	local attackTool = session.tools.Pickaxe
	if attackTool:GetAttribute("ToolFamily") ~= family then
		return
	end
	local power, cd, capacity = stats(a)
	if writablePlayer(p.UserId) ~= p then
		return
	end
	drainPending(p, a, capacity)
	if used(a) >= capacity or Materials.Count(a.pendingMaterials) > 0 then
		if os.clock() - (session.fullNotice or 0) > 2 then
			session.fullNotice = os.clock()
			note(p, "Bucket full or earned materials pending. Tap SELL to make room.")
		end
		return
	end
	local now = os.clock()
	if
		session.pending
		or sequence <= (session.lastSequence or 0)
		or now - session.lastStrike < cd - 0.035
	then
		return
	end
	local hit = contact(p, target, point, 0.5)
	if not hit then
		return
	end
	point = hit.Position
	session.lastSequence, session.lastStrike = sequence, math.max(now, session.lastStrike + cd)
	session.attack = (session.attack or 0) + 1
	local token = session.attack
	guards.nextAttackAt = serverNow + cd - 0.035
	guards.lastMiningAt = serverNow
	if charged then
		guards.chargedUntil = serverNow + 8
		p:SetAttribute("ChargedUntil", guards.chargedUntil)
	end
	if family == "Drill" then
		-- One validated immediate tick per request. There is no delayed/overlapping drill loop.
		ordinaryHit(p, a, session, target, hit, power, sequence, family, cd, false)
		return true
	end
	local windup = charged and 0.45
		or family == "Explosive" and C.Tools.Explosive.Fuse
		or cd
			* (C.Animation.Anticipation + C.Animation.Acceleration)
			/ (C.Animation.Anticipation + C.Animation.Acceleration + C.Animation.Recoil + C.Animation.Recovery)
	local placement = {
		token = token,
		target = target,
		tool = attackTool,
		round = round,
		layer = activeLayer,
		impact = { Position = hit.Position, Normal = hit.Normal, Instance = hit.Instance },
	}
	if family == "Explosive" then
		placement.damage, placement.precise, placement.critical = damageRoll(a, session, target, point, power)
	end
	session.pending = placement
	Feedback:FireAllClients(
		"Windup",
		p.UserId,
		charged
				and (0.45 / (C.Animation.Anticipation + C.Animation.Acceleration) * (C.Animation.Anticipation + C.Animation.Acceleration + C.Animation.Recoil + C.Animation.Recovery))
			or family == "Explosive" and windup
			or cd,
		sequence,
		point,
		attackTool
	)
	if family == "Explosive" then
		Feedback:FireAllClients(
			"Charge",
			p.UserId,
			sequence,
			point,
			hit.Normal,
			round,
			workspace:GetServerTimeNow()
		)
	end
	task.delay(windup, function()
		if sessions[p] ~= session or session.attack ~= token then
			return
		end
		session.pending = nil
		if
			not equipped(p, "Pickaxe")
			or session.tools.Pickaxe ~= attackTool
			or requestRound ~= round
			or session.training
			or status ~= "Excavating"
			or not State:GetAttribute("Ready")
			or effectiveTool(a) ~= family
			or not alive(p)
			or writablePlayer(p.UserId) ~= p
		then
			Feedback:FireAllClients("ChargeCancel", p.UserId, sequence)
			Feedback:FireClient(p, "Miss", sequence)
			return
		end
		if family == "Explosive" then
			-- Validated placement survives destruction of its original plate. Do not
			-- raycast that plate again or substitute the newly exposed layer.
			blast(p, placement, sequence, cd)
			afterRoot(p, a, session)
		else
			local impact = eligible(target, activeLayer) and contact(p, target, point, C.Mining.ImpactGrace)
			if not impact then
				Feedback:FireClient(p, "Miss", sequence)
				return
			end
			if not ordinaryHit(p, a, session, target, impact, power, sequence, family, cd, charged) then
				Feedback:FireClient(p, "Miss", sequence)
			end
		end
	end)
	return true
end
local terminalByAction = {
	Sell = "SellTerminal",
	Power = "PowerTerminal",
	Speed = "SpeedTerminal",
	Capacity = "CapacityTerminal",
	NextRound = "NextTerminal",
}
local function purchase(p, key, quantity)
	if writablePlayer(p.UserId) ~= p then
		return
	end
	if trials[accounts[p.UserId]] then
		note(p, "Finish your drill trial before buying upgrades.")
		return
	end
	local a = accounts[p.UserId]
	local config = a and Rules.ToolConfig(effectiveTool(a), C)
	local u = config and config.Upgrades[key]
	if not a or not u or not alive(p) then
		return
	end
	if quantity ~= 1 and quantity ~= 5 and quantity ~= "Max" then
		return
	end
	local count, cost = Economy.Quote(key, a[key], a.cash, quantity, config)
	if count == 0 then
		note(
			p,
			a[key] >= u.MaxLevel and "Upgrade complete."
				or "Need $" .. Economy.Price(key, a[key], config) .. " for the next level."
		)
		return
	end
	a.cash -= cost
	a[key] += count
	a.toolLevels[a.toolId] = a.toolLevels[a.toolId] or {}
	a.toolLevels[a.toolId][key] = a[key]
	advance(p, "Upgrade", count)
	tutorial(p, "AtUpgrade")
	syncPlayer(p)
	Feedback:FireClient(p, "UpgradeBought", key, count)
end
sellLoads = function(p, maximum, automatic)
	if writablePlayer(p.UserId) ~= p or not alive(p) or not Depot:FindFirstChild("SellTerminal") then
		return
	end
	local a = accounts[p.UserId]
	local totalValue, moved = 0, 0
	local loads = {}
	for _ = 1, maximum do
		local value = math.floor(a.materialValue * (1 + toolLevel(a, "Value") * C.Upgrades.Value.Step) + 0.5)
		if value <= 0 then
			break
		end
		table.insert(loads, { credits = value, units = used(a) })
		tutorial(p, "AtDepot")
		for _, l in C.Layers do
			a.contents[l.Id] = 0
		end
		a.materialValue = 0
		if a.introStage <= 3 then
			a.introStage = 4
		end
		a.cash += value
		a.income += value
		totalValue += value
		advance(p, "Sell", 1)
		tutorial(p, "Sell")
		local _, _, cap = stats(a)
		moved += drainPending(p, a, cap, true)
	end
	syncPlayer(p)
	if totalValue > 0 then
		Feedback:FireClient(p, "Sold", totalValue, moved, Materials.Count(a.pendingMaterials), loads)
	elseif not automatic then
		note(p, "Your bucket is empty.")
	end
end
local function station(p, action)
	if writablePlayer(p.UserId) ~= p then
		return
	end
	local ch = alive(p)
	local name = terminalByAction[action]
	local terminal = name and Depot:FindFirstChild(name)
	if not ch or not terminal then
		return
	end
	local a = accounts[p.UserId]
	if not a then
		return
	end
	if action == "Sell" then
		sellLoads(p, 1 + skill(a, "collection.batch_unload"), false)
	elseif action == "NextRound" then
		if status ~= "Revealed" then
			note(p, "Excavate more outer and deep sections to uncover the specimen.")
			return
		end
		if workspace:GetServerTimeNow() < readyAt then
			note(p, "Reveal in progress. Please wait.")
			return
		end
		nextExpedition()
	else
		purchase(p, action, 1)
	end
end
Action.OnServerEvent:Connect(function(p, kind, a, b, c, d)
	local s = sessions[p]
	if not s or typeof(kind) ~= "string" then
		return
	end
	local now = os.clock()
	-- Cancellation cannot be lost behind a full ordinary request budget. No damage/refund is granted.
	if kind == "InputHeld" then
		if typeof(a) == "boolean" and (not a or now - (s.lastHeldUpdate or -math.huge) >= 0.2) then
			s.lastHeldUpdate = now
			s.inputUntil = a and workspace:GetServerTimeNow() + 1.2 or 0
		end
		return
	end
	if (kind == "SkillMenu" or kind == "BlockingMenu") and typeof(a) == "boolean" then
		if kind == "SkillMenu" then
			s.skillMenu = a
		else
			s.menu = a
		end
		s.blocking = s.skillMenu or s.menu
		if s.blocking then
			cancelAttack(p, s)
		end
		return
	end
	if kind == "Cancel" or kind == "DrillStop" then
		s.attack = (s.attack or 0) + 1
		s.pending = nil
		s.flow, s.relay = nil, nil
		s.inputUntil = 0
		p:SetAttribute("FlowBuild", 0)
		p:SetAttribute("FlowUntil", 0)
		p:SetAttribute("FlowReadyUntil", 0)
		if now - (s.lastCancelBroadcast or -math.huge) >= 0.1 then
			s.lastCancelBroadcast = now
			Feedback:FireAllClients("Cancel", p.UserId)
		end
		return
	end
	if writablePlayer(p.UserId) ~= p then
		return
	end
	if now - (s.window or 0) >= 1 then
		s.window = now
		s.requests = 0
	end
	s.requests = (s.requests or 0) + 1
	if s.requests > 24 then
		return
	end
	if
		kind == "SkillPurchase"
		or kind == "SkillRespec"
		or kind == "SkillLoadout"
		or kind == "SkillToggle"
	then
		if now - (s.lastSkillRequest or -math.huge) < 0.25 then
			return
		end
		s.lastSkillRequest = now
		local account = accounts[p.UserId]
		local prog = account.progression
		local level = Skills.Level(prog.xpUnits / Skills.XPScale)
		local failure
		if not alive(p) or s.training then
			failure = "Finish training and use a living character."
		elseif kind == "SkillPurchase" then
			if typeof(a) ~= "string" or #a > 80 then
				return
			end
			failure = Skills.PurchaseReason(level, prog.ranks, a)
			if not failure then
				prog.ranks[a] = (prog.ranks[a] or 0) + 1
			end
		elseif kind == "SkillToggle" then
			if skill(account, "collection.sale_latch") == 0 then
				failure = "Learn Sale Latch first."
			elseif typeof(a) ~= "boolean" then
				return
			else
				prog.saleLatch = a
			end
		else
			local room = ownRoom(p)
			local _, root = alive(p)
			local floor = room and room:FindFirstChild("Floor")
			local localPos = floor and floor.CFrame:PointToObjectSpace(root.Position)
			local ceiling = room and room:FindFirstChild("Ceiling")
			local inside = localPos
				and math.abs(localPos.X) < floor.Size.X / 2 - 1
				and math.abs(localPos.Z) < floor.Size.Z / 2 - 1
				and localPos.Y >= 0
				and ceiling
				and root.Position.Y < ceiling.Position.Y
			if not inside then
				failure = "Go inside your own room to change your build."
			elseif
				s.pending
				or workspace:GetServerTimeNow()
						- math.max(prog.guards.lastDamageAt or 0, prog.guards.lastMiningAt or 0)
					< 10
			then
				failure = "Wait 10 seconds after mining, with no pending action."
			elseif kind == "SkillRespec" then
				if workspace:GetServerTimeNow() < (prog.guards.respecUntil or 0) then
					failure = "Free respec is available once every 60 seconds."
				else
					prog.ranks = {}
					prog.loadout = { "", "" }
					prog.saleLatch = false
					prog.guards.respecUntil = workspace:GetServerTimeNow() + 60
					cancelAttack(p, s)
				end
			else
				local slots = level >= 30 and 2 or level >= 5 and 1 or 0
				if typeof(a) ~= "number" or a % 1 ~= 0 or a < 1 or a > slots then
					failure = "That active slot is locked."
				elseif b ~= "" and (b ~= "impact.charged_swing" or skill(account, b) == 0) then
					failure = "Learn a supported active skill first."
				else
					for i = 1, 2 do
						if prog.loadout[i] == b then
							prog.loadout[i] = ""
						end
					end
					prog.loadout[a] = b
					cancelAttack(p, s)
				end
			end
		end
		syncPlayer(p)
		Feedback:FireClient(
			p,
			"SkillReceipt",
			not failure,
			failure or (kind == "SkillPurchase" and "Skill rank learned." or "Build updated."),
			a
		)
		return
	elseif kind == "EnterLab" then
		-- Compatibility no-op: player arrival never owns the server egg lifecycle.
		return
	elseif kind == "GuideSkip" then
		accounts[p.UserId].introStage = 5
		syncPlayer(p)
	elseif kind == "TutorialSkip" or kind == "TutorialReplay" then
		local account = accounts[p.UserId]
		account.tutorial = kind == "TutorialSkip" and 8 or 1
		syncPlayer(p)
		return
	elseif kind == "Home" or kind == "TryDrill" then
		if now - s.lastStation < 0.5 or not alive(p) then
			return
		end
		s.lastStation = now
		local account = accounts[p.UserId]
		if kind == "Home" then
			cancelAttack(p, s)
			training(p, s, false)
			local room = ownRoom(p)
			if room then
				p.Character:PivotTo(room.RoomSpawn.CFrame * CFrame.new(0, 3.5, 0))
			end
		else
			if account.ownedTools.Drill then
				note(p, "You already own the Helix Drill. Equip it in Tools.")
				return
			end
			if s.trialUsed or account.drillTrialUsed then
				note(p, "Your free drill trial has already been used. Unlock the drill to keep it.")
				return
			end
			training(p, s, false)
			s.trialUsed = true
			account.drillTrialUsed = true
			p:SetAttribute("DrillTrialUsed", true)
			trials[account] = os.clock() + 90
			trialSelected[account] = true
			p:SetAttribute("DrillTrialEndsAt", workspace:GetServerTimeNow() + 90)
			if account.introStage == 4 then
				account.introStage = 5
			end
			giveTools(p, p.Character, s)
			p.Character.Humanoid:EquipTool(s.tools.Pickaxe)
			Feedback:FireClient(p, "TrialStarted")
			note(p, "Helix Drill equipped for 90 seconds. Upgrades stay safe.")
			task.delay(90, function()
				if sessions[p] ~= s then
					trials[account] = nil
					trialSelected[account] = nil
					return
				end
				local wasUsingTrial = trialSelected[account] ~= false
				local retainDrill = trialSelected[account] ~= false and account.ownedTools.Drill
				if retainDrill then
					Rules.SwitchTool(account, "Drill")
				end
				trials[account] = nil
				trialSelected[account] = nil
				if sessions[p] == s then
					p:SetAttribute("DrillTrialEndsAt", nil)
					if p.Character and wasUsingTrial then
						giveTools(p, p.Character, s)
					end
					syncPlayer(p)
					note(
						p,
						account.ownedTools.Drill and "Trial complete. Your owned drill remains available."
							or "Trial complete. Unlock the Helix Drill when you are ready."
					)
				end
			end)
		end
		syncPlayer(p)
	elseif
		kind == "Tool"
		or kind == "BuyTool"
		or kind == "EquipTool"
		or kind == "Creature"
		or kind == "DisplayCreature"
		or kind == "RoomTheme"
		or kind == "Training"
	then
		if now - s.lastStation < 0.25 or not alive(p) then
			return
		end
		s.lastStation = now
		local account = accounts[p.UserId]
		if kind == "Tool" or kind == "BuyTool" or kind == "EquipTool" then
			if typeof(a) ~= "string" or not Rules.Tools[a] or not Kit:FindFirstChild("Starter" .. a) then
				return
			end
			local buying = kind == "BuyTool" or (kind == "Tool" and not account.ownedTools[a])
			if buying then
				if account.ownedTools[a] then
					syncPlayer(p)
					return
				end
				if account.cash < Rules.Tools[a].Cost then
					note(p, "Not enough credits to unlock this tool.")
					return
				end
				account.cash -= Rules.Tools[a].Cost
				account.ownedTools[a] = true
				syncPlayer(p)
				note(p, Rules.Tools[a].Name .. " unlocked. Select it from your toolbelt.")
				return
			end
			local trial = a == "Drill" and trials[account] and trials[account] > now
			if not account.ownedTools[a] and not trial then
				return
			end
			training(p, s, false)
			if not account.ownedTools[a] then
				trialSelected[account] = true
			else
				trialSelected[account] = false
				Rules.SwitchTool(account, a)
			end
			if a == "Drill" and account.introStage == 4 then
				account.introStage = 5
			end
			cancelAttack(p, s)
			giveTools(p, p.Character, s)
		elseif kind == "DisplayCreature" then
			if not require(Shared.CollectionSlots).Assign(account.displaySlots, account.creatures, a, b) then
				return
			end
		elseif kind == "Creature" then
			if typeof(a) ~= "string" or not Rules.Creature(a) or (account.creatures[a] or 0) < 1 then
				return
			end
			account.equippedCreature = a
		elseif kind == "RoomTheme" then
			if typeof(a) ~= "string" then
				return
			end
			for _, theme in Rules.RoomThemes do
				if theme.Id == a then
					if not account.roomThemes[a] then
						if account.cash < theme.Cost then
							note(p, "Not enough credits for this room theme.")
							return
						end
						account.cash -= theme.Cost
						account.roomThemes[a] = true
					end
					account.roomTheme = a
				end
			end
		elseif kind == "Training" then
			if not training(p, s, not s.training) then
				note(p, "Use the training machine inside your own room.")
			end
		end
		syncPlayer(p)
	elseif kind == "Swing" then
		if typeof(a) ~= "number" or a ~= a or a % 1 ~= 0 or a < 1 or a > 2147483647 then
			return
		end
		if
			not alive(p)
			or not equipped(p, "Pickaxe")
			or effectiveTool(accounts[p.UserId]) ~= "Pickaxe"
			or s.training
			or s.pending
			or status ~= "Excavating"
			or a <= (s.lastSequence or 0)
		then
			return
		end
		local _, cooldown = stats(accounts[p.UserId])
		if now - s.lastStrike < cooldown then
			return
		end
		s.lastStrike, s.lastSequence = now, a
		Feedback:FireAllClients("Windup", p.UserId, cooldown, a, nil, s.tools.Pickaxe)
	elseif kind == "Mine" or kind == "ChargedMine" then
		if now - s.lastRequest < 0.08 then
			return
		end
		s.lastRequest = now
		local accepted = strike(p, a, b, c, d, kind == "ChargedMine")
		if
			not accepted
			and typeof(d) == "number"
			and d == d
			and d >= 1
			and d <= 2147483647
			and d % 1 == 0
		then
			Feedback:FireClient(p, "Miss", d)
		end
	elseif kind == "Upgrade" then
		if typeof(a) ~= "string" or not C.Upgrades[a] or now - s.lastStation < 0.20 then
			return
		end
		s.lastStation = now
		purchase(p, a, b)
	elseif terminalByAction[kind] then
		if now - s.lastStation < 0.25 then
			return
		end
		s.lastStation = now
		station(p, kind)
	end
end)
for _, desc in Depot:GetDescendants() do
	if desc:IsA("ProximityPrompt") then
		desc.Triggered:Connect(function(p)
			local s = sessions[p]
			if not s or os.clock() - s.lastStation < 0.25 then
				return
			end
			s.lastStation = os.clock()
			if C.Upgrades[desc.Name] then
				Feedback:FireClient(p, "OpenShop", desc.Name)
			else
				station(p, desc.Name)
			end
		end)
	end
end
giveTools = function(p, ch, s)
	local backpack = p:WaitForChild("Backpack", 15)
	local human = ch:WaitForChild("Humanoid", 15)
	if not backpack or not human or sessions[p] ~= s or p.Character ~= ch then
		return
	end
	cancelAttack(p, s)
	if s.deathConnection then
		s.deathConnection:Disconnect()
	end
	s.deathConnection = human.Died:Connect(function()
		if sessions[p] == s then
			cancelAttack(p, s)
		end
	end)
	human:UnequipTools()
	for _, old in s.tools do
		old:Destroy()
	end
	s.tools = {}
	for kind, name in { Pickaxe = "StarterPickaxe" } do
		local a = accounts[p.UserId]
		local template = Kit:FindFirstChild("Starter" .. effectiveTool(a)) or Kit[name]
		local t = template:Clone()
		t.Name = Rules.Tools[effectiveTool(a)].Name
		t:SetAttribute("ToolFamily", effectiveTool(a))
		t:SetAttribute("ToolKind", kind)
		t:SetAttribute("OwnerUserId", p.UserId)
		if effectiveTool(a) == "Pickaxe" then
			t.Grip = Clips.PickaxeGrip
			local tip = t:FindFirstChild("StrikeTip", true)
			if tip and tip:IsA("Attachment") then
				tip.Position = Clips.PickaxeStrikeTip
			end
		end
		s.tools[kind] = t
		t.Equipped:Connect(function()
			if sessions[p] == s then
				tutorial(p, "Equip" .. kind)
			end
		end)
		t.Unequipped:Connect(function()
			if sessions[p] ~= s or s.tools[kind] ~= t then
				return
			end
			cancelAttack(p, s)
		end)
		t.Parent = backpack
		if human.Health > 0 then
			human:EquipTool(t)
		end
	end
	syncPlayer(p)
end
local function joined(p)
	if sessions[p] then
		return
	end
	p:SetAttribute("ProfileReady", false)
	local loaded = Profiles.Load(p)
	if not loaded then
		p:Kick(
			p:GetAttribute("ProfileLoadError")
				or "Your research is still saving or unavailable. Please reconnect shortly."
		)
		return
	end
	if p.Parent ~= Players then
		Profiles.Save(p, loaded, true)
		return
	end
	if loaded.tutorial == 3 or loaded.tutorial == 4 then
		loaded.tutorial = 5
	end
	accounts[p.UserId] = loaded
	local retained = serverSkillGuards[p.UserId]
	if retained then
		for key, value in retained do
			loaded.progression.guards[key] = math.max(value, loaded.progression.guards[key] or 0)
		end
	end
	serverSkillGuards[p.UserId] = loaded.progression.guards

	local s = {
		tools = {},
		lastStrike = -math.huge,
		lastCollect = -math.huge,
		lastRequest = -math.huge,
		lastStation = -math.huge,
	}
	sessions[p] = s
	-- Transfer once, into the newly locked loaded profile; never write an offline profile.
	local claims = serverClaims[p.UserId]
	if claims and writablePlayer(p.UserId) == p then
		local claimed = Materials.Count(claims)
		local _, _, cap = stats(loaded)
		drainPending(p, loaded, cap, true)
		for _, entry in claims do
			Materials.Add(loaded.pendingMaterials, entry.id, entry.unitValue, entry.units)
		end
		serverClaims[p.UserId] = nil
		local delivered = drainPending(p, loaded, cap, true)
		p:SetAttribute("RecoveredMaterialClaim", claimed)
		p:SetAttribute("RecoveredMaterialDelivered", delivered)
		p:SetAttribute("RecoveredMaterialPending", claimed - delivered)
	end
	loaded.mining = eggDamage[p.UserId] or 0
	EggRewards:IncludeSpectator(round, p.UserId)
	p:SetAttribute("RecoveredEggCreatures", deliverEggRewards(p))
	publishEggResults(p)
	s.connection = p.CharacterAdded:Connect(function(ch)
		training(p, s, false)
		giveTools(p, ch, s)
	end)
	syncPlayer(p)
	p:SetAttribute("ProfileReady", true)
	if p.Character then
		task.spawn(giveTools, p, p.Character, s)
	end
end
for _, s in Sections:GetChildren() do
	local li = s:GetAttribute("Layer")
	if li and C.Layers[li] then
		local p = s:FindFirstChild("Plate") or Dormant:FindFirstChild(s.Name)
		assert(p, "Missing plate " .. s.Name)
		local permanent = (s:GetAttribute("Row") or 0) < C.Geometry.PermanentRows
		s:SetAttribute("Permanent", permanent)
		sections[s] =
			{ layer = li, hp = C.Layers[li].Durability, broken = false, part = p, permanent = permanent }
		if not permanent then
			total += 1
			layerTotals[li] = (layerTotals[li] or 0) + 1
		end
	end
end
Piles:ClearAllChildren()
Players.PlayerAdded:Connect(joined)
Players.PlayerRemoving:Connect(function(p)
	local s = sessions[p]
	if s then
		training(p, s, false)
		s.connection:Disconnect()
		if s.deathConnection then
			s.deathConnection:Disconnect()
		end
		for _, t in s.tools do
			t:Destroy()
		end
		sessions[p] = nil
	end
	local a = accounts[p.UserId]
	if a then
		trials[a] = nil
		trialSelected[a] = nil
		if accounts[p.UserId] == a then
			accounts[p.UserId] = nil
		end
		Profiles.Save(p, a, true)
	end
end)
beginRound()
for _, p in Players:GetPlayers() do
	task.spawn(joined, p)
end

-- Session-backed tutorial progress; replace account persistence at this boundary later.
task.spawn(function()
	while true do
		task.wait(0.5)
		for p in sessions do
			local ch, root = alive(p)
			if ch then
				if (root.Position - Depot.SellTerminal.Position).Magnitude <= C.StationRange then
					tutorial(p, "AtDepot")
				end
				for _, key in { "Power", "Speed", "Capacity" } do
					if (root.Position - Depot[key .. "Terminal"].Position).Magnitude <= 8 then
						tutorial(p, "AtUpgrade")
					end
				end
			end
		end
	end
end)

task.spawn(function()
	while true do
		task.wait(60)
		for p in sessions do
			local a = accounts[p.UserId]
			if a then
				task.spawn(Profiles.Save, p, a, false)
			end
		end
	end
end)
game:BindToClose(function()
	shuttingDown = true
	for p, session in sessions do
		cancelAttack(p, session)
	end
	local pending = 0
	for p in sessions do
		local a = accounts[p.UserId]
		if a then
			pending += 1
			task.spawn(function()
				Profiles.Save(p, a, true)
				pending -= 1
			end)
		end
	end
	local deadline = os.clock() + 25
	while pending > 0 and os.clock() < deadline do
		task.wait(0.1)
	end
end)

task.spawn(function()
	while true do
		task.wait(0.25)
		for p, session in sessions do
			if session.training then
				local _, root = alive(p)
				local a = accounts[p.UserId]
				local device = practiceFor(p)
				if
					not root
					or not device
					or not a
					or not session.trainingHumanoid
					or session.trainingHumanoid.Health <= 0
					or not session.tools.Pickaxe
					or session.tools.Pickaxe.Parent ~= p.Character
					or (root.Position - device.TrainingSpot.Position).Magnitude > 10
				then
					training(p, session, false)
				else
					local completed = math.floor(
						(workspace:GetServerTimeNow() - session.trainingStarted) / TrainingCycle.Duration
					)
					if completed <= session.trainingAward then
						continue
					end
					local earned = completed - session.trainingAward
					session.trainingAward = completed
					a.strength = math.min(10000, a.strength + earned)
					if a.introStage == 1 then
						a.introStage = 2
					end
					syncPlayer(p)
					Feedback:FireClient(p, "TrainingPulse", a.strength)
					if a.strength >= 10000 then
						training(p, session, false)
					end
				end
			end
		end
	end
end)
for _, room in workspace.VesperLab.Rooms:GetChildren() do
	local device = room:FindFirstChild("TrainingStation")
	local prompt = device and device:FindFirstChild("TrainStrength", true)
	if prompt then
		prompt.Triggered:Connect(function(p)
			local s = sessions[p]
			if not s or os.clock() - s.lastStation < 0.3 or room:GetAttribute("OwnerUserId") ~= p.UserId then
				return
			end
			s.lastStation = os.clock()
			training(p, s, not s.training)
		end)
	end
end
local workshop = workspace.VesperLab:FindFirstChild("SharedWorkshop")
for _, entry in require(script.Parent.RoomTerminals).Build(workspace.VesperLab.Rooms) do
	local function updateOwner()
		entry.display.Panel.Owner.Text = entry.room:GetAttribute("OwnerDisplayName") or "AWAITING ROOM OWNER"
	end
	entry.room:GetAttributeChangedSignal("OwnerDisplayName"):Connect(updateOwner)
	updateOwner()
	entry.prompt.Triggered:Connect(function(p)
		local s = sessions[p]
		local _, root = alive(p)
		if
			not s
			or not root
			or entry.room:GetAttribute("OwnerUserId") ~= p.UserId
			or os.clock() - s.lastStation < 0.3
			or (root.Position - entry.terminal.Position).Magnitude > 12
		then
			return
		end
		s.lastStation = os.clock()
		training(p, s, false)
		Feedback:FireClient(p, "OpenShop", entry.page)
	end)
end
if workshop then
	for _, entry in { { "Console", "TOOLS" }, { "UpgradeConsole", "RIG" } } do
		local terminal = workshop:FindFirstChild(entry[1])
		local prompt = terminal and terminal:FindFirstChildOfClass("ProximityPrompt")
		if prompt then
			prompt.Triggered:Connect(function(p)
				local s = sessions[p]
				local _, root = alive(p)
				if
					not s
					or not root
					or os.clock() - s.lastStation < 0.3
					or (root.Position - terminal.Position).Magnitude > 14
				then
					return
				end
				s.lastStation = os.clock()
				training(p, s, false)
				Feedback:FireClient(p, "OpenShop", entry[2])
			end)
		end
	end
end
