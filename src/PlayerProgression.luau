-- One profile field, one XP source. Never interprets legacy ResearchXP as this schema.
local C = require(game.ReplicatedStorage.VesperShared.SkillCatalog)
local P = {}
local function int(v, max)
	return type(v) == "number" and v == v and math.clamp(math.floor(v), 0, max) or 0
end
function P.New()
	return { version = C.Version, xpUnits = 0, ranks = {}, loadout = { "", "" }, saleLatch = false, highestLevel = 0, guards = {} }
end
function P.Normalize(raw)
	if raw == nil then
		return P.New()
	end
	assert(type(raw) == "table" and raw.version == C.Version, "Unsupported progression schema")
	local p = P.New()
	p.xpUnits = int(raw.xpUnits, C.Threshold(100) * C.XPScale)
	local level = C.Level(p.xpUnits / C.XPScale)
	-- Preserve only valid earned allocations; reject inconsistent persisted builds instead of silently respecing.
	for id, rank in type(raw.ranks) == "table" and raw.ranks or {} do
		local n = C.Nodes[id]
		assert(n and n.Implemented and rank == int(rank, n.MaxRank), "Unsupported saved skill allocation")
		if rank > 0 then
			p.ranks[id] = rank
		end
	end
	assert(C.Spent(p.ranks) <= C.Points(level), "Saved skill allocation exceeds entitlement")
	for id, rank in p.ranks do
		local n = C.Nodes[id]
		assert(level >= n.Levels[rank], "Saved skill level requirement mismatch")
		for _, req in n.Prerequisites do
			assert((p.ranks[req] or 0) > 0, "Saved skill prerequisite mismatch")
		end
	end
	for slot = 1, (level >= 30 and 2 or level >= 5 and 1 or 0) do
		local id = type(raw.loadout) == "table" and raw.loadout[slot]
		if id == "impact.charged_swing" and p.ranks[id] and not table.find(p.loadout, id) then
			p.loadout[slot] = id
		end
	end
	p.saleLatch = raw.saleLatch == true and (p.ranks["collection.sale_latch"] or 0) > 0
	p.highestLevel = math.max(level, int(raw.highestLevel, 100))
	for _, key in
		{
			"chargedUntil",
			"latchUntil",
			"relayUntil",
			"lastWindow",
			"lightningUntil",
			"respecUntil",
			"lastDamageAt",
			"lastMiningAt",
			"nextAttackAt",
		}
	do
		local v = type(raw.guards) == "table" and raw.guards[key]
		if type(v) == "number" and v == v and v >= 0 and v < 1e12 then
			p.guards[key] = v
		end
	end
	return p
end
function P.Credit(a, damage, eggId)
	local p = a.progression
	local before = C.Level(p.xpUnits / C.XPScale)
	local units = damage * assert(C.EggXP[eggId], "Egg needs an explicit XP factor") * C.XPMultiplier
	local accepted = math.min(units, C.Threshold(100) * C.XPScale - p.xpUnits)
	p.xpUnits += accepted
	local after = C.Level(p.xpUnits / C.XPScale)
	p.highestLevel = math.max(p.highestLevel, after)
	return accepted, before, after
end
return P
