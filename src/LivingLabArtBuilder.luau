-- Edit-only art assembly for original place. No economy, saves, or combat authority.
local B={}
local C={stone=Color3.fromRGB(199,193,171),trim=Color3.fromRGB(68,115,111),dark=Color3.fromRGB(43,57,67),metal=Color3.fromRGB(99,111,107),warm=Color3.fromRGB(255,218,157),bone=Color3.fromRGB(219,204,168)}
local function lab()
	assert(game.PlaceId==94763223427049 and not game:GetService('RunService'):IsRunning(),'Original Edit mode only')
	return workspace.VesperLab
end
local function model(parent,name)
	local old=parent:FindFirstChild(name);if old then old:Destroy()end
	local m=Instance.new('Model');m.Name=name;m.Parent=parent;return m
end
local function part(parent,name,size,cf,color,material,solid)
	local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.stone;p.Material=material or Enum.Material.SmoothPlastic
	p.Anchored=true;p.CanCollide=solid==true;p.CanQuery=solid==true;p.CanTouch=false;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent;return p
end
local function beam(parent,name,a,b,w,color)
	return part(parent,name,Vector3.new(w,w,(a-b).Magnitude),CFrame.lookAt((a+b)/2,b),color,Enum.Material.Metal,false)
end
local function mesh(parent,name,cf,scale,color)
	local template=game.ServerStorage.LivingLabArtAssets[name];local p=template:Clone();local sc=typeof(scale)=='Vector3'and scale or Vector3.one*(scale or 1)
	p.Size=template.Size*sc;p.CFrame=cf*CFrame.new(template:GetAttribute('SourceCenter')*sc);p.Color=color or Color3.new(1,1,1)
	local finish=p:FindFirstChildOfClass('SurfaceAppearance');if finish then finish.Color=p.Color end
	p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Parent=parent;return p
end
local function oldMesh(parent,name,cf,scale)
	local t=game.ServerStorage.LivingLabAssets[name];local p=t:Clone();p.Size=t.Size*scale;p.CFrame=cf*CFrame.new(t:GetAttribute('SourceCenter')*scale);p.Color=C.bone;p.Parent=parent;return p
end
local function radial(a,r,y)return Vector3.new(math.sin(a)*r,y,math.cos(a)*r)end
local function label(parent,name,cf,w,h,text)
	local p=part(parent,name,Vector3.new(w,h,.24),cf,C.dark,nil,false)
	local g=Instance.new('SurfaceGui');g.Face=Enum.NormalId.Front;g.CanvasSize=Vector2.new(w*70,h*70);g.LightInfluence=.35;g.MaxDistance=230;g.Parent=p
	local t=Instance.new('TextLabel');t.Size=UDim2.fromScale(.94,.82);t.Position=UDim2.fromScale(.03,.09);t.BackgroundTransparency=1;t.Text=text;t.TextColor3=C.warm;t.Font=Enum.Font.FredokaOne;t.TextScaled=true;t.Parent=g;return p
end
local function tasklight(parent,cf,width,range)
	part(parent,'AttachedLampHousing',Vector3.new(width+.8,.7,2),cf,C.metal,Enum.Material.Metal,false)
	local p=part(parent,'WarmLens',Vector3.new(width,.15,1.4),cf*CFrame.new(0,-.43,0),C.warm,Enum.Material.SmoothPlastic,false)
	local l=Instance.new('SurfaceLight');l.Face=Enum.NormalId.Bottom;l.Angle=110;l.Brightness=1.3;l.Range=range or 23;l.Color=C.warm;l.Shadows=false;l.Parent=p
