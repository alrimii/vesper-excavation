-- Sole authority: mining, direct bucket awards, sales and purchases.
local Players = game:GetService("Players")
local Shared = game.ReplicatedStorage:WaitForChild("VesperShared")
require(script.Parent:WaitForChild("ProgressiveFractureBuilder")).Prepare(Shared)
local C = require(Shared:WaitForChild("ExcavationConfig"))
local Economy = require(Shared.UpgradeEconomy)
local Rules = require(Shared.ProgressionRules)
local TrainingCycle = require(Shared.TrainingCycle)
local Delivery = require(Shared.DeliverySequence)
local giveTools
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
		s.attack = (s.attack or 0) + 1
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
local initialDeliveryPending = true
local random = Random.new()
local Catalog = require(Shared:WaitForChild("DiscoveryCatalog"))
local Profiles = require(script.Parent.ResearchProfiles)
local Action = Shared.Remotes:WaitForChild("Action")
local Feedback = Shared.Remotes:WaitForChild("Feedback")
local State = Shared:WaitForChild("RoundState")
local Piles = Shared:WaitForChild("ResourcePiles")
local Egg = workspace.VesperLab.Egg
local Sections = Egg.Sections
local Dormant = game.ServerStorage:WaitForChild("EggDormant")
local Depot = workspace.VesperLab.ResourceDepot
local Kit = game.ServerStorage.VesperKit
local sessions, accounts, sections = {}, {}, {}
local total, removed, deepRemoved = 0, 0, 0
local activeLayer = 1
local layerRemaining = {}
local layerTotals = {}
local round, status, readyAt = 0, "Excavating", 0
local specimenId = "lumen"
local contributors = {}
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
	return math.floor((config.Mining.Power + a.Power * config.Upgrades.Power.Step) * Rules.PowerBonus(a)),
		math.max(config.Mining.MinimumCooldown, config.Mining.Cooldown - a.Speed * config.Upgrades.Speed.Step),
		C.Collection.Capacity + a.Capacity * config.Upgrades.Capacity.Step
end
local function used(a)
	local n = 0
	for _, l in C.Layers do
		n += a.contents[l.Id] or 0
	end
	return n
end
local function price(a, key)
	return Economy.Price(key, a[key], Rules.ToolConfig(effectiveTool(a), C))
end
local function syncPlayer(p)
	local a = accounts[p.UserId]
	if not a then
		return
	end
	local power, cd, cap = stats(a)
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
			MiningContribution = a.mining,
			CollectionIncome = a.income,
			BucketUsed = used(a),
			BucketCapacity = cap,
			StrikePower = power,
			StrikeCooldown = cd,
			YieldBonus = a.Yield,
			SaleMultiplier = 1 + a.Value * C.Upgrades.Value.Step,
			BucketBaseValue = a.materialValue,
			PrecisionMultiplier = C.Precision.Multiplier + a.Precision * C.Upgrades.Precision.Step,
			CriticalChance = a.Critical * C.Upgrades.Critical.Step,
		}
	do
		p:SetAttribute(k, v)
	end
	for _, l in C.Layers do
		p:SetAttribute("Bucket_" .. l.Id, a.contents[l.Id] or 0)
	end
	for key, u in config.Upgrades do
		p:SetAttribute(key .. "Level", a[key])
		p:SetAttribute(key .. "Price", a[key] < u.MaxLevel and price(a, key) or -1)
	end
	p:SetAttribute("ResearchXP", a.xp)
	p:SetAttribute("ResearchLevel", Catalog.Level(a.xp))
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
		a.xp += 30
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
	contributors = {}
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
	accessEnabled(true)
	transitioning = false
