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
