-- Phase 5B shared presentation/configuration. Authority lives in ExcavationService.
local S = {
	Version = 1,
	MaxLevel = 100,
	XPScale = 10000,
	XPMultiplier = 1,
	EggXP = { bronze = 400, golden = 460, volcanic = 520 },
	Nodes = {},
	Order = {},
}
function S.Threshold(level)
	local l = math.clamp(math.floor(level), 0, S.MaxLevel)
	return 200 * l + 20 * l * l + math.floor(l ^ 4 / 10)
end
function S.Level(xp)
	local low, high = 0, S.MaxLevel
	while low < high do
		local mid = math.ceil((low + high) / 2)
		if xp >= S.Threshold(mid) then
			low = mid
		else
			high = mid - 1
		end
	end
	return low
end
function S.Points(level)
	return level == 0 and 0 or 1 + math.floor(level / 2) + math.floor(level / 10)
end
local function node(id, name, branch, x, y, levels, cost, prerequisites, effects, tool, active)
	S.Nodes[id] = {
		Id = id,
		Name = name,
		Branch = branch,
		X = x,
		Y = y,
		Levels = levels,
		Cost = cost,
		MaxRank = #levels,
		Prerequisites = prerequisites,
		Effects = effects,
		Tool = tool or "All tools",
		Active = active == true,
		Implemented = true,
	}
	table.insert(S.Order, id)
end
node(
	"impact.fault_survey",
	"Fault Survey",
	"Impact",
	-260,
	0,
	{ 1, 20 },
	1,
	{},
	{
		"Mark 2 visible weakened sections (35% HP or less) within 8 studs of your aim.",
		"Mark 4 visible weakened sections within 12 studs. Refreshes at most 4 times/second.",
	}
)
node(
	"impact.charged_swing",
	"Charged Swing",
	"Impact",
	-350,
	180,
	{ 5 },
	2,
	{ "impact.fault_survey" },
	{
		"A 0.45s windup delivers 160% of one normal strike. 8s technique cooldown plus normal cadence. Equip in your room.",
	},
	"Pickaxe",
	true
)
node(
	"impact.steady_aim",
	"Steady Aim",
	"Impact",
	-190,
	340,
	{ 15, 40 },
	2,
	{ "impact.fault_survey" },
	{
		"Ordinary strike/drill precision radius: 1.00 stud (base 0.75). Multiplier unchanged.",
		"Ordinary strike/drill precision radius: 1.20 studs.",
	},
	"Pickaxe / Drill"
)
node(
	"collection.batch_unload",
	"Batch Unload",
	"Collection",
	0,
	0,
	{ 1, 20 },
	1,
	{},
	{
		"Explicit Sell processes up to 2 bucket loads, draining earned pending materials between loads.",
		"Explicit Sell processes up to 3 bucket loads. Original material values and each load's rounding stay intact.",
	}
)
node(
	"collection.sale_latch",
	"Sale Latch",
	"Collection",
	0,
	180,
	{ 5 },
	2,
	{ "collection.batch_unload" },
	{
		"Optional toggle: after accepted ordinary mining fills the bucket, sell 1 load. Requires active input and damage within 3s; 8s cooldown. No automatic aiming/mining.",
	}
)
node(
	"technique.precision_relay",
	"Precision Relay",
	"Technique",
	260,
	0,
	{ 1, 20 },
	1,
	{},
	{
		"After breaking a section, carry your precision chain to a precise neighbor within 4 studs on the same layer for 3s. 6s cooldown; chain cap 3.",
		"Relay window becomes 5s. A nonprecise next hit consumes the relay.",
	},
	"Pickaxe / Drill"
)
node(
	"technique.chain_lightning",
	"Chain Lightning",
	"Technique",
	190,
	180,
	{ 5 },
	2,
	{ "technique.precision_relay" },
	{
		"25% opportunity per 4s window, 8s cooldown. Up to 2 exposed neighbors: 80% / 50% base power, 4-stud hops, 6-stud origin limit. No recursive arcs.",
	},
	"Pickaxe / Drill"
)
node(
	"technique.core_drill",
	"Flow Drill",
	"Technique",
	350,
	340,
	{ 15, 40 },
	2,
	{ "technique.precision_relay" },
	{
		"4s valid drilling across targets prepares 3s at 125% damage. Up to 2s contact gap preserves buildup; release/cancel clears it. Ready expires after 4s.",
		"The 3s Flow boost becomes 135% damage. No paused ordinary ticks.",
	},
	"Drill"
)
local planned = {
	{ "impact.crosscut", "Crosscut", "Impact", -260, 520, { "impact.charged_swing", "impact.steady_aim" } },
	{ "impact.overbreak", "Overbreak", "Impact", -260, 700, { "impact.crosscut" } },
	{ "impact.fault_mark", "Fault Mark", "Impact", -260, 880, { "impact.overbreak" } },
	{ "impact.fault_collapse", "Fault Collapse", "Impact", -260, 1060, { "impact.fault_mark" } },
	{ "collection.sample_packing", "Sample Packing", "Collection", 70, 340, { "collection.batch_unload" } },
	{
		"collection.claim_priorities",
		"Claim Priorities",
		"Collection",
		0,
		520,
		{ "collection.sale_latch", "collection.sample_packing" },
	},
	{ "collection.clean_extraction", "Clean Extraction", "Collection", 0, 700, {
		"collection.claim_priorities",
	} },
	{ "collection.refinery_link", "Refinery Link", "Collection", 0, 880, { "collection.clean_extraction" } },
	{ "collection.expedition_harness", "Expedition Harness", "Collection", 0, 1060, {
		"collection.refinery_link",
	} },
	{ "technique.shaped_charge", "Shaped Charge", "Technique", 190, 520, { "technique.chain_lightning" } },
	{ "technique.pulse_drill", "Pulse Drill", "Technique", 350, 700, { "technique.core_drill" } },
	{ "technique.arc_routing", "Arc Routing", "Technique", 260, 880, { "technique.chain_lightning" } },
	{ "technique.storm_circuit", "Storm Circuit", "Technique", 260, 1060, { "technique.arc_routing" } },
}
for _, n in planned do
	S.Nodes[n[1]] = {
		Id = n[1],
		Name = n[2],
		Branch = n[3],
		X = n[4],
		Y = n[5],
		Prerequisites = n[6],
		Implemented = false,
		MaxRank = 0,
		Effects = { "PLANNED: unavailable in this development checkpoint; cannot spend points." },
	}
	table.insert(S.Order, n[1])
end
function S.Rank(a, id)
	return a.progression and a.progression.ranks[id] or 0
end
function S.Spent(ranks)
	local spent = 0
	for id, rank in ranks do
		local n = S.Nodes[id]
		if n and n.Implemented then
			spent += n.Cost * rank
		end
	end
	return spent
end
function S.PurchaseReason(level, ranks, id, testMode)
	local n = S.Nodes[id]
	if not n or not n.Implemented then
		return "This node is PLANNED, not purchasable."
	end
	local rank = ranks[id] or 0
	if rank >= n.MaxRank then
		return "All ranks already learned."
	end
	if testMode == true then return nil end
	if level < n.Levels[rank + 1] then
		return "Requires level " .. n.Levels[rank + 1] .. "."
	end
	for _, req in n.Prerequisites do
		if (ranks[req] or 0) < 1 then
			return "Learn " .. S.Nodes[req].Name .. " first."
		end
	end
	if S.Points(level) - S.Spent(ranks) < n.Cost then
		return "Not enough skill points."
	end
	return nil
end
return S
