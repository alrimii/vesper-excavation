-- One focused Edit-mode verification. Only fake Players and an in-memory store;
-- no real profile reads/writes, teleports, Play or gameplay automation.
local root = game.ServerScriptService.Vesper
local profileModule = root.ResearchProfiles:Clone()
profileModule.Parent = root
local Profiles = require(profileModule)
local Access = require(root.OwnerTestAccess)
local Skills = require(game.ReplicatedStorage.VesperShared.SkillCatalog)
local Rules = require(game.ReplicatedStorage.VesperShared.ProgressionRules)
local Economy = require(game.ReplicatedStorage.VesperShared.UpgradeEconomy)
local Config = require(game.ReplicatedStorage.VesperShared.ExcavationConfig)
local Http = game:GetService("HttpService")
local checks = {}
local function check(value, name)
	assert(value, name)
	table.insert(checks, name)
end
local function player(id)
	local p = { UserId = id, attributes = {} }
	function p:SetAttribute(k, v)
		self.attributes[k] = v
	end
	function p:GetAttribute(k)
		return self.attributes[k]
	end
	function p:Kick(message)
		error("Unexpected kick: " .. message)
	end
	return p
end
local enabled = true
local writes = 0
local records = {}
local store = {}
function store:UpdateAsync(key, transform)
	writes += 1
	local nextValue = transform(records[key])
	if nextValue then
		records[key] = nextValue
	end
	return nextValue
end
local p = player(Access.OwnerUserId)
local other = player(0) -- synthetic, never a connected Roblox account
local P = Profiles.new(store, false, function() end, function()
	return enabled
end)
local real = P.Normalize(nil)
real.cash = 321
records[tostring(p.UserId)] = { data = real, generation = "fresh-start-20261110" }
local before = Http:JSONEncode(real)
check(Access.Decide(p.UserId, "", 0, nil, nil) == "route-test", "owner auto-routes before profile load")
check(
	Access.Decide(p.UserId, "reserved", 0, game.PlaceId, {}) == "test",
	"owner reserved-server test authorization"
)
check(
	Access.Decide(0, "", 0, game.PlaceId, { OwnerTestMode = "test-v1" }) == "normal",
	"spoofed teleport data grants no access"
)
check(Access.Decide(0, "reserved", 0, nil, nil) == "deny", "other players cannot join owner test world")
check(
	Access.Decide(p.UserId, "", 0, game.PlaceId, { OwnerTestMode = "normal-v1" }) == "normal",
	"off toggle selects normal profile on rejoin"
)
local a = P.Load(p)
check(
	P.IsTest(a) and P.CanMutate(p) and writes == 0,
	"live-mode test profile requires no datastore operation"
)
for id in Rules.Tools do
	check(a.ownedTools[id], "tool available: " .. id)
	for _, key in Rules.UpgradeKeys do
		assert(a.toolLevels[id][key] == 0, "upgrade must start at zero")
	end
end
check(next(a.progression.ranks) == nil, "skill ranks start at zero")
local implemented, planned = 0, 0
for id, n in Skills.Nodes do
	if n.Implemented then
		implemented += 1
		assert(Skills.PurchaseReason(0, {}, id, true) == nil, "test skill availability: " .. id)
	else
		planned += 1
		assert(Skills.PurchaseReason(100, {}, id, true) ~= nil, "planned skill must stay unavailable")
	end
end
check(
	implemented == 8 and planned == 13,
	"all eight implemented skills available; thirteen planned stay unavailable"
)
check(Skills.PurchaseReason(0, {}, "impact.charged_swing", false) ~= nil, "normal skill gates preserved")
check(
	Economy.Quote("Power", 0, math.huge, 1, Rules.ToolConfig("Drill", Config)) == 1,
	"individual test upgrade rank quote"
)
check(
	Economy.Quote("Power", 0, 0, 1, Rules.ToolConfig("Drill", Config)) == 0,
	"normal zero-currency quote still blocked"
)
a.cash, a.Power, a.progression.ranks["impact.charged_swing"] = 0, 1, 1
check(P.Save(p, a, false) and writes == 0, "test autosave cannot persist rewards or upgrades")
check(not P.Save(other, a, false) and writes == 0, "test account cannot save through another player")
check(P.Save(p, a, true) and writes == 0, "test leave/shutdown discards profile without writes")
check(Http:JSONEncode(real) == before, "normal saved profile unchanged by test activity")
enabled = false
local normal = P.Load(p)
check(
	not P.IsTest(normal)
		and normal.cash == 321
		and not normal.ownedTools.Drill
		and normal.Power == 0
		and next(normal.progression.ranks) == nil,
	"normal mode restores original currency, ownership and progression"
)
local afterLoad = writes
check(not P.Save(p, a, false) and writes == afterLoad, "stale test reference cannot overwrite normal profile")
check(P.Save(p, normal, true), "normal profile retains normal locked save path")
-- Even the injected test-policy dependency cannot authorize a different UserId.
enabled = true
local unauthorized = P.Load(other)
check(not P.IsTest(unauthorized), "profile layer independently rejects non-owner test authorization")
profileModule:Destroy()
return {
	passed = #checks,
	checks = checks,
	implementedSkills = implemented,
	plannedSkills = planned,
	realDatastoreOperations = 0,
	playSessions = 0,
}
