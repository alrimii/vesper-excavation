-- Single Edit-only planting recipe. Finished reusable meshes; no runtime vegetation engine.
local B = {}
local V, CF = Vector3.new, CFrame.new
local function group(parent, name)
	local m = Instance.new("Model")
	m.Name = name
	m.Parent = parent
	return m
end
local function solid(parent, name, size, cf, color, material)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.Limestone
	p.Anchored = true
	p.CanCollide = true
	p.CanQuery = true
	p.CanTouch = false
	p.Parent = parent
	return p
end
local function soil(parent, cf, w, d)
	local p =
		solid(parent, "ExposedSoil", V(w, 0.16, d), cf, Color3.fromRGB(66, 59, 43), Enum.Material.Ground)
	p.CanCollide = false
	p.CanQuery = false
end
local function pocket(parent, cf, w, d)
	solid(parent, "SupportedStonePlanter", V(w, 1.25, d), cf * CF(0, -0.65, 0), Color3.fromRGB(120, 127, 110))
	soil(parent, cf, w - 0.65, d - 0.65)
end
local function vine(parent, name, cf, height)
	local t = assert(game.ServerStorage.IntegratedGreeneryAssets:FindFirstChild(name))
	local p = t:Clone()
	local s = height / t.Size.Y
	p.Size = t.Size * s
	p.CFrame = cf * CFrame.Angles(0, math.pi, 0) * CF(t:GetAttribute("SourceCenter") * s) * t.CFrame.Rotation
	p.Color = Color3.fromRGB(200, 219, 187)
	local appearance = p:FindFirstChildOfClass("SurfaceAppearance")
	if appearance then
		appearance.Color = p.Color
	end
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.CastShadow = false
	p.Parent = parent
	return p
end
local function plant(parent, name, cf, height)
	local t = assert(game.ServerStorage.LivingLabArtAssets:FindFirstChild(name))
	local p = t:Clone()
	local s = height / t.Size.Y
	p.Size = t.Size * s
	p.CFrame = cf * CF(t:GetAttribute("SourceCenter") * s)
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.CastShadow = false
	p.Parent = parent
	return p
end
function B.Commons()
	assert(
		game.PlaceId == 94763223427049 and not game:GetService("RunService"):IsRunning(),
		"Original Edit place only"
	)
	local lab = workspace.VesperLab
	for _, name in
		{
			"CompactCommons",
			"InteriorCommons",
			"ResearchGardenIslands",
			"FocalResearchDisplays",
			"ExcavationPlanting",
		}
	do
		local old = lab:FindFirstChild(name)
		if old then
			old:Destroy()
		end
	end
	local root = group(lab, "CompactCommons")
	local cf = CFrame.lookAt(V(-116, 0, 116), Vector3.zero)
	local bed = group(root, "MaintainedFernCourt")
	pocket(bed, cf * CF(0, 3.1, 0), 29, 12)
	-- Distinct canopy/fern positions retain soil gaps; no foliage embedded in the trunk.
	plant(bed, "CanopyYoung", cf * CF(8.5, 3.2, 1.7), 12)
	plant(bed, "Broadleaf", cf * CF(-9, 3.2, 2), 6)
	plant(bed, "ForestFern", cf * CF(-1.5, 3.2, 2.7), 4.5)
	plant(bed, "ForestFern", cf * CF(4.5, 3.2, -3.2), 3.5)
	plant(bed, "Clover", cf * CF(-6, 3.2, -3), 1.5)
	vine(bed, "TrailingVine", cf * CF(-8.3, 3.2, -5.7), 2.2)
	solid(root, "StoneSeat", V(28, 0.75, 3.5), cf * CF(0, 3.2, -11), Color3.fromRGB(173, 170, 149))
	for _, x in { -10, 10 } do
		solid(
			root,
			"SeatLeg",
			V(2, 2.3, 3),
			cf * CF(x, 1.8, -11),
			Color3.fromRGB(59, 76, 75),
			Enum.Material.Metal
		)
	end
	local bed2 = group(root, "LaboratoryFernBed")
	local b = CF(-44, 3.1, -121)
	pocket(bed2, b, 18, 10)
	plant(bed2, "Broadleaf", b * CF(-5, 0.1, 1.8), 5.6)
	plant(bed2, "ForestFern", b * CF(4.5, 0.1, 1.8), 4)
	plant(bed2, "Clover", b * CF(0, 0.1, -2), 1.6)
	vine(bed2, "TrailingVine", b * CF(5, 0, -4.7), 2.1)
	return root
