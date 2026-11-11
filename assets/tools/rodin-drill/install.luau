-- Edit only. Call with a fresh insertion of Model 138354353381740.
return function(imported)
	assert(not game:GetService("RunService"):IsRunning(), "Edit only")
	local count = 0
	for _, p in imported:GetDescendants() do
		if p:IsA("PackageLink") then
			p:Destroy() -- Keep the fitted local copy independent of package reimports.
		elseif p:IsA("MeshPart") then
			count += 1
			p.Anchored, p.Massless = true, true
			p.CanCollide, p.CanTouch, p.CanQuery = false, false, false
			p.Color, p.Material = Color3.new(1, 1, 1), Enum.Material.SmoothPlastic
			p.TextureID = "" -- SourcePBR owns all maps; avoid a redundant legacy texture request.
			local sa = Instance.new("SurfaceAppearance")
			sa.Name = "SourcePBR"
			sa.ColorMap = "rbxassetid://90195186307933"
			sa.MetalnessMap = "rbxassetid://109105119248998"
			sa.RoughnessMap = "rbxassetid://116118521758364"
			sa.NormalMap = "rbxassetid://135980048625105"
			sa.EmissiveMaskContent = Content.fromUri("rbxassetid://120770337746294")
			sa.EmissiveStrength = 0.25
			sa.EmissiveTint = Color3.new(1, 1, 1)
			sa.Parent = p
		end
	end
	assert(count == 2, "Unexpected drill assembly")
	-- Importer's assembly frame reverses the source X/Z axes, as with the pickaxe.
	-- Rotate the complete assembly, preserving the individual imported transforms.
	imported:PivotTo(CFrame.Angles(0, math.pi, 0))
	imported.Name = "RodinDrill"
	imported:SetAttribute("SourceFile", "rodin-drill-source/base_basic_pbr.fbx")
	imported:SetAttribute("SourceSHA256", "f041424d6c1aaf1881aa62d99a9f9c37ede9a2cc515c2a3d5655d8722c27e06d")
	imported:SetAttribute("TriangleCount", 9570)
	imported.Parent = game.ServerStorage.ToolPresentationAssets
	local b = game.ServerStorage.VesperTools.ToolPresentationBuilder:Clone()
	local result = require(b).Drill()
	b:Destroy()
	game:GetService("ChangeHistoryService"):SetWaypoint("Supplied Rodin drill integration")
	return result
end
