-- Canonical Edit-only environment recipe. Gameplay anchors, egg, access and profiles are not rebuilt.
local B={}
local C={stone=Color3.fromRGB(211,211,191),trim=Color3.fromRGB(82,128,126),dark=Color3.fromRGB(49,67,79),recess=Color3.fromRGB(65,82,94),metal=Color3.fromRGB(97,113,119),warm=Color3.fromRGB(255,222,164),leaf=Color3.fromRGB(86,126,69),soil=Color3.fromRGB(67,72,56),bone=Color3.fromRGB(219,205,169)}
local function guard()
	assert(game.PlaceId==94763223427049 and not game:GetService('RunService'):IsRunning(),'Original Edit-mode place only')
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
local function beam(parent,name,a,b,width,color)
	local p=part(parent,name,Vector3.new(width,width,(b-a).Magnitude),CFrame.lookAt((a+b)/2,b),color,Enum.Material.Metal,false);p.CastShadow=false;return p
end
local function mesh(parent,name,cf,scale,color)
	local template=game.ServerStorage.LivingLabAssets[name];local p=template:Clone();p.Name=name
	p.Size=template.Size*(scale or 1);p.CFrame=cf*CFrame.new(template:GetAttribute('SourceCenter')*(scale or 1))
	p.Color=color or C.stone;p.Material=Enum.Material.SmoothPlastic;p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.Parent=parent;return p
end
local function label(parent,name,cf,width,height,text)
	local p=part(parent,name,Vector3.new(width,height,.28),cf,C.dark,nil,false)
	local g=Instance.new('SurfaceGui');g.Face=Enum.NormalId.Front;g.CanvasSize=Vector2.new(width*60,height*60);g.LightInfluence=.25;g.MaxDistance=190;g.Parent=p
	local t=Instance.new('TextLabel');t.Size=UDim2.fromScale(.94,.84);t.Position=UDim2.fromScale(.03,.08);t.BackgroundTransparency=1;t.Text=text;t.TextColor3=C.warm;t.Font=Enum.Font.FredokaOne;t.TextScaled=true;t.Parent=g;return p
end
local function lamp(parent,cf,width)
	part(parent,'TaskLightHousing',Vector3.new(width+.8,.5,1.6),cf,C.metal,Enum.Material.Metal,false)
	local p=part(parent,'WarmDiffuser',Vector3.new(width,.13,1.15),cf*CFrame.new(0,-.3,0),C.warm,Enum.Material.SmoothPlastic,false)
	local l=Instance.new('SurfaceLight');l.Face=Enum.NormalId.Bottom;l.Angle=105;l.Range=26;l.Brightness=1.1;l.Color=C.warm;l.Shadows=false;l.Parent=p
end
local function planter(parent,cf,width,depth,height)
	local m=Instance.new('Model');m.Name='IntegratedPlanter';m.Parent=parent
	part(m,'MineralBase',Vector3.new(width,height,depth),cf*CFrame.new(0,height/2,0),C.stone,Enum.Material.SmoothPlastic,true)
	part(m,'RecessedSoil',Vector3.new(width-.8,.12,depth-.8),cf*CFrame.new(0,height+.01,0),C.soil,Enum.Material.Ground,false)
	for _,z in {-1,1}do part(m,'DressedRim',Vector3.new(width+.1,.35,.38),cf*CFrame.new(0,height+.14,z*(depth-.2)/2),C.trim,nil,false)end
	for _,x in {-1,1}do part(m,'EndRim',Vector3.new(.38,.35,depth-.6),cf*CFrame.new(x*(width-.2)/2,height+.14,0),C.trim,nil,false)end
	for x=-width/2+2.6,width/2-1.5,4.7 do
		mesh(m,'PlantBush',cf*CFrame.new(x,height+.08,0)*CFrame.Angles(0,x*.21,0),.8,C.leaf)
		mesh(m,'PlantLeaves',cf*CFrame.new(x+.8,height+.1,-.5)*CFrame.Angles(0,x*.4,0),.72,Color3.fromRGB(121,153,80))
	end
	return m
