-- Edit only. Fresh Model 124702277394975; originals remain private and unchanged.
return function(imported)
	assert(not game:GetService("RunService"):IsRunning(), "Edit only")
	assert(
		not game.ReplicatedStorage.VesperShared.SpecimenAssets:FindFirstChild("crystal_triceratops"),
		"Already installed"
	)
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
			sa.ColorMap = "rbxassetid://72193654815759"
			sa.MetalnessMap = "rbxassetid://133239986373567"
			sa.RoughnessMap = "rbxassetid://85178923137606"
			sa.NormalMap = "rbxassetid://108125817040792"
			sa.Parent = p
		end
	end
	assert(count == 1, "Unexpected source assembly")
	-- Same importer correction as the Rodin tools; retain every part transform.
	imported:PivotTo(CFrame.Angles(0, math.pi, 0))
	imported.WorldPivot = CFrame.identity
	imported.Name = "crystal_triceratops"
	for key, value in
		{
			CanonicalCreature = true,
			PreserveMaterials = true,
			ForwardNegativeZ = true,
			StaticMesh = true,
			DefaultScale = 1,
			TriangleCount = 10050,
			VertexCount = 5030,
			Icon = "rbxassetid://102662158340345",
			SourceFile = "rodin-crystal-triceratops-source/base_basic_pbr.fbx",
		}
	do
		imported:SetAttribute(key, value)
	end
	imported.Parent = game.ReplicatedStorage.VesperShared.SpecimenAssets
	game:GetService("ChangeHistoryService"):SetWaypoint("Supplied Crystal Triceratops canonical model")
	return imported:GetFullName()
end
