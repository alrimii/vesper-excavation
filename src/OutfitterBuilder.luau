-- Editable, canonical shop recipe. Run only in the original Edit-mode place.
local M={}
function M.Build()
	assert(game.PlaceId==94763223427049 and not game:GetService("RunService"):IsRunning(),"Original Edit-mode place only")
	local lab=workspace.VesperLab
	local old=lab.SharedWorkshop
	local prompts={}
	for _,n in {"Console","UpgradeConsole"} do prompts[n]=old[n]:FindFirstChildOfClass("ProximityPrompt"):Clone() end
	local m=Instance.new("Model");m.Name="SharedWorkshop"
	local basis=CFrame.new(135,.675,0)*CFrame.Angles(0,-math.pi/2,0);m.WorldPivot=basis
	local wood=Color3.fromRGB(133,83,46);local dark=Color3.fromRGB(77,48,32)
	local cut=Color3.fromRGB(184,129,69);local stone=Color3.fromRGB(171,156,126)
	local metal=Color3.fromRGB(70,77,73);local cream=Color3.fromRGB(255,229,171)
	local function p(n,size,pos,color,material,solid,rotation)
		local a=Instance.new("Part");a.Name=n;a.Size=size;a.CFrame=basis*CFrame.new(pos)*(rotation or CFrame.new())
		a.Color=color;a.Material=material or Enum.Material.SmoothPlastic;a.Anchored=true
		a.CanCollide=solid==true;a.CanTouch=false;a.CanQuery=solid==true;a.TopSurface=Enum.SurfaceType.Smooth;a.BottomSurface=Enum.SurfaceType.Smooth;a.Parent=m;return a
	end
	local function box(n,x,y,z,sx,sy,sz,c,mat,solid,rot) return p(n,Vector3.new(sx,sy,sz),Vector3.new(x,y,z),c,mat,solid,rot) end
	local function label(n,x,y,z,w,h,text)
		local a=box(n,x,y,z,w,h,.28,dark,Enum.Material.Wood,false)
		local g=Instance.new("SurfaceGui");g.Face=Enum.NormalId.Back;g.CanvasSize=Vector2.new(w*60,h*60);g.LightInfluence=0;g.MaxDistance=150;g.Parent=a
		local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Size=UDim2.fromScale(.94,.84);t.Position=UDim2.fromScale(.03,.08);t.Text=text;t.TextColor3=cream;t.Font=Enum.Font.FredokaOne;t.TextScaled=true;t.Parent=g
		return a
	end
	-- Small footprint, open front, broad shallow access steps: no doorway choke point.
	box("CarvedStoneFoundation",0,.35,0,46,.7,29,stone,Enum.Material.Sandstone,true)
	box("FrontStep",0,.13,16,42,.26,3.5,stone,Enum.Material.Sandstone,true)
	box("ApproachPaving",0,.025,20.5,38,.05,5.5,Color3.fromRGB(141,128,103),Enum.Material.Slate,false)
	for i=-10,10 do box("FloorBoard",i*2.1,.76,0,2.04,.12,27, i%2==0 and wood or cut,Enum.Material.WoodPlanks,true) end
	for _,x in {-22,22} do
		box("StoneCorner",x,1.8,12,2.6,2.2,2.6,stone,Enum.Material.Sandstone,true)
		box("EntryTimber",x,7.4,12,1.65,10,1.65,dark,Enum.Material.Wood,true)
		box("BackTimber",x,7.4,-12,1.65,13.2,1.65,dark,Enum.Material.Wood,true)
		for _,y in {3.2,10.5} do box("PostBinding",x,y,12,1.78,.35,1.78,metal,Enum.Material.Metal,false) end
		box("LowSideWall",x,2.5,0,.7,3.4,23,stone,Enum.Material.Sandstone,true)
		box("SideCap",x,4.35,0,1.1,.3,23.5,cut,Enum.Material.Wood,false)
	end
	box("BackStoneWall",0,3,-13,44,4.5,.8,stone,Enum.Material.Sandstone,true)
	for i=-10,10 do box("BackBoard",i*2.1,8.4,-13,2.02,6.3,.5,wood,Enum.Material.Wood,true) end
	box("Lintel",0,12.6,12,46,1.2,2.1,dark,Enum.Material.Wood,true)
	box("RearLintel",0,12.6,-12,46,1.2,2.1,dark,Enum.Material.Wood,true)
	-- Short slatted canopy keeps the interior and tool silhouettes visible.
	for i=-11,11 do box("CanopyPlank",i*2,13.4,8.5,1.92,.32,10,cut,Enum.Material.Wood,false,CFrame.Angles(math.rad(-5),0,0)) end
	label("OutfitterSign",0,12.2,13.2,23,2.5,"THE OUTFITTER")
	-- Large physical pickaxe emblem, not a light or an ornamental UI ring.
	box("EmblemHandle",0,16.1,12.2,.8,5.6,.75,cut,Enum.Material.Wood,false,CFrame.Angles(0,0,math.rad(-22)))
	box("EmblemHead",-.6,18.0,12.2,5.8,1,.9,metal,Enum.Material.Metal,false,CFrame.Angles(0,0,math.rad(-12)))
	box("EmblemGrip",.7,14.2,12.2,.94,1.7,.88,dark,Enum.Material.Wood,false,CFrame.Angles(0,0,math.rad(-22)))
	-- One workbench anchors the shop. Open side routes lead to the two wall displays.
	for _,x in {-7.3,7.3} do for _,z in {-1,3} do box("BenchLeg",x,2.4,z,1.1,3.2,1.1,dark,Enum.Material.Wood,true) end end
	box("BenchApron",0,3.0,3.1,16,1.4,.5,wood,Enum.Material.Wood,true)
	box("BenchTop",0,4.15,1,17,.55,6.4,cut,Enum.Material.Wood,true)
	box("BenchShelf",0,1.5,1,15,.3,4.3,wood,Enum.Material.Wood,true)
	box("ChargeTray",3,4.53,1,5.8,.2,4,metal,Enum.Material.Metal,false)
	label("ChargeLabel",3,3.1,3.43,7,1.2,"CHARGE")
	-- Pickaxe rack and drill cradle have deliberately different construction.
	box("PickaxeRack",-14,7,-11.95,10,8,.6,dark,Enum.Material.Wood,false)
	for _,x in {-17,-11} do box("RackPeg",x,8,-11.3,.3,.35,1.2,metal,Enum.Material.Metal,false) end
	label("PickaxeLabel",-14,11.6,-11.45,10,1.4,"PICKAXE")
	box("DrillPlinth",14,2.5,-8.5,9,3.4,6,stone,Enum.Material.Sandstone,true)
	box("DrillCradle",14,4.4,-8.5,9.5,.4,6.5,wood,Enum.Material.Wood,true)
	for _,x in {11.7,16.3} do box("CradleStop",x,4.95,-8.5,.55,.7,3.2,metal,Enum.Material.Metal,false) end
	label("DrillLabel",14,8.8,-11.45,10,1.4,"DRILL")
	local assets=game.ReplicatedStorage.VesperShared.EquipmentAssets
	local function display(id,where,span,rotation)
		local d=Instance.new("Model");d.Name=id.."Display"
		for _,node in assets[id]:GetDescendants() do if node:IsA("BasePart") and node.Transparency<1 then
			local c=node:Clone();for _,v in c:GetDescendants() do if v:IsA("LuaSourceContainer") or v:IsA("Constraint") or v:IsA("JointInstance") or v:IsA("ParticleEmitter") or v:IsA("Light") then v:Destroy() end end
			c.Anchored,c.CanCollide,c.CanTouch,c.CanQuery=true,false,false,false;c.Parent=d
		end end
		local _,size=d:GetBoundingBox();d:ScaleTo(span/math.max(size.X,size.Y,size.Z))
		local cf=d:GetBoundingBox();d:PivotTo(basis*CFrame.new(where)*rotation*cf:ToObjectSpace(d:GetPivot()));d.Parent=m
	end
	display("Pickaxe",Vector3.new(-14,7.1,-10.6),6.6,CFrame.Angles(0,math.pi,math.rad(-18)))
	display("Drill",Vector3.new(14,6.5,-8.5),3.8,CFrame.Angles(0,math.rad(40),0))
	display("Explosive",Vector3.new(3,5.88,1),2.5,CFrame.Angles(0,math.rad(15),0))
	-- Useful workbench dressing: vise, folded canvas, one mineral sample. No fake products.
	box("ViseBase",-5,4.6,1,2,.35,1.8,metal,Enum.Material.Metal,false)
	for _,x in {-5.6,-4.4} do box("ViseJaw",x,5.1,1,.45,.65,1.4,metal,Enum.Material.Metal,false) end
	box("FoldedCanvas",-1,4.6,0,2.5,.3,2,Color3.fromRGB(76,103,82),Enum.Material.Fabric,false)
	box("MineralSample",-1,5.15,0,1,.8,.9,Color3.fromRGB(117,153,133),Enum.Material.Slate,false,CFrame.Angles(.1,.3,.2))
	for _,x in {-17,17} do
		box("LampArm",x,11.1,-10.9,.3,.3,3,metal,Enum.Material.Metal,false)
		local hood=box("MountedDisplayLamp",x,10.8,-9.6,2,.5,1.8,metal,Enum.Material.Metal,false)
		local light=Instance.new("SurfaceLight");light.Face=Enum.NormalId.Bottom;light.Range=18;light.Brightness=1.2;light.Angle=110;light.Color=cream;light.Parent=hood
	end
	-- Preserve the exact prompt paths used by the existing server; approach remains primary.
	for i,n in {"Console","UpgradeConsole"} do
		local a=label(n,i==1 and -8 or 8,1.35,12.8,8,.95,i==1 and "EQUIPMENT" or "UPGRADES")
		prompts[n].Parent=a
	end
	box("WelcomeMat",0,.84,10,17,.025,5,Color3.fromRGB(72,100,79),Enum.Material.Fabric,false)
	label("Welcome",0,1.1,12.85,7,.65,"STEP INSIDE")
	local zone=box("ApproachZone",0,4.8,12.5,24,8,10,cream,nil,false);zone.Transparency=1
	m:SetAttribute("OutfitterRevision",1)
	old:Destroy();m.Parent=lab
	lab:SetAttribute("OutfitterRevision",1)
	return m:GetFullName().." / "..#m:GetDescendants().." descendants"
end
return M