end
local function radial(a,r,y)return Vector3.new(math.sin(a)*r,y,math.cos(a)*r)end
function B.Envelope()
	local lab=guard()
	for _,name in {'Dome','Infrastructure','ThermalServiceBays','FixtureHousings','WayfindingFixtures','Presentation','CraneGantry','RoomConnections'}do
		local old=lab:FindFirstChild(name);if old then old:Destroy()end
	end
	for _,p in lab.Architecture:GetChildren()do if p.Name~='ArenaFloor' and p.Name~='Foundation'then p:Destroy()end end
	lab.Architecture.ArenaFloor.Color=Color3.fromRGB(131,139,134);lab.Architecture.ArenaFloor.Material=Enum.Material.SmoothPlastic
	lab.Architecture.Foundation.Color=C.dark
	local dome=model(lab,'Dome');local profiles={{350,52},{326,109},{264,170},{179,218},{88,247},{0,258}}
	for i=0,23 do
		local a=i*math.pi/12;local rot=CFrame.Angles(0,a,0)
		local frame=Instance.new('Model');frame.Name=string.format('DomeSector%02d',i+1);frame.Parent=dome
		local r=350*math.cos(math.pi/24);local w=700*math.sin(math.pi/24)
		part(frame,'EnclosureSill',Vector3.new(w,12,2),rot*CFrame.new(0,6.675,r),C.stone,nil,true)
		local glass=part(frame,'ClerestoryGlass',Vector3.new(w,39.325,.18),rot*CFrame.new(0,32.3375,r),Color3.fromRGB(185,215,217),Enum.Material.Glass,true)
		glass.Transparency=.78;glass.Reflectance=.035;glass.CastShadow=false
		for band=1,5 do
			local pane=mesh(frame,'DomePane'..band,rot,1,Color3.fromRGB(190,217,222));pane.Material=Enum.Material.Glass;pane.Transparency=.83;pane.Reflectance=.025;pane.DoubleSided=true;pane.CastShadow=false;pane.CanCollide=true;pane.CanQuery=true
			local p,q=profiles[band],profiles[band+1]
			local edge=a+math.pi/24
			beam(frame,'ConnectedMeridian',radial(edge,p[1],p[2]),radial(edge,q[1],q[2]),band<3 and 1.5 or 1.05,C.trim)
			if band<5 then beam(frame,'LatitudeJoint',radial(a-math.pi/24,q[1],q[2]),radial(a+math.pi/24,q[1],q[2]),1.1,C.metal)end
		end
		beam(frame,'SillCap',radial(a-math.pi/24,350,52),radial(a+math.pi/24,350,52),2,C.stone)
		part(frame,'PeripheralColumn',Vector3.new(3.2,52,3.2),CFrame.new(radial(a+math.pi/24,350,26)),C.trim,Enum.Material.Metal,true)
		task.wait()
	end
	local cap=part(dome,'CrownJoint',Vector3.new(8,1.2,8),CFrame.new(0,258,0),C.trim,Enum.Material.Metal,true);cap.Shape=Enum.PartType.Ball
	local lighting=game:GetService('Lighting');lighting.ClockTime=11.2;lighting.Brightness=2;lighting.ExposureCompensation=0
	lighting.Ambient=Color3.fromRGB(103,116,125);lighting.OutdoorAmbient=Color3.fromRGB(166,174,179)
	lighting.EnvironmentDiffuseScale=.7;lighting.EnvironmentSpecularScale=.45
	local atmosphere=lighting:FindFirstChildOfClass('Atmosphere');if atmosphere then atmosphere.Density=.16;atmosphere.Offset=.15;atmosphere.Color=Color3.fromRGB(207,222,226);atmosphere.Decay=Color3.fromRGB(144,165,177);atmosphere.Glare=0;atmosphere.Haze=1 end
	for _,p in lighting:GetChildren()do if p:IsA('BloomEffect')then p.Intensity=.08;p.Size=18;p.Threshold=2 elseif p:IsA('ColorCorrectionEffect')then p.Brightness=0;p.Contrast=.035;p.Saturation=-.035;p.TintColor=Color3.new(1,1,1) elseif p:IsA('DepthOfFieldEffect')then p.Enabled=false elseif p:IsA('SunRaysEffect')then p.Intensity=.025 end end
	lab:SetAttribute('LivingLabRevision',1)
	return 'Glass envelope, connected ribs and lighting saved'
