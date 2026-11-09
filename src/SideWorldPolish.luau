assert(not game:GetService("RunService"):IsRunning(), "Edit only")
local lab = workspace.VesperLab
local access = lab.ExcavationAccess
local startY = 3.495 + 91.55 * 0.2
local upperY = 3.495 + 91.55 * 0.8
local old = access:FindFirstChild("AccessRevision4")
if old then
	old:Destroy()
end
local build = Instance.new("Model")
build.Name = "AccessRevision4"
build.Parent = access
local steel = Color3.fromRGB(43, 57, 70)
local gold = Color3.fromRGB(190, 158, 96)
local function part(name, size, cf, color, collide, parent, class)
	local p = Instance.new(class or "Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color or steel
	p.Material = Enum.Material.Metal
	p.Anchored = true
	p.CanCollide = collide == true
	p.CanQuery = false
	p.CanTouch = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent or build
	return p
end
local function point(angle, radius, y)
	return Vector3.new(math.cos(angle) * radius, y, math.sin(angle) * radius)
end
local function path(t, offset)
	local y = 3.495 + 91.55 * t
	local phi = math.acos(math.clamp(1 - 2 * (y + 10.2) / 104.04, -1, 1))
	local radius = math.max(18, 40.8 * math.sin(phi) * (1 + 0.18 * math.cos(phi)) + 12)
	return point(t * math.pi * 10, radius + (offset or 0), y)
end
local function beam(name, a, b, width, color)
	return part(
		name,
		Vector3.new(width, width, (b - a).Magnitude),
		CFrame.lookAt((a + b) / 2, b),
		color,
		false
	)
end
local function deck(name, a, b, width)
	local p = part(
		name,
		Vector3.new(width, 0.35, (b - a).Magnitude + 0.35),
		CFrame.lookAt((a + b) / 2, b),
		steel,
		true
	)
	p.Material = Enum.Material.DiamondPlate
	return p
end
for _, p in access:GetChildren() do
	local index = p:GetAttribute("RouteIndex")
	if
		(index and (index < 96 or index >= 384))
		or (p.Name == "SmoothOuterBarrier" and (p.Position.Y < startY + 1.55 or p.Position.Y > upperY + 1.55))
		or p.Name:match("^Crown")
		or p.Name:match("^LandingEnd")
	then
		p:Destroy()
	end
end
for _, name in { "Access_0_Deck", "Access_0_Trim", "Access_4_Deck", "Access_4_Trim" } do
	local p = access.BlenderAccessFinish:FindFirstChild(name)
	if p then
		p:Destroy()
	end
end
-- Remove lights that belonged to the deleted ground spiral.
for _, p in lab.CinematicFixtures:GetChildren() do
	if (p.Name == "GuideLightHousing" or p.Name == "StairGuideLight") and p.Position.Y < startY then
		p:Destroy()
	end
end
local entry = path(0.2)
local landing = part(
	"LadderTransferLanding",
	Vector3.new(12, 0.4, 9),
	CFrame.new(entry + Vector3.new(0, 0, -4)),
	steel,
	true
)
landing.Material = Enum.Material.DiamondPlate
local ladderBottom = 3.75
local ladderTop = startY + 0.2
local ladderCenter = Vector3.new(entry.X, (ladderBottom + ladderTop) / 2, -8)
local truss = part(
	"ClimbableEntry",
	Vector3.new(4, ladderTop - ladderBottom, 2),
	CFrame.new(ladderCenter),
	steel,
	true,
	build,
	"TrussPart"
)
truss.Transparency = 1
for _, side in { -1, 1 } do
	part(
		"LadderRail",
		Vector3.new(0.25, ladderTop - ladderBottom + 3, 0.3),
		CFrame.new(ladderCenter + Vector3.new(side * 2.2, 1.5, 0)),
		gold,
		false
	)
	beam(
		"LandingHandrail",
		entry + Vector3.new(side * 5.9, 3, -8),
		entry + Vector3.new(side * 5.9, 3, 0),
		0.14,
		gold
	)
	local wall = part(
		"LandingGuard",
		Vector3.new(0.2, 3, 8),
		CFrame.new(entry + Vector3.new(side * 5.9, 1.5, -4)),
		steel,
		true
	)
	wall.Transparency = 1
end
for y = ladderBottom + 0.35, ladderTop, 1.05 do
	part(
		"LadderRung",
		Vector3.new(4.4, 0.16, 0.32),
		CFrame.new(entry.X, y, -8),
		Color3.fromRGB(163, 184, 191),
		false
	)
end
part("EntryFooting", Vector3.new(10, 0.18, 6), CFrame.new(entry.X, 3.73, -11), steel, true)
local sign = part("AccessSign", Vector3.new(4.5, 2, 0.18), CFrame.new(entry.X + 4.5, 6.5, -8), steel, false)
local sg = Instance.new("SurfaceGui")
sg.Face = Enum.NormalId.Front
sg.CanvasSize = Vector2.new(450, 200)
sg.Parent = sign
local label = Instance.new("TextLabel")
label.Size = UDim2.fromScale(1, 1)
label.BackgroundTransparency = 1
label.Text = "EXCAVATION ACCESS\nCLIMB TO WALKWAY"
label.TextColor3 = Color3.fromRGB(241, 208, 145)
label.TextSize = 34
label.Font = Enum.Font.GothamBold
label.Parent = sg
local maxGap = 0
local previous
for i = 384, 479 do
	local t, u = i / 480, (i + 1) / 480
	local a, b = path(t), path(u)
	if previous then
		maxGap = math.max(maxGap, (a - previous).Magnitude)
	end
	previous = b
	deck("UpperContinuousDeck", a, b, 12)
	local x, z = path(t, 6), path(u, 6)
	beam("UpperRail", x + Vector3.yAxis * 3, z + Vector3.yAxis * 3, 0.14, gold)
	local wall = part(
		"UpperGuard",
		Vector3.new(0.2, 3, (z - x).Magnitude + 0.35),
		CFrame.lookAt((x + z) / 2 + Vector3.yAxis * 1.5, z + Vector3.yAxis * 1.5),
		steel,
		true
	)
	wall.Transparency = 1
	if i % 8 == 0 then
		part("UpperRailPost", Vector3.new(0.16, 3, 0.16), CFrame.new(x + Vector3.yAxis * 1.5), gold, false)
		local lens = part(
			"UpperGuideLens",
			Vector3.new(0.25, 0.06, 1.4),
			CFrame.lookAt(a, b) * CFrame.new(5.3, 0.23, 0),
			Color3.fromRGB(237, 208, 146),
			false
		)
		lens.Material = Enum.Material.Neon
		lens.CastShadow = false
	end
	if i % 24 == 0 then
		task.wait()
	end
end
for i = 0, 47 do
	local a, b = i / 96 * math.pi * 2, (i + 1) / 96 * math.pi * 2
	deck("CrownDeck", point(a, 18, 95.045), point(b, 18, 95.045), 12)
	local x, z = point(a, 24, 98.045), point(b, 24, 98.045)
	beam("CrownRail", x, z, 0.14, gold)
	local wall = part(
		"CrownGuard",
		Vector3.new(0.2, 3, (z - x).Magnitude + 0.25),
		CFrame.lookAt((x + z) / 2 - Vector3.yAxis * 1.5, z - Vector3.yAxis * 1.5),
		steel,
		true
	)
	wall.Transparency = 1
	if i % 12 == 0 then
		part("CrownSupport", Vector3.new(0.18, 3, 0.18), CFrame.new(point(a, 24, 96.545)), gold, false)
	end
end
-- A half-circle lookout: open at the ascending ramp, safely capped at the far end.
local capA, capB = point(math.pi, 12, 98.045), point(math.pi, 24, 98.045)
beam("CrownEndRail", capA, capB, 0.18, gold)
local cap = part("CrownEndGuard", Vector3.new(12, 3, 0.25), CFrame.new(-18, 96.545, 0), steel, true)
cap.Transparency = 1
part("CrownEndPost", Vector3.new(0.18, 3, 0.18), CFrame.new(-12, 96.545, 0), gold, false)
-- Low-cost environmental motion: sparse vent particles and a small set of status lights.
local prior = lab:FindFirstChild("AtmosphereDetails")
if prior then
	prior:Destroy()
end
local details = Instance.new("Model")
details.Name = "AtmosphereDetails"
details.Parent = lab
for i = 0, 7 do
	local a = i / 8 * math.pi * 2
	local pos = point(a, 72, 4)
	local base = part(
		"CoolingVent",
		Vector3.new(3, 0.3, 1.8),
		CFrame.new(pos) * CFrame.Angles(0, -a, 0),
		steel,
		false,
		details
	)
	local attachment = Instance.new("Attachment")
	attachment.Parent = base
	local mist = Instance.new("ParticleEmitter")
	mist.Name = "VentMist"
	mist.Texture = "rbxasset://textures/particles/smoke_main.dds"
	mist.Rate = 0.6
	mist.Lifetime = NumberRange.new(2, 3.5)
	mist.Speed = NumberRange.new(0.7, 1.3)
	mist.SpreadAngle = Vector2.new(12, 12)
	mist.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 2) })
	mist.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.25, 0.89),
		NumberSequenceKeypoint.new(1, 1),
	})
	mist.Color = ColorSequence.new(Color3.fromRGB(176, 201, 211))
	mist.LightInfluence = 1
	mist.Parent = attachment
	local lens = part(
		"StatusLens",
		Vector3.new(1.6, 0.06, 0.18),
		base.CFrame * CFrame.new(0, 0.19, 0),
		Color3.fromRGB(93, 185, 180),
		false,
		details
	)
	lens.Material = Enum.Material.Neon
	lens.CastShadow = false
	lens:SetAttribute("PulsePhase", i * 0.7)
	local light = Instance.new("PointLight")
	light.Brightness = 0.25
	light.Range = 10
	light.Shadows = false
	light.Color = lens.Color
	light.Parent = lens
end
local lighting = game:GetService("Lighting")
lighting.EnvironmentSpecularScale = 0.48
lighting.EnvironmentDiffuseScale = 0.70
lighting.Ambient = Color3.fromRGB(119, 129, 144)
lighting.OutdoorAmbient = Color3.fromRGB(130, 142, 158)
lighting.ExposureCompensation = 0.12
lighting.Brightness = 2
access:SetAttribute("LayoutVersion", "LadderEntrySemicircleV5")
access:SetAttribute("UpperEndpointGap", maxGap)
return {
	entryHeight = startY,
	ladderHeight = ladderTop - ladderBottom,
	upperJoinGap = maxGap,
	crown = "connected semicircle with end guard",
	ventCount = 8,
}
