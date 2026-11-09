from pathlib import Path
R=Path(__file__).resolve().parent
p=R/'ExcavationConfig.luau';s=p.read_text(encoding='utf-8').replace('Cooldown = 0.64, MinimumCooldown = 0.36','Cooldown = 0.60, MinimumCooldown = 0.30')
a=s.index('\tUpgrades = {');b=s.index('\n\tCompletion',a)
s=s[:a]+'''\tUpgrades = {
		Power = { Name = "Impact Core", Description = "Break tough plates with fewer strikes.", BaseCost = 18, CostGrowth = 1.12, MaxLevel = 30, Step = 2, Icon = "Power" },
		Speed = { Name = "Rapid Drive", Description = "Shorten the full strike cycle.", BaseCost = 24, CostGrowth = 1.14, MaxLevel = 25, Step = 0.012, Icon = "Speed" },
		Capacity = { Name = "Field Storage", Description = "Stay on the egg longer between sales.", BaseCost = 16, CostGrowth = 1.11, MaxLevel = 40, Step = 10, Icon = "Capacity" },
		Precision = { Name = "Precision Tip", Description = "Reward accurate hits on the gold point.", BaseCost = 30, CostGrowth = 1.14, MaxLevel = 20, Step = 0.02, Icon = "Pickaxe" },
		Yield = { Name = "Sample Extractor", Description = "Collect extra material from every plate.", BaseCost = 45, CostGrowth = 1.18, MaxLevel = 15, Step = 1, Icon = "Bucket" },
		Value = { Name = "Material Refinery", Description = "Increase the value of each sale.", BaseCost = 30, CostGrowth = 1.15, MaxLevel = 25, Step = 0.02, Icon = "Cash" },
		Critical = { Name = "Resonance Head", Description = "Chance for a 1.5x damage strike.", BaseCost = 40, CostGrowth = 1.15, MaxLevel = 20, Step = 0.0125, Icon = "Power" },
	},'''+s[b:];p.write_text(s,encoding='utf-8')
p=R/'ResearchProfiles.luau';s=p.read_text(encoding='utf-8')
s=s.replace('local token =','local C = require(game.ReplicatedStorage.VesperShared.ExcavationConfig)\n\tlocal token =',1)
s=s.replace('Power = number(raw.Power, 8),','Power = number(raw.Power, C.Upgrades.Power.MaxLevel),').replace('Speed = number(raw.Speed, 6),','Speed = number(raw.Speed, C.Upgrades.Speed.MaxLevel),').replace('Capacity = number(raw.Capacity, 10),','Capacity = number(raw.Capacity, C.Upgrades.Capacity.MaxLevel),\n\t\t\teconomyVersion = 2,')
s=s.replace('\t\tfor _, id in { "Shell",','''		for key, upgrade in C.Upgrades do a[key] = number(raw[key], upgrade.MaxLevel) end
		if raw.economyVersion ~= 2 then
			a.Power = math.min(C.Upgrades.Power.MaxLevel, math.ceil(number(raw.Power,8)*7/2))
			a.Speed = math.min(C.Upgrades.Speed.MaxLevel, math.ceil(number(raw.Speed,6)*0.04/0.012))
			a.Capacity = math.min(C.Upgrades.Capacity.MaxLevel, number(raw.Capacity,10)*2)
		end
		for _, id in { "Shell",''')