end
function B.FloorAndAccess()
	local lab=guard();local floor=model(lab,'StoneCirculation');local count=0
	for row=-15,15 do
		local group=Instance.new('Model');group.Name='StoneCourse'..row;group.Parent=floor
		for col=-12,12 do
			local x=col*24.3+(row%2)*12.15;local z=row*18.3;local distance=Vector2.new(x,z).Magnitude
			if distance>91 and distance<257 then
				local tone=({Color3.fromRGB(163,173,162),Color3.fromRGB(154,166,158),Color3.fromRGB(175,178,163)})[(col+row)%3+1]
				local slab=mesh(group,'StoneSlab'..((col-row)%3+1),CFrame.new(x,.685,z),1,tone);slab.CanCollide=true;slab.CanQuery=true;count+=1
			end
		end;task.wait()
	end
	-- Existing access collision, decks, ladder and guard coordinates remain byte-for-byte unchanged.
	for _,p in lab.ExcavationAccess:GetDescendants()do if p:IsA('BasePart') and p.Transparency<1 then
		if p.Name:find('Rail')or p.Name:find('Rung')then p.Color=C.trim;p.Material=Enum.Material.Metal
		elseif p.Name:find('Deck')or p.Name=='Landing'then p.Color=Color3.fromRGB(161,176,171);p.Material=Enum.Material.Metal
		elseif p.Name:find('Support')or p.Name:find('Column')then p.Color=C.stone;p.Material=Enum.Material.Metal end
	end end
	for _,p in lab.CentralPlatform:GetDescendants()do if p:IsA('BasePart') and p.Transparency<1 then p.Color=p.Name:find('Accent') and C.trim or Color3.fromRGB(139,157,153);p.Material=Enum.Material.Metal end end
	local plants=model(lab,'ExcavationPlanting')
	-- Outside the preserved platform (radius 74.25), access supports and rubble flight space.
	for _,degrees in {32,148,212,328}do local a=math.rad(degrees);planter(plants,CFrame.new(radial(a,83,.675))*CFrame.Angles(0,a,0),12,5,1.8)end
	planter(plants,CFrame.new(64,.675,-13),9,4,2.3)
	planter(plants,CFrame.new(61,22.005,-3),5,3,1.2)
	return count..' dressed stone slabs; access geometry retained'
end
local function bayFrame(parent,name,basis)
	local m=Instance.new('Model');m.Name=name;m.WorldPivot=basis;m.Parent=parent
	local function p(n,s,v,c,solid,mat)return part(m,n,s,basis*CFrame.new(v),c,mat,solid)end
	p('RecessFloor',Vector3.new(53,.22,41),Vector3.new(0,.79,0),C.recess,true)
	p('ResearchBackWall',Vector3.new(53,30,1),Vector3.new(0,15.9,20),C.dark,true)
	p('AcousticCeiling',Vector3.new(55,1.2,43),Vector3.new(0,33,0),C.dark,true)
	for _,x in {-27,27}do
		p('BayCheek',Vector3.new(1.2,33,43),Vector3.new(x,17,0),C.stone,true)
		p('PortalColumn',Vector3.new(3.5,31,4.2),Vector3.new(x,16,-21),C.stone,true)
		p('ColumnSocket',Vector3.new(4.2,2.5,4.8),Vector3.new(x,2,-21),C.trim,true)
		p('JointBand',Vector3.new(3.6,1.3,4.3),Vector3.new(x,27,-21),C.trim,false)
	end
	p('IntegratedLintel',Vector3.new(57,3.5,5),Vector3.new(0,31.6,-21),C.stone,true)
	p('RecessedHeader',Vector3.new(49,1.7,.3),Vector3.new(0,28.6,-23),C.trim,false)
	lamp(m,basis*CFrame.new(0,29,-18),17)
	return m,p
end
local function displayTool(parent,id,cf,span)
	local d=Instance.new('Model');d.Name=id..'Display'
	for _,node in game.ReplicatedStorage.VesperShared.EquipmentAssets[id]:GetDescendants()do if node:IsA('BasePart')and node.Transparency<1 then
		local p=node:Clone();for _,c in p:GetDescendants()do if c:IsA('LuaSourceContainer')or c:IsA('Constraint')or c:IsA('JointInstance')or c:IsA('ParticleEmitter')or c:IsA('Light')then c:Destroy()end end
		p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Parent=d
	end end
	local _,s=d:GetBoundingBox();d:ScaleTo(span/math.max(s.X,s.Y,s.Z));local c=d:GetBoundingBox();d:PivotTo(cf*c:ToObjectSpace(d:GetPivot()));d.Parent=parent
