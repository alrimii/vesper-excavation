-- Edit-time, persistent native geometry. No runtime mesh permissions required.
assert(not game:GetService("RunService"):IsRunning(), "Edit only")
local lab = workspace.VesperLab
local access = lab.ExcavationAccess
assert(not access:FindFirstChild("CrownLookoutV2"), "Polish already installed")
local archive = Instance.new("Folder")
archive.Name = "BeforeAccessPolish_20261109"
local snapshot = access:Clone()
snapshot.Parent = archive
archive.Parent = game.ServerStorage
local model = Instance.new("Model")
model.Name = "CrownLookoutV2"
local steel, edge, amber =
	Color3.fromRGB(58, 68, 77), Color3.fromRGB(115, 126, 132), Color3.fromRGB(224, 160, 68)
local function part(name, size, cf, color, collide, class)
	local p = Instance.new(class or "Part")
	p.Name, p.Size, p.CFrame = name, size, cf
	p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery = true, collide == true, false, false
	p.Material, p.Color, p.Reflectance = Enum.Material.Metal, color or steel, 0
	p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	p.Parent = model
	return p
end
local function beam(name, a, b, width, color)
	return part(name, Vector3.new(width, width, (b - a).Magnitude), CFrame.lookAt((a + b) / 2, b), color)
end
local function point(a, r, y)
	return Vector3.new(math.cos(a) * r, y, math.sin(a) * r)
end
-- Triangular prisms tile each annular sector edge-to-edge. No coplanar overlaps.
local function triangle(a, b, c)
	local ab, ac, bc = b - a, c - a, c - b
	if ab:Dot(ab) > ac:Dot(ac) and ab:Dot(ab) > bc:Dot(bc) then
		c, a = a, c
	elseif ac:Dot(ac) > bc:Dot(bc) then
		a, b = b, a
	end
	ab, ac, bc = b - a, c - a, c - b
	local right = ac:Cross(ab).Unit
	local back = bc.Unit
	local up = bc:Cross(right).Unit
	local height = math.abs(ab:Dot(up))
	local one = part(
		"FittedDeck",
		Vector3.new(0.35, height, math.abs(ab:Dot(back))),
		CFrame.fromMatrix((a + b) / 2, right, up, back),
		steel,
		true,
		"WedgePart"
	)
	local two = part(
		"FittedDeck",
		Vector3.new(0.35, height, math.abs(ac:Dot(back))),
		CFrame.fromMatrix((a + c) / 2, -right, up, -back),
		steel,
		true,
		"WedgePart"
	)
	one.Material, two.Material = Enum.Material.DiamondPlate, Enum.Material.DiamondPlate
end
local y = 95.045
for i = 0, 11 do
	local a, b = i / 12 * math.pi / 2, (i + 1) / 12 * math.pi / 2
	local p, q, r, s = point(a, 12, y), point(a, 24, y), point(b, 24, y), point(b, 12, y)
	triangle(p, q, r)
	triangle(p, r, s)
	beam("OuterRim", q - Vector3.yAxis * 0.28, r - Vector3.yAxis * 0.28, 0.28, edge)
	beam("InnerRim", p - Vector3.yAxis * 0.28, s - Vector3.yAxis * 0.28, 0.28, edge)
	for _, height in { 1.5, 3 } do
		beam(
			"LookoutRail",
			point(a, 24, y + height),
			point(b, 24, y + height),
			0.15,
			height == 3 and amber or edge
		)
	end
	local wall = part(
		"LookoutGuard",
		Vector3.new(0.18, 3, (r - q).Magnitude + 0.03),
		CFrame.lookAt((q + r) / 2 + Vector3.yAxis * 1.5, r + Vector3.yAxis * 1.5),
		steel,
		true
	)
	wall.Transparency = 1
	if i % 3 == 0 then
		part("LookoutPost", Vector3.new(0.22, 3.15, 0.22), CFrame.new(point(a, 24, y + 1.5)), edge)
		part("PostShoe", Vector3.new(0.65, 0.14, 0.65), CFrame.new(point(a, 24, y + 0.22)), steel)
		beam("DeckRib", point(a, 12, y - 0.38), point(a, 24, y - 0.38), 0.4, edge)
	end
end
local endA, endB = point(math.pi / 2, 12, y), point(math.pi / 2, 24, y)
for _, height in { 1.5, 3 } do
	beam(
		"EndRail",
		endA + Vector3.yAxis * height,
		endB + Vector3.yAxis * height,
		0.18,
		height == 3 and amber or edge
	)
end
for _, p in { endA, endB } do
	part("EndPost", Vector3.new(0.25, 3.2, 0.25), CFrame.new(p + Vector3.yAxis * 1.5), edge)
end
local guard = part(
	"EndGuard",
	Vector3.new(0.2, 3, 12),
	CFrame.lookAt((endA + endB) / 2 + Vector3.yAxis * 1.5, endB + Vector3.yAxis * 1.5),
	steel,
	true
)
guard.Transparency = 1
-- Connect the lookout to the outer edge of the preceding turn.
for _, a in { math.pi / 6, math.pi / 3, math.pi / 2 } do
	local t = 0.8 + a / (math.pi * 10)
	local lowerY = 3.495 + 91.55 * t
	local phi = math.acos(math.clamp(1 - 2 * (lowerY + 10.2) / 104.04, -1, 1))
	local lowerR = math.max(18, 40.8 * math.sin(phi) * (1 + 0.18 * math.cos(phi)) + 12) + 5.5
	beam("LookoutStrut", point(a, lowerR, lowerY - 0.35), point(a, 23.5, y - 0.5), 0.45, steel)
end
local retired = 0
for _, p in access:GetDescendants() do
	if p:IsA("BasePart") then
		if string.sub(p.Name, 1, 5) == "Crown" then
			p.Parent = archive
			retired += 1
		elseif p.Name == "SmoothOuterBarrier" then
			-- Imported trim already provides the rail; glass here overlaps it at every joint.
			p.Transparency = 1
		elseif
			string.match(p.Name, "^Access_%d_Deck$")
			or p.Name == "UpperContinuousDeck"
			or p.Name == "LadderTransferLanding"
		then
			p.Color, p.Material, p.Reflectance = steel, Enum.Material.DiamondPlate, 0
		elseif
			string.match(p.Name, "^Access_%d_Trim$")
			or p.Name == "UpperRail"
			or p.Name == "LadderRail"
		then
			p.Color, p.Material, p.Reflectance = edge, Enum.Material.Metal, 0
		elseif p.Name == "UpperRailPost" then
			p.Color = amber
		elseif p.Name == "OutboardSupport" then
			p.Size = Vector3.new(0.8, p.Size.Y, 0.8)
			p.Color = steel
		elseif p.Name == "OutboardBrace" then
			p.Size = Vector3.new(0.32, 0.32, p.Size.Z)
			p.Color = steel
		end
	end
end
-- Small lights no longer cast distracting hard shadows across the walking surface.
for _, p in lab.CinematicFixtures:GetDescendants() do
	if p:IsA("BasePart") and p.Name == "StairGuideLight" then
		p.Color = Color3.fromRGB(228, 190, 126)
	end
end
model.Parent = access
access:SetAttribute("PolishVersion", "FittedLookoutV2")
return { retiredCrownParts = retired, newParts = #model:GetChildren(), landingArcDegrees = 90 }
