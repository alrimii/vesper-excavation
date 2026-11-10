-- Canonical, scoped Edit-only map recipe. Never required by a runtime script.
local M = {}
local cream, teal, steel, ochre = Color3.fromRGB(205,199,178), Color3.fromRGB(70,111,112), Color3.fromRGB(65,78,86), Color3.fromRGB(209,157,76)
local function part(parent,name,size,cf,color,solid,material)
	local p=Instance.new("Part")
	p.Name,p.Size,p.CFrame=name,size,cf
	p.Color,p.Material=color or steel,material or Enum.Material.SmoothPlastic
	p.Anchored,p.CanCollide,p.CanTouch,p.CanQuery=true,solid==true,false,solid==true
	p.TopSurface,p.BottomSurface=Enum.SurfaceType.Smooth,Enum.SurfaceType.Smooth
	p.Parent=parent
	return p
end
local function model(parent,name)
	local old=parent:FindFirstChild(name)
	if old then old:Destroy() end
	local m=Instance.new("Model");m.Name=name;m.Parent=parent
	return m
end
local function sign(parent,name,size,cf,text,face)
	local p=part(parent,name,size,cf,teal,false)
	local g=Instance.new("SurfaceGui")
	g.Face,g.CanvasSize,g.LightInfluence,g.MaxDistance=face or Enum.NormalId.Front,Vector2.new(800,math.max(80,800*size.Y/size.X)),0,140
	g.Parent=p
	local t=Instance.new("TextLabel")
	t.Size,t.Position,t.BackgroundTransparency=UDim2.fromScale(0.9,0.8),UDim2.fromScale(0.05,0.1),1
	t.Text,t.TextColor3,t.Font,t.TextSize=text,Color3.fromRGB(250,239,204),Enum.Font.GothamBold,50
	t.TextScaled=true
	t.Parent=g
	return p
end
local function beam(parent,name,a,b,width,color)
	return part(parent,name,Vector3.new(width,width,(b-a).Magnitude),CFrame.lookAt((a+b)/2,b),color,true,Enum.Material.Metal)
end
local function guard()
	assert(not game:GetService("RunService"):IsRunning(),"Edit-mode recipe only")
	assert(game.PlaceId==94763223427049,"Original place only")
	return workspace.VesperLab
end
function M.Central()
	local lab=guard()
	local removed={}
	local function remove(p)
		table.insert(removed,p:GetFullName());p:Destroy()
	end
	for i=37,42 do
		local p=lab.FixtureHousings:FindFirstChild("IndustrialLuminaire"..i)
		if p then remove(p) end
	end
	if lab:FindFirstChild("AtmosphereDetails") then remove(lab.AtmosphereDetails) end
	local gantry=lab.CraneGantry
	for _,p in gantry:GetChildren() do
		if ({TowerChord=true,TowerDiagonal=true,TowerCollar=true,ImpactGuard=true,GuardStripe=true})[p.Name] then remove(p) end
	end
	local supports=model(gantry,"SimpleTowerSupports")
	for _,x in {-96,96} do for _,z in {-96,96} do
		part(supports,"Tower",Vector3.new(4.5,186.825,4.5),CFrame.new(x,96.0875,z),cream,true,Enum.Material.Metal)
		part(supports,"FootSocket",Vector3.new(6,3,6),CFrame.new(x,4.175,z),steel,true)
		part(supports,"FootBand",Vector3.new(6.04,0.25,6.04),CFrame.new(x,5.8,z),ochre,false)
	end end
	local access=lab.ExcavationAccess
	local ends={}
	for _,p in access:GetChildren() do
		if p.Name=="OutboardBrace" then
			local a=(p.CFrame*CFrame.new(0,0,-p.Size.Z/2)).Position
			local b=(p.CFrame*CFrame.new(0,0,p.Size.Z/2)).Position
			table.insert(ends,a.Y>b.Y and a or b)
			remove(p)
		end
	end
	local arms=access:FindFirstChild("WalkwaySupportArms")
	if #ends>0 or not arms then arms=model(access,"WalkwaySupportArms") end
	for _,p in access:GetChildren() do if p.Name=="OutboardSupport" then
		p.Color,p.Material=steel,Enum.Material.Metal
		local top=p.Position+Vector3.yAxis*(p.Size.Y/2)
		local best,dist=nil,math.huge
		for _,e in ends do local d=(top-e).Magnitude;if d<dist then best,dist=e,d end end
		if best then
			beam(arms,"TopBracket",Vector3.new(top.X,best.Y,top.Z),best,0.48,steel)
			beam(arms,"Knee",Vector3.new(top.X,best.Y-2,top.Z),Vector3.new(top.X,best.Y,top.Z):Lerp(best,0.22),0.35,steel)
		end
	end end
	-- Remove only exact duplicated visible decoration; retain every deck and invisible guard.
	local seen={}
	for _,p in access.DeploymentSections:GetDescendants() do
		if p:IsA("BasePart") and (p.Name=="Handrail" or p.Name=="RailPost" or p.Name=="EdgeBeam") then
			local key=p.Name..tostring(p.CFrame)..tostring(p.Size)
			if seen[key] then remove(p) else seen[key]=true end
		end
	end
	return removed
