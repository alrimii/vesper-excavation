local lab = workspace.VesperLab
local access = lab.ExcavationAccess
assert(not access:FindFirstChild("DeploymentSections"), "Refit already applied")
local retired = Instance.new("Folder")
retired.Name = "Retired"
retired.Parent = game.ServerStorage.Stage29CentralRepairBackup
for _, p in lab.ResourceDepot:GetDescendants() do
	if p:IsA("ProximityPrompt") or p:IsA("Light") or p:IsA("LayerCollector") then
		p.Enabled = false
	end
	if p:IsA("BasePart") then
		p.CanCollide, p.CanTouch, p.CanQuery = false, false, false
	end
end
for _, p in lab.CinematicFixtures:GetChildren() do
	if p.Name == "StairGuideLight" or p.Name == "GuideLightHousing" then
		p.Parent = retired
	end
end
access.MountedAccessLights.Parent = retired
access.BlenderAccessFinish.Parent = retired
local sections = Instance.new("Folder")
sections.Name = "DeploymentSections"
sections.Parent = access
local decks = {}
for _, p in access:GetDescendants() do
	if p.Name == "ContinuousRamp" or p.Name == "UpperContinuousDeck" then
		table.insert(decks, p)
	end
end
table.sort(decks, function(a, b)
	return a.Position.Y < b.Position.Y
end)
local function part(model, name, size, cf, color)
	local p = Instance.new("Part")
	p.Name, p.Size, p.CFrame = name, size, cf
	p.Color, p.Material = color, Enum.Material.Metal
	p.Anchored = true
	p.CanCollide, p.CanTouch, p.CanQuery = false, false, false
	p.CastShadow = false
	p.Parent = model
	return p
end
local models = {}
for i, deck in decks do
	local model = Instance.new("Model")
	model.Name = string.format("Section%03d", i)
	local radial = Vector3.new(deck.Position.X, 0, deck.Position.Z).Unit
	local sign = deck.CFrame.RightVector:Dot(radial) > 0 and 1 or -1
	model:SetAttribute("Hinge", deck.CFrame * CFrame.new(sign * 6, 0, 0))
	model:SetAttribute("FoldSign", -sign)
	model:SetAttribute("Rank", (i - 1) / #decks)
	deck.Transparency = 0
	deck.Material = Enum.Material.DiamondPlate
	deck.Color = Color3.fromRGB(49, 61, 72)
	deck.Parent = model
	local railX = sign * 5.9
	part(
		model,
		"EdgeBeam",
		Vector3.new(0.22, 0.45, deck.Size.Z - 0.2),
		deck.CFrame * CFrame.new(railX, -0.12, 0),
		Color3.fromRGB(86, 102, 115)
	)
	for _, y in { 1.5, 3 } do
		part(
			model,
			"Handrail",
			Vector3.new(0.16, 0.16, deck.Size.Z - 0.15),
			deck.CFrame * CFrame.new(railX, y, 0),
			Color3.fromRGB(125, 140, 149)
		)
	end
	if i % 4 == 0 or i == 1 then
		part(
			model,
			"RailPost",
			Vector3.new(0.2, 3, 0.2),
			deck.CFrame * CFrame.new(railX, 1.5, 0),
			Color3.fromRGB(86, 102, 115)
		)
	end
	model.Parent = sections
	models[i] = { model = model, deck = deck }
	if i % 80 == 0 then
		task.wait()
	end
end
for _, p in access:GetDescendants() do
	if p.Name == "SmoothOuterBarrier" or p.Name == "UpperGuard" then
		local best, dist = nil, math.huge
		for _, entry in models do
			local d = (entry.deck.Position - p.Position + Vector3.yAxis * 1.5).Magnitude
			if d < dist then
				best, dist = entry.model, d
			end
		end
		p.Parent = best
	elseif p.Name == "UpperRail" or p.Name == "UpperRailPost" or p.Name == "UpperGuideLens" then
		p.Parent = retired
	end
end
local terminal = access.TerminalLanding
local deck = terminal.TerminalDeck
local radial = Vector3.new(deck.Position.X, 0, deck.Position.Z).Unit
local sign = deck.CFrame.RightVector:Dot(radial) > 0 and 1 or -1
terminal:SetAttribute("Hinge", deck.CFrame * CFrame.new(sign * 6, 0, 0))
terminal:SetAttribute("FoldSign", -sign)
terminal:SetAttribute("Rank", 1)
terminal.Parent = sections
return { sections = #decks + 1, retired = #retired:GetChildren() }
