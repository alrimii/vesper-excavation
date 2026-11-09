-- Edit-time fitted access. All dimensions follow the restored dense shell.
local config = game.ReplicatedStorage.VesperShared.ExcavationConfig:Clone()
config.Parent = game.ServerStorage
local C = require(config)
config:Destroy()
local access = workspace.VesperLab.ExcavationAccess
access:ClearAllChildren()
local function path(t, offset)
	local y = 3.15 + t * 64
	local phi = math.acos(math.clamp(1 - 2 * (y + 2 - C.Geometry.Base.Y) / C.Geometry.Height, -1, 1))
	local radius = C.Geometry.Radius * math.sin(phi) * (1 + 0.18 * math.cos(phi)) + 5.5 + offset
	local a = t * math.pi * 9
	return Vector3.new(math.cos(a) * radius, y, math.sin(a) * radius)
end
for i = 0, 319 do
	local a, b = path(i / 320, 0), path((i + 1) / 320, 0)
	local p = Instance.new("Part")
	p.Name = "ServiceRamp"
	p.Anchored = true
	p.Size = Vector3.new(7, 0.3, (b - a).Magnitude + 0.18)
	p.CFrame = CFrame.lookAt((a + b) / 2, b)
	p.Material = Enum.Material.DiamondPlate
	p.Color = Color3.fromRGB(58, 69, 77)
	p.Parent = access
	local c, d =
		path(i / 320, 3.3) + Vector3.new(0, 2.7, 0), path((i + 1) / 320, 3.3) + Vector3.new(0, 2.7, 0)
	local rail = Instance.new("Part")
	rail.Name = "SafetyRail"
	rail.Anchored = true
	rail.CanQuery = false
	rail.Size = Vector3.new(0.14, 0.14, (d - c).Magnitude + 0.1)
	rail.CFrame = CFrame.lookAt((c + d) / 2, d)
	rail.Color = Color3.fromRGB(212, 159, 66)
	rail.Material = Enum.Material.Metal
	rail.Parent = access
	if i % 80 == 0 then
		task.wait()
	end
end
for i = 0, 63 do
	local a = i / 64 * math.pi * 2
	local b = (i + 1) / 64 * math.pi * 2
	local x, y =
		Vector3.new(math.cos(a) * 13, 66, math.sin(a) * 13),
		Vector3.new(math.cos(b) * 13, 66, math.sin(b) * 13)
	local p = Instance.new("Part")
	p.Name = "CapWalkway"
	p.Anchored = true
	p.Size = Vector3.new(5, 0.25, (y - x).Magnitude + 0.1)
	p.CFrame = CFrame.lookAt((x + y) / 2, y)
	p.Color = Color3.fromRGB(58, 69, 77)
	p.Material = Enum.Material.DiamondPlate
	p.Parent = access
end
return "Dense shell access fitted"