end
function M.Ladder()
	local lab=guard()
	local m=lab.ExcavationAccess.AccessRevision4
	local names={LadderTransferLanding=true,ClimbableEntry=true,LadderRail=true,LadderRung=true,EntryFooting=true,AccessSign=true,LandingHandrail=true,LandingGuard=true}
	for _,p in m:GetChildren() do if names[p.Name] then p:Destroy() end end
	local built=model(m,"LadderEntrance")
	local x,bottom,top=52.26727295,3.645,22.005
	part(built,"Landing",Vector3.new(8,0.4,9),CFrame.new(x,top-0.2,-4),steel,true,Enum.Material.Metal)
	for _,dx in {-3.8,3.8} do
		part(built,"LandingColumn",Vector3.new(0.5,top-bottom-0.4,0.5),CFrame.new(x+dx,(bottom+top-0.4)/2,-0.1),cream,true,Enum.Material.Metal)
		for _,z in {-8,0} do
			part(built,"GuardPost",Vector3.new(0.22,3.1,0.22),CFrame.new(x+dx,top+1.55,z),ochre,true,Enum.Material.Metal)
		end
		for _,y in {top+1.5,top+3} do
			part(built,"SideRail",Vector3.new(0.18,0.18,8),CFrame.new(x+dx,y,-4),ochre,true,Enum.Material.Metal)
		end
		local g=part(built,"LandingGuard",Vector3.new(0.18,3,8),CFrame.new(x+dx,top+1.5,-4),steel,true)
		g.Transparency=1
	end
	local climb=Instance.new("TrussPart")
	climb.Name,climb.Size,climb.CFrame="ClimbableEntry",Vector3.new(2,top-bottom,2),CFrame.new(x,(bottom+top)/2,-9.5)
	climb.Anchored,climb.Transparency,climb.CanCollide,climb.CanTouch=true,1,true,false
	climb.Parent=built
	for _,dx in {-1.6,1.6} do
		part(built,"LadderRail",Vector3.new(0.24,top-bottom+3,0.24),CFrame.new(x+dx,(bottom+top+3)/2,-10.45),cream,true,Enum.Material.Metal)
		part(built,"FootSocket",Vector3.new(0.65,0.3,0.7),CFrame.new(x+dx,bottom+0.15,-10.45),steel,true)
	end
	for y=bottom+0.5,top,1 do part(built,"Rung",Vector3.new(3,0.18,0.3),CFrame.new(x,y,-10.45),ochre,false,Enum.Material.Metal) end
	part(built,"ApproachMat",Vector3.new(5,0.05,3.5),CFrame.new(x,bottom+0.025,-12.3),teal,false)
	part(built,"SignPost",Vector3.new(0.3,5.2,0.3),CFrame.new(x+4.7,bottom+2.6,-10.45),steel,true)
	sign(built,"AccessSign",Vector3.new(4.4,1.5,0.25),CFrame.new(x+4.7,bottom+5.2,-10.45),"CLIMB")
	return "LadderEntrance"
