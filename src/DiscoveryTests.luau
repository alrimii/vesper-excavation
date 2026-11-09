-- Run explicitly in Studio; never a gameplay entry point.
local Profiles = require(game.ServerScriptService.Vesper.ResearchProfiles)
local Catalog = require(game.ReplicatedStorage.VesperShared.DiscoveryCatalog)
local function run()
	local passed = {}
	local function check(name, condition)
		assert(condition, name)
		table.insert(passed, name)
	end
	local rows = {}
	local fail = false
	local fake = {}
	function fake:UpdateAsync(key, transform)
		if fail then
			error("Injected save outage")
		end
		local value = transform(rows[key])
		if value ~= nil then
			rows[key] = value
		end
		return value
	end
	local function player(id)
		return {
			UserId = id,
			SetAttribute = function(self, k, v)
				self[k] = v
			end,
			Kick = function(self, reason)
				self.kicked = reason
			end,
		}
	end
	local first = Profiles.new(fake, false, function() end)
	local second = Profiles.new(fake, false, function() end)
	local p = player(101)
	local a = first.Load(p)
	check("New account starts empty", a.cash == 0 and a.xp == 0)
	local q = player(101)
	check("Concurrent server cannot claim locked profile", second.Load(q) == nil)
	a.cash = 220
	a.discoveries.lumen = 1
	a.contents.Shell = 9
	a.Power = 2
	check("Autosave renews owned session", first.Save(p, a, false))
	check("Save snapshot survives later mutation", rows["101"].data.cash == 220)
	a.cash = 140
	check("Release commits final value", first.Save(p, a, true))
	local reloaded = second.Load(q)
	check(
		"Rejoin restores economy, inventory and archive",
		reloaded.cash == 140
			and reloaded.Power == 2
			and reloaded.contents.Shell == 9
			and reloaded.discoveries.lumen == 1
	)
	check("Released session cannot overwrite new session", not first.Save(p, a, false))
	fail = true
	check("Write failure returns false", not second.Save(q, reloaded, false))
	check("Write failure closes unsafe session", q.kicked ~= nil)
	fail = false
	check("Final save can retry safely", second.Save(q, reloaded, true))
	local clean = Profiles.Normalize({
		cash = 0 / 0,
		xp = -20,
		Power = 999,
		discoveries = { lumen = -1 },
		contents = {
			Shell = -5,
		},
	})
	check(
		"Corrupt values are bounded",
		clean.cash == 0
			and clean.xp == 0
			and clean.Power == 28
			and clean.discoveries.lumen == 0
			and clean.contents.Shell == 0
	)
	check("Specimen catalog wraps", Catalog.ForRound(7).Id == Catalog.ForRound(1).Id)
	check("Rank thresholds", Catalog.Level(0) == 1 and Catalog.Level(60) == 2)
	check(
		"Contracts cycle with increasing rewards",
		Catalog.Contract(6).Kind == Catalog.Contract(1).Kind
			and Catalog.Contract(6).Reward > Catalog.Contract(1).Reward
	)
	check("Tutorial completion persists", Profiles.Normalize({ tutorial = 8 }).tutorial == 8)
	return passed
end
return run
