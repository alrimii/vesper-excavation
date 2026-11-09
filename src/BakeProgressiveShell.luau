-- Edit-time authoring only. Native CSG keeps the source surface and UVs.
-- Never run CSG in a hit handler.
local shared = game.ReplicatedStorage.VesperShared
local archive = game.ServerStorage.RoomRebuildArchive
local geometry = game:GetService("GeometryService")
assert(not archive:FindFirstChild("OuterShellBeforeProgressive"), "Already installed")
local staged = Instance.new("Folder")
staged.Name = "ProgressiveOuterShellStaging"
staged.Parent = game.ServerStorage
staged:SetAttribute("Status", "Building")
task.spawn(function()
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
			staged:SetAttribute("CompletedRows", row - 9)
			task.wait()
		end
	end)
	staged:SetAttribute("Status", ok and "ReadyForInstall" or "Failed")
	if not ok then
		staged:SetAttribute("Error", tostring(err))
	end
end)
return "Building outer-shell geometry only; live library has not been replaced."
