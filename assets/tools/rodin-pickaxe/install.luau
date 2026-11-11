-- Edit-only fitting of a fresh insertion of uploaded model 125687100665406.
-- Pass the inserted Model. Transform the complete assembly; never reset individual
-- MeshPart CFrames from bounds centers (the imported local mesh axes are rotated).
return function(imported)
	assert(not game:GetService("RunService"):IsRunning(), "Edit only")
	assert(imported:IsA("Model"), "Pass the freshly inserted Rodin model")
	local assets = game.ServerStorage.ToolPresentationAssets
	local meshes = 0
	for _, item in imported:GetDescendants() do
		if item:IsA("PackageLink") then
			item:Destroy()
		elseif item:IsA("MeshPart") then
			meshes += 1
			item.Anchored, item.Massless = true, true
			item.CanCollide, item.CanTouch, item.CanQuery = false, false, false
			item.Color = Color3.new(1, 1, 1)
			item.Material = Enum.Material.SmoothPlastic
			item.TextureID = "rbxassetid://90874713782709"
			local surface = item:FindFirstChildOfClass("SurfaceAppearance")
				or Instance.new("SurfaceAppearance")
			surface.Name = "SourcePBR"
			surface.Color = Color3.new(1, 1, 1)
			surface.ColorMap = "rbxassetid://90874713782709"
			surface.MetalnessMap = "rbxassetid://106595719402423"
			surface.RoughnessMap = "rbxassetid://71119738114898"
			surface.Parent = item
		end
	end
	assert(meshes == 7, "Unexpected asset assembly")
	imported:PivotTo(CFrame.Angles(0, math.pi, 0))
	imported:SetAttribute("SourceFile", "agentic_0003_pack_fbx_model.fbx")
	imported:SetAttribute("SourceSHA256", "fd986e665b296d1bb016b4f6da7fffb44ef6bee883d06d5c3cd2e096220f320c")
	imported:SetAttribute("TriangleCount", 38016)
	for _, name in { "RodinPickaxe", "AuthoredPickaxe" } do
		local old = assets:FindFirstChild(name)
		if old and old ~= imported then
			old:Destroy()
		end
	end
	imported.Name = "RodinPickaxe"
	imported.Parent = assets
	return require(game.ServerStorage.VesperTools.ToolPresentationBuilder).Pickaxe()
end
