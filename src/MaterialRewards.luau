-- Server-only material accounting. All functions are non-yielding; no remotes or DataStore writes.
local M = {}
local C = require(game.ReplicatedStorage.VesperShared.ExcavationConfig)
local resources = {}
for _, layer in C.Layers do resources[layer.Id] = true end

function M.Record(data, userId, damage, yieldLevel)
	data.contributions = data.contributions or {}
	local entry = data.contributions[userId] or { damage = 0, weightedYield = 0 }
	entry.damage += damage
	entry.weightedYield += damage * yieldLevel * C.Upgrades.Yield.Step
	data.contributions[userId] = entry
end

function M.Allocate(data, baseYield)
	local rows, total, allocated = {}, 0, 0
	local totalWeightedYield, allocatedBonus = 0, 0
	for _, entry in data.contributions or {} do total += entry.damage end
	if total <= 0 then return rows end
	for userId, entry in data.contributions do
		local numerator = baseYield * entry.damage
		local units = math.floor(numerator / total)
		allocated += units
		local bonusFloor = math.floor(entry.weightedYield / total)
		totalWeightedYield += entry.weightedYield
		allocatedBonus += bonusFloor
		table.insert(rows, { userId = userId, base = units, remainder = numerator % total,
			bonus = bonusFloor, bonusRemainder = entry.weightedYield % total })
	end
	-- Equal-denominator integer remainders avoid floating-point tie ambiguity.
	table.sort(rows, function(a, b)
		if a.remainder == b.remainder then return a.userId < b.userId end
		return a.remainder > b.remainder
	end)
	for i = 1, baseYield - allocated do rows[i].base += 1 end
	-- Round the combined entitlement once, then apportion that exact bonus pool.
	-- All entitlements share total as denominator, so sum numerators before dividing.
	local bonusPool = math.floor(totalWeightedYield / total + 0.5)
	table.sort(rows, function(a, b)
		if a.bonusRemainder == b.bonusRemainder then return a.userId < b.userId end
		return a.bonusRemainder > b.bonusRemainder
	end)
	for i = 1, bonusPool - allocatedBonus do rows[i].bonus += 1 end
	table.sort(rows, function(a, b) return a.userId < b.userId end)
	return rows
end

-- Compact claims aggregate by resource AND original per-unit egg value.
-- List order is first acquisition order. Partial delivery never averages values.
function M.Add(list, id, unitValue, units)
	if units <= 0 then return end
	for _, entry in list do
		if entry.id == id and entry.unitValue == unitValue then
			entry.units += units
			return
		end
	end
	table.insert(list, { id = id, unitValue = unitValue, units = units })
end

function M.Normalize(raw)
	local list = {}
	if type(raw) ~= "table" then return list end
	for _, entry in ipairs(raw) do
		if type(entry) == "table" and resources[entry.id]
			and type(entry.units) == "number" and entry.units == entry.units
			and entry.units > 0 and entry.units < 2 ^ 53
			and type(entry.unitValue) == "number" and entry.unitValue == entry.unitValue
			and entry.unitValue > 0 and entry.unitValue < math.huge then
			M.Add(list, entry.id, entry.unitValue, math.floor(entry.units))
		end
	end
	return list
end

function M.Count(list, resourceId)
	local total = 0
	for _, entry in list do
		if not resourceId or entry.id == resourceId then total += entry.units end
	end
	return total
end

function M.Drain(account, capacity)
	local used = 0
	for _, layer in C.Layers do used += account.contents[layer.Id] or 0 end
	local room, delivered = math.max(0, capacity - used), 0
	while room > 0 and #account.pendingMaterials > 0 do
		local entry = account.pendingMaterials[1]
		local units = math.min(room, entry.units)
		account.contents[entry.id] = (account.contents[entry.id] or 0) + units
		account.materialValue += units * entry.unitValue
		entry.units -= units
		room -= units
		delivered += units
		if entry.units == 0 then table.remove(account.pendingMaterials, 1) end
	end
	return delivered
end
return M
