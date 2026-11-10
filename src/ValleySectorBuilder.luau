-- Edit-only scenery assembly for the original place. No player or gameplay authority.
local B={}
local angle=math.rad(56)
local basis=CFrame.Angles(0,angle,0)
local function model(parent,name)
	local m=Instance.new('Model');m.Name=name;m.Parent=parent;return m
end
local function mesh(parent,folder,name,cf,scale,tint)
	local t=folder[name];local p=t:Clone();scale=scale or 1
	local sc=typeof(scale)=='Vector3'and scale or Vector3.one*scale
	-- Native FBX mesh X is mirrored; source geometry coordinates remain authored in Blender.
	if folder==game.ServerStorage.LivingLabArtAssets then local pos=cf.Position;cf=CFrame.new(-pos.X,pos.Y,pos.Z)*cf.Rotation end
	p.Size=t.Size*sc;p.CFrame=basis*cf*CFrame.new(t:GetAttribute('SourceCenter')*sc)
	p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false
	p.Color=tint or Color3.new(1,1,1);local sa=p:FindFirstChildOfClass('SurfaceAppearance');if sa then sa.Color=p.Color end
	p.Parent=parent;return p
end
function B.Build()
	assert(game.PlaceId==94763223427049 and not game:GetService('RunService'):IsRunning(),'Original Edit mode only')
	local lab=workspace.VesperLab;local exterior=lab.DecorativeExterior
	local previous=exterior:FindFirstChild('EastValleySector');if previous then previous:Destroy()end
	-- Explicit named modules and two old mountain placements only; other sectors stay intact.
	for _,name in {'WaterfallBasin1','LandscapeGroup2','LandscapeGroup3'}do local old=exterior:FindFirstChild(name);if old then old:Destroy()end end
	for _,p in exterior:GetChildren()do if p:IsA('BasePart')and p.Name:match('^Mountain')then
		local deg=math.deg(math.atan2(p.Position.X,p.Position.Z))%360
		if deg>30 and deg<90 then p:Destroy()end
	end end
	local root=model(exterior,'EastValleySector');root:SetAttribute('SceneryOnly',true);root:SetAttribute('SectorBearing',56);root:SetAttribute('Revision',1)
	local geology=model(root,'ConnectedGeology');local assets=game.ServerStorage.ValleySectorAssets;local nature=game.ServerStorage.LivingLabArtAssets
	for _,name in {'ConnectedValley','RiverCliffMass','ValleyRidgeNear','ValleyRidgeFar'}do
		local offset=name=='ValleyRidgeFar'and CFrame.new(0,10,0)or name=='ValleyRidgeNear'and CFrame.new(0,40,0)or name=='RiverCliffMass'and CFrame.new(0,40,0)or CFrame.identity
		local scale=name=='ValleyRidgeFar'and Vector3.new(1,1.95,1)or name=='ValleyRidgeNear'and Vector3.new(1,1.5,1)or Vector3.one
		local tint=name=='RiverCliffMass'and Color3.fromRGB(168,188,176)or nil
		mesh(geology,assets,name,offset,scale,tint);task.wait()end
	-- Static authoring placement samples the imported triangle surfaces, not physics or gameplay.
	-- This avoids floating roots caused by FBX handedness or height-field approximation.
	local triangles={}
	for _,name in {'ConnectedValley','RiverCliffMass'}do
		local p=geology[name];local em=game:GetService('AssetService'):CreateEditableMeshAsync(Content.fromUri(p.MeshId))
		assert(em,'Editable mesh read unavailable for terrain placement')
		local points={};local ratio=p.Size/p.MeshSize
		for _,id in em:GetVertices()do points[id]=basis:PointToObjectSpace(p.CFrame:PointToWorldSpace(em:GetPosition(id)*ratio))end
		for _,id in em:GetFaces()do
			local face=em:GetFaceVertices(id);local a,b,c=points[face[1]],points[face[2]],points[face[3]]
			local den=(b.Z-c.Z)*(a.X-c.X)+(c.X-b.X)*(a.Z-c.Z)
			if math.abs(den)>.0001 then table.insert(triangles,{a,b,c,den,math.min(a.X,b.X,c.X),math.max(a.X,b.X,c.X),math.min(a.Z,b.Z,c.Z),math.max(a.Z,b.Z,c.Z)})end
		end
		em:Destroy();task.wait()
	end
	local function placedHeight(x,z)
		x=-x;local best=-math.huge
		for _,t in triangles do if x>=t[5]and x<=t[6]and z>=t[7]and z<=t[8]then
			local a,b,c=t[1],t[2],t[3];local u=((b.Z-c.Z)*(x-c.X)+(c.X-b.X)*(z-c.Z))/t[4];local v=((c.Z-a.Z)*(x-c.X)+(a.X-c.X)*(z-c.Z))/t[4]
			if u>=-.0001 and v>=-.0001 and u+v<=1.0001 then best=math.max(best,u*a.Y+v*b.Y+(1-u-v)*c.Y)end
		end end
		assert(best>-math.huge,'Planting position outside authored ground')
		return best
	end
	local water=model(root,'Watercourse')
	for _,name in {'TwinCascade','ReceivingBasin','ValleyOutflow','BasinFoam'}do local p=mesh(water,assets,name,CFrame.new(0,40,0),1);p.CastShadow=false end
	-- Oaks share the same leaf family; no smooth blob shrubs, palms or conflicting pines.
	local woods=model(root,'ForestGroups')
	local groups={
		{-230,439,5,1.95},{-152,461,5,1.9},{190,435,5,1.95},{270,479,6,2.2},
		{-289,565,5,2.3},{255,568,5,2.2},{-165,738,5,2.4},{136,757,5,2.3},
		{-302,812,5,2.3},{309,835,4,2.3},{-242,936,4,2.2},{248,950,4,2.2},{-105,711,4,2.1},{104,714,4,2.0},{-330,490,6,2.2},{325,505,6,2.1},{40,798,7,2.1}}
	for n,g in groups do
		local cluster=model(woods,'Woodland'..n);local rng=Random.new(900+n)
		for j=1,g[3]do
			local x=g[1]+rng:NextNumber(-36,36);local z=g[2]+rng:NextNumber(-26,26)
			local h=placedHeight(x,z)-.65;local scale=g[4]*rng:NextNumber(.87,1.2)
			mesh(cluster,nature,j%3==0 and 'CanopyYoung'or'CanopyOak',CFrame.new(x,h,z)*CFrame.Angles(0,rng:NextNumber()*math.pi*2,0),scale,Color3.fromRGB(223,236,212))
		end
		-- Undergrowth grouped at forest edges, sharing Quaternius leaf textures.
		for j=1,4 do
			local x=g[1]+rng:NextNumber(-40,40);local z=g[2]-20+rng:NextNumber(-14,14)
			mesh(cluster,nature,'LeafShrub',CFrame.new(x,placedHeight(x,z)-.15,z)*CFrame.Angles(0,j+n,0),2.1,Color3.fromRGB(216,232,199))
			if n<7 then mesh(cluster,nature,'ForestFern',CFrame.new(x+4,placedHeight(x+4,z+3)-.1,z+3)*CFrame.Angles(0,j,0),1.5,Color3.fromRGB(216,232,199))end
		end
		task.wait()
	end
	local rocks=model(root,'IntegratedOutcrops')
	-- Broad partly buried rock shoulders, sparse enough to read the continuous cliff behind.
	local placements={{-165,535,3.2},{-221,573,3.6},{184,537,3.4},{244,591,4},{-331,663,4.8},{310,704,4.2},{-106,484,2.3},{133,485,2},{-50,553,2},{124,552,2.5},{-95,695,2.1},{75,686,2.5}}
	for n,d in placements do
		local spread=d[3]*7
		local h=math.min(placedHeight(d[1],d[2]),placedHeight(d[1]-spread,d[2]),placedHeight(d[1]+spread,d[2]),placedHeight(d[1],d[2]-spread*.6),placedHeight(d[1],d[2]+spread*.6))-5
		mesh(rocks,nature,n%2==0 and 'RockLedge'or'RockShoulder',CFrame.new(d[1],h,d[2])*CFrame.Angles(0,n*.72,0),Vector3.new(d[3]*1.8,d[3]*.7,d[3]*1.3),Color3.fromRGB(191,201,184))
		for j=1,2 do local x=d[1]+j*9;local z=d[2]+j*3;mesh(rocks,nature,'LeafShrub',CFrame.new(x,placedHeight(x,z)-.2,z),1.7,Color3.fromRGB(212,231,193))end
	end
	-- Broad attached rock buttresses break the continuous cliff face into substantial strata.
	-- They are embedded in the authored mass; the mass, not separate boulder towers, carries the silhouette.
	local buttresses=model(root,'CliffButtresses')
	local faces={{-230,98,581,5.8,8.8,4.4},{-153,102,577,5.2,10,4},{-87,95,585,4.4,8,3.8},{110,96,579,5.6,9.8,4.6},{186,100,580,5.8,8.4,4.3},{247,100,594,4.5,8,3.5},{-205,179,639,5.9,9.1,4.2},{-127,177,638,5.1,8.5,4.1},{117,177,636,5.3,10,4.5},{208,178,641,6.4,9,4.8}}
	for i,d in faces do mesh(buttresses,nature,i%3==0 and 'RockLedge'or'RockShoulder',CFrame.new(d[1],d[2],d[3])*CFrame.Angles(0,(i%3-1)*.16,0),Vector3.new(d[4],d[5],d[6]),Color3.fromRGB(231,235,216))end
	-- Restrained native scrolling texture accents; no script loop, particles or lights.
	local anchor=Instance.new('Part');anchor.Name='WaterMotionAnchors';anchor.Size=Vector3.one;anchor.Transparency=1;anchor.Anchored=true;anchor.CanCollide=false;anchor.CanTouch=false;anchor.CanQuery=false;anchor.CFrame=basis*CFrame.new(0,40,0);anchor.Parent=water
	local path={{-20,222,644},{-17,209,638},{-12,183,628},{-8,155,620},{0,147,611},{10,145,598},{22,137,586},{25,118,581},{28,95,575},{33,80,566}}
	for strip=1,2 do
		local last
		for i,point in path do
			local a=Instance.new('Attachment');a.Name='Flow'..strip..'_'..i;a.Position=Vector3.new(-point[1]+(strip==1 and -7 or 7),point[2],point[3]);a.Parent=anchor
			if last then local b=Instance.new('Beam');b.Name='WaterStreak';b.Attachment0=last;b.Attachment1=a;b.Width0=4;b.Width1=4;b.FaceCamera=true;b.Segments=1;b.Texture='rbxassetid://109793194125471';b.TextureLength=18;b.TextureSpeed=.6;b.TextureMode=Enum.TextureMode.Wrap;b.LightEmission=.15;b.LightInfluence=.5;b.Transparency=NumberSequence.new(.38);b.Color=ColorSequence.new(Color3.fromRGB(220,241,228));b.Parent=anchor end
			last=a
		end
	end
	lab:SetAttribute('ValleySectorRevision',1)
	return 'East valley sector rebuilt; other scenery/interior retained'
end
return B
