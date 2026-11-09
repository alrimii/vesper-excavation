-- Run in edit mode. Rebuildable staging for the discovery release.
local lab = workspace.VesperLab
local old = lab:FindFirstChild("ResearchGallery")
if old then
	old:Destroy()
end
local gallery = Instance.new("Model")
gallery.Name = "ResearchGallery"
gallery.Parent = lab
local catalog = require(game.ReplicatedStorage.VesperShared.DiscoveryCatalog)
local builder = require(game.ReplicatedStorage.VesperShared.SpecimenBuilder)
local function part(parent, name, size, cf, color, material)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.Metal
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end
for i, entry in catalog.Specimens do
	local a = math.rad(-65 + (i - 1) * 26)
	local pos = Vector3.new(math.sin(a) * 78, 1, math.cos(a) * 78)
	local pod = Instance.new("Model")
	pod.Name = entry.Id
	pod.Parent = gallery
	local base = part(pod, "Pedestal", Vector3.new(10, 1.6, 10), CFrame.new(pos), Color3.fromRGB(25, 38, 54))
	local accent = part(
		pod,
		"LightBand",
		Vector3.new(10.15, 0.16, 10.15),
		CFrame.new(pos + Vector3.new(0, 0.75, 0)),
		entry.Color,
		Enum.Material.Neon
	)
	accent.CanCollide = false
	accent.CanQuery = false
	accent.CanTouch = false
	local display = builder.Build(entry.Id, entry.Color)
	display:ScaleTo(0.8)
	display:PivotTo(CFrame.lookAt(pos + Vector3.new(0, 4, 0), Vector3.new(0, 5, 0)))
	display.Parent = pod
	for _, p in display:GetDescendants() do
		if p:IsA("BasePart") then
			p:SetAttribute("OriginalColor", p.Color)
			p.Color = Color3.fromRGB(28, 45, 60)
		end
	end
	local label = Instance.new("BillboardGui")
	label.Name = "Plaque"
	label.Adornee = base
	label.Size = UDim2.fromOffset(170, 54)
	label.StudsOffset = Vector3.new(0, 9, 0)
	label.MaxDistance = 95
	label.AlwaysOnTop = false
	label.Parent = pod
	local t = Instance.new("TextLabel")
	t.Name = "Title"
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundColor3 = Color3.fromRGB(12, 23, 34)
	t.BackgroundTransparency = 0.2
	t.TextColor3 = entry.Color
	t.TextSize = 13
	t.Font = Enum.Font.GothamBold
	t.Text = entry.Class .. "\nUNDISCOVERED"
	t.Parent = label
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = t
end
local sign =
	part(gallery, "ArchiveSign", Vector3.new(28, 6, 0.6), CFrame.new(0, 10, 92), Color3.fromRGB(16, 28, 43))
sign.CanCollide = false
local surface = Instance.new("SurfaceGui")
surface.Face = Enum.NormalId.Front
surface.CanvasSize = Vector2.new(840, 180)
surface.Parent = sign
local title = Instance.new("TextLabel")
title.Size = UDim2.fromScale(1, 1)
title.BackgroundTransparency = 1
title.Text = "THE LIVING ARCHIVE\nEXCAVATE  /  DISCOVER  /  COLLECT"
title.Font = Enum.Font.GothamBold
title.TextSize = 39
title.TextColor3 = Color3.fromRGB(143, 230, 218)
title.Parent = surface
local L = game:GetService("Lighting")
L.Brightness = 2.4
L.ClockTime = 14
L.Ambient = Color3.fromRGB(78, 91, 116)
L.OutdoorAmbient = Color3.fromRGB(93, 111, 137)
L.ExposureCompensation = 0.2
local grade = L:FindFirstChild("VesperGrade")
if grade then
	grade.TintColor = Color3.fromRGB(238, 247, 255)
	grade.Contrast = 0.035
	grade.Saturation = -0.05
	grade.Brightness = 0.015
end
for _, v in L:GetChildren() do
	if v:IsA("BloomEffect") then
		v.Intensity = 0.18
		v.Size = 24
		v.Threshold = 1.4
	end
end
for _, v in lab:GetDescendants() do
	if v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then
		if v.Color.G > v.Color.R * 1.3 then
			v.Color = Color3.fromRGB(179, 226, 242)
		end
	end
end
require(game.ReplicatedStorage.VesperShared.ExcavationUI).Build(game.StarterGui)
workspace:SetAttribute("VesperRelease", "Discovery 1.0")
return "Discovery staging rebuilt: 6 specimen exhibits, lighting, HUD."
