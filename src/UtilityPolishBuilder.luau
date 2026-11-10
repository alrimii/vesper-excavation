-- Retired after the living-laboratory checkpoint.
assert(not (workspace:FindFirstChild("VesperLab") and workspace.VesperLab:GetAttribute("LivingLabRevision")), "Historical environment recipe retired; use LivingLabBuilder")
-- Persistent edit-time environment construction; no gameplay systems or asset uploads.
assert(not game:GetService("RunService"):IsRunning(), "Edit only")
local lab = workspace.VesperLab
assert(not lab:FindFirstChild("ThermalServiceBays"), "Utility polish already installed")
local archive = Instance.new("Folder")
archive.Name = "BeforeUtilityPolish_20261109"
lab.Infrastructure:Clone().Parent = archive
lab.AtmosphereDetails:Clone().Parent = archive
archive.Parent = game.ServerStorage
local retired = Instance.new("Folder")
retired.Name = "RetiredFixtures"
retired.Parent = archive
local root = Instance.new("Model")
root.Name = "ThermalServiceBays"
local steel = Color3.fromRGB(72, 82, 90)
local dark = Color3.fromRGB(25, 33, 40)
local enamel = Color3.fromRGB(162, 173, 178)
local amber = Color3.fromRGB(224, 160, 68)
local function part(parent, name, size, cf, color, collide, material)
	local p = Instance.new("Part")
	p.Name, p.Size, p.CFrame = name, size, cf
	p.Color, p.Material = color, material or Enum.Material.Metal
	p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery = true, collide == true, false, false
	p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	p.CastShadow = math.min(size.X, size.Y, size.Z) > 0.15
	p.Parent = parent
	return p
end
local function pipe(parent, name, a, b, radius, color)
	local p = part(
		parent,
		name,
		Vector3.new((b - a).Magnitude, radius * 2, radius * 2),
		CFrame.lookAt((a + b) / 2, b) * CFrame.Angles(0, math.pi / 2, 0),
		color,
		false
	)
	p.Shape = Enum.PartType.Cylinder
	return p
