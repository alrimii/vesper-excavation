local M = {}
function M.Place(model, pedestal)
	local _, size = model:GetBoundingBox()
	model:ScaleTo(model:GetScale() * 7 / math.max(size.X, size.Y, size.Z))
	local bounds, scaled = model:GetBoundingBox()
	local target = pedestal.CFrame
		* CFrame.new(0, pedestal.Size.Y / 2 + scaled.Y / 2 + 0.04, 0)
		* CFrame.Angles(0, math.pi, 0)
	model:PivotTo(target * bounds:ToObjectSpace(model:GetPivot()))
end
function M.Build(room)
	local old = room:FindFirstChild("CollectionShelf")
	if old then
		old:Destroy()
	end
	local model = Instance.new("Model")
	model.Name = "CollectionShelf"
	local basis = room:GetPivot() * CFrame.new(0, 0, 27)
	local dark, steel, enamel =
		Color3.fromRGB(25, 36, 48), Color3.fromRGB(66, 84, 99), Color3.fromRGB(183, 198, 207)
	local function part(name, size, pos, color, material)
		local p = Instance.new("Part")
		p.Name, p.Size, p.CFrame = name, size, basis * CFrame.new(pos)
		p.Color, p.Material = color, material or Enum.Material.Metal
		p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery = true, false, false, false
		p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
		p.CastShadow = false
		p.Parent = model
		return p
	end
	local floor = room:GetPivot():PointToObjectSpace(room.Floor.Position).Y + room.Floor.Size.Y / 2
	local base =
		part("CabinetBase", Vector3.new(37, 4.8 - floor, 11), Vector3.new(0, (floor + 4.8) / 2, 0), dark)
	base.CanCollide = true
	part("Shelf", Vector3.new(37.4, 0.45, 11.4), Vector3.new(0, 5.025, 0), steel)
	part("ArchiveBack", Vector3.new(36.4, 11, 0.4), Vector3.new(0, 10.75, 5.2), dark)
	part("CabinetCrown", Vector3.new(37.4, 0.5, 11.4), Vector3.new(0, 16.5, 0), steel)
	part("RelicStand", Vector3.new(4, 0.25, 4), Vector3.new(0, 16.875, 1), dark)
	for _, x in { -18.2, 18.2 } do
		part("CabinetSide", Vector3.new(0.4, 11, 11), Vector3.new(x, 10.75, 0), enamel)
	end
	for _, x in { -6, 6 } do
		part("DisplayDivider", Vector3.new(0.18, 11, 10.7), Vector3.new(x, 10.75, 0), steel)
	end
	local slots = {}
	for i = 1, 3 do
		local x = (i - 2) * 12
		part("DrawerFace", Vector3.new(11.3, 2.6, 0.14), Vector3.new(x, 3, -5.62), steel)
		part("DrawerHandle", Vector3.new(2.8, 0.16, 0.28), Vector3.new(x, 3.6, -5.86), enamel)
		part("WallMount", Vector3.new(0.7, 8, 1.75), Vector3.new(x, 10, 6.275), steel)
		local pedestal = part("Display" .. i, Vector3.new(10.8, 0.3, 8.6), Vector3.new(x, 5.45, -0.5), dark)
		local accent = part(
			"RarityAccent" .. i,
			Vector3.new(10.4, 0.1, 0.14),
			Vector3.new(x, 5.48, -4.88),
			Color3.fromRGB(113, 210, 190),
			Enum.Material.Neon
		)
		local plaque = part("Plaque" .. i, Vector3.new(10.8, 1.2, 0.12), Vector3.new(x, 4.35, -5.78), dark)
		local surface = Instance.new("SurfaceGui")
		surface.MaxDistance = 100
		surface.Face, surface.CanvasSize = Enum.NormalId.Front, Vector2.new(540, 80)
		surface.AlwaysOnTop, surface.LightInfluence = false, 0
		surface.Parent = plaque
		local label = Instance.new("TextLabel")
		label.Size, label.BackgroundTransparency = UDim2.fromScale(1, 1), 1
		label.Text = "DISPLAY 0" .. i .. "\nSELECT IN ARCHIVE"
		label.TextColor3 = Color3.fromRGB(169, 195, 209)
		label.Font, label.TextSize = Enum.Font.GothamBold, 23
		label.Parent = surface
		part(
			"DisplayLens",
			Vector3.new(7, 0.08, 0.5),
			Vector3.new(x, 16.18, -0.5),
			Color3.fromRGB(217, 230, 232),
			Enum.Material.Neon
		)
		slots[i] = { part = pedestal, accent = accent, model = nil, id = nil, label = label }
	end
	model.Parent = room
	return { model = model, slots = slots, basis = basis }
end
return M
