-- All prices and awards are re-evaluated by the server. No paid boosts are enabled.
local P = {}
P.Tools = {
	Pickaxe = {
		Name = "Field Pickaxe",
		Cost = 0,
		Power = 25,
		Cooldown = 0.60,
		MinimumCooldown = 0.30,
		PowerStep = 2,
		SpeedStep = 0.006,
		MaxLevel = 50,
		PriceScale = 1,
		Color = Color3.fromRGB(228, 187, 113),
	},
	Drill = {
		Name = "Helix Drill",
		Cost = 18000,
		Power = 55,
		Cooldown = 0.38,
		MinimumCooldown = 0.18,
		PowerStep = 4,
		SpeedStep = 0.004,
		MaxLevel = 50,
		PriceScale = 4,
		Color = Color3.fromRGB(94, 232, 211),
	},
	Explosive = {
		Name = "Seismic Charge",
		Cost = 85000,
		Power = 280,
		Cooldown = 2.4,
		MinimumCooldown = 1.4,
		PowerStep = 16,
		SpeedStep = 0.02,
		MaxLevel = 50,
		PriceScale = 12,
		Color = Color3.fromRGB(255, 141, 91),
	},
}
P.ToolOrder = { "Pickaxe", "Drill", "Explosive" }
P.UpgradeKeys = { "Power", "Speed", "Capacity", "Precision", "Yield", "Value", "Critical" }
P.Eggs = {
	{
		Id = "bronze",
		Name = "ANCIENT BRONZE",
		Rarity = "UNCOMMON",
		Weight = 65,
		Durability = 1,
		Value = 1,
		DropChance = 0.08,
		Color = Color3.fromRGB(245, 224, 184),
		Glow = Color3.fromRGB(127, 235, 204),
	},
	{
		Id = "golden",
		Name = "GILDED SOVEREIGN",
		Rarity = "RARE",
		Weight = 27,
		Durability = 2.6,
		Value = 2,
		DropChance = 0.15,
		Color = Color3.fromRGB(255, 208, 91),
		Glow = Color3.fromRGB(255, 236, 159),
	},
	{
		Id = "volcanic",
		Name = "VOLCANIC HEART",
		Rarity = "LEGENDARY",
		Weight = 8,
		Durability = 6,
		Value = 4,
		DropChance = 0.25,
		Color = Color3.fromRGB(87, 66, 65),
		Glow = Color3.fromRGB(255, 111, 57),
	},
}
P.CreatureVariants = {
	{
		Id = "crownback",
		Name = "Vesper Crownback",
		Weight = 80,
		Rarity = "RARE",
		Power = 0.08,
		Color = Color3.fromRGB(238, 188, 103),
	},
	{
		Id = "crownback_gilded",
		Name = "Gilded Crownback",
		Weight = 18,
		Rarity = "EPIC",
		Power = 0.16,
		Color = Color3.fromRGB(255, 222, 111),
	},
	{
		Id = "crownback_ember",
		Name = "Ember Crownback",
		Weight = 2,
		Rarity = "LEGENDARY",
		Power = 0.30,
		Color = Color3.fromRGB(255, 125, 75),
	},
	{
		Id = "crystal_triceratops",
		ModelId = "crystal_triceratops",
		Name = "Crystal Triceratops",
		Weight = 0,
		Rarity = "TEST",
		Power = 0,
		TestOnly = true,
		Icon = "rbxassetid://102662158340345",
		Color = Color3.fromRGB(104, 226, 209),
	},
}
-- The original three weighted entries remain the complete normal drop pool.
P.CreatureDrops = {}
for _, entry in P.CreatureVariants do
	if not entry.TestOnly then
		table.insert(P.CreatureDrops, entry)
	end
end
P.RoomThemes = {
	{ Id = "teal", Name = "Containment", Cost = 0, Color = Color3.fromRGB(84, 221, 197) },
	{ Id = "amber", Name = "Amber Archive", Cost = 4500, Color = Color3.fromRGB(255, 194, 101) },
	{ Id = "violet", Name = "Astral Archive", Cost = 14000, Color = Color3.fromRGB(182, 145, 255) },
}
function P.Egg(id)
	for _, entry in P.Eggs do
		if entry.Id == id then
			return entry
		end
	end
	return P.Eggs[1]
end
function P.Creature(id)
	for _, entry in P.CreatureVariants do
		if entry.Id == id then
			return entry
		end
	end
end
function P.Choose(list, random)
	local total = 0
	for _, entry in list do
		total += entry.Weight
	end
	local value = random:NextNumber() * total
	for _, entry in list do
		value -= entry.Weight
		if value < 0 then
			return entry
		end
	end
	return list[#list]
end
local configs = {}
function P.ToolConfig(id, base)
	id = P.Tools[id] and id or "Pickaxe"
	if configs[id] then
		return configs[id]
	end
	local tool = P.Tools[id]
	local c = table.clone(base)
	c.ToolFamily = id
	c.Mining = table.clone(base.Mining)
	c.Mining.Power, c.Mining.Cooldown, c.Mining.MinimumCooldown =
		tool.Power, tool.Cooldown, tool.MinimumCooldown
	c.Upgrades = {}
	for key, original in base.Upgrades do
		local u = table.clone(original)
		u.BaseCost = math.floor(u.BaseCost * tool.PriceScale)
		if key == "Power" then
			u.MaxLevel, u.Step = tool.MaxLevel, tool.PowerStep
		end
		if key == "Speed" then
			u.MaxLevel, u.Step = tool.MaxLevel, tool.SpeedStep
		end
		c.Upgrades[key] = u
	end
	configs[id] = c
	return c
end
function P.PowerBonus(account)
	local creature = P.Creature(account.equippedCreature)
	return 1 + math.min(1, (account.strength or 0) * 0.0001) + (creature and creature.Power or 0)
end
function P.Level(account, id, key)
	if id == account.toolId then
		return account[key] or 0
	end
	return (account.toolLevels[id] or {})[key] or 0
end
function P.SwitchTool(account, id)
	if not P.Tools[id] or not account.ownedTools[id] then
		return false
	end
	account.toolLevels[account.toolId] = account.toolLevels[account.toolId] or {}
	for _, key in P.UpgradeKeys do
		account.toolLevels[account.toolId][key] = account[key] or 0
	end
	account.toolId = id
	for _, key in P.UpgradeKeys do
		account[key] = (account.toolLevels[id] or {})[key] or 0
	end
	return true
end
return P
