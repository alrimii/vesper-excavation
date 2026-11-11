-- Shared presentation data. Rewards are decided by the server.
local D = {}
D.SamplesRequired = 6
D.Specimens = {
	{
		Id = "crownback",
		Name = "Vesper Crownback",
		Class = "ANCIENT / 001",
		Color = Color3.fromRGB(238, 188, 103),
		Clue = "A heavy heartbeat. Something shifts inside the sealed membrane.",
		Description = "An ancient armored drake awakened from the mineral shell.",
		Reward = 650,
	},
	{
		Id = "crystal_triceratops",
		Name = "Crystal Triceratops",
		Class = "OWNER TEST / ACQUISITION UNCONFIGURED",
		Color = Color3.fromRGB(104, 226, 209),
		Clue = "A crystal-crowned herbivore awaits a future expedition.",
		Description = "Crystal horns, a sturdy frill and a bright, curious face. Owner test access only.",
		Reward = 0,
		TestOnly = true,
		Icon = "rbxassetid://102662158340345",
	},
	{
		Id = "frost_spirit_mammoth",
		Name = "Frost Spirit Mammoth",
		Class = "OWNER TEST / ACQUISITION UNCONFIGURED",
		Color = Color3.fromRGB(168, 226, 237),
		Clue = "A frostbound skeleton carries a quiet crystal spirit.",
		Description = "Bone arches and icy crystals. Owner test access only.",
		Reward = 0,
		TestOnly = true,
		Icon = "rbxassetid://92417754262688",
	},
	{
		Id = "volcanic_sabertooth",
		Name = "Volcanic Sabertooth",
		Class = "OWNER TEST / ACQUISITION UNCONFIGURED",
		Color = Color3.fromRGB(255, 151, 77),
		Clue = "Two long fangs guard a volcanic hunter.",
		Description = "A striped hunter with twin saber teeth. Owner test access only.",
		Reward = 0,
		TestOnly = true,
		Icon = "rbxassetid://87450192565257",
	},
	{
		Id = "fossil_tortoise",
		Name = "Fossil Tortoise",
		Class = "OWNER TEST / ACQUISITION UNCONFIGURED",
		Color = Color3.fromRGB(126, 210, 183),
		Clue = "Ancient spirals decorate a patient shell bearer.",
		Description = "A fossil-studded shell and sturdy feet. Owner test access only.",
		Reward = 0,
		TestOnly = true,
		Icon = "rbxassetid://113226296678070",
	},
}
function D.ForRound(_round)
	return D.Specimens[1]
end
function D.Level(xp)
	return require(script.Parent.SkillCatalog).Level(math.max(0, xp))
end
function D.Contract(index)
	local templates = {
		{ "Break", 5, "Break 5 shell plates", 15 },
		{ "Collect", 24, "Collect 24 material", 20 },
		{ "Sell", 1, "Sell a load of material", 18 },
		{ "Upgrade", 2, "Buy 2 upgrade levels", 25 },
		{ "Break", 12, "Break 12 plates", 35 },
	}
	local t = templates[(index - 1) % #templates + 1]
	return { Kind = t[1], Goal = t[2], Title = t[3], Reward = t[4] + math.floor((index - 1) / #templates) * 4 }
end
return D
