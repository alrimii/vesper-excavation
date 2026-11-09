-- Shared ramp mesh: one edit-time CSG shape, reused around a freestanding service spiral.
local B = {}
local function triangle(parent, a, b, c)
	local ab, ac, bc = b - a, c - a, c - b
	if ab:Dot(ab) > ac:Dot(ac) and ab:Dot(ab) > bc:Dot(bc) then
		c, a = a, c
	elseif ac:Dot(ac) > bc:Dot(bc) then
		a, b = b, a
	end
	ab, ac, bc = b - a, c - a, c - b
	local right = ac:Cross(ab).Unit
	local back = bc.Unit
	local up = bc:Cross(right).Unit
	for _, v in
		{ { (a + b) / 2, right, up, back, math.abs(ab:Dot(back)) }, {
			(a + c) / 2,
			-right,
			up,
			-back,
			math.abs(ac:Dot(back)),
		} }
	do
		local p = Instance.new("WedgePart")
		p.Size = Vector3.new(0.22, math.abs(ab:Dot(up)), v[5])
		p.CFrame = CFrame.fromMatrix(v[1], v[2], v[3], v[4])
		p.Anchored = true
		p.Parent = parent
	end
end
local function rod(parent, name, a, b, width, color)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = Vector3.new(width, width, (b - a).Magnitude)
	p.CFrame = CFrame.lookAt((a + b) / 2, b)
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Color = color
	p.Material = Enum.Material.Metal
	p.Parent = parent
	return p
end
function B.Build()
	assert(not game:GetService("RunService"):IsRunning(), "Edit only")
	local count = 120
	local totalAngle = math.pi * 3
	local height = 64
	local radius = 36
	local function path(t, offset)
		local a = t * totalAngle
		return Vector3.new(
			math.cos(a) * (radius + offset),
			3.15 + t * height,
			math.sin(a) * (radius + offset)
		)
	end
	local work = Instance.new("Model")
	work.Parent = game.ServerStorage
	local a, b, c, d = path(0, -4), path(0, 4), path(1 / count, 4), path(1 / count, -4)
	triangle(work, a, b, c)
	triangle(work, a, c, d)
	local pieces = work:GetChildren()
	local first = table.remove(pieces, 1)
	local template = first:UnionAsync(
		pieces,
		Enum.CollisionFidelity.PreciseConvexDecomposition,
		Enum.RenderFidelity.Automatic
	)
	template.Name = "ServiceDeck"
	template.Anchored = true
	template.UsePartColor = true
	template.Color = Color3.fromRGB(43, 57, 65)
	template.Material = Enum.Material.Metal
	template.CanTouch = false
	work:Destroy()
	local root = Instance.new("Model")
	root.Name = "ExcavationAccess_New"
	root.Parent = workspace.VesperLab
	for i = 0, count - 1 do
		local t = i / count
		local u = (i + 1) / count
		local tile = template:Clone()
		tile.CFrame = CFrame.new(0, t * height, 0) * CFrame.Angles(0, -t * totalAngle, 0) * template.CFrame
		tile.Parent = root
		rod(
			root,
			"SafetyRail",
			path(t, 3.9) + Vector3.new(0, 2.8, 0),
			path(u, 3.9) + Vector3.new(0, 2.8, 0),
			0.14,
			Color3.fromRGB(115, 143, 149)
		)
		if i % 5 == 0 then
			rod(
				root,
				"Stanchion",
				path(t, 3.9),
				path(t, 3.9) + Vector3.new(0, 2.8, 0),
				0.16,
				Color3.fromRGB(74, 97, 106)
			)
			local lamp = rod(
				root,
				"EdgeMarker",
				path(t, 3.9) + Vector3.new(0, 0.15, 0),
				path(u, 3.9) + Vector3.new(0, 0.15, 0),
				0.13,
				Color3.fromRGB(116, 205, 201)
			)
			lamp.Material = Enum.Material.Neon
		end
		if i % 30 == 0 and i > 0 and i < 90 then
			local top = path(t, 4.2)
			rod(root, "ServiceSupport", Vector3.new(top.X, 0.5, top.Z), top, 0.9, Color3.fromRGB(34, 46, 55))
		end
		if i % 30 == 0 then
			task.wait()
		end
	end
	template:Destroy()
	local old = workspace.VesperLab:FindFirstChild("ExcavationAccess")
	if old then
		old:Destroy()
	end
	root.Name = "ExcavationAccess"
	return #root:GetChildren()
end
return B
