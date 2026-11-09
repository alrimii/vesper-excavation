local E = require(script.Parent.UpgradeEconomy)
local M = {}
function M.Upgrade(key, level, cash, quantity, config)
	local maximum = config.Upgrades[key].MaxLevel
	local count, cost = E.Quote(key, level, cash, quantity, config)
	local current = E.Effect(key, level, config)
	if level >= maximum then
		return string.format("LEVEL %d / %d\n%s\nFully upgraded for this tool", level, maximum, current),
			"MAXIMIZED",
			false
	end
	local target = math.min(maximum, level + math.max(1, count))
	local detail = string.format(
		"LEVEL %d / %d\nNow: %s\nAfter: %s",
		level,
		maximum,
		current,
		E.Effect(key, target, config)
	)
	if count == 0 then
		return detail, string.format("NEED $%d MORE", math.max(0, E.Price(key, level, config) - cash)), false
	end
	return detail, string.format("UPGRADE +%d / $%d", count, cost), true
end
function M.ToolStats(id, player, rules, base)
	local config = rules.ToolConfig(id, base)
	local powerLevel = player:GetAttribute("ToolLevel_" .. id .. "_Power") or 0
	local speedLevel = player:GetAttribute("ToolLevel_" .. id .. "_Speed") or 0
	local power = config.Mining.Power + powerLevel * config.Upgrades.Power.Step
	local cooldown = math.max(
		config.Mining.MinimumCooldown,
		config.Mining.Cooldown - speedLevel * config.Upgrades.Speed.Step
	)
	return power, cooldown, powerLevel, speedLevel
end
return M
