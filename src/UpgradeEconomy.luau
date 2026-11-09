local DefaultConfig = require(script.Parent.ExcavationConfig)
local E = {}
E.Order = { "Power", "Speed", "Capacity", "Precision", "Yield", "Value", "Critical" }
function E.Price(key, level, config)
	local u = (config or DefaultConfig).Upgrades[key]
	return math.floor(u.BaseCost * u.CostGrowth ^ level + 0.5)
end
function E.Quote(key, level, cash, quantity, config)
	local u = (config or DefaultConfig).Upgrades[key]
	local limit = quantity == "Max" and u.MaxLevel or quantity
	local count, cost = 0, 0
	for i = level, math.min(u.MaxLevel - 1, level + limit - 1) do
		local nextCost = E.Price(key, i, config)
		if cost + nextCost > cash then
			break
		end
		cost += nextCost
		count += 1
	end
	return count, cost
end
function E.Effect(key, level, config)
	local C = config or DefaultConfig
	local step = C.Upgrades[key].Step
	if key == "Power" then
		return string.format("%d damage", C.Mining.Power + level * step)
	elseif key == "Speed" then
		return string.format(
			"%.2fs / hit",
			math.max(C.Mining.MinimumCooldown, C.Mining.Cooldown - level * step)
		)
	elseif key == "Capacity" then
		return string.format("%d storage", C.Collection.Capacity + level * step)
	elseif key == "Precision" then
		return string.format("%.2fx precise damage", C.Precision.Multiplier + level * step)
	elseif key == "Yield" then
		return string.format("+%d per plate", level * step)
	elseif key == "Value" then
		return string.format("+%d%% sale value", math.floor(level * step * 100 + 0.5))
	else
		return string.format("%.1f%% critical chance", level * step * 100)
	end
end
return E