end
local retiredCount = 0
local islands = {
	ServiceSkid = true,
	PumpHousing = true,
	PumpInlet = true,
	PumpReturn = true,
	UpperDuct = true,
	PumpVent = true,
	EquipmentLabel = true,
	IslandGuard = true,
}
for _, bay in lab.Infrastructure:GetChildren() do
	if not bay:IsA("Model") then
		continue
	end
	for _, p in bay:GetChildren() do
		if islands[p.Name] then
			p.Parent = retired
			retiredCount += 1
		end
	end
	local index = tonumber(string.match(bay.Name, "%d+"))
	if not index or (index - 1) % 3 ~= 0 then
		continue
	end
	local old = bay:FindFirstChild("VentHousing")
	if not old then
		continue
	end
	local basis = CFrame.new(old.Position.X, 0.675, old.Position.Z) * old.CFrame.Rotation
	local model = Instance.new("Model")
	model.Name = "ThermalBay" .. index
	local function p(name, size, position, color, collide, material)
		return part(model, name, size, basis * CFrame.new(position), color, collide, material)
	end
	p("Foundation", Vector3.new(26, 0.55, 16), Vector3.new(0, 0.275, 0), dark, true, Enum.Material.Concrete)
	for _, x in { -10, 7 } do
		p("SkidRail", Vector3.new(0.8, 0.65, 12), Vector3.new(x, 0.875, 0), steel)
	end
	p("RadiatorBody", Vector3.new(18, 12, 10), Vector3.new(-2, 7.2, 0), enamel, true)
	p("RadiatorRecess", Vector3.new(16.6, 9, 0.25), Vector3.new(-2, 7.4, -5.16), dark)
	for _, x in { -6, 2 } do
		local center = basis:PointToWorldSpace(Vector3.new(x, 7.8, -5.42))
		pipe(
			model,
			"FanShroud",
			center + basis.LookVector * 0.05,
			center + basis.LookVector * 0.5,
			3.25,
			steel
		)
		pipe(model, "FanWell", center + basis.LookVector * 0.51, center + basis.LookVector * 0.57, 2.83, dark)
		for k = 0, 4 do
			local a = k * math.pi * 2 / 5
			part(
				model,
				"FanBlade",
				Vector3.new(2.1, 0.58, 0.13),
				basis
					* CFrame.new(x + math.cos(a) * 1.4, 7.8 + math.sin(a) * 1.4, -6.04)
					* CFrame.Angles(0, 0, a + 0.45),
				steel
			)
		end
		pipe(model, "FanHub", center + basis.LookVector * 0.6, center + basis.LookVector * 0.77, 0.55, enamel)
		for _, offset in { -1.5, 0, 1.5 } do
			p("FanGuard", Vector3.new(0.09, 5.5, 0.1), Vector3.new(x + offset, 7.8, -6.3), enamel)
		end
	end
	p("ServiceRail", Vector3.new(17, 0.35, 0.25), Vector3.new(-2, 2.7, -5.24), steel)
	for _, x in { -10.5, 6.5 } do
		p("CornerArmor", Vector3.new(0.35, 11, 0.3), Vector3.new(x, 7.2, -5.22), steel)
		for _, y in { 2.1, 12.2 } do
			p("PanelFastener", Vector3.new(0.23, 0.23, 0.16), Vector3.new(x, y, -5.43), amber)
		end
	end
	p("TopCap", Vector3.new(19, 0.4, 10.6), Vector3.new(-2, 13.4, 0), steel)
	p("HeaderInset", Vector3.new(15, 0.7, 0.15), Vector3.new(-2, 12.6, -5.24), dark)
	p("HeaderStripe", Vector3.new(4, 0.12, 0.08), Vector3.new(-7, 12.6, -5.36), amber)
	p("TankFoot", Vector3.new(4, 0.65, 4), Vector3.new(9, 0.875, 1), dark)
	local tank = p("ExpansionTank", Vector3.new(9, 3.4, 3.4), Vector3.new(9, 5.7, 1), steel, true)
	tank.Shape = Enum.PartType.Cylinder
	tank.CFrame = basis * CFrame.new(9, 5.7, 1) * CFrame.Angles(0, 0, math.pi / 2)
	for _, y in { 2.3, 9.1 } do
		local band = p("TankBand", Vector3.new(0.26, 3.7, 3.7), Vector3.new(9, y, 1), amber)
		band.Shape = Enum.PartType.Cylinder
		band.CFrame = basis * CFrame.new(9, y, 1) * CFrame.Angles(0, 0, math.pi / 2)
	end
	pipe(
		model,
		"SupplyLink",
		basis:PointToWorldSpace(Vector3.new(6, 4, 1)),
		basis:PointToWorldSpace(Vector3.new(9, 4, 1)),
		0.43,
		steel
	)
	local riser = bay:FindFirstChild("VerticalCoolant")
	if riser then
		local start = basis:PointToWorldSpace(Vector3.new(9, 6, 2.5))
		local endPoint = Vector3.new(riser.Position.X, 6.675, riser.Position.Z)
		local elbow = basis:PointToWorldSpace(Vector3.new(9, 6, basis:PointToObjectSpace(endPoint).Z))
		pipe(model, "SupplyPipe", start, elbow, 0.48, steel)
		pipe(model, "RiserConnection", elbow, endPoint, 0.48, steel)
		local joint = part(model, "Elbow", Vector3.new(0.98, 0.98, 0.98), CFrame.new(elbow), steel)
		joint.Shape = Enum.PartType.Ball
		for _, f in { 0.3, 0.7 } do
			local pos = start:Lerp(elbow, f)
			part(
				model,
				"PipeSupport",
				Vector3.new(0.35, pos.Y - 0.675, 0.35),
				CFrame.new(pos.X, (pos.Y + 0.675) / 2, pos.Z),
				dark
			)
		end
	end
	for _, oldPart in bay:GetChildren() do
		if
			oldPart.Name == "VentHousing"
			or oldPart.Name == "VentSlat"
			or oldPart.Name == "EquipmentAccent"
		then
			oldPart.Parent = retired
			retiredCount += 1
		end
	end
	model.Parent = root
end
-- Existing emitter and status lens stay aligned with their newly grounded vent.
for _, vent in lab.AtmosphereDetails:GetChildren() do
	if vent:IsA("BasePart") and vent.Name == "CoolingVent" then
		local previous = vent.Position
		local delta = Vector3.new(0, 0.975 - previous.Y, 0)
		vent.CFrame += delta
		vent.Color, vent.Material = dark, Enum.Material.Metal
		for _, lens in lab.AtmosphereDetails:GetChildren() do
			if
				lens:IsA("BasePart")
				and lens.Name == "StatusLens"
				and (lens.Position - previous).Magnitude < 1
			then
				lens.CFrame += delta
			end
		end
		local model = Instance.new("Model")
		model.Name = "FloorVentHousing"
		part(model, "VentFoot", Vector3.new(3.3, 0.15, 2.1), vent.CFrame * CFrame.new(0, -0.225, 0), steel)
		for i = -2, 2 do
			part(
				model,
				"VentLouver",
				Vector3.new(2.5, 0.08, 0.1),
				vent.CFrame * CFrame.new(0, 0.19, i * 0.25),
				steel
			)
		end
		model.Parent = root
	end
end
root.Parent = lab
local count = 0
for _, p in root:GetDescendants() do
	if p:IsA("BasePart") then
		count += 1
	end
end
return { retired = retiredCount, newParts = count, serviceBays = 4, groundedVents = 8 }
