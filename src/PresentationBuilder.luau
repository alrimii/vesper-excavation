-- Edit-time art pass. Preserves room, station and excavation identities.
local P = {}
local amber = Color3.fromRGB(239, 177, 83)
local ice = Color3.fromRGB(110, 202, 206)
local dark = Color3.fromRGB(29, 39, 47)
local function part(parent, name, size, cf, color, material)
	local p = Instance.new("Part")
	p.Name, p.Size, p.CFrame = name, size, cf
	p.Color, p.Material = color, material or Enum.Material.Metal
	p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery = true, false, false, false
	p.CastShadow = false
	p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end
local function ring(parent, name, radius, y, width, color, material)
	for i = 0, 95 do
		local a = (i + 0.5) * math.pi / 48
		part(
			parent,
			name,
			Vector3.new(width, 0.08, 2 * radius * math.tan(math.pi / 96) + 0.025),
			CFrame.new(math.cos(a) * radius, y, math.sin(a) * radius) * CFrame.Angles(0, -a, 0),
			color,
			material
		)
	end
end
function P.Build()
 assert(not (workspace:FindFirstChild("VesperLab") and workspace.VesperLab:GetAttribute("MapCleanupRevision")), "Historical recipe retired; use MapCleanupBuilder for the current map")

	local lab = workspace.VesperLab
	local old = lab:FindFirstChild("Presentation")
	if old then
		old:Destroy()
	end
	local decor = Instance.new("Model")
	decor.Name = "Presentation"
	decor.Parent = lab
	local floor = lab.Architecture.ArenaFloor
	local floorY = floor.Position.Y
		+ (math.abs(floor.CFrame.RightVector.Y) * floor.Size.X + math.abs(floor.CFrame.UpVector.Y) * floor.Size.Y + math.abs(
			floor.CFrame.LookVector.Y
		) * floor.Size.Z) / 2
		+ 0.055
	-- Thin inlays sit above the floor, never coplanar with it.
	ring(decor, "InnerLabBoundary", 65, floorY, 0.30, ice, Enum.Material.Neon)
	ring(decor, "OuterLabBoundary", 174, floorY, 0.22, Color3.fromRGB(95, 112, 121), Enum.Material.Metal)
	for i = 0, 11 do
		local a = i * math.pi / 6
		local cf = CFrame.Angles(0, a, 0)
		for _, side in { -1, 1 } do
			part(
				decor,
				"RouteBorder",
				Vector3.new(0.24, 0.07, 89),
				cf * CFrame.new(side * 7.5, floorY + 0.035, 120),
				Color3.fromRGB(119, 138, 143)
			)
			for r = 82, 162, 20 do
				part(
					decor,
					"RouteLight",
					Vector3.new(0.32, 0.09, 4),
					cf * CFrame.new(side * 7.5, floorY + 0.085, r),
					ice,
					Enum.Material.Neon
				)
			end
			local x = side * 26
			part(decor, "PortalPier", Vector3.new(2.6, 30, 3.2), cf * CFrame.new(x, 15, 180), dark)
			part(
				decor,
				"PierInset",
				Vector3.new(0.38, 23, 0.12),
				cf * CFrame.new(x, 16, 178.33),
				ice,
				Enum.Material.Neon
			)
			part(
				decor,
				"PierFoot",
				Vector3.new(4.4, 1.2, 4.8),
				cf * CFrame.new(x, 0.9, 180),
				Color3.fromRGB(50, 63, 72)
			)
		end
		part(decor, "PortalLintel", Vector3.new(55, 2.2, 3.4), cf * CFrame.new(0, 30, 180), dark)
		part(
			decor,
			"PortalLight",
			Vector3.new(19, 0.25, 0.25),
			cf * CFrame.new(0, 28.7, 178.4),
			amber,
			Enum.Material.Neon
		)
		local plate = part(decor, "SectorNumber", Vector3.new(12, 4, 0.16), cf * CFrame.new(0, 34, 178), dark)
		local gui = Instance.new("SurfaceGui")
		gui.Face = Enum.NormalId.Front
		gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		gui.PixelsPerStud = 30
		gui.LightInfluence = 0
		gui.Parent = plate
		local text = Instance.new("TextLabel")
		text.Size, text.BackgroundTransparency = UDim2.fromScale(1, 1), 1
		text.Text = string.format("SECTOR  %02d", i + 1)
		text.Font, text.TextSize, text.TextColor3 = Enum.Font.GothamMedium, 45, ice
		text.Parent = gui
	end
	for _, p in lab.ExcavationAccess:GetDescendants() do
		if p:IsA("BasePart") then
			if p.Name == "SafetyRail" then
				p.Color = Color3.fromRGB(91, 117, 124)
			end
		end
	end
	local light = game:GetService("Lighting")
	light.Ambient = Color3.fromRGB(100, 118, 134)
	light.OutdoorAmbient = Color3.fromRGB(83, 104, 124)
	light.ExposureCompensation = 0.18
	light.EnvironmentDiffuseScale, light.EnvironmentSpecularScale = 0.45, 0.3
	local grade = light:FindFirstChild("VesperGrade")
	if grade then
		grade.Contrast, grade.Saturation = 0.08, -0.02
		grade.TintColor = Color3.fromRGB(240, 247, 255)
	end
	local bloom = light:FindFirstChildOfClass("BloomEffect")
	if bloom then
		bloom.Intensity, bloom.Size, bloom.Threshold = 0.12, 22, 1.8
	end
	local atmosphere = light:FindFirstChildOfClass("Atmosphere")
	if atmosphere then
		atmosphere.Density, atmosphere.Haze = 0.12, 0.5
		atmosphere.Color = Color3.fromRGB(160, 185, 205)
	end
	-- Reduce the six overlapping floor lights that washed out the shell.
	for _, o in lab.CentralPlatform:GetDescendants() do
		if o:IsA("PointLight") then
			o.Brightness = 0.25
		end
	end
	local key = part(
		decor,
		"SpecimenKeyLight",
		Vector3.new(3, 1, 2),
		CFrame.lookAt(Vector3.new(-29, 62, -32), Vector3.new(0, 30, 0)),
		Color3.fromRGB(170, 193, 203)
	)
	local spot = Instance.new("SpotLight")
	spot.Face = Enum.NormalId.Front
	spot.Angle = 95
	spot.Range = 60
	spot.Brightness = 2
	spot.Color = Color3.fromRGB(255, 234, 205)
	spot.Shadows = true
	spot.Parent = key
	for _, m in lab.Egg.Sections:GetChildren() do
		local p = m:FindFirstChild("Plate")
		if p then
			p.CastShadow = false
		end
	end
	return #decor:GetDescendants()
end
return P
