-- Original tools and geodesic dual tessellation. Edit-time CSG only.
local Q = {}
local C = require(game.ReplicatedStorage.VesperShared.ExcavationConfig)
local amber = Color3.fromRGB(210, 155, 64)
local function part(parent, name, size, cf, color, mat, class)
	local p = Instance.new(class or "Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = mat or Enum.Material.Metal
	p.Anchored = true
	p.CanTouch = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end
local function rod(parent, name, a, b, width, color)
	return part(
		parent,
		name,
		Vector3.new(width, width, (a - b).Magnitude),
		CFrame.lookAt((a + b) / 2, b),
		color
	)
end
local function triangle(parent, a, b, c, thickness, color, mat)
	local ab, ac, bc = b - a, c - a, c - b
	if ab:Dot(ab) > ac:Dot(ac) and ab:Dot(ab) > bc:Dot(bc) then
		c, a = a, c
	elseif ac:Dot(ac) > bc:Dot(bc) then
		a, b = b, a
	end
	ab, ac, bc = b - a, c - a, c - b
	local cross = ac:Cross(ab)
	if cross.Magnitude < 0.0001 then
		return
	end
	local right = cross.Unit
	local back = bc.Unit
	local up = bc:Cross(right).Unit
	local h = math.abs(ab:Dot(up))
	for _, v in
		{ { (a + b) / 2, right, up, back, math.abs(ab:Dot(back)) }, {
			(a + c) / 2,
			-right,
			up,
			-back,
			math.abs(ac:Dot(back)),
		} }
	do
		if v[5] > 0.001 then
			part(
				parent,
				"Facet",
				Vector3.new(thickness, h, v[5]),
				CFrame.fromMatrix(v[1], v[2], v[3], v[4]),
				color,
				mat,
				"WedgePart"
			)
		end
	end
end
function Q.Shell()
	return require(game.ServerStorage.VesperTools.EggBuilder).Build()
end
function Q.Tools()
	return require(script.Parent.ToolPresentationBuilder).Build()
end
function Q.Access()
	local root = workspace.VesperLab.ExcavationAccess
	for _, p in root:GetChildren() do
		if p.Name == "ServiceRamp" or p.Name == "SafetyRail" or p.Name == "RampPanels" then
			p:Destroy()
		end
	end
	local panels = Instance.new("Model")
	panels.Name = "RampPanels"
	panels.Parent = root
	local g = C.Geometry
	local count = 120
	local function path(t, offset)
		local y = 3.15 + t * 62
		local v = math.clamp((y + 3 - g.Base.Y) / g.Height * 2 - 1, -1, 1)
		local r = g.Radius * math.sqrt(1 - v * v) * (1 - 0.22 * v) + 6 + offset
		local a = t * math.pi * 5
		return Vector3.new(math.cos(a) * r, y, math.sin(a) * r)
	end
	for i = 0, count - 1 do
		local t, u = i / count, (i + 1) / count
		local a, b, c, d = path(t, -3.5), path(t, 3.5), path(u, 3.5), path(u, -3.5)
		triangle(panels, a, b, c, 0.25, Color3.fromRGB(69, 77, 81), Enum.Material.Metal)
		triangle(panels, a, c, d, 0.25, Color3.fromRGB(69, 77, 81), Enum.Material.Metal)
		local rail = rod(
			root,
			"SafetyRail",
			path(t, 3.3) + Vector3.new(0, 2.7, 0),
			path(u, 3.3) + Vector3.new(0, 2.7, 0),
			0.16,
			amber
		)
		rail.CanCollide = false
		rail.CanQuery = false
	end
	return "Continuous fitted ramp panels and rail joints"
end
return Q