end
function B.Workshop()
	local lab=guard();local old=lab.SharedWorkshop;local prompts={}
	for _,n in {'Console','UpgradeConsole'}do prompts[n]=old[n]:FindFirstChildOfClass('ProximityPrompt'):Clone()end
	local a=math.rad(75);local basis=CFrame.new(radial(a,291,0))*CFrame.Angles(0,a,0)
	local m,p=bayFrame(lab,'RecessedWorkshopReplacement',basis)
	label(m,'WorkshopIdentity',basis*CFrame.new(0,25,-23.3),27,3.5,'EQUIPMENT LAB')
	p('ToolDisplayBackboard',Vector3.new(44,14,.6),Vector3.new(0,15,18.9),C.recess,false)
	for _,x in {-15,0,15}do p('MountChannel',Vector3.new(10,.6,.6),Vector3.new(x,13,18.4),C.metal,false)end
	displayTool(m,'Pickaxe',basis*CFrame.new(-15,16,17.8)*CFrame.Angles(0,math.pi,.2),8.3)
	displayTool(m,'Drill',basis*CFrame.new(0,16,17)*CFrame.Angles(0,2.5,0),6.2)
	displayTool(m,'Explosive',basis*CFrame.new(15,14.7,16.9),4.5)
	for i,id in {'PICKAXE','DRILL','CHARGE'}do label(m,id..'Label',basis*CFrame.new((i-2)*15,10.3,18.1),11,1.9,id)end
	p('IntegratedWorkbench',Vector3.new(45,5.8,7),Vector3.new(0,3.8,11),C.trim,true)
	p('MineralWorktop',Vector3.new(46,.6,8),Vector3.new(0,7,10.6),C.stone,true)
	for _,x in {-17,-6,6,17}do
		p('CabinetFront',Vector3.new(9.8,4.6,.35),Vector3.new(x,3.8,7.3),C.recess,false)
		p('InsetPull',Vector3.new(2.7,.2,.3),Vector3.new(x,5.2,7.05),C.warm,false)
	end
	p('ServiceTray',Vector3.new(9,.2,4),Vector3.new(-12,7.4,10),C.metal,false)
	displayTool(m,'Pickaxe',basis*CFrame.new(-12,8.2,10)*CFrame.Angles(0,0,math.pi/2),4)
	lamp(m,basis*CFrame.new(0,24.5,15),28)
	for i,n in {'Console','UpgradeConsole'}do
		local console=label(m,n,basis*CFrame.new(i==1 and -11 or 11,5.2,6.95),13,2,i==1 and 'EQUIPMENT' or 'UPGRADES');prompts[n].Parent=console
	end
	local zone=p('ApproachZone',Vector3.new(39,8,14),Vector3.new(0,4.8,-16),C.trim,false);zone.Transparency=1
	p('ApproachInlay',Vector3.new(37,.035,10),Vector3.new(0,.925,-16),Color3.fromRGB(114,144,134),false)
	label(m,'ApproachNotice',basis*CFrame.new(0,2.8,7),12,1.25,'BROWSE EQUIPMENT')
	-- Bring the counter/display forward to the circulation edge, leaving the recess as staff workspace.
	local presentation={ToolDisplayBackboard=true,MountChannel=true,IntegratedWorkbench=true,MineralWorktop=true,CabinetFront=true,InsetPull=true,ServiceTray=true,Console=true,UpgradeConsole=true,ApproachNotice=true,PICKAXELabel=true,DRILLLabel=true,CHARGELabel=true}
	local delta=basis:VectorToWorldSpace(Vector3.new(0,0,-19))
	for _,node in m:GetChildren()do
		if node:IsA('Model') and node.Name:find('Display') then node:PivotTo(node:GetPivot()+delta)
		elseif node:IsA('BasePart') and (presentation[node.Name] or ((node.Name=='TaskLightHousing' or node.Name=='WarmDiffuser') and basis:PointToObjectSpace(node.Position).Z>0))then node.CFrame+=delta end
	end
	old:Destroy();m.Name='SharedWorkshop';m:SetAttribute('LivingLabRevision',1)
	return 'Perimeter workshop at 75 degrees; existing interaction paths retained'
