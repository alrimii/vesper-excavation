-- Fitted roof sectors remove overlapping rectangular panels and invalid basis transforms.
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
		{
			{ (a + b) / 2, right, up, back, math.abs(ab:Dot(back)) },
			{
				(a + c) / 2,
				-right,
				up,
				-back,
				math.abs(ac:Dot(back)),
			},
		}
	do
		local p = Instance.new("WedgePart")
		p.Size = Vector3.new(0.8, math.abs(ab:Dot(up)), v[5])
		p.CFrame = CFrame.fromMatrix(v[1], v[2], v[3], v[4])
		p.Anchored = true
		p.Parent = parent
	end
end

function B.Build()
	assert(not game:GetService("RunService"):IsRunning(), "Edit only")
	local profiles = { { 260, 60 }, { 240, 104 }, { 194, 150 }, { 128, 186 }, { 60, 208 }, { 0, 214 } }
	local dome = workspace.VesperLab.Dome
	for band = 1, 5 do
		local r0, y0 = profiles[band][1], profiles[band][2]
		local r1, y1 = profiles[band + 1][1], profiles[band + 1][2]
		local a = math.pi / 48
		local p = Vector3.new(-math.sin(a) * r0, y0, math.cos(a) * r0)
		local q = Vector3.new(math.sin(a) * r0, y0, math.cos(a) * r0)
		local r = Vector3.new(math.sin(a) * r1, y1, math.cos(a) * r1)
		local t = Vector3.new(-math.sin(a) * r1, y1, math.cos(a) * r1)
		local work = Instance.new("Model")
		work.Parent = game.ServerStorage
		triangle(work, p, q, r)
		if r1 > 0 then
			triangle(work, p, r, t)
		end
		local parts = work:GetChildren()
		local first = table.remove(parts, 1)
		local template = first:UnionAsync(parts, Enum.CollisionFidelity.Box, Enum.RenderFidelity.Automatic)
		template.Name = "FittedRoofPanel"
		template.UsePartColor = true
		template.Color = band % 2 == 0 and Color3.fromRGB(29, 39, 49) or Color3.fromRGB(35, 46, 56)
		template.Material = Enum.Material.Metal
		template.Anchored = true
		template.CanCollide = false
		template.CanTouch = false
		template.CanQuery = false
		template.CastShadow = true
		local batch = dome["RoofBand" .. band]
		for _, old in batch:GetChildren() do
			if old.Name == "MetalRoofPanel" or old.Name == "FittedRoofPanel" then
				old:Destroy()
			end
		end
		for i = 0, 47 do
			local clone = template:Clone()
			clone.CFrame = CFrame.Angles(0, i * math.pi / 24, 0) * template.CFrame
			clone.Parent = batch
		end
		template:Destroy()
		work:Destroy()
		task.wait()
	end
	return "240 fitted roof panels; five reusable shapes"
end
return B
