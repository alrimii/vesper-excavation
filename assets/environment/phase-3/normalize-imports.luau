return function(data)
	assert(game.PlaceId==94763223427049 and not game:GetService('RunService'):IsRunning())
	local lib=game.ServerStorage:FindFirstChild('IntegratedGreeneryAssets')or Instance.new('Folder')
	lib.Name,lib.Parent='IntegratedGreeneryAssets',game.ServerStorage
	local report={}
	for _,name in {'ArchitecturalIvy','TrailingVine'}do
		local m=assert(game.ServerStorage:FindFirstChild(name));local d=data[name]
		local part
		for _,p in m:GetDescendants()do
			assert(not p:IsA('LuaSourceContainer'),'Unexpected source in import')
			if p:IsA('PackageLink')then p:Destroy()end
			if p:IsA('MeshPart')then assert(not part);part=p end
		end
		assert(part);local size=Vector3.new(table.unpack(d.size));local factor=size.Magnitude/part.Size.Magnitude
		assert((part.Size*factor-size).Magnitude<.01)
		part.Size=size
		part.CFrame=CFrame.new(Vector3.new(table.unpack(d.center)))*CFrame.Angles(0,math.pi,0)
		part.Name=name;part.Anchored=true;part.CanCollide=false;part.CanTouch=false;part.CanQuery=false;part.CastShadow=false
		part.Color=Color3.new(1,1,1);part.Material=Enum.Material.SmoothPlastic
		part:SetAttribute('SourceCenter',Vector3.new(table.unpack(d.center)))
		part:SetAttribute('SourceTriangles',d.triangles)
		part:SetAttribute('SourceURL','https://grab3d.com/models/nature/'..d.source..'/')
		part:SetAttribute('LicenseClaim','CC0 listed by Grab3D; provenance record retained')
		part.Parent=lib;m:Destroy()
		local sa=part:FindFirstChildOfClass('SurfaceAppearance')
		report[name]={size=tostring(part.Size),mesh=part.MeshId,colorMap=sa and sa.ColorMap or part.TextureID,normal=sa and sa.NormalMap or'',rotation=tostring(part.CFrame.Rotation)}
	end
	game:GetService('ChangeHistoryService'):SetWaypoint('Phase 3 normalized vine assets')
	return game.HttpService:JSONEncode(report)
end