end
function M.Shop()
	local lab=guard()
	local old=lab.SharedWorkshop
	-- Retain working prompt instances and paths; no menu/price reconstruction.
	local terminals={}
	for _,name in {"Console","UpgradeConsole"} do terminals[name]=old[name]:Clone() end
	local m=model(lab,"SharedWorkshop")
	local basis=CFrame.new(135,0.675,0)*CFrame.Angles(0,-math.pi/2,0)
	m.WorldPivot=basis
	local function p(n,s,v,c,solid) return part(m,n,s,basis*CFrame.new(v),c,solid) end
	p("Floor",Vector3.new(62,0.24,38),Vector3.new(0,0.12,0),cream,true)
	p("BackWall",Vector3.new(62,14,0.8),Vector3.new(0,7.24,-18.6),teal,true)
	for _,x in {-30.6,30.6} do
		p("SideWall",Vector3.new(0.8,7,37.2),Vector3.new(x,3.74,0),teal,true)
		p("EntryPost",Vector3.new(1.2,14,1.2),Vector3.new(x,7.24,18),cream,true)
		p("SideCap",Vector3.new(1.1,0.3,37.2),Vector3.new(x,7.39,0),ochre,false)
	end
	p("Awning",Vector3.new(62,0.5,7),Vector3.new(0,14.49,16),cream,true)
	sign(m,"ShopSign",Vector3.new(34,3,0.5),basis*CFrame.new(0,12.6,19),"TOOLWORKS",Enum.NormalId.Back)
	local assets=game.ReplicatedStorage.VesperShared.EquipmentAssets
	for i,id in {"Pickaxe","Drill","Explosive"} do
		local x=(i-2)*19
		p("DisplayBench",Vector3.new(16,3.4,7),Vector3.new(x,1.94,-12),steel,true)
		p("BenchTop",Vector3.new(16.4,0.3,7.4),Vector3.new(x,3.79,-12),cream,true)
		sign(m,id.."Label",Vector3.new(15,2,0.25),basis*CFrame.new(x,11.5,-18.05),id:upper(),Enum.NormalId.Back)
		local display=Instance.new("Model");display.Name=id.."Display"
		for _,node in assets[id]:GetDescendants() do if node:IsA("BasePart") then
			local clone=node:Clone()
			for _,d in clone:GetDescendants() do if d:IsA("JointInstance") or d:IsA("Constraint") or d:IsA("LuaSourceContainer") then d:Destroy() end end
			clone.Anchored,clone.CanCollide,clone.CanTouch,clone.CanQuery=true,false,false,false
			clone.Parent=display
		end end
		local _,size=display:GetBoundingBox();display:ScaleTo(6.5/math.max(size.X,size.Y,size.Z))
		local box,scaled=display:GetBoundingBox()
		display:PivotTo(basis*CFrame.new(x,3.99+scaled.Y/2,-12)*CFrame.Angles(0,-0.3,0)*box:ToObjectSpace(display:GetPivot()))
		display.Parent=m
		local light=p("BenchLight",Vector3.new(8,0.2,1.5),Vector3.new(x,13.6,-15),cream,false)
		local lamp=Instance.new("SurfaceLight");lamp.Face=Enum.NormalId.Bottom;lamp.Brightness=0.8;lamp.Range=20;lamp.Angle=100;lamp.Color=Color3.fromRGB(255,237,207);lamp.Parent=light
	end
	for i,name in {"Console","UpgradeConsole"} do
		local terminal=terminals[name]
		terminal.Size=Vector3.new(8,3.2,2)
		terminal.CFrame=basis*CFrame.new(i==1 and -24 or 24,1.84,9)
		local display=terminal:FindFirstChildOfClass("SurfaceGui")
		if display then
			local labels={}
			for _,child in display:GetChildren() do if child:IsA("TextLabel") then table.insert(labels,child) end end
			table.sort(labels,function(a,b) return a.Position.Y.Scale<b.Position.Y.Scale end)
			for j,label in labels do
				if j==1 then label.Text=i==1 and "EQUIPMENT" or "UPGRADES";label.Position=UDim2.fromScale(0.05,0.1);label.Size=UDim2.fromScale(0.9,0.8)
				else label:Destroy() end
			end
		end
		terminal.Parent=m
	end
	local zone=p("ApproachZone",Vector3.new(40,8,12),Vector3.new(0,4.24,12),teal,false)
	zone.Transparency=1
	p("EntryMat",Vector3.new(20,0.04,7),Vector3.new(0,0.26,14),teal,false)
	return "SharedWorkshop"