end
local function vegetation(parent,cf,seed,size)
	local rng=Random.new(seed);size=size or 1
	mesh(parent,'GroundShrub',cf*CFrame.new(-3*size,0,0)*CFrame.Angles(0,rng:NextNumber()*6,0),size*.9)
	mesh(parent,'Broadleaf',cf*CFrame.new(2*size,0,1*size)*CFrame.Angles(0,rng:NextNumber()*6,0),size*.9)
	mesh(parent,'ForestFern',cf*CFrame.new(-size,0,3*size)*CFrame.Angles(0,rng:NextNumber()*6,0),size*.5)
	mesh(parent,'LeafShrub',cf*CFrame.new(size,0,-3*size)*CFrame.Angles(0,rng:NextNumber()*6,0),size*.85)
	for i=1,2 do local x=rng:NextNumber(-5,5)*size;local z=rng:NextNumber(-4,4)*size;mesh(parent,'SoftGrass',cf*CFrame.new(x,0,z)*CFrame.Angles(0,i,0),size*.85)end
	if seed%3==0 then mesh(parent,'LanceLeaf',cf*CFrame.new(4,.1,-2),size*.18);mesh(parent,'Clover',cf*CFrame.new(-4,.1,2),size*1.35)end
end
local function lowerArchitecture(p,factor)
	local original=p:GetAttribute('LabArtOriginalCFrame')or p.CFrame
	local size=p:GetAttribute('LabArtOriginalSize')or p.Size
	p:SetAttribute('LabArtOriginalCFrame',original);p:SetAttribute('LabArtOriginalSize',size)
	p.CFrame=CFrame.new(original.Position.X,.7+(original.Position.Y-.7)*factor,original.Position.Z)*original.Rotation
	p.Size=Vector3.new(size.X,size.Y*factor,size.Z)
end
function B.Floor()
	local r=lab();local f=model(r,'StoneCirculation')
	-- Keep the existing continuous collision floor. Decorative joints do not add physics edges.
	r.Architecture.ArenaFloor.Color=Color3.fromRGB(125,127,117);r.Architecture.ArenaFloor.Material=Enum.Material.Slate
	for i=0,3 do mesh(f,'PavingQuarter',CFrame.new(0,.71,0)*CFrame.Angles(0,i*math.pi/2,0),1,Color3.fromRGB(245,242,231))end
	-- Flush boundary courses close the circular apron and perimeter transition.
	for _,radius in {74.7,115,131,235,267}do
		for i=0,143 do local a=i*math.pi/72;local b=(i+1)*math.pi/72;local p=beam(f,'FlushDressedCourse',radial(a,radius,.72),radial(b,radius,.72),.23,Color3.fromRGB(151,149,133));p.Material=Enum.Material.Slate;p.CastShadow=false end
		task.wait()
	end
	return 'Four shared paving meshes; reliable original continuous collision floor'
