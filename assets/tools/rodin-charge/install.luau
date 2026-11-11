-- Edit-only, fresh insertion of owner Model 92010232869320.
return function(imported)
	assert(not game:GetService("RunService"):IsRunning(), "Edit only")
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
			sa.ColorMap = "rbxassetid://107516321449088"
			sa.MetalnessMap = "rbxassetid://73326595026303"
			sa.RoughnessMap = "rbxassetid://71409232252049"
			sa.NormalMap = "rbxassetid://129645955556486"
			sa.Parent = p
		end
	end
	assert(count == 1, "Unexpected supplied charge assembly")
	imported:PivotTo(CFrame.Angles(0, math.pi, 0))
	imported.Name = "RodinCharge"
	imported:SetAttribute("SourceFile", "rodin-charge-source/base.obj")
	imported:SetAttribute("SourceSHA256", "89d4879e42e1cc4bfaed481b3ef3a64ae65f57adb930ff6c643656181fe49f43")
	imported:SetAttribute("TriangleCount", 8620)
	imported.Parent = game.ServerStorage.ToolPresentationAssets
	local b = game.ServerStorage.VesperTools.ToolPresentationBuilder:Clone()
	local result = require(b).Charge()
	b:Destroy()
	game:GetService("ChangeHistoryService"):SetWaypoint("Supplied Rodin sticky charge")
	return result
end