end
function M.Rooms()
	local lab=guard()
	local Cabinet=require(game.ServerScriptService.Vesper.CollectionCabinet)
	local paths=model(lab,"RoomConnections")
	local entrances={}
	for _,room in lab.Rooms:GetChildren() do
		local basis=room:GetPivot()
		local number=room:GetAttribute("RoomNumber")
		entrances[number]=(basis*CFrame.new(0,0.675,-44)).Position
		local decor=model(room,"FrontageAndZones")
		-- OwnerSign's Display.Text remains the RoomAllocator contract.
		for _,p in room:GetChildren() do
			if p.Name=="FrontPanel" then p.Color=cream end
			if p.Name=="PortalJamb" then p.Color=teal end
			if p.Name=="PortalHeader" then p.Color=teal end
		end
		room.OwnerSign.Size=Vector3.new(28,3,0.3)
		room.OwnerSign.CFrame=basis*CFrame.new(0,31.2,-38)
		room.OwnerSign.Color=teal
		local mount=room:FindFirstChild("OwnerSignMount")
		if mount then mount.Size=Vector3.new(29,3.6,0.4);mount.CFrame=basis*CFrame.new(0,31.2,-37.6) end
		-- A real entrance apron joins the existing threshold; no floating overlay on the room floor.
		part(decor,"Apron",Vector3.new(38,0.32,9),basis*CFrame.new(0,0.835,-39.7),cream,true)
		sign(decor,"EntryNumber",Vector3.new(8,2.4,0.3),basis*CFrame.new(-29,8,-36),string.format("LAB %02d",number))
		local station=room.TrainingStation
		local before=station:GetPivot()
		local target=basis*CFrame.new(22,1.775,-12)
		local delta=target*before:Inverse()
		station:PivotTo(target)
		for _,p in station:GetDescendants() do
			local rest=p:GetAttribute("RestCFrame")
			if typeof(rest)=="CFrame" then p:SetAttribute("RestCFrame",delta*rest) end
			if p:IsA("ProximityPrompt") and p.Name=="TrainStrength" then p:Destroy() end
		end
		station.TrainingSpot.Size=Vector3.new(5,0.12,4)
		station.TrainingSpot.Color=ochre
		station.TrainingSpot.Material=Enum.Material.SmoothPlastic
		-- Lower the existing base onto the room floor and use a single non-colliding marked surface.
		local floor=room.Floor.Position.Y+room.Floor.Size.Y/2
		local bottom=station.Base.Position.Y-station.Base.Size.Y/2
		local shift=CFrame.new(0,floor-bottom,0)
		station:PivotTo(shift*station:GetPivot())
		for _,p in station:GetDescendants() do local rest=p:GetAttribute("RestCFrame");if typeof(rest)=="CFrame" then p:SetAttribute("RestCFrame",shift*rest) end end
		local signCF=station.TrainingSpot.CFrame*CFrame.new(0,0.08,2.9)*CFrame.Angles(-math.pi/2,0,0)
		sign(decor,"TrainingInstructions",Vector3.new(7,1.2,0.08),signCF,"STEP ON TO TRAIN")
		-- Reserve a distinct, empty right-rear footprint; this is not an incubation implementation.
		part(decor,"FutureCareMat",Vector3.new(17,0.04,13),basis*CFrame.new(19,1.3025,13),Color3.fromRGB(127,145,132),false)
		for _,x in {12.5,25.5} do
			part(decor,"CareSignFoot",Vector3.new(0.35,2.0175,0.35),basis*CFrame.new(x,2.29125,19.6),teal,true)
		end
		sign(decor,"FutureCareSign",Vector3.new(15,1.5,0.12),basis*CFrame.new(19,3.3,19.6),"FUTURE CARE SPACE")
		local display=Cabinet.Build(room);Cabinet.Refresh(display,nil)
		task.wait()
	end
	-- Direct between-room paths remove the need to return to the center between neighbors.
	for i=1,12 do
		local a,b=entrances[i],entrances[i%12+1]
		local length=(b-a).Magnitude
		part(paths,"ConnectingPath"..i,Vector3.new(10,0.08,length-10),CFrame.lookAt((a+b)/2+Vector3.yAxis*0.04,b+Vector3.yAxis*0.04),Color3.fromRGB(153,153,134),false)
	end
	-- Retire disconnected monumental portals and their signs. Keep utility lighting and its supports.
	for _,p in lab.Presentation:GetChildren() do
		if ({PortalPier=true,PortalLintel=true,PierInset=true,PierFoot=true,PortalLight=true,RouteLight=true})[p.Name] then p:Destroy() end
	end
	for _,p in lab.WayfindingFixtures:GetChildren() do
		if ({RoomRouteSign=true,RouteSignFace=true,RouteAccent=true,SignMount=true})[p.Name] then p:Destroy() end
	end
	lab:SetAttribute("MapCleanupRevision",1)
	return "12 fixed room spawns retained; left-wall shelves, right-side training and direct connecting paths"
end
return M