end
function B.Planting()
	local r=lab();local m=model(r,'ExcavationPlanting')
	for _,degree in {42,138,222,318}do
		-- Mesh starts on +X; turn it so its curved edge follows the actual platform.
		local a=math.rad(degree);local rot=CFrame.new(0,.75,0)*CFrame.Angles(0,math.pi/2-a,0)
		mesh(m,'CrescentBed',rot,1);mesh(m,'CrescentSoil',rot,1)
		for j=-2,2 do local angle=a+j*.072;local point=radial(angle,86+(j%2)*2,2.9)
			vegetation(m,CFrame.new(point)*CFrame.Angles(0,angle,0),degree+j,1)
			if j==-2 or j==2 then mesh(m,'RockRound',CFrame.new(radial(angle,88,2.8)),.6,Color3.fromRGB(210,212,190))end
		end
		for _,j in {-1,1}do mesh(m,'FlowerAccent',CFrame.new(radial(a+j*.1,79.3,2.9)),1.2)end
		task.wait()
	end
	-- Three destination groupings, leaving broad radial approaches to every room.
	local islands=model(r,'ResearchGardenIslands')
	for i,degree in {18,162,282}do
		local a=math.rad(degree);local cf=CFrame.new(radial(a,182,.75))*CFrame.Angles(0,a,0);local g=model(islands,'GardenIsland'..i)
		local base=part(g,'RoundedStoneBed',Vector3.new(3,40,24),cf*CFrame.new(0,1.5,0)*CFrame.Angles(0,0,math.pi/2),C.stone,Enum.Material.Limestone,false);base.Shape=Enum.PartType.Cylinder
		local earth=part(g,'Soil',Vector3.new(.15,37,21),cf*CFrame.new(0,3,0)*CFrame.Angles(0,0,math.pi/2),Color3.fromRGB(74,89,52),Enum.Material.Ground,false);earth.Shape=Enum.PartType.Cylinder
		mesh(g,i==2 and 'CanopyTwisted' or 'CanopyYoung',cf*CFrame.new(-7,3,0),.72)
		for _,x in {-12,-3,7,13}do vegetation(g,cf*CFrame.new(x,3,0),i*40+x,.9)end
		mesh(g,'RockLedge',cf*CFrame.new(8,3,3)*CFrame.Angles(0,1,0),.7)
		-- A curved reading edge supports the research landmark instead of random furniture.
		part(g,'ReadingBench',Vector3.new(19,.7,3),cf*CFrame.new(0,2.6,-13.2),Color3.fromRGB(153,124,83),Enum.Material.Wood,false)
		for _,x in {-7,7}do part(g,'BenchFoot',Vector3.new(1.5,2.6,2.7),cf*CFrame.new(x,1.3,-13.2),C.trim,nil,false)end
		label(g,'GardenIdentity',cf*CFrame.new(0,5,10.5),16,2,i==1 and 'FIELD BOTANY' or i==2 and 'DISCOVERY GARDEN' or 'MINERAL STUDIES')
		task.wait()
	end
	-- Landing and route planting stays outside the preserved ladder/deck bounds.
	vegetation(m,CFrame.new(70,.75,-14),411,1.1)
	part(m,'LandingPlantingPocket',Vector3.new(7,1.4,4.5),CFrame.new(60,22.1,-4),C.stone,Enum.Material.Limestone,false)
	part(m,'LandingSoil',Vector3.new(6.2,.12,3.7),CFrame.new(60,22.83,-4),Color3.fromRGB(74,89,52),Enum.Material.Ground,false)
	for _,z in {-5.4,-2.6}do beam(m,'AttachedPlanterBracket',Vector3.new(56.1,21.55,z),Vector3.new(61.5,21.55,z),.45,C.trim)end
	vegetation(m,CFrame.new(60,22.9,-4),412,.55)
	return 'Four platform crescents, three substantial destination gardens, access-side planting'
