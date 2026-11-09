-- Server-only, non-yielding completion settlement. No DataStore writes or client intents.
local M = {}
local Http = game:GetService("HttpService")
local Rules = require(game.ReplicatedStorage.VesperShared.ProgressionRules)
local receiptLimit = 256

function M.NormalizeReceipts(raw)
	local list, seen = {}, {}
	if type(raw) ~= "table" then
		return list
	end
	for _, id in ipairs(raw) do
		if type(id) == "string" and #id <= 160 and not seen[id] then
			seen[id] = true
			table.insert(list, id)
			if #list > receiptLimit then
				table.remove(list, 1)
			end
		end
	end
	return list
end

function M.new(random)
	-- JobId can be empty in Studio; the additional GUID distinguishes every server run.
	local sessionId = game.JobId .. ":" .. Http:GenerateGUID(false)
	local settlements = {}
	local api = {}
	local function resultFor(settlement, userId)
		local result = settlement.results[userId]
		if not result then
			-- Spectators get a factual no-roll result, never a fallback draw.
			result = {
				userId = userId,
				damage = 0,
				share = 0,
				chance = 0,
				eligible = false,
				creatureId = "",
				creditsDue = 0,
				xpDue = 0,
				delivered = false,
			}
			settlement.results[userId] = result
		end
		return result
	end
	function api:Freeze(round, egg, ledger, totalDamage, completedAt, nextAt, earnedXP)
		if settlements[round] then
			return settlements[round]
		end
		local settlement = {
			id = sessionId .. ":" .. tostring(round),
			round = round,
			eggName = egg.Name,
			soloChance = egg.DropChance,
			value = egg.Value,
			totalDamage = totalDamage,
			completedAt = completedAt,
			nextAt = nextAt,
			results = {},
			revealed = false,
		}
		settlements[round] = settlement
		local userIds = {}
		for userId, damage in ledger do
			if damage > 0 then
				table.insert(userIds, userId)
			end
		end
		table.sort(userIds)
		for _, userId in userIds do
			local result = resultFor(settlement, userId)
			result.damage = ledger[userId]
			result.earnedXP = (earnedXP and earnedXP[userId] or 0) / 10000
			result.share = totalDamage > 0 and result.damage / totalDamage or 0
			result.chance = egg.DropChance * result.share
			result.eligible = result.damage > 0 and totalDamage > 0
			-- Exactly one independent Bernoulli draw per eligible UserId. No last-hit input.
			if result.eligible and random:NextNumber() < result.chance then
				result.creatureId = Rules.Choose(Rules.CreatureVariants, random).Id
			end
		end
		return settlement
	end
	function api:Reveal(round, onlineLoadedUserIds, revealedAt)
		local settlement = settlements[round]
		if not settlement or settlement.revealed then
			return false
		end
		-- Preserve the existing stipend timing/policy: loaded online contributors at reveal.
		for _, userId in onlineLoadedUserIds do
			local result = resultFor(settlement, userId)
			if result.damage > 0 then
				result.creditsDue = math.floor(250 * settlement.value) -- XP was already credited at damage time
			end
		end
		settlement.revealedAt, settlement.revealed = revealedAt, true
		return true
	end
	function api:IncludeSpectator(round, userId)
		local settlement = settlements[round]
		if settlement and settlement.revealed then
			resultFor(settlement, userId)
		end
	end
	function api:Deliver(userId, account)
		-- Caller must verify the loaded profile is writable for this exact Player/session.
		local rounds, creatures = {}, 0
		for round, settlement in settlements do
			if settlement.revealed and settlement.results[userId] then
				table.insert(rounds, round)
			end
		end
		table.sort(rounds)
		for _, round in rounds do
			local settlement = settlements[round]
			local result = settlement.results[userId]
			if not result.delivered then
				local receipt = settlement.id .. ":" .. tostring(userId)
				if not table.find(account.eggRewardReceipts, receipt) then
					local creature = Rules.Creature(result.creatureId)
					if creature then
						account.creatures[creature.Id] = (account.creatures[creature.Id] or 0) + 1
						account.discoveries.crownback = (account.discoveries.crownback or 0) + 1
						if account.equippedCreature == "" then
							account.equippedCreature = creature.Id
						end
						creatures += 1
					end
					account.cash += result.creditsDue
					if creature or result.creditsDue > 0 or result.xpDue > 0 then
						table.insert(account.eggRewardReceipts, receipt)
						if #account.eggRewardReceipts > receiptLimit then
							table.remove(account.eggRewardReceipts, 1)
						end
					end
				end
				-- Retained for this entire server session, including after later eggs start.
				result.delivered = true
			end
		end
		return creatures
	end
	function api:History(userId)
		local rounds, history = {}, {}
		for round, settlement in settlements do
			if settlement.revealed and settlement.results[userId] then
				table.insert(rounds, round)
			end
		end
		table.sort(rounds)
		-- UI history is bounded; this never deletes settlements or undelivered rewards.
		for i = math.max(1, #rounds - 11), #rounds do
			local settlement = settlements[rounds[i]]
			local result = settlement.results[userId]
			table.insert(
				history,
				{
					settlementId = settlement.id,
					round = settlement.round,
					eggName = settlement.eggName,
					revealedAt = settlement.revealedAt,
					nextAt = settlement.nextAt,
					damage = result.damage,
					totalDamage = settlement.totalDamage,
					contributionShare = result.share,
					soloChance = settlement.soloChance,
					personalChance = result.chance,
					eligible = result.eligible,
					outcome = not result.eligible and "NoRoll" or result.creatureId ~= "" and "Won" or "Lost",
					creatureId = result.creatureId,
					delivered = result.delivered,
					credits = result.delivered and result.creditsDue or 0,
					xp = result.earnedXP or 0,
					pendingCredits = result.delivered and 0 or result.creditsDue,
					pendingXP = result.delivered and 0 or result.xpDue,
				}
			)
		end
		return history
	end
	return api
end
return M
