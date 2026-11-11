-- Session-locked profiles. Studio uses memory so tests cannot change live progress.
-- Authorized ONE-TIME fresh start, 10 November 2026. This name is permanent:
-- never derive it from a date, place version, join, or subsequent publication.
-- Old servers only know VesperDiscovery_v1 and cannot write this generation.
-- Retired records are not read, copied or migrated; namespace isolation is NOT deletion.
local LIVE_STORE = "VesperDiscovery_FreshStart_20261110"
local GENERATION = "fresh-start-20261110"
local function create(store, studio, pause, testPolicy)
	local P = {}
	local wait = pause or task.wait
	local function isStudio()
		return studio == true or (studio == nil and game:GetService("RunService"):IsStudio())
	end
	local Http = game:GetService("HttpService")
	local DS = store or game:GetService("DataStoreService"):GetDataStore(LIVE_STORE)
	local C = require(game.ReplicatedStorage.VesperShared.ExcavationConfig)
	local Progression = require(game.ReplicatedStorage.VesperShared.ProgressionRules)
	local token = game.JobId .. Http:GenerateGUID(false)
	local locks, saving, closing, leases = {}, {}, {}, {}
	local tests = {}
	local testAccounts = setmetatable({}, { __mode = "k" })
	local OwnerTest = require(script.Parent.OwnerTestAccess)
	local Materials = require(script.Parent.MaterialRewards)
	local EggRewards = require(script.Parent.EggRewards)
	local SkillProgress = require(script.Parent.PlayerProgression)
	local function number(v, max)
		return type(v) == "number" and v == v and math.clamp(math.floor(v), 0, max) or 0
	end
	function P.Normalize(raw)
		raw = type(raw) == "table" and raw or {}
		local preferences = type(raw.preferences) == "table" and raw.preferences or {}
		local a = {
			preferences = {
				sound = preferences.sound ~= false,
				reducedMotion = preferences.reducedMotion == true,
			},
			cash = number(raw.cash, 1e9),
			income = number(raw.income, 1e9),
			mining = 0,
			Power = number(raw.Power, C.Upgrades.Power.MaxLevel),
			Speed = number(raw.Speed, C.Upgrades.Speed.MaxLevel),
			Capacity = number(raw.Capacity, C.Upgrades.Capacity.MaxLevel),
			economyVersion = 2,
			tutorial = math.max(1, number(raw.tutorial, 8)),
			strength = number(raw.strength, 10000),
			relics = number(raw.relics, 1000000),
			toolId = Progression.Tools[raw.toolId] and raw.toolId or "Pickaxe",
			ownedTools = { Pickaxe = true },
			toolLevels = {},
			creatures = {},
			equippedCreature = "",
			roomTheme = "teal",
			roomThemes = { teal = true },
			profileVersion = 3,
			drillTrialUsed = raw.drillTrialUsed == true,
			introStage = math.max(1, number(raw.introStage or (raw.tutorial == 8 and 5 or 1), 5)),
			contents = {},
			pendingMaterials = Materials.Normalize(raw.pendingMaterials),
			eggRewardReceipts = EggRewards.NormalizeReceipts(raw.eggRewardReceipts),
			xp = number(raw.xp, 1e8), -- untouched legacy field; never displayed or credited in schema 1
			progression = SkillProgress.Normalize(raw.progression),
			samples = number(raw.samples, 1e8),
			discoveries = {},
			contract = math.max(1, number(raw.contract, 1e6)),
			contractProgress = number(raw.contractProgress, 1000),
		}
		for key, upgrade in C.Upgrades do
			a[key] = number(raw[key], upgrade.MaxLevel)
		end
		if raw.economyVersion ~= 2 then
			a.Power = math.min(C.Upgrades.Power.MaxLevel, math.ceil(number(raw.Power, 8) * 7 / 2))
			a.Speed = math.min(C.Upgrades.Speed.MaxLevel, math.ceil(number(raw.Speed, 6) * 0.04 / 0.012))
			a.Capacity = math.min(C.Upgrades.Capacity.MaxLevel, number(raw.Capacity, 10) * 2)
		end
		for _, id in { "Shell", "Membrane", "Tissue" } do
			a.contents[id] = number(type(raw.contents) == "table" and raw.contents[id], 2000)
		end
		local baseValue = 0
		for _, layer in C.Layers do
			baseValue += a.contents[layer.Id] * layer.Value
		end
		a.materialValue = math.clamp(number(raw.materialValue, 1e8), baseValue, baseValue * 4)
		for _, id in { "lumen", "ember", "astral", "tide", "sol", "bloom", "crownback" } do
			a.discoveries[id] = number(type(raw.discoveries) == "table" and raw.discoveries[id], 1e6)
		end
		for _, entry in require(game.ReplicatedStorage.VesperShared.DiscoveryCatalog).Specimens do
			a.discoveries[entry.Id] =
				number(type(raw.discoveries) == "table" and raw.discoveries[entry.Id], 1e6)
		end

		for id in Progression.Tools do
			local config = Progression.ToolConfig(id, C)
			local saved = type(raw.toolLevels) == "table" and raw.toolLevels[id]
			saved = type(saved) == "table" and saved or {}
			a.ownedTools[id] = id == "Pickaxe"
				or (type(raw.ownedTools) == "table" and raw.ownedTools[id] == true)
			a.toolLevels[id] = {}
			for _, key in Progression.UpgradeKeys do
				local value = saved[key]
				if raw.profileVersion ~= 3 and id == "Pickaxe" then
					value = a[key]
				end
				if raw.profileVersion == 3 and raw.toolId == id and type(raw[key]) == "number" then
					value = raw[key]
				end
				a.toolLevels[id][key] = number(value, config.Upgrades[key].MaxLevel)
			end
		end
		if not a.ownedTools[a.toolId] then
			a.toolId = "Pickaxe"
		end
		for _, key in Progression.UpgradeKeys do
			a[key] = a.toolLevels[a.toolId][key]
		end
		for _, entry in Progression.CreatureVariants do
			a.creatures[entry.Id] =
				number(type(raw.creatures) == "table" and raw.creatures[entry.Id], 1000000)
			if raw.equippedCreature == entry.Id and a.creatures[entry.Id] > 0 then
				a.equippedCreature = entry.Id
			end
		end
		a.displaySlots = require(game.ReplicatedStorage.VesperShared.CollectionSlots).Normalize(
			raw.displaySlots,
			a.creatures,
			Progression.CreatureVariants
		)
		for _, entry in Progression.RoomThemes do
			a.roomThemes[entry.Id] = entry.Id == "teal"
				or (type(raw.roomThemes) == "table" and raw.roomThemes[entry.Id] == true)
			if raw.roomTheme == entry.Id and a.roomThemes[entry.Id] then
				a.roomTheme = entry.Id
			end
		end
		return a
	end
	function P.IsTest(account)
		return testAccounts[account] == true
	end
	function P.CanMutate(player)
		return not closing[player]
			and (
				tests[player] ~= nil
				or isStudio()
				or (locks[player] ~= nil and (leases[player] or 0) > os.time())
			)
	end
	function P.Load(player)
		local ownerTest = OwnerTest.IsOwner(player.UserId) and (testPolicy or OwnerTest.IsTestPlayer)(player)
		if ownerTest or isStudio() then
			player:SetAttribute("SaveStatus", ownerTest and "TEST - NOT SAVED" or "STUDIO PREVIEW")
			local preview = P.Normalize(nil)
			for id in Progression.Tools do
				preview.ownedTools[id] = true
			end
			for _, theme in Progression.RoomThemes do
				preview.roomThemes[theme.Id] = true
			end
			for _, creature in Progression.CreatureVariants do
				preview.creatures[creature.Id] = 1
			end
			preview.displaySlots = require(game.ReplicatedStorage.VesperShared.CollectionSlots).Normalize(
				nil,
				preview.creatures,
				Progression.CreatureVariants
			)
			preview.cash = ownerTest and 1000000000 or 100000000
			if ownerTest then
				tests[player], testAccounts[preview] = preview, true
				preview.progression.xpUnits = require(game.ReplicatedStorage.VesperShared.SkillCatalog).Threshold(
					100
				) * require(game.ReplicatedStorage.VesperShared.SkillCatalog).XPScale
				preview.progression.highestLevel = 100
				preview.tutorial, preview.introStage = 8, 5
				for id in preview.discoveries do
					preview.discoveries[id] = 1
				end
			end
			player:SetAttribute("StudioTestUnlocks", not ownerTest)
			return preview
		end
		local key = tostring(player.UserId)
		local sessionToken = token .. Http:GenerateGUID(false)
		local incompatible = false
		for attempt = 1, 4 do
			incompatible = false
			local ok, result = pcall(function()
				return DS:UpdateAsync(key, function(old)
					-- Only an absent key gets defaults. Existing data is never reset on load.
					if old == nil then
						return {
							data = P.Normalize(nil),
							generation = GENERATION,
							lock = sessionToken,
							lease = os.time() + 180,
						}
					end
					if type(old) ~= "table" or old.generation ~= GENERATION or type(old.data) ~= "table" then
						incompatible = true
						return nil
					end
					if old.lock and old.lock ~= sessionToken and (old.lease or 0) > os.time() then
						return nil
					end
					local raw = old.data.progression
					local valid = type(raw) == "table" and raw.version == 1
					if valid then
						valid = pcall(P.Normalize, old.data)
					end
					if not valid then
						incompatible = true
						return nil
					end
					return {
						data = old.data,
						generation = GENERATION,
						lock = sessionToken,
						lease = os.time() + 180,
					}
				end)
			end)
			if incompatible then
				player:SetAttribute(
					"ProfileLoadError",
					"Your current profile could not be loaded safely. Please contact the developer. Your progress has not been reset."
				)
				return nil
			end
			if ok and result and result.lock == sessionToken then
				locks[player] = sessionToken
				leases[player] = result.lease
				player:SetAttribute("SaveStatus", "SAVED")
				return P.Normalize(result.data)
			end
			wait(attempt)
		end
		return nil
	end
	function P.Save(player, a, release)
		-- Identity guard covers autosave, leave, shutdown and stray old references.
		-- Test accounts never reach the serializer or any persistent-store call.
		if testAccounts[a] then
			local active = tests[player] == a
			if release then
				tests[player] = nil
			end
			return active
		end
		if tests[player] then
			return false
		end
		if isStudio() then
			return true
		end
		if release then
			closing[player] = true
		end
		local deadline = os.clock() + 12
		while saving[player] and os.clock() < deadline do
			wait(0.1)
		end
		if saving[player] then
			return false
		end
		if not locks[player] or (closing[player] and not release) then
			return false
		end
		local encoded, snapshot = pcall(function()
			return Http:JSONDecode(Http:JSONEncode(a))
		end)
		if not encoded then
			player:SetAttribute("SaveStatus", "SAVE ERROR")
			return false
		end
		saving[player] = true
		local sessionToken = locks[player]
		local success = false
		for attempt = 1, 3 do
			local ok, result = pcall(function()
				return DS:UpdateAsync(tostring(player.UserId), function(old)
					if type(old) ~= "table" or old.generation ~= GENERATION or old.lock ~= sessionToken then
						return nil
					end
					return {
						data = snapshot,
						generation = GENERATION,
						lock = not release and sessionToken or nil,
						lease = not release and os.time() + 180 or nil,
					}
				end)
			end)
			if ok and result then
				leases[player] = result.lease
				success = true
				break
			end
			wait(attempt)
		end
		saving[player] = nil
		if success then
			if release then
				locks[player] = nil
				closing[player] = nil
			end
			player:SetAttribute("SaveStatus", "SAVED")
		else
			player:SetAttribute("SaveStatus", "SAVE RETRY")
			if not release then
				closing[player] = true
				player:Kick("Your research could not be saved safely. Please reconnect.")
			end
		end
		return success
	end
	return P
end
local default = create()
default.new = create
return default
