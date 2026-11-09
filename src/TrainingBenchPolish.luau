assert(not game:GetService("RunService"):IsRunning(), "Edit only")
local lab = workspace.VesperLab
local archive = Instance.new("Folder")
archive.Name = "BeforeTrainingBench_20261109"
archive.Parent = game.ServerStorage
local steel = Color3.fromRGB(77, 89, 98)
local dark = Color3.fromRGB(26, 36, 45)
local enamel = Color3.fromRGB(167, 179, 184)
local amber = Color3.fromRGB(224, 160, 68)
local total = 0
for _, room in lab.Rooms:GetChildren() do
	local station = room.TrainingStation
	assert(not station:FindFirstChild("BenchFinish"), "Bench already polished")
	local copy = station:Clone()
	copy.Name = room.Name
	copy.Parent = archive
	local finish = Instance.new("Model")
	finish.Name = "BenchFinish"
	local origin = station.Base.CFrame * CFrame.new(0, -0.325, 0)
	local function p(name, size, pos, color, material)
		local part = Instance.new("Part")
		part.Name, part.Size, part.CFrame = name, size, origin * CFrame.new(pos)
		part.Color, part.Material = color, material or Enum.Material.Metal
		part.Anchored, part.CanCollide, part.CanTouch, part.CanQuery = true, false, false, false
		part.TopSurface, part.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
		part.Parent = finish
		total += 1
		return part
	end
	local floor = room.Floor.Position.Y + room.Floor.Size.Y / 2
	local baseBottom = station.Base.Position.Y - station.Base.Size.Y / 2
	if baseBottom > floor then
		p(
			"GroundingPlinth",
			Vector3.new(14, baseBottom - floor, 12),
			Vector3.new(0, (floor + baseBottom) / 2 - origin.Position.Y, 0),
			dark
		)
	end
	station.Base.Color, station.Base.Material = dark, Enum.Material.Metal
	station.Deck.Color, station.Deck.Material = steel, Enum.Material.DiamondPlate
	for _, part in station:GetChildren() do
		if part:IsA("BasePart") then
			local pos = origin:PointToObjectSpace(part.Position)
			if part.Name == "Pillar" then
				part.Size = Vector3.new(1.1, 6.5, 1.6)
				part.CFrame = origin * CFrame.new(pos.X, 4.25, -3.6)
				part.Color = enamel
			elseif part.Name == "PillarInset" then
				part.Size = Vector3.new(0.16, 2, 0.1)
				part.CFrame = origin * CFrame.new(pos.X, 5.8, -2.75)
				part.Color = amber
			elseif part.Name == "PillarFoot" then
				part.Color = dark
			elseif part.Name == "Cradle" then
				part.Color = steel
				part.Material = Enum.Material.Metal
			end
		end
	end
	station.Crosshead.Size = Vector3.new(13, 1.3, 2)
	station.Crosshead.CFrame = origin * CFrame.new(0, 7.65, -3.6)
	station.Crosshead.Color = dark
	for _, v in station:GetDescendants() do
		if v:IsA("BillboardGui") then
			v.Enabled = false
		end
	end
	local function label(parent, name, heading, sub)
		local gui = Instance.new("SurfaceGui")
		gui.MaxDistance = 200
		gui.Name = name
		gui.Face, gui.SizingMode, gui.CanvasSize =
			Enum.NormalId.Back, Enum.SurfaceGuiSizingMode.FixedSize, Vector2.new(640, 200)
		gui.LightInfluence, gui.AlwaysOnTop, gui.Parent = 0, false, parent
		for i, value in { heading, sub } do
			local text = Instance.new("TextLabel")
			text.Name = i == 1 and "Status" or "Subtitle"
			text.Size, text.Position =
				UDim2.new(0.94, 0, 0.4, 0), UDim2.fromScale(0.03, i == 1 and 0.06 or 0.52)
			text.BackgroundTransparency, text.Font, text.TextSize =
				1, Enum.Font.GothamBold, i == 1 and 45 or 27
			text.Text, text.TextColor3, text.Parent =
				value, i == 1 and Color3.fromRGB(239, 216, 175) or enamel, gui
		end
	end
	for _, g in station.Crosshead:GetChildren() do
		if g:IsA("SurfaceGui") then
			g.Enabled = false
		end
	end
	label(station.Crosshead, "BenchName", "TOOL PRACTICE", "USE YOUR EQUIPPED TOOL")
	station.TrainingSpot.Color, station.TrainingSpot.Material = dark, Enum.Material.Rubber
	local pad = origin:PointToObjectSpace(station.TrainingSpot.Position)
	for _, x in { -1.8, 1.8 } do
		p("StandingPadEdge", Vector3.new(0.10, 0.025, 2.1), Vector3.new(x, pad.Y + 0.075, pad.Z), amber)
	end
	for _, x in { -0.8, 0.8 } do
		p("FootMarker", Vector3.new(0.25, 0.025, 0.7), Vector3.new(x, pad.Y + 0.075, pad.Z), enamel)
	end
	-- Target supports stop below the strike area; no cage across the tool approach.
	for _, x in { -1.65, 1.65 } do
		p("CradleShoe", Vector3.new(0.6, 0.8, 1.3), Vector3.new(x, 1.25, -3.6), dark)
		local contact = p("CradlePad", Vector3.new(0.35, 0.3, 1.1), Vector3.new(x, 1.72, -3.6), steel)
		contact.Material = Enum.Material.Rubber
	end
	p("CradleSupport", Vector3.new(3.8, 0.25, 3.8), Vector3.new(0, 0.92, -3.6), dark)
	station.Control.Color, station.Control.Material = steel, Enum.Material.Metal
	station.Screen.Color, station.Screen.Material = dark, Enum.Material.SmoothPlastic
	label(station.Screen, "TrainingStatus", "READY", "START / STOP NEAR THE BENCH")
	local control = origin:PointToObjectSpace(station.Control.Position)
	p("ConsoleFoot", Vector3.new(2.8, 0.2, 1.5), Vector3.new(control.X, 0.95, control.Z), dark)
	p(
		"BenchStatusLens",
		Vector3.new(0.18, 0.3, 0.1),
		Vector3.new(control.X - 1, control.Y - 0.65, control.Z + 0.68),
		Color3.fromRGB(101, 157, 146),
		Enum.Material.Neon
	)
	for _, x in { -6, 6 } do
		p("BaseCorner", Vector3.new(0.5, 0.2, 1), Vector3.new(x, 0.9, 4.5), amber)
	end
	finish.Parent = station
end
return { benches = 12, addedParts = total }
