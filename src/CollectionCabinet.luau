-- Authoritative Edit/runtime shelf recipe; each display reads only its room owner's data.
local M = {}
local Shared = game.ReplicatedStorage.VesperShared
local Rules = require(Shared.ProgressionRules)
local Specimen = require(Shared.SpecimenBuilder)
local stone, metal, timber, dark =
	Color3.fromRGB(133, 132, 116),
	Color3.fromRGB(64, 79, 75),
	Color3.fromRGB(141, 112, 78),
	Color3.fromRGB(39, 48, 45)
function M.Place(model, pedestal)
	local _, size = model:GetBoundingBox()
	model:ScaleTo(model:GetScale() * math.min(6.6 / size.X, 5 / size.Y, 5 / size.Z))
	local bounds, scaled = model:GetBoundingBox()
	model:PivotTo(
		pedestal.CFrame
			* CFrame.new(0, pedestal.Size.Y / 2 + scaled.Y / 2 + 0.08, 0)
			* CFrame.Angles(0, math.pi, 0)
			* bounds:ToObjectSpace(model:GetPivot())
	)
end
function M.Build(room)
	local old = room:FindFirstChild("CollectionShelf")
	if old then
		old:Destroy()
	end
	local model = Instance.new("Model")
	model.Name = "CollectionShelf"
	model:SetAttribute("Recipe", "PersonalRoomPhase2")
	local basis = room:GetPivot() * CFrame.new(38, 0, 0) * CFrame.Angles(0, math.pi / 2, 0)
	local floor = room:GetPivot():PointToObjectSpace(room.Floor.Position).Y + room.Floor.Size.Y / 2
	-- Twelve slots now; unused wall length permits an additional modular bay.
	local columns = math.max(4, math.ceil(#Rules.CreatureVariants / 3))
	local pitch = math.min(12, 60 / columns)
	local width = columns * pitch
	model:SetAttribute("SlotCapacity", columns * 3)
	local function part(name, size, pos, color, material, collide)
		local p = Instance.new("Part")
		p.Name, p.Size, p.CFrame = name, size, basis * CFrame.new(pos)
		p.Color, p.Material = color, material or Enum.Material.Metal
		p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery = true, collide == true, false, true
		p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
		p.Parent = model
		return p
	end
	local function label(p, value, canvas)
		local gui = Instance.new("SurfaceGui")
		gui.Name, gui.Face, gui.CanvasSize =
			"Identification", Enum.NormalId.Front, canvas or Vector2.new(650, 120)
		gui.LightInfluence, gui.MaxDistance = 0.25, 100
		gui.Parent = p
		local t = Instance.new("TextLabel")
		t.Name, t.Size, t.BackgroundTransparency = "Text", UDim2.fromScale(1, 1), 1
		t.Text, t.TextSize, t.Font = value, 31, Enum.Font.GothamMedium
		t.TextColor3, t.TextWrapped = Color3.fromRGB(224, 218, 196), true
		t.Parent = gui
		return t
	end
	part(
		"StoneBacking",
		Vector3.new(width, 22, 0.5),
		Vector3.new(0, floor + 11, 3.35),
		stone,
		Enum.Material.Limestone,
		true
	)
	for col = 0, columns do
		part(
			"WallRail",
			Vector3.new(0.3, 21.6, 0.45),
			Vector3.new((col - columns / 2) * pitch, floor + 11, 2.85),
			metal,
			nil,
			true
		)
	end
	local slots = {}
	for row = 0, 2 do
		local y = floor + 1.65 + row * 6.6
		part(
			"ShelfDeck",
			Vector3.new(width + 0.5, 0.32, 6.7),
			Vector3.new(0, y, 0),
			timber,
			Enum.Material.Wood,
			true
		)
		for col = 1, columns do
			local index, x = row * columns + col, (col - (columns + 1) / 2) * pitch
			local entry = Rules.CreatureVariants[index]
			for _, side in { -1, 1 } do
				part(
					"ShelfBracket",
					Vector3.new(0.25, 1.1, 4.8),
					Vector3.new(x + side * (pitch / 2 - 1), y - 0.65, 0.65),
					metal,
					nil,
					true
				)
			end
			local pedestal = part(
				"Display" .. index,
				Vector3.new(pitch - 1.1, 0.16, 5.7),
				Vector3.new(x, y + 0.24, 0),
				dark,
				Enum.Material.Slate,
				true
			)
			pedestal:SetAttribute("SlotIndex", index)
			if entry then
				local plaque = part(
					"Plaque" .. index,
					Vector3.new(pitch - 1.1, 0.88, 0.12),
					Vector3.new(x, y - 0.3, -3.42),
					metal
				)
				local text = label(plaque, "UNDISCOVERED")
				local accent = part(
					"RarityAccent" .. index,
					Vector3.new(1.4, 0.08, 0.15),
					Vector3.new(x, y + 0.2, -3.42),
					metal
				)
				table.insert(slots, { part = pedestal, accent = accent, label = text, entry = entry })
			end
		end
	end
	part(
		"Cornice",
		Vector3.new(width + 0.5, 0.45, 6.7),
		Vector3.new(0, floor + 21.3, 0),
		timber,
		Enum.Material.Wood,
		true
	)
	local ownerLabel = label(
		part("OwnerBadge", Vector3.new(22, 0.9, 0.15), Vector3.new(0, floor + 22.1, -2.8), metal),
		"COLLECTION",
		Vector2.new(1000, 70)
	)
	for _, x in { -width / 3, 0, width / 3 } do
		local lamp = part(
			"ShelfLight",
			Vector3.new(6, 0.12, 0.3),
			Vector3.new(x, floor + 20.95, -2.8),
			Color3.fromRGB(209, 196, 154),
			Enum.Material.SmoothPlastic
		)
		local light = Instance.new("PointLight")
		light.Color, light.Brightness, light.Range, light.Shadows =
			Color3.fromRGB(255, 231, 188), 0.65, 18, false
		light.Parent = lamp
	end
	model.Parent = room
	return { model = model, slots = slots, ownerLabel = ownerLabel }
end
function M.Refresh(display, owner)
	display.model:SetAttribute("OwnerUserId", owner and owner.UserId or nil)
	display.ownerLabel.Text = owner and (owner.DisplayName .. " / COLLECTION") or "COLLECTION"
	for _, slot in display.slots do
		local entry = slot.entry
		local known = owner ~= nil and (owner:GetAttribute("Creature_" .. entry.Id) or 0) > 0
		local favorite = false
		for i = 1, 3 do
			favorite = favorite or (known and owner:GetAttribute("DisplaySlot" .. i) == entry.Id)
		end
		slot.label.Text = known and (entry.Name .. "\n" .. entry.Rarity .. (favorite and " / FAVORITE" or ""))
			or "UNDISCOVERED"
		slot.label.TextColor3 = known and entry.Color or Color3.fromRGB(197, 203, 191)
		slot.accent.Color = known and entry.Color or metal
		local key = entry.Id .. tostring(known)
		if slot.id ~= key then
			if slot.model then
				slot.model:Destroy()
			end
			-- These three existing variants share Crownback geometry and the existing variant finish.
			local assetId = entry.ModelId
				or (Shared.SpecimenAssets:FindFirstChild(entry.Id) and entry.Id)
				or "crownback"
			local specimen = Specimen.Build(assetId)
			for _, p in specimen:GetDescendants() do
				if not known and (p:IsA("SurfaceAppearance") or p:IsA("Texture") or p:IsA("Decal")) then
					p:Destroy()
				elseif p:IsA("BasePart") then
					p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery = true, false, false, false
					if known then
						p.Color = p.Color:Lerp(entry.Color, 0.35)
						local appearance = p:FindFirstChildOfClass("SurfaceAppearance")
						if appearance then
							appearance.Color = entry.Color
						end
					else
						p.Color, p.Material, p.Reflectance =
							Color3.fromRGB(26, 32, 29), Enum.Material.SmoothPlastic, 0
						if p:IsA("MeshPart") then
							p.TextureID = ""
						end
					end
				end
			end
			M.Place(specimen, slot.part)
			specimen.Name = "Specimen" .. tostring(slot.part:GetAttribute("SlotIndex"))
			specimen:SetAttribute("Discovered", known)
			specimen.Parent, slot.model, slot.id = display.model, specimen, key
		end
	end
end
return M
