local E = require(script.Parent.UpgradeEconomy)
local M = {}
local function damage(config, level, bonus)
	return math.floor((config.Mining.Power + level * config.Upgrades.Power.Step) * bonus)
end
local function interval(config, level)
	return math.max(config.Mining.MinimumCooldown, config.Mining.Cooldown - level * config.Upgrades.Speed.Step)
end
local function effective(key, level, config, player)
	local bonus = player and player:GetAttribute("PowerBonus") or 1
	local family = config.ToolFamily
	local pl = key == "Power" and level or player and player:GetAttribute("ToolLevel_" .. family .. "_Power") or 0
	local sl = key == "Speed" and level or player and player:GetAttribute("ToolLevel_" .. family .. "_Speed") or 0
	local power, cd = damage(config, pl, bonus), interval(config, sl)
	if key == "Power" then
		return family == "Drill" and string.format("%d / tick (%.1f DPS)", power, power / cd)
			or family == "Explosive" and string.format("%d center damage", power)
			or string.format("%d / strike", power)
	elseif key == "Speed" then
		return family == "Drill" and string.format("%.3fs / tick (%.1f DPS)", cd, power / cd)
			or family == "Explosive" and string.format("%.3fs cooldown", cd)
			or string.format("%.3fs / strike", cd)
	end
	if key == "Yield" then return string.format("+%d at 100%% section contribution", level * config.Upgrades.Yield.Step) end
	return E.Effect(key, level, config)
end
function M.Upgrade(key, level, cash, quantity, config, player)
	local maximum = config.Upgrades[key].MaxLevel
	local count, cost = E.Quote(key, level, cash, quantity, config)
	local current = effective(key, level, config, player)
	local description = config.Upgrades[key].Description
	if key == "Power" then
		description = config.ToolFamily == "Drill" and "More damage on each confirmed contact tick."
			or config.ToolFamily == "Explosive" and "More center damage; the fixed blast fades toward its edge."
			or "More damage per deliberate strike."
	elseif key == "Speed" then
		description = config.ToolFamily == "Drill" and "Shorter interval between focused damage ticks."
			or config.ToolFamily == "Explosive" and "Shorter time between charges; fuse stays fixed."
			or "Shorter full swing cycle while holding attack."
	elseif key == "Yield" then
		description = "Personal extra materials, weighted by your effective damage and Yield level at each hit; rounded at section break."
	elseif key == "Precision" and config.ToolFamily == "Explosive" then
		description = "Accurate placement on the gold point boosts the whole blast before distance falloff."
	elseif key == "Critical" and config.ToolFamily == "Explosive" then
		description = "One critical roll per blast: 1.5x damage before distance falloff."
	end
	local detail = string.format("LEVEL %d / %d\nNow: %s", level, maximum, current)
	if level >= maximum then return detail .. "\n" .. description, "MAXIMIZED", false end
	local nextPrice = E.Price(key, level, config)
	detail ..= "\nNext: " .. effective(key, level + 1, config, player)
		.. string.format("\nNext price: $%d / %s", nextPrice, cash >= nextPrice and "affordable" or "insufficient credits")
	if count > 1 then detail ..= "\nBatch: " .. effective(key, level + count, config, player) end
	detail ..= "\n" .. description
	if key == "Power" or key == "Speed" then detail ..= "\nIncludes strength/creature bonus; precision and critical hits vary." end
	if count == 0 then return detail, string.format("NEED $%d MORE", math.max(0, nextPrice - cash)), false end
	return detail, string.format("UPGRADE +%d / $%d", count, cost), true
end
function M.ToolStats(id, player, rules, base)
	local config = rules.ToolConfig(id, base)
	local pl = player:GetAttribute("ToolLevel_" .. id .. "_Power") or 0
	local sl = player:GetAttribute("ToolLevel_" .. id .. "_Speed") or 0
	return damage(config, pl, player:GetAttribute("PowerBonus") or 1), interval(config, sl), pl, sl
end
function M.ToolDescription(id, player, rules, base)
	local power, cd, pl, sl = M.ToolStats(id, player, rules, base)
	local detail
	if id == "Drill" then
		detail = string.format("Focused contact: %d damage / %.3fs tick = %.1f DPS.\nHold desktop attack; tap the touch button to toggle. No contact means no damage.", power, cd, power / cd)
	elseif id == "Explosive" then
		local b = base.Tools.Explosive
		detail = string.format("%d center damage / %.3fs cooldown.\n%.2fs fuse; %g-stud radius; at most %d visible exposed sections. Linear falloff to %d%% at the edge. One free bucket slot is required to mine; earned overflow stays pending. Placement survives the original section breaking.\nF, switching tools or opening a menu cancels the fuse; releasing attack stops repeats.", power, cd, b.Fuse, b.Radius, b.MaxSections, b.EdgeMultiplier * 100)
	else
		detail = string.format("Deliberate strikes: %d damage / %.3fs swing.\nHold attack to repeat. Aim at the gold point for precision.", power, cd)
	end
	return detail .. string.format("\nPower level %d / Speed level %d.\nIncludes current strength/creature bonus, before precision/critical. Each tool keeps its own upgrades; select RIG to improve the equipped tool.", pl, sl)
end
return M