s=s.replace('raw.contents[id], 240','raw.contents[id], 2000');p.write_text(s,encoding='utf-8')
p=R/'ExcavationService.luau';s=p.read_text(encoding='utf-8').replace('local Catalog =','local Economy = require(Shared.UpgradeEconomy)\nlocal random = Random.new()\nlocal Catalog =',1)
s=s.replace('math.floor(u.BaseCost * u.CostGrowth ^ a[key] + 0.5)','Economy.Price(key, a[key])').replace('\tlocal u = C.Upgrades[key]\n\treturn Economy.Price','\treturn Economy.Price')
s=s.replace('StrikeCooldown = cd,','StrikeCooldown = cd,\n\t\t\tYieldBonus = a.Yield,\n\t\t\tSaleMultiplier = 1 + a.Value * C.Upgrades.Value.Step,\n\t\t\tPrecisionMultiplier = C.Precision.Multiplier + a.Precision * C.Upgrades.Precision.Step,\n\t\t\tCriticalChance = a.Critical * C.Upgrades.Critical.Step,')
s=s.replace('used(a) + C.Layers[data.layer].Yield >','used(a) + C.Layers[data.layer].Yield + a.Yield >')
s=s.replace('C.Precision.Multiplier + math.max(0, chain - 1)', '(C.Precision.Multiplier + a.Precision * C.Upgrades.Precision.Step) + math.max(0, chain - 1)')
s=s.replace('local damage = math.min(data.hp, math.floor(power * multiplier + 0.5))','local critical = random:NextNumber() < a.Critical * C.Upgrades.Critical.Step\n\t\tlocal damage = math.min(data.hp, math.floor(power * multiplier * (critical and 1.5 or 1) + 0.5))')
s=s.replace('\t\t\tprecise\n\t\t)', '\t\t\tprecise,\n\t\t\tcritical\n\t\t)')
s=s.replace('a.contents[layer.Id] = (a.contents[layer.Id] or 0) + layer.Yield','local amount = layer.Yield + a.Yield\n\t\t\ta.contents[layer.Id] = (a.contents[layer.Id] or 0) + amount').replace('advance(p, "Collect", layer.Yield)','advance(p, "Collect", amount)').replace('"Collected", layer.Yield','"Collected", amount')
s=s.replace('local function station(p, action)','''local function purchase(p, key, quantity)
	local a = accounts[p.UserId]
	local u = C.Upgrades[key]
	if not a or not u or not alive(p) then return end
	if quantity ~= 1 and quantity ~= 5 and quantity ~= "Max" then return end
	local count, cost = Economy.Quote(key, a[key], a.cash, quantity)
	if count == 0 then note(p, a[key] >= u.MaxLevel and "Upgrade complete." or "Need $" .. Economy.Price(key,a[key]) .. " for the next level.") return end
	a.cash -= cost
	a[key] += count
	advance(p, "Upgrade", count)
	tutorial(p, "AtUpgrade")
	syncPlayer(p)
	Feedback:FireClient(p, "UpgradeBought", key, count)
end
local function station(p, action)''')
s=s.replace('\t\tif value <= 0 then','\t\tvalue = math.floor(value * (1 + a.Value * C.Upgrades.Value.Step) + 0.5)\n\t\tif value <= 0 then',1)
a=s.index('\telse\n\t\tlocal u = C.Upgrades[action]',s.index('local function station'));b=s.index('\n\tend\nend\nAction.OnServerEvent',a);s=s[:a]+'\telse\n\t\tpurchase(p, action, 1)'+s[b:]
s=s.replace('\telseif terminalByAction[kind] then','''	elseif kind == "Upgrade" then
		if typeof(a) ~= "string" or not C.Upgrades[a] or now - s.lastStation < 0.20 then return end
		s.lastStation = now
		purchase(p, a, b)
	elseif terminalByAction[kind] then''')
p.write_text(s,encoding='utf-8')
p=R/'DiscoveryCatalog.luau';s=p.read_text(encoding='utf-8');a=s.index('\tlocal templates = {');b=s.index('\n\tlocal t =',a)
s=s[:a]+'''\tlocal templates = {
		{ "Break", 5, "Break 5 shell plates", 15 },
		{ "Collect", 24, "Collect 24 material", 20 },
		{ "Sell", 1, "Sell a load of material", 18 },
		{ "Upgrade", 2, "Buy 2 upgrade levels", 25 },
		{ "Break", 12, "Break 12 plates", 35 },
	}'''+s[b:];s=s.replace('% #templates','% #templates').replace('/ 4) * 20','/ #templates) * 4');p.write_text(s,encoding='utf-8')