end
local function nextExpedition(selectedEgg)
	if transitioning then
		return
	end
	transitioning = true
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
	status = "Hatching"
	readyAt = workspace:GetServerTimeNow() + 2.2 + C.Completion.RevealSeconds
	State:SetAttribute("PhaseStartedAt", workspace:GetServerTimeNow())
	local completed = round
	syncRound()
	task.delay(2.2, function()
		if round ~= completed or status ~= "Hatching" then
			return
		end
		status = "Revealed"
		State:SetAttribute("PhaseStartedAt", workspace:GetServerTimeNow())
		local candidates = {}
		for _, p in Players:GetPlayers() do
			if accounts[p.UserId] and sessions[p] then
				table.insert(candidates, p)
			end
		end
		local winner, creature
		-- Earned-only draw. Paid luck is deliberately disabled until configured and policy checked.
		if #candidates > 0 and random:NextNumber() < currentEgg.DropChance then
			winner = candidates[random:NextInteger(1, #candidates)]
			creature = Rules.Choose(Rules.CreatureVariants, random)
			local a = accounts[winner.UserId]
			a.creatures[creature.Id] = (a.creatures[creature.Id] or 0) + 1
			a.discoveries.crownback = (a.discoveries.crownback or 0) + 1
			if a.equippedCreature == "" then
				a.equippedCreature = creature.Id
			end
		end
		State:SetAttribute("LastWinner", winner and winner.DisplayName or "")
		State:SetAttribute("LastCreature", creature and creature.Name or "")
		for _, p in candidates do
			local a = accounts[p.UserId]
			if contributors[p.UserId] then
				local reward = math.floor(250 * currentEgg.Value)
				a.cash += reward
				a.xp += 100
			end
			syncPlayer(p)
		end
		syncRound()
		Feedback:FireAllClients("Reveal", specimenId)
		-- One immutable personal receipt; displaying it never grants rewards again.
		for _, p in candidates do
			p:SetAttribute(
				"LastExpeditionResult",
				game:GetService("HttpService"):JSONEncode({
					round = completed,
					revealedAt = State:GetAttribute("PhaseStartedAt"),
					nextAt = readyAt,
					winnerId = winner and winner.UserId or 0,
					winnerName = winner and winner.DisplayName or "",
					creatureId = creature and creature.Id or "",
					credits = contributors[p.UserId] and math.floor(250 * currentEgg.Value) or 0,
					xp = contributors[p.UserId] and 100 or 0,
				})
			)
		end
		task.delay(C.Completion.RevealSeconds, function()
			if C.Completion.AutoReset and round == completed and status == "Revealed" then
				nextExpedition()
			end
		end)
	end)
end
local function strike(p, target, point, requestRound, sequence)
	if
		typeof(sequence) ~= "number"
		or sequence ~= sequence
		or sequence < 1
		or sequence > 2147483647
		or sequence % 1 ~= 0
	then
		return
	end
	local ch, root, head = alive(p)
	local session = sessions[p]
	local a = accounts[p.UserId]
	if
		not ch
		or not session
		or session.training
		or not equipped(p, "Pickaxe")
		or requestRound ~= round
		or not finite(point)
	then
		return
	end
	local data = typeof(target) == "Instance" and sections[target]
	if
		status ~= "Excavating"
		or not State:GetAttribute("Ready")
		or not data
		or data.broken
		or data.permanent
		or data.layer ~= activeLayer
		or not target:GetAttribute("Exposed")
	then
		return
	end
	local power, cd, capacity = stats(a)
	if used(a) + C.Layers[data.layer].Yield + a.Yield > capacity then
		if os.clock() - (session.fullNotice or 0) > 2 then
			session.fullNotice = os.clock()
			note(p, "Bucket full for this plate. Sell your resources from UPGRADES.")
		end
		return
	end
	local now = os.clock()
	if sequence <= (session.lastSequence or 0) or now - session.lastStrike < cd - 0.035 then
		return
	end
	local direction = point - head.Position
	local distance = direction.Magnitude
	if
		distance < 0.01
		or distance > C.Mining.Reach + 0.5
		or (point - root.Position).Magnitude > C.Mining.Reach + 3
	then
		return
	end
	local hit = workspace:Raycast(head.Position, direction.Unit * (distance + 0.7), rayParams(ch))
	if not hit or hit.Instance.Parent ~= target or (hit.Position - point).Magnitude > 1.3 then
		return
	end
	point = hit.Position
	session.lastSequence = sequence
	session.lastStrike = math.max(now, session.lastStrike + cd)
	session.attack = (session.attack or 0) + 1
	local token = session.attack
	local attackTool = session.tools.Pickaxe
	local duration = cd
	local sum = C.Animation.Anticipation
		+ C.Animation.Acceleration
		+ C.Animation.Recoil
		+ C.Animation.Recovery
	local windup = duration * (C.Animation.Anticipation + C.Animation.Acceleration) / sum
	Feedback:FireAllClients("Windup", p.UserId, duration, sequence, point)
	task.delay(windup, function()
		if
			sessions[p] ~= session
			or session.attack ~= token
			or not equipped(p, "Pickaxe")
			or session.tools.Pickaxe ~= attackTool
			or requestRound ~= round
		then
			return
		end
		local ch2, root2, head2 = alive(p)
		local delta = head2 and point - head2.Position
		local valid = delta
			and delta.Magnitude > 0.01
			and delta.Magnitude <= C.Mining.Reach + C.Mining.ImpactGrace
			and (point - root2.Position).Magnitude <= C.Mining.Reach + C.Mining.ImpactGrace + 3
		local impact = valid
			and workspace:Raycast(head2.Position, delta.Unit * (delta.Magnitude + 0.7), rayParams(ch2))
		if
			status ~= "Excavating"
			or data.broken
			or data.permanent
			or data.layer ~= activeLayer
			or not target:GetAttribute("Exposed")
			or not impact
			or impact.Instance.Parent ~= target
		then
			Feedback:FireClient(p, "Miss", sequence)
			return
		end
		local _, _, currentCapacity = stats(a)
		if used(a) + C.Layers[data.layer].Yield + a.Yield > currentCapacity then
			Feedback:FireClient(p, "Miss", sequence)
			return
		end
		local precise = (impact.Position - target:GetAttribute("Center")).Magnitude <= C.Precision.Radius
		local chain = precise and (session.lastTarget == target and session.precisionChain or 0) or 0
		chain = precise and math.min(chain + 1, C.Precision.MaxChain) or 0
		session.lastTarget, session.precisionChain = target, chain
		local multiplier = precise
				and (C.Precision.Multiplier + a.Precision * C.Upgrades.Precision.Step) + math.max(
					0,
					chain - 1
				) * C.Precision.ChainStep
			or 1
		local critical = random:NextNumber() < a.Critical * C.Upgrades.Critical.Step
		local damage = math.min(data.hp, math.floor(power * multiplier * (critical and 1.5 or 1) + 0.5))
		data.hp -= damage
		a.mining += damage
		contributors[p.UserId] = true
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
			critical
		)
		if data.hp <= 0 then
			data.broken = true
			target:SetAttribute("Intact", false)
			removed += 1
			a.xp += 2
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
				a.xp += 4
				a.cash += 3
				advance(p, "Sample", 1)
			end
			local fragment = {
				CFrame = data.part.CFrame,
				Normal = impact.Normal,
				SectionId = target.Name,
				RoundId = round,
				CollectorUserId = p.UserId,
				Size = data.part.Size,
				Center = target:GetAttribute("Center"),
				Template = string.format("L%d_R%02d", data.layer, target:GetAttribute("Row")),
			}
			expose(target, false)
			local layer = C.Layers[data.layer]
			local amount = layer.Yield + a.Yield
			a.contents[layer.Id] = (a.contents[layer.Id] or 0) + amount
			if a.introStage <= 2 then
				a.introStage = 3
			end
			a.materialValue += amount * layer.Value * currentEgg.Value
			advance(p, "Collect", amount)
			Feedback:FireAllClients(
				"Fragments",
				target:GetAttribute("Center"),
				root2.Position,
				data.layer,
				fragment
			)
			Feedback:FireClient(p, "Collected", amount)
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
	end)
end
local terminalByAction = {
	Sell = "SellTerminal",
	Power = "PowerTerminal",
	Speed = "SpeedTerminal",
	Capacity = "CapacityTerminal",
	NextRound = "NextTerminal",
}
local function purchase(p, key, quantity)
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
	advance(p, "Upgrade", count)
	tutorial(p, "AtUpgrade")
	syncPlayer(p)
	Feedback:FireClient(p, "UpgradeBought", key, count)
end
local function station(p, action)
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
		tutorial(p, "AtDepot")
		local value = math.floor(a.materialValue * (1 + a.Value * C.Upgrades.Value.Step) + 0.5)
		if value <= 0 then
			note(p, "Your bucket is empty.")
			return
		end
		for _, l in C.Layers do
			a.contents[l.Id] = 0
		end
		a.materialValue = 0
		if a.introStage <= 3 then
			a.introStage = 4
		end
		a.cash += value
		a.income += value
		advance(p, "Sell", 1)
		tutorial(p, "Sell")
		syncPlayer(p)
		Feedback:FireClient(p, "Sold", value)
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
	if now - (s.window or 0) >= 1 then
		s.window = now
		s.requests = 0
	end
	s.requests = (s.requests or 0) + 1
	if s.requests > 24 then
		return
	end
	if kind == "Cancel" then
		s.attack = (s.attack or 0) + 1
		Feedback:FireAllClients("Cancel", p.UserId)
		return
	elseif kind == "EnterLab" then
		-- Dispatch only after the first player closes the loading screen.
		-- Later arrivals cannot reset an expedition already in progress.
		if initialDeliveryPending and alive(p) then
			initialDeliveryPending = false
			if round == 1 and removed == 0 and status == "Excavating" and not transitioning then
				nextExpedition(currentEgg)
			end
		end
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
			s.attack = (s.attack or 0) + 1
			Feedback:FireAllClients("Cancel", p.UserId)
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
		if not alive(p) or not equipped(p, "Pickaxe") then
			return
		end
		local _, cooldown = stats(accounts[p.UserId])
		if now - s.lastStrike < cooldown then
			return
		end
		s.lastStrike = now
		Feedback:FireAllClients("Windup", p.UserId, cooldown, a, nil)
	elseif kind == "Mine" then
		if now - s.lastRequest < 0.08 then
			return
		end
		s.lastRequest = now
		strike(p, a, b, c, d)
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
			s.attack = (s.attack or 0) + 1
			Feedback:FireAllClients("Cancel", p.UserId)
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
	local loaded = Profiles.Load(p)
	if not loaded then
		p:Kick("Your research is still saving or unavailable. Please reconnect shortly.")
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

	local s = {
		tools = {},
		lastStrike = -math.huge,
		lastCollect = -math.huge,
		lastRequest = -math.huge,
		lastStation = -math.huge,
	}
	sessions[p] = s
	s.connection = p.CharacterAdded:Connect(function(ch)
		training(p, s, false)
		giveTools(p, ch, s)
	end)
	syncPlayer(p)
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
		for _, t in s.tools do
			t:Destroy()
		end
		sessions[p] = nil
	end
	local a = accounts[p.UserId]
	if a then
		trials[a] = nil
		trialSelected[a] = nil
		Profiles.Save(p, a, true)
		if accounts[p.UserId] == a then
			accounts[p.UserId] = nil
		end
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
		local eligible = 0
		for p, session in sessions do
			eligible += 1
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
		State:SetAttribute("DrawPlayers", eligible)
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
