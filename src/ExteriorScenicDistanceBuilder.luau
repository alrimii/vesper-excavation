-- Edit-only scenic compression. Reuses existing meshes; no duplicate scenery or terrain edits.
local B = {}
function B.Build()
	assert(
		game.PlaceId == 94763223427049 and not game:GetService("RunService"):IsRunning(),
		"Original Edit place only"
	)
	local exterior = workspace.VesperLab.DecorativeExterior
	local ground = exterior.ContinuousLowGround
	local query = {}
	for _, p in ground:GetChildren() do
		query[p] = p.CanQuery
		p.CanQuery = true
	end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = { ground }
	local function seat(x, z)
		local hit = workspace:Raycast(Vector3.new(x, 500, z), Vector3.new(0, -1000, 0), params)
		return hit and hit.Position.Y or -8
	end
	local count = 0
	for _, group in { exterior.SeparatedRockMassifs, exterior.IrregularForestIslands } do
		for _, p in group:GetDescendants() do
			if not p:IsA("MeshPart") then
				continue
			end
			local cf = p:GetAttribute("ScenicOriginalCFrame") or p.CFrame
			local size = p:GetAttribute("ScenicOriginalSize") or p.Size
			p:SetAttribute("ScenicOriginalCFrame", cf)
			p:SetAttribute("ScenicOriginalSize", size)
			local radius = Vector3.new(cf.X, 0, cf.Z).Magnitude
			local mountain = group == exterior.SeparatedRockMassifs
			local destination = mountain and (p.Name == "RockMassif5" and 630 or 850)
				or math.clamp(460 + (radius - 700) * 0.04, 450, 540)
			local scale = destination / radius
			local x, z = cf.X * scale, cf.Z * scale
			local bottom = mountain and -30 or seat(x, z) - 1
			-- Preserve the high-player silhouette elevation; extend bases down into existing grade.
			local top = 95 + (cf.Y + size.Y / 2 - 95) * scale
			if not mountain then
				top = bottom + math.clamp(top - bottom, size.Y * scale, size.Y * scale * 1.4)
			end
			if p.Name == "RockMassif5" then
				bottom = seat(x, z) - 8
				top = bottom + size.Y * scale
			end
			p.Size = Vector3.new(size.X * scale, math.max(15, top - bottom), size.Z * scale)
			p.CFrame = CFrame.new(x, bottom + p.Size.Y / 2, z) * cf.Rotation
			p.RenderFidelity = Enum.RenderFidelity.Automatic
			p:SetAttribute("ScenicDistanceRevision", 1)
			count += 1
		end
	end
	for p, value in query do
		p.CanQuery = value
	end
	return count
end
return B