end
function B.Exterior()
	assert(not workspace.VesperLab:GetAttribute('ValleySectorRevision'),'Exterior recipe superseded locally by ValleySectorBuilder; preserve reviewed sector')
	local r=lab();local m=model(r,'DecorativeExterior');m:SetAttribute('SceneryOnly',true)
	local ground=part(m,'ScenicBase',Vector3.new(2,3000,3000),CFrame.new(0,-5,0)*CFrame.Angles(0,0,math.pi/2),Color3.fromRGB(83,111,69),Enum.Material.Grass,false);ground.Shape=Enum.PartType.Cylinder
	local groups={{8,460,1.3},{42,465,1.4},{78,490,1.6},{112,468,1.3},{151,490,1.5},{189,455,1.2},{229,520,1.9},{269,477,1.5},{307,455,1.35},{340,472,1.4}}
	for i,d in groups do
		local a=math.rad(d[1]);local cf=CFrame.new(radial(a,d[2],-3))*CFrame.Angles(0,a,0);local g=model(m,'LandscapeGroup'..i)
		local nearY=3+(i%3)*.55;local rearY=4.2+(i%2)*.7
		mesh(g,'PlantedSlope',cf,Vector3.new(d[3],nearY,1.3),Color3.fromRGB(143,183,104))
		mesh(g,'PlantedSlope',cf*CFrame.new(-20,2,86),Vector3.new(1.4,rearY,1.5),Color3.fromRGB(138,175,104))
		local function heightAt(x,z)
			local function h(px,pz,sx,sy,sz)
				px/=65*sx;pz/=45*sz
				return math.max(0,12*math.max(0,1-px*px-pz*pz)^1.2+2*math.max(0,1-math.abs(px))*math.sin(px*3+pz*4))*sy
			end
			return math.max(h(x,z,d[3],nearY,1.3),2+h(x+20,z-86,1.4,rearY,1.5))-.4
		end
		for j=1,5 do
			local x=({-45,-22,0,22,48})[j];local z=({14,50,68,32,5})[j];local height=heightAt(x,z)
			local names={'CanopyOak','CanopyYoung','MountainPine','CanopyTwisted','CanopyOak'}
			mesh(g,names[(j+i)%5+1],cf*CFrame.new(x,height,z)*CFrame.Angles(0,j*1.4+i,0),2.4+(i+j)%3*.4,Color3.fromRGB(225,239,214))
		end
		for j=1,4 do
			local x=-48+j*20;local z=-16+(j%2)*16
			mesh(g,j%2==0 and 'RockLedge' or 'RockShoulder',cf*CFrame.new(x,heightAt(x,z)-2,z)*CFrame.Angles(0,j+i,0),1.5+(j%3)*.5,Color3.fromRGB(191,201,178))
			vegetation(g,cf*CFrame.new(x,heightAt(x,z-13),z-13),i*100+j,1.8)
		end
		task.wait()
	end
	-- Unequal peak groups and open saddles replace a ring of repeated blocks.
	local peaks={{12,820,1.7,1.8},{46,900,2.2,2.6},{70,780,1.3,1.5},{104,950,2.3,2.9},{139,850,1.8,2.1},{168,980,2.4,3.1},{201,870,1.9,2.2},{242,930,2.1,3.2},{275,840,1.5,2.2},{312,960,2.5,2.6},{343,820,1.5,1.8}}
	for i,d in peaks do local a=math.rad(d[1]);mesh(m,'Mountain'..(i%3+1),CFrame.new(radial(a,d[2],-5))*CFrame.Angles(0,a+i*.27,0),Vector3.new(d[3],d[4],d[3]),Color3.fromRGB(132+(i%3)*7,159+(i%3)*5,166+(i%3)*6));task.wait()end
	for i,degree in {56,232}do
		local a=math.rad(degree);local cf=CFrame.new(radial(a,505,104))*CFrame.Angles(0,a+math.pi,0);local fall=model(m,'WaterfallBasin'..i)
		mesh(fall,'PlantedSlope',cf*CFrame.new(0,-112,45),Vector3.new(2,8.7,2.5),Color3.fromRGB(140,176,105))
		mesh(fall,'Mountain2',cf*CFrame.new(0,-100,-57),Vector3.new(1.4,1.8,1.1),Color3.fromRGB(166,182,159))
		-- Broad stratified ledges support the elevated receiving basin, visible above the wall bays.
		for tier=0,3 do for _,side in {-1,1}do
			mesh(fall,'RockLedge',cf*CFrame.new(side*(26-tier*3),-95+tier*25,42)*CFrame.Angles(0,side*.25+tier*.4,0),Vector3.new(4.4-tier*.35,3.7,4.3),Color3.fromRGB(179,194,160))
		end end
		for _,side in {-1,1}do
			for j=0,3 do mesh(fall,j%2==0 and 'RockLedge' or 'RockShoulder',cf*CFrame.new(side*(19+j*3),j*20,-j*5)*CFrame.Angles(0,side*.4+j*.3,0),Vector3.new(2.9,2.9,2.5),Color3.fromRGB(203,210,190))end
			mesh(fall,'CanopyOak',cf*CFrame.new(side*38,79,-20),1.5)
		end
		mesh(fall,'CascadeSheet',cf,1,Color3.fromRGB(200,233,229))
		local pool=part(fall,'ReceivingPool',Vector3.new(.35,64,43),cf*CFrame.new(0,.55,48)*CFrame.Angles(0,0,math.pi/2),Color3.fromRGB(68,139,145),Enum.Material.SmoothPlastic,false);pool.Shape=Enum.PartType.Cylinder
		local source=part(fall,'SourcePool',Vector3.new(.25,28,22),cf*CFrame.new(0,84,-5)*CFrame.Angles(0,0,math.pi/2),Color3.fromRGB(80,153,153),Enum.Material.SmoothPlastic,false);source.Shape=Enum.PartType.Cylinder
		for j=1,8 do local angle=j*math.pi/4;mesh(fall,'RockRound',cf*CFrame.new(math.cos(angle)*31,0,48+math.sin(angle)*21)*CFrame.Angles(0,angle,0),1.6)end
		for j=1,4 do mesh(fall,'GroundShrub',cf*CFrame.new(-35+j*17,1,70),1.8)end
		-- A few opaque crest shapes show flow direction without particles or stacked glass.
		for _,x in {-4,1,5}do beam(fall,'WaterCrest',cf:PointToWorldSpace(Vector3.new(x,82,10)),cf:PointToWorldSpace(Vector3.new(x,74,14)),.35,Color3.fromRGB(221,239,225))end
		task.wait()
	end
	return 'Composed near slopes, mixed tree clusters, varied distant ridges and two connected waterfall basins'
