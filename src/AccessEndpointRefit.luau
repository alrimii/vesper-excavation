assert(not game:GetService("RunService"):IsRunning(), "Edit only")
local lab = workspace.VesperLab
local access = lab.ExcavationAccess
assert(not access:FindFirstChild("TerminalLanding"), "Endpoint already refitted")
local archive = Instance.new("Folder")
archive.Name, archive.Parent = "Stage27AccessBackup", game.ServerStorage
access:Clone().Parent = archive
lab.CinematicFixtures:Clone().Parent = archive
local retired = Instance.new("Folder")
retired.Name, retired.Parent = "Retired", archive
local t = 456 / 480
local y = 3.495 + 91.55 * t
local angle = t * math.pi * 10
local phi = math.acos(math.clamp(1 - 2 * (y + 10.2) / 104.04, -1, 1))
local radius = math.max(18, 40.8 * math.sin(phi) * (1 + 0.18 * math.cos(phi)) + 12)
local endPoint = Vector3.new(math.cos(angle) * radius, y, math.sin(angle) * radius)
local priorT = 455 / 480
local priorY = 3.495 + 91.55 * priorT
local priorPhi = math.acos(math.clamp(1 - 2 * (priorY + 10.2) / 104.04, -1, 1))
local priorR = math.max(18, 40.8 * math.sin(priorPhi) * (1 + 0.18 * math.cos(priorPhi)) + 12)
local prior =
	Vector3.new(math.cos(priorT * math.pi * 10) * priorR, y, math.sin(priorT * math.pi * 10) * priorR)
local tangent = (endPoint - prior).Unit
local retiredParts = 0
local offsets =
	{ UpperContinuousDeck = 0, UpperRail = 3, UpperGuard = 1.5, UpperRailPost = 1.5, UpperGuideLens = 0.23 }
local crown = access:FindFirstChild("CrownLookoutV2")
if crown then
	crown.Parent = retired
end
for _, p in access:GetDescendants() do
	local offset = offsets[p.Name]
	if p:IsA("BasePart") and offset and p.Position.Y - offset > y + 0.02 then
		p.Parent = retired
		retiredParts += 1
	end
end
local retiredLights = 0
for _, p in lab.CinematicFixtures:GetChildren() do
	if
		p:IsA("BasePart")
		and (p.Name == "StairGuideLight" or p.Name == "GuideLightHousing")
		and p.Position.Y >= 3.495 + 91.55 * 0.8
	then
		p.Parent = retired
		retiredLights += 1
	end
end
local model = Instance.new("Model")
model.Name = "TerminalLanding"
local basis = CFrame.lookAt(endPoint, endPoint + tangent)
local steel, gold = Color3.fromRGB(58, 68, 77), Color3.fromRGB(224, 160, 68)
local function p(name, size, offset, color, collide)
	local part = Instance.new("Part")
	part.Name, part.Size, part.CFrame = name, size, basis * CFrame.new(offset)
	part.Material, part.Color = Enum.Material.Metal, color
	part.Anchored, part.CanCollide, part.CanTouch, part.CanQuery = true, collide == true, false, true
	part.TopSurface, part.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	part.Parent = model
	return part
end
local deck = p("TerminalDeck", Vector3.new(12, 0.35, 6), Vector3.new(0, 0, -3), steel, true)
deck.Material = Enum.Material.DiamondPlate
for _, x in { -5.9, 5.9 } do
	for _, z in { -0.3, -5.85 } do
		p("TerminalPost", Vector3.new(0.2, 3, 0.2), Vector3.new(x, 1.675, z), steel)
	end
	for _, height in { 1.5, 3 } do
		p("TerminalSideRail", Vector3.new(0.16, 0.16, 5.55), Vector3.new(x, 0.175 + height, -3.075), gold)
	end
	local guard = p("TerminalSideGuard", Vector3.new(0.18, 3, 6), Vector3.new(x, 1.675, -3), steel, true)
	guard.Transparency = 1
end
for _, height in { 1.5, 3 } do
	p("TerminalEndRail", Vector3.new(11.8, 0.16, 0.16), Vector3.new(0, height + 0.175, -5.85), gold)
end
local guard = p("TerminalEndGuard", Vector3.new(12, 3, 0.18), Vector3.new(0, 1.675, -5.85), steel, true)
guard.Transparency = 1
model.Parent = access
access:SetAttribute("TerminalHeight", y)
return {
	retiredStairParts = retiredParts,
	retiredLightParts = retiredLights,
	terminalHeight = y,
	terminalRadius = radius,
}