end
function B.Build()
	assert(
		game.PlaceId == 94763223427049 and not game:GetService("RunService"):IsRunning(),
		"Original Edit place only"
	)
	local lab = workspace.VesperLab
	assert(game.ServerStorage.IntegratedGreeneryAssets:FindFirstChild("ArchitecturalIvy"))
	assert(game.ServerStorage.IntegratedGreeneryAssets:FindFirstChild("TrailingVine"))
	for _, name in { "IntegratedGreenery", "RetainedFixedPlanting", "CompactBotanicalSupports" } do
		local old = lab:FindFirstChild(name)
		if old then
			old:Destroy()
		end
	end
	for _, p in lab.CrownDeliveryDock:GetDescendants() do
		if p.Name == "FixedRimMoss" then
			p:Destroy()
		end
	end
	B.Commons()
	local root = group(lab, "IntegratedGreenery")
	root:SetAttribute("RecipeRevision", 1)
	local frames = group(root, "SelectedFrameGardens")
	-- Soil containers attach to stationary columns. Four focal groups leave the main valley panes open.
	for i, pos in
		{ V(201.434, 31, 154.566), V(-154.566, 31, -201.434), V(-214, 31, 28.174), V(88.642, 31, 214) }
	do
		local g = group(frames, "FrameGarden" .. i)
		local cf = CFrame.lookAt(pos, V(0, pos.Y, 0)) * CF(0, 0, -1.45)
		pocket(g, cf, 12, 3.1)
		for _, x in { -4.3, 4.3 } do
			local a = cf:PointToWorldSpace(V(x, -0.85, 0.4))
			local b = cf:PointToWorldSpace(V(0, -4, 1.45))
			solid(
				g,
				"FixedShelfBracket",
				V(0.35, 0.35, (a - b).Magnitude),
				CFrame.lookAt((a + b) / 2, b),
				Color3.fromRGB(56, 72, 66),
				Enum.Material.Metal
			)
		end
		vine(g, "ArchitecturalIvy", cf * CF(-2.5, 0.1, -0.2) * CFrame.Angles(0, 0, 0.06), 20 + i * 0.45)
		vine(g, "ArchitecturalIvy", cf * CF(3, 0.1, -0.35) * CFrame.Angles(0, 0, -0.08), 15 + i * 0.6)
		vine(g, "TrailingVine", cf * CF(-2.7, 20.7, -0.35), 8.2 + i * 0.7)
	end
	local roofs = group(root, "UnevenRoofPlanting")
	for _, d in
		{ { 1, -24, 8 }, { 3, 25, 12 }, { 5, -19, 9.5 }, { 7, 23, 10 }, { 9, 25, 13 }, { 11, -25, 8.7 } }
	do
		local room = lab.Rooms:FindFirstChild(string.format("Room%02d", d[1]))
		assert(room, "Expected existing room")
		local g = group(roofs, room.Name)
		local cf = room:GetPivot() * CF(d[2], 28.8, -32.8)
		if d[1] ~= 3 and d[1] ~= 9 then
			pocket(g, cf, 12, 3.2)
		end
		plant(g, "ForestFern", cf * CF(-2, 0.2, 0.2), 3.5)
		plant(g, "Clover", cf * CF(2.5, 0.2, 0), 1.8)
		for j, x in { -4, 0, 4.5 } do
			vine(
				g,
				"TrailingVine",
				cf * CF(x, 0.1, -2.8) * CFrame.Angles(0, 0, (j - 2) * 0.06),
				d[3] * (j == 2 and 1 or 0.67)
			)
		end
	end
	local access = group(root, "FixedAccessPlanting")
	-- These follow the outboard fixed column, behind the ladder's clear climbing volume.
	vine(access, "ArchitecturalIvy", CF(58.1, 4.95, 1.2) * CFrame.Angles(0, math.rad(25), -0.15), 16.0)
	vine(access, "TrailingVine", CF(57.4, 20.8, 0.7) * CFrame.Angles(0, math.rad(25), 0), 6.4)
	plant(access, "Clover", CF(58.3, 4.97, 1.6), 1)
	-- Sparse high-level accents on fixed outboard braces, beyond every moving hoist component.
	local crown = group(root, "FixedCrownPlanting")
	for _, side in { -1, 1 } do
		local cf = CF(side * 76, 247.8, 18)
		pocket(crown, cf, 5, 3)
		vine(crown, "ArchitecturalIvy", cf * CFrame.Angles(0, 0, side * math.rad(74)), 9)
		vine(crown, "TrailingVine", cf * CF(0, 0, -1.3), 5.4)
	end
	game:GetService("ChangeHistoryService"):SetWaypoint("Phase 3 integrated finished greenery")
	return "Four frame gardens, six uneven roof groups, fixed access/crown accents and two replaced ground beds"
end
return B
