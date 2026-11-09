-- Rebuild native fracture geometry once per server, never during combat.
-- CSG MeshPart data is session-scoped; original uploaded meshes are the saved source.
local M = {}
local prepared = false
function M.Prepare(shared)
	if prepared then
		return
	end
	shared:SetAttribute("OuterFracturesReady", false)
	shared:SetAttribute("OuterFractureError", nil)
	local geometry = game:GetService("GeometryService")
	local staged = Instance.new("Folder")
	local ok, err = pcall(function()
		for row = 10, 39 do
			local name = string.format("L1_R%02d", row)
			local source = shared.EggAssetPreload[name]
			local phi = (row + 0.5) * math.pi / 40
			local dz = 52.02 * math.sin(phi)
			local dr = 40.8 * (math.cos(phi) * (1 + 0.18 * math.cos(phi)) - 0.18 * math.sin(phi) ^ 2)
			local normal = Vector3.new(dz, -dr, 0).Unit
			local side = Vector3.zAxis
			local up = normal:Cross(side).Unit
			local width = source.Size.Z * 0.5
			local height = (math.abs(up.X) * source.Size.X + math.abs(up.Y) * source.Size.Y) * 0.5
			local random = Random.new(7219 + row * 73)
			local sites = {}
			-- Unevenly distributed cells avoid identical triangular or radial wedges.
			for index = 1, 28 do
				local radius = math.sqrt((index - 0.5) / 28) * 0.94
				local angle = index * 2.3999632297 + row * 0.41 + random:NextNumber(-0.18, 0.18)
				sites[index] = source.Position
					+ side * (math.cos(angle) * width * radius)
					+ up * (math.sin(angle) * height * radius)
			end
			local neutral = source:Clone()
			neutral.Color = Color3.new(1, 1, 1)
			neutral.MaterialVariant = ""
			neutral.TextureID = ""
			for _, child in neutral:GetChildren() do
				if child:IsA("SurfaceAppearance") then
					child:Destroy()
				end
			end
			local results = geometry:FragmentAsync(neutral, sites, {
				CollisionFidelity = Enum.CollisionFidelity.Box,
				RenderFidelity = Enum.RenderFidelity.Precise,
			})
			neutral:Destroy()
			assert(#results >= 12, name .. ": insufficient fragments")
			local group = Instance.new("Folder")
			group.Name = name
			for i, item in results do
				local p = item.Instance
				p.Name = name .. string.format("_Chip%02d", item.Index or i)
				local center = p.ExtentsCFrame.Position
				local delta = center - source.Position
				local tangent = delta - normal * delta:Dot(normal)
				local direction = tangent.Magnitude > 0.001 and tangent.Unit or side
				local localPivot = p.CFrame:PointToObjectSpace(center)
				p.PivotOffset = CFrame.new(localPivot)
				p:SetAttribute("FragmentPivot", localPivot)
				p:SetAttribute("FractureCenter", source.CFrame:PointToObjectSpace(center))
				p:SetAttribute("RelativeCFrame", source.CFrame:ToObjectSpace(p.CFrame))
				p:SetAttribute("FractureDirection", source.CFrame:VectorToObjectSpace(direction))
				p:SetAttribute("SurfaceNormal", source.CFrame:VectorToObjectSpace(normal))
				p:SetAttribute("CrackSeed", random:NextNumber())
				p:SetAttribute("ProgressiveFracture", true)
				p.Anchored = true
				p.CanCollide, p.CanTouch, p.CanQuery = false, false, false
				p.Color, p.Material, p.MaterialVariant = source.Color, source.Material, source.MaterialVariant
				p.Reflectance = source.Reflectance
				p.Transparency, p.LocalTransparencyModifier = 0, 0
				p.CastShadow = source.CastShadow
				p.Parent = group
			end
			group.Parent = staged
			group:SetAttribute("FragmentCount", #results)
			shared:SetAttribute("OuterFractureRowsReady", row - 9)
			task.wait()
		end
	end)
	if not ok then
		staged:Destroy()
		shared:SetAttribute("OuterFractureError", tostring(err))
		error("Outer shell preparation failed: " .. tostring(err))
	end
	local library = shared:WaitForChild("FractureLibrary")
	for _, group in staged:GetChildren() do
		local old = library:FindFirstChild(group.Name)
		if old then
			old:Destroy()
		end
		group.Parent = library
	end
	staged:Destroy()
	prepared = true
	shared:SetAttribute("OuterFracturesReady", true)
end
return M
