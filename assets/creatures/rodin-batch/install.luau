-- Edit-only installer. Call with the fresh uploaded model, its geometry record,
-- and the matching upload-name entries from uploads.json.
return function(imported, record, assets)
	assert(not game:GetService("RunService"):IsRunning(), "Edit only")
	local root = game.ReplicatedStorage.VesperShared.SpecimenAssets
	assert(not root:FindFirstChild(record.id), "Already installed")
	local count = 0
	for _, p in imported:GetDescendants() do
		if p:IsA("PackageLink") then
			p:Destroy()
		elseif p:IsA("MeshPart") then
			count += 1
			p.Anchored, p.Massless = true, true
			p.CanCollide, p.CanTouch, p.CanQuery = false, false, false
			p.Color, p.Material, p.TextureID = Color3.new(1, 1, 1), Enum.Material.SmoothPlastic, ""
			local sa = Instance.new("SurfaceAppearance")
			sa.Name = "SourcePBR"
			for property, suffix in
				{ ColorMap = "Color", MetalnessMap = "Metalness", RoughnessMap = "Roughness", NormalMap = "Normal" }
			do
				sa[property] = "rbxassetid://" .. assets[record.uploadName .. suffix].assetId
			end
			sa.Parent = p
		end
	end
	assert(count == record.meshes, "Unexpected assembly")
	imported:PivotTo(CFrame.Angles(0, math.pi, 0))
	imported.WorldPivot = CFrame.identity
	imported.Name = record.id
	for key, value in
		{
			CanonicalCreature = true,
			PreserveMaterials = true,
			ForwardNegativeZ = true,
			StaticMesh = true,
			DefaultScale = 1,
			TriangleCount = record.triangles,
			VertexCount = record.vertices,
			Icon = "rbxassetid://" .. assets[record.uploadName .. "Icon"].assetId,
			SourceFile = "rodin-creatures-source/" .. record.folder .. "/base_basic_pbr.fbx",
			PreviewHull = game:GetService("HttpService"):JSONEncode(record.previewHull),
		}
	do
		imported:SetAttribute(key, value)
	end
	imported.Parent = root
	return imported:GetFullName()
end
