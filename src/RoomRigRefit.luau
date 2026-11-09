assert(not game:GetService("RunService"):IsRunning(), "Edit only")
local lab = workspace.VesperLab
local backup = Instance.new("Folder")
backup.Name = "Stage26WorldBackup"
backup.Parent = game.ServerStorage
local count = 0
for _, room in lab.Rooms:GetChildren() do
	local station = room:FindFirstChild("TrainingStation")
	if station and not station:GetAttribute("CompactCradle") then
		local saved = Instance.new("Folder")
		saved.Name = room.Name
		saved.Parent = backup
		station:Clone().Parent = saved
		room.CollectionShelf:Clone().Parent = saved
		local origin = station.Base.CFrame * CFrame.new(0, -0.325, 0)
		for _, p in station:GetChildren() do
			if
				p.Name == "Pillar"
				or p.Name == "PillarInset"
				or p.Name == "PillarFoot"
				or p.Name == "Crosshead"
			then
				p:Destroy()
			end
		end
		local function part(name, size, cf, color)
			local p = Instance.new("Part")
			p.Name, p.Size, p.CFrame = name, size, origin * cf
			p.Color, p.Material = color, Enum.Material.Metal
			p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery = true, false, false, false
			p.Parent = station
			return p
		end
		local steel, dark, gold =
			Color3.fromRGB(98, 115, 125), Color3.fromRGB(29, 43, 55), Color3.fromRGB(215, 164, 77)
		for _, side in { -1, 1 } do
			part(
				"CradleArm",
				Vector3.new(0.65, 2.1, 1.5),
				CFrame.new(side * 2.2, 2, -3.6) * CFrame.Angles(0, 0, side * -0.22),
				steel
			)
			local pin =
				part("CradleHinge", Vector3.new(0.85, 1.2, 1.2), CFrame.new(side * 2.4, 1.25, -3.6), dark)
			pin.Shape = Enum.PartType.Cylinder
			part("ContactJaw", Vector3.new(0.45, 0.7, 1.2), CFrame.new(side * 1.75, 2.8, -3.6), dark)
			part("SafetyStripe", Vector3.new(0.12, 0.35, 1.52), CFrame.new(side * 2.25, 2.35, -3.6), gold)
		end
		part("BenchRearRail", Vector3.new(8, 0.6, 0.5), CFrame.new(0, 1.15, -5.5), steel)
		local target = station.PracticeEgg
		target.Size = Vector3.new(3.9, 5, 3.9)
		target.CFrame += Vector3.yAxis * 0.3
		target:SetAttribute("RestSize", target.Size)
		target:SetAttribute("RestCFrame", target.CFrame)
		station:SetAttribute("CompactCradle", true)
		local shelf = room.CollectionShelf
		local old = room:GetPivot() * CFrame.new(0, 10.7, 25)
		local new = room:GetPivot() * CFrame.new(34, 10.7, 8) * CFrame.Angles(0, math.pi / 2, 0)
		shelf:PivotTo(new * old:Inverse() * shelf:GetPivot())
		for _, g in shelf:GetDescendants() do
			if g:IsA("SurfaceGui") then
				g.MaxDistance = 160
			end
		end
		count += 1
	end
end
-- These lights were left stationary while their support columns retracted.
local lights = Instance.new("Model")
lights.Name = "MountedAccessLights"
local originals = Instance.new("Folder")
originals.Name = "SpecimenLights"
originals.Parent = backup
local children = lab.CinematicFixtures:GetChildren()
for _, housing in children do
	if housing.Name == "MountedSpecimenLight" then
		housing:Clone().Parent = originals
		local radial = Vector3.new(housing.Position.X, 0, housing.Position.Z).Unit
		for _, lens in children do
			if lens.Name == "SpecimenLightLens" and (lens.Position - housing.Position).Magnitude < 1 then
				lens:Clone().Parent = originals
				lens.CFrame -= radial * 0.95
				lens.Parent = lights
			end
		end
		local collar = Instance.new("Part")
		collar.Name, collar.Size, collar.CFrame =
			"LightMountCollar", Vector3.new(1.1, 1.2, 1.1), CFrame.new(housing.Position)
		collar.Color, collar.Material = Color3.fromRGB(65, 80, 91), Enum.Material.Metal
		collar.Anchored, collar.CanCollide, collar.CanTouch, collar.CanQuery = true, false, false, false
		collar.Parent = lights
		housing.CFrame -= radial * 0.95
		for _, light in housing:GetChildren() do
			if light:IsA("Light") then
				light.Shadows = false
			end
		end
		housing.Parent = lights
	end
end
if #lights:GetChildren() > 0 then
	lights.Parent = lab.ExcavationAccess
else
	lights:Destroy()
end
return { rooms = count, archived = backup:GetFullName() }