end
function B.BaysAndRooms()
	local lab=guard();local bays=model(lab,'LaboratoryBays');local greens=model(lab,'PerimeterPlanting')
	for i=0,11 do
		local a=(i+.5)*math.pi/6;local basis=CFrame.new(radial(a,291,0))*CFrame.Angles(0,a,0)
		if i~=2 then
			local m,p=bayFrame(bays,'ResearchBay'..(i+1),basis)
			local fossils=i==1 or i==3 or i==7
			label(m,'Discipline',basis*CFrame.new(0,25,-23.3),29,3,fossils and 'FOSSIL STUDIES' or i%2==0 and 'SAMPLE LAB' or 'FIELD RESEARCH')
			p('WorkSurface',Vector3.new(45,.65,7),Vector3.new(0,7.1,13),C.stone,true)
			p('LabCabinet',Vector3.new(43,6,6),Vector3.new(0,3.75,13.3),C.recess,true)
			for _,x in {-15,0,15}do
				p('DrawerFront',Vector3.new(13.5,4.8,.28),Vector3.new(x,4,10.12),C.trim,false)
				p('DrawerPull',Vector3.new(3,.2,.25),Vector3.new(x,5.6,9.9),C.metal,false)
			end
			for _,y in {13.3,20.5}do p('RecessedShelf',Vector3.new(45,.6,4.5),Vector3.new(0,y,17),C.metal,false)end
			if fossils then
				mesh(m,'FossilSkull',basis*CFrame.new(-12,13.65,16)*CFrame.Angles(0,-.25,0),1.6,C.bone)
				mesh(m,'FossilBone',basis*CFrame.new(6,13.65,16)*CFrame.Angles(0,math.pi/2,0),1.2,C.bone)
				mesh(m,'Ammonite',basis*CFrame.new(13,20.85,16),1.3,Color3.fromRGB(194,173,132))
				label(m,'FossilLabel',basis*CFrame.new(-12,11.7,14.6),11,1.25,'HERBIVORE / 01')
				label(m,'CoreLabel',basis*CFrame.new(8,11.7,14.6),13,1.25,'FIELD SPECIMENS')
			else
				for j=1,3 do
					local x=(j-2)*13;local jar=p('SpecimenJar',Vector3.new(4.6,4,4.6),Vector3.new(x,9.65,13),Color3.fromRGB(182,211,208),false,Enum.Material.Glass);jar.Shape=Enum.PartType.Cylinder;jar.CFrame*=CFrame.Angles(0,0,math.pi/2);jar.Transparency=.6;jar.CastShadow=false
					local lid=p('JarSeal',Vector3.new(.3,4.8,4.8),Vector3.new(x,12.05,13),C.metal,false);lid.Shape=Enum.PartType.Cylinder;lid.CFrame*=CFrame.Angles(0,0,math.pi/2)
					mesh(m,'ScenicRock',basis*CFrame.new(x,7.5,13)*CFrame.Angles(0,j,0),.055,({C.trim,C.bone,Color3.fromRGB(145,123,105)})[j])
				end
				mesh(m,'FossilBone',basis*CFrame.new(-10,13.65,16)*CFrame.Angles(0,math.pi/2,0),1,C.bone)
				mesh(m,'Ammonite',basis*CFrame.new(9,13.65,16),1,C.bone)
			end
		end
		for _,x in {-29.5,29.5}do planter(greens,basis*CFrame.new(x,.675,-15),5,10,3)end
		-- Planting is on architecture, not in entrances or training triggers.
		planter(greens,basis*CFrame.new(0,33.65,-17),20,5,1.6)
		task.wait()
	end
	for _,room in lab.Rooms:GetChildren()do
		for _,p in room:GetChildren()do if p:IsA('BasePart')then
			if ({FrontPanel=true,PortalJamb=true,PortalHeader=true,LeftWall=true,RightWall=true})[p.Name]then p.Color=C.stone;p.Material=Enum.Material.SmoothPlastic
			elseif ({BackWall=true,Ceiling=true,WallPanel=true,RearPanel=true})[p.Name]then p.Color=C.recess;p.Material=Enum.Material.SmoothPlastic
			elseif ({JambStripe=true,PanelFrame=true,Skirting=true,DoorwayRecess=true})[p.Name]then p.Color=C.trim;p.Material=Enum.Material.Metal
			elseif p.Name=='Floor'then p.Color=Color3.fromRGB(153,166,160);p.Material=Enum.Material.SmoothPlastic
			elseif p.Name=='HeaderLight'then p.Color=C.warm;p.Material=Enum.Material.SmoothPlastic
			elseif p.Name=='SpawnLane'then p.Color=Color3.fromRGB(135,161,151);p.Material=Enum.Material.SmoothPlastic end
		end end
		local basis=room:GetPivot();local front=model(room,'LivingLabFrontage')
		for _,x in {-23,23}do planter(front,basis*CFrame.new(x,.675,-40.5),8,4,2.4)end
		for _,x in {-32,32}do part(front,'MineralPortalFoot',Vector3.new(5,2,6),basis*CFrame.new(x,1.675,-36.5),C.trim,nil,true)end
		-- Keep RoomSpawn, OwnerSign.Display.Text, CollectionShelf and TrainingStation intact.
		task.wait()
	end
	return 'Eleven recessed research bays and twelve preserved room frontages'