end
function B.Frontage()
	local r=lab();local plants=model(r,'PerimeterPlanting')
	for i,room in r.Rooms:GetChildren()do
		local old=room:FindFirstChild('LivingLabFrontage');if old then old:Destroy()end
		local cf=room:GetPivot();local g=model(room,'LivingLabFrontage')
		local architecture={FrontPanel=true,LeftWall=true,RightWall=true,BackWall=true,Ceiling=true,PortalHeader=true,PortalJamb=true,OwnerSign=true,OwnerSignMount=true,NumberSign=true,NumberSignMount=true,RoomType=true,RoomTypeMount=true,HeaderLight=true,JambStripe=true,DoorwayRecess=true,WallPanel=true,PanelFrame=true,RearPanel=true,RearSeam=true,InnerSign=true,ServiceConduit=true,CeilingFixture=true}
		for _,p in room:GetChildren()do if p:IsA('BasePart')and architecture[p.Name]then
			lowerArchitecture(p,.6)
			if p.Name=='NumberSign'then p.Size=Vector3.new(8,4,p.Size.Z)elseif p.Name=='NumberSignMount'then p.Size=Vector3.new(8.5,4.5,p.Size.Z)elseif p.Name=='OwnerSign'then p.Size=Vector3.new(28,2.5,p.Size.Z)end
		end end
		for _,x in {-29,29}do
			part(g,'IntegratedPlantingPlinth',Vector3.new(13,3.1,9),cf*CFrame.new(x,2.2,-40),C.stone,Enum.Material.Limestone,false)
			part(g,'Soil',Vector3.new(11.4,.15,7.5),cf*CFrame.new(x,3.82,-40),Color3.fromRGB(75,87,54),Enum.Material.Ground,false)
			vegetation(g,cf*CFrame.new(x,3.9,-40),i*23+x,.9)
		end
		for _,x in {-22,22}do
			part(g,'DressedPortalPier',Vector3.new(3.4,20,4.7),cf*CFrame.new(x,10.9,-37),C.stone,Enum.Material.Limestone,false)
			part(g,'PierSocket',Vector3.new(4.2,3.8,5.3),cf*CFrame.new(x,2.7,-37),C.trim,Enum.Material.Metal,false)
		end
		for _,p in room:GetDescendants()do
			if p:IsA('TextLabel')and (p.Text:find('FUTURE') or p.Text:find('IMPLEMENT') or p.Text:find('PLANNED'))then p.Text=''end
			if p:IsA('BasePart')and p.Name=='Threshold'then p.Color=Color3.fromRGB(139,159,145);p.Material=Enum.Material.Slate end
		end
		task.wait()
	end
	for i,bay in r.LaboratoryBays:GetChildren()do
		local cf=bay:GetPivot();local number=tonumber(bay.Name:match('%d+'));local a=math.rad((number-.5)*30);cf=CFrame.new(radial(a,291,0))*CFrame.Angles(0,a,0)
		local architecture={ResearchBackWall=true,AcousticCeiling=true,BayCheek=true,PortalColumn=true,ColumnSocket=true,JointBand=true,IntegratedLintel=true,RecessedHeader=true,TaskLightHousing=true,WarmDiffuser=true,Discipline=true}
		for _,p in bay:GetChildren()do if p:IsA('BasePart')and architecture[p.Name]then lowerArchitecture(p,.8)end end
		for _,p in bay:GetChildren()do if p.Name=='AngledFrieze'or p.Name=='HeaderShoulder'then p:Destroy()end end
		-- Layered header/shoulder makes deep bays legible without blocking entrances.
		part(bay,'AngledFrieze',Vector3.new(48,3,3.5),cf*CFrame.new(0,24,-20)*CFrame.Angles(math.rad(-12),0,0),C.trim,Enum.Material.Metal,false)
		for _,x in {-24,24}do beam(bay,'HeaderShoulder',cf:PointToWorldSpace(Vector3.new(x,20,-22)),cf:PointToWorldSpace(Vector3.new(x*.85,24,-22)),2.5,C.stone)end
		if number%3~=0 then
			vegetation(plants,cf*CFrame.new(-19,27.3,-16),number*12,1.1)
			vegetation(plants,cf*CFrame.new(17,27.3,-16),number*14,1)
		end
		-- Alternating mineral shelving, field benches and large fossil alcoves break identical frontage.
		if number==2 or number==8 then
			local prior=bay:FindFirstChild('CuratedSpecimenLabel');if prior then prior:Destroy()end
			for _,p in bay:GetChildren()do if p.Name=='RecessedShelf'or p.Name=='FossilSkull'or p.Name=='FossilBone'or p.Name=='Ammonite'or p.Name=='FossilLabel'or p.Name=='CoreLabel'then p:Destroy()end end
			oldMesh(bay,'FossilSkull',cf*CFrame.new(-8,7.6,6)*CFrame.Angles(0,-.25,0),3.2)
			oldMesh(bay,'Ammonite',cf*CFrame.new(14,9.8,9)*CFrame.Angles(math.pi/2,0,0),2.6)
			label(bay,'CuratedSpecimenLabel',cf*CFrame.new(0,5.5,9),29,2.6,'ANCIENT HERBIVORE')
		elseif number%3==0 then
			for _,p in bay:GetChildren()do if p.Name=='LowBoulder'then p:Destroy()end end
			for j=1,3 do mesh(bay,'LowBoulder',cf*CFrame.new(-14+j*7,7.5,10)*CFrame.Angles(0,j,0),.65,({Color3.fromRGB(185,218,204),Color3.fromRGB(231,192,135),Color3.fromRGB(160,185,207)})[j])end
		end
		task.wait()
	end
	return 'Planted room portals, varied research frontage; functional signs/anchors retained'
