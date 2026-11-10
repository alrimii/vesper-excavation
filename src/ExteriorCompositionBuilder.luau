-- Sole Edit recipe for the Phase 3 scenery composition. Retained meshes; no gameplay.
local B = {}
local layout = require(script.Parent.ExteriorIntegrationLayout)
function B.Build()
	assert(
		game.PlaceId == 94763223427049 and not game:GetService("RunService"):IsRunning(),
		"Original Edit place only"
	)
	local lab = workspace.VesperLab
	for _, d in layout do
		assert(game.ServerStorage[d.template[1]]:FindFirstChild(d.template[2]), d.template[2])
	end
	local old = lab:FindFirstChild("DecorativeExterior")
	if old then
		old:Destroy()
	end
	local root = Instance.new("Model")
	root.Name = "DecorativeExterior"
	root:SetAttribute("SceneryOnly", true)
	root:SetAttribute("CompositionRevision", 4)
	root.Parent = lab
	local groups = {}
	for i, d in layout do
		local g = groups[d.group]
		if not g then
			g = Instance.new("Model")
			g.Name = d.group
			g.Parent = root
			groups[d.group] = g
		end
		local p = game.ServerStorage[d.template[1]][d.template[2]]:Clone()
		p.Name = d.name
		p.Size = Vector3.new(table.unpack(d.size))
		p.CFrame = CFrame.new(table.unpack(d.cf))
		p.Color = Color3.new(table.unpack(d.color))
		p.TextureID = d.texture
		p.Material = Enum.Material[d.material]
		local sa = p:FindFirstChildOfClass("SurfaceAppearance")
		if sa then
			sa.Color = p.Color
		end
		p.Anchored = true
		p.CanCollide = false
		p.CanTouch = false
		p.CanQuery = false
		p.CastShadow = false
		p.Transparency = 0
		p.RenderFidelity = Enum.RenderFidelity.Automatic
		p:SetAttribute("ScenicOriginalCFrame", nil)
		p:SetAttribute("ScenicOriginalSize", nil)
		p:SetAttribute("ScenicDistanceRevision", nil)
		p:SetAttribute("CompositionIndex", i)
		p.Parent = g
		if i % 70 == 0 then
			task.wait()
		end
	end
	local ground = groups.ContinuousLowGround
	for _, p in ground:GetChildren() do
		p.CanQuery = true
	end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = { ground }
	local function height(x, z)
		local hit = workspace:Raycast(Vector3.new(x, 500, z), Vector3.new(0, -1000, 0), params)
		return hit and hit.Position.Y or -8
	end
	for _, p in root:GetDescendants() do
		if p:IsA("MeshPart") then
			local d = layout[p:GetAttribute("CompositionIndex")]
			if d.seat then
				local x, z = p.Position.X, p.Position.Z
				local y = height(x, z)
				if d.bury and d.bury > 3 then
					local dx, dz = p.Size.X * 0.27, p.Size.Z * 0.27
					y = math.min(
						y,
						height(x - dx, z),
						height(x + dx, z),
						height(x, z - dz),
						height(x, z + dz)
					)
				end
				p.CFrame = CFrame.new(x, y + p.Size.Y / 2 - (d.bury or 1), z) * p.CFrame.Rotation
			end
		end
	end
	for _, p in ground:GetChildren() do
		p.CanQuery = false
	end
	require(script.Parent.ExteriorAtmosphereBuilder).Build()
	lab:SetAttribute("ExteriorCompositionRevision", 4)
	return "452 retained mesh placements: layered woodland, seated foothills, separated massifs and meadow transitions"
end
return B