end
function B.Exterior()
	local lab=guard();local m=model(lab,'DecorativeExterior');m:SetAttribute('SceneryOnly',true)
	local ground=part(m,'ScenicGround',Vector3.new(2,2600,2600),CFrame.new(0,-5,0)*CFrame.Angles(0,0,math.pi/2),Color3.fromRGB(112,137,111),Enum.Material.SmoothPlastic,false);ground.Shape=Enum.PartType.Cylinder
	for ring=1,2 do for i=0,17 do
		local a=(i+.35*ring)*math.pi/9;local r=ring==1 and 620 or 1000;local h=(ring==1 and 120 or 220)+(i%4)*25
		local rock=mesh(m,'ScenicRock',CFrame.new(radial(a,r,-4))*CFrame.Angles(0,a,0),1,ring==1 and Color3.fromRGB(117,140,145)or Color3.fromRGB(139,159,175))
		rock.Size=Vector3.new(115+(i%3)*35,h,100+(i%4)*22);rock.CFrame=CFrame.new(radial(a,r,h/2-4))*CFrame.Angles(0,a,math.rad((i%3-1)*12))
	end;task.wait()end
	for i=0,47 do
		local a=i*math.pi/24;local r=435+(i%4)*31;local scale=2.2+(i%5)*.22
		mesh(m,'ScenicTree',CFrame.new(radial(a,r,1))*CFrame.Angles(0,a+.5,0),scale,({Color3.fromRGB(76,112,81),Color3.fromRGB(99,132,86),Color3.fromRGB(89,121,101)})[i%3+1])
		-- Brown stem sleeve retains the source silhouette while separating bark/foliage materials.
		local stem=part(m,'TreeBark',Vector3.new(scale*8,scale*.85,scale*.85),CFrame.new(radial(a,r,scale*4+1))*CFrame.Angles(0,0,math.pi/2),Color3.fromRGB(103,88,66),Enum.Material.Wood,false);stem.Shape=Enum.PartType.Cylinder
	end
	for _,degrees in {35,145,260}do
		local a=math.rad(degrees);local basis=CFrame.new(radial(a,560,0))*CFrame.Angles(0,a,0)
		local rock=mesh(m,'ScenicRock',basis,1,Color3.fromRGB(116,139,146));rock.Size=Vector3.new(90,140,70);rock.CFrame=basis*CFrame.new(0,65,0)
		part(m,'DistantWaterfall',Vector3.new(12,105,.4),basis*CFrame.new(0,70,-35.3),Color3.fromRGB(180,214,218),Enum.Material.SmoothPlastic,false)
		for _,x in {-3,3}do part(m,'WaterRibbon',Vector3.new(1.7,103,.08),basis*CFrame.new(x,70,-35.55),Color3.fromRGB(219,235,230),Enum.Material.SmoothPlastic,false)end
		local pool=part(m,'DistantPool',Vector3.new(.3,60,40),basis*CFrame.new(0,1,-36)*CFrame.Angles(0,0,math.pi/2),Color3.fromRGB(111,169,173),Enum.Material.SmoothPlastic,false);pool.Shape=Enum.PartType.Cylinder
	end
	return 'Two mountain layers, tree belt, three static waterfalls; no exterior collision or gameplay'
end
function B.Anchors()
	local lab=guard();local f=lab:FindFirstChild('FunctionalAnchors')or Instance.new('Folder');f.Name='FunctionalAnchors';f.Parent=lab;f:ClearAllChildren()
	local function ref(name,target)local o=Instance.new('ObjectValue');o.Name=name;o.Value=target;o.Parent=f end
	ref('CurrentEgg',lab.Egg);ref('ExcavationAccess',lab.ExcavationAccess);ref('WorkshopInteraction',lab.SharedWorkshop.ApproachZone)
	for _,room in lab.Rooms:GetChildren()do ref(room.Name..'_Spawn',room.RoomSpawn);ref(room.Name..'_Entrance',room.Threshold);ref(room.Name..'_Training',room.TrainingStation.TrainingSpot)end
	return 'Functional references separated from visual modules'
end
return B