end
function B.Fossils()
	local r=lab();local root=model(r,'FocalResearchDisplays')
	for i,degree in {115,295}do
		local a=math.rad(degree);local cf=CFrame.new(radial(a,225,.75))*CFrame.Angles(0,a,0);local g=model(root,'FossilStudy'..i)
		part(g,'DressedExhibitBase',Vector3.new(36,2.3,19),cf*CFrame.new(0,1.15,0),C.stone,Enum.Material.Limestone,false)
		part(g,'InsetSpecimenBed',Vector3.new(34,.25,17),cf*CFrame.new(0,2.42,0),C.dark,Enum.Material.Slate,false)
		mesh(g,'FossilRibcage',cf*CFrame.new(1,2.7,0)*CFrame.Angles(0,math.pi/2,0),1.15,Color3.fromRGB(231,219,193))
		oldMesh(g,'FossilSkull',cf*CFrame.new(-14,7.3,0)*CFrame.Angles(0,-math.pi/2,0),2.05)
		for _,x in {-16,16}do part(g,'MuseumLampSupport',Vector3.new(.55,16,.55),cf*CFrame.new(x,8,7),C.trim,Enum.Material.Metal,false)end
		tasklight(g,cf*CFrame.new(0,16.3,7),32,22)
		for _,x in {-13,13}do beam(g,'SupportConnection',cf:PointToWorldSpace(Vector3.new(x,16.3,7)),cf:PointToWorldSpace(Vector3.new(x,16.3,0)),.5,C.trim)end
		label(g,'ExhibitName',cf*CFrame.new(0,3.1,-9.6),27,2.8,i==1 and 'THE FIRST DIG' or 'BENEATH THE SHELL')
		label(g,'ExhibitCaption',cf*CFrame.new(0,1.1,-9.65),25,1.1,'ANCIENT SPECIMENS  /  FIELD COLLECTION')
		vegetation(g,cf*CFrame.new(23,0,5),i*49,1.1)
		task.wait()
	end
	return 'Two large mounted ribcage/skull focal displays with attached task lighting'
end
function B.WorkshopAndAccess()
	local r=lab();local shop=r.SharedWorkshop;local a=math.rad(75);local cf=CFrame.new(radial(a,291,0))*CFrame.Angles(0,a,0)
	local old=shop:FindFirstChild('ArtFraming');if old then old:Destroy()end;local g=model(shop,'ArtFraming')
	local architecture={ResearchBackWall=true,AcousticCeiling=true,BayCheek=true,PortalColumn=true,ColumnSocket=true,JointBand=true,IntegratedLintel=true,RecessedHeader=true}
	for _,p in shop:GetChildren()do if p:IsA('BasePart')and architecture[p.Name]then lowerArchitecture(p,.8)end end
	-- Keep original interaction instances and bounds; pull visual product wall toward the counter.
	for _,p in shop:GetChildren()do
		if p:IsA('BasePart')and p.Name=='WorkshopIdentity'then p:Destroy()end
		if p:IsA('BasePart')and (p.Name=='PortalColumn' or p.Name=='BayCheek')then p.Color=C.stone end
	end
	label(g,'OutfitterIdentity',cf*CFrame.new(0,21,-24),38,3.7,'EXCAVATION WORKSHOP')
	part(g,'RecessedCanopy',Vector3.new(48,3,6),cf*CFrame.new(0,25.3,-19)*CFrame.Angles(math.rad(-12),0,0),C.trim,Enum.Material.Metal,false)
	for _,x in {-23,23}do beam(g,'AngledHeader',cf:PointToWorldSpace(Vector3.new(x,19,-22)),cf:PointToWorldSpace(Vector3.new(x*.8,24,-22)),3,C.stone)end
	tasklight(g,cf*CFrame.new(0,22.5,-5),38,26)
	for _,p in shop:GetChildren()do if p:IsA('BasePart')and p.Name:find('Label')then
		local gui=p:FindFirstChildOfClass('SurfaceGui');if gui then gui.LightInfluence=.1;gui.MaxDistance=240 end
	end end
	vegetation(g,cf*CFrame.new(-23,27.3,-16),81,1);vegetation(g,cf*CFrame.new(22,27.3,-16),82,1)
	-- Noncolliding footings around unchanged support centerlines and ladder footprint.
	local access=model(r,'AccessArtIntegration')
	for _,p in r.ExcavationAccess:GetChildren()do if p:IsA('BasePart')and p.Name:find('SupportBase')then
		part(access,'DressedSupportShoe',Vector3.new(5,2.3,5),CFrame.new(p.Position.X,1.9,p.Position.Z),C.stone,Enum.Material.Limestone,false)
	end end
	return 'Recessed workshop header/task-light and planted access integration, unchanged shop authority'
end
function B.CrownAndLighting()
	local r=lab();local dock=model(r,'CrownDeliveryDock')
	-- Fixed cross-members actually terminate at the dome latitude at y=247/r=88.
	for _,z in {-18,18}do
		local x=math.sqrt(88*88-z*z)
		beam(dock,'AttachedCrownBridge',Vector3.new(-x,247,z),Vector3.new(x,247,z),1.4,C.trim)
	end
	local i=0;for _,x in {-18,18}do for _,z in {-18,18}do i+=1;part(dock,'DeliverySocket'..i,Vector3.new(2.8,1,2.8),CFrame.new(x,246.8,z),C.metal,Enum.Material.Metal,false)end end
	local lighting=game:GetService('Lighting');lighting.ClockTime=14.2;lighting.Brightness=2.4;lighting.ExposureCompensation=-.1;lighting.Ambient=Color3.fromRGB(83,96,109);lighting.OutdoorAmbient=Color3.fromRGB(154,171,179);lighting.EnvironmentDiffuseScale=.65;lighting.EnvironmentSpecularScale=.3
	local at=lighting:FindFirstChildOfClass('Atmosphere');if at then at.Density=.14;at.Haze=.8;at.Glare=0;at.Color=Color3.fromRGB(210,224,227);at.Decay=Color3.fromRGB(146,171,181)end
	for _,p in r.Dome:GetDescendants()do if p:IsA('BasePart')and (p.Name=='ConnectedMeridian' or p.Name=='PeripheralColumn')then p.Color=C.trim end end
	r:SetAttribute('LivingLabArtRevision',1)
	return 'Physically attached crown delivery sockets and balanced daylight/task-light hierarchy'
end
return B
