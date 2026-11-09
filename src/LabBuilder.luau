-- VESPER laboratory / enlarged cooperative arena.
-- Edit-time builder. Reuses the Rooms folder and all twelve room Models.
local Builder={}
local C={
 Dark=Color3.fromRGB(27,32,38), Metal=Color3.fromRGB(49,57,65),
 Panel=Color3.fromRGB(67,75,81), Concrete=Color3.fromRGB(86,89,89),
 Trim=Color3.fromRGB(118,128,132), Amber=Color3.fromRGB(218,157,61),
 Warm=Color3.fromRGB(255,218,167), White=Color3.fromRGB(216,220,211),
 Black=Color3.fromRGB(15,21,27), Blue=Color3.fromRGB(96,153,163),
}
local function model(parent,name)
 local m=Instance.new("Model") m.Name=name m.Parent=parent return m
end
local function part(parent,name,size,cf,color,material,collide)
 local p=Instance.new("Part") p.Name=name p.Size=size p.CFrame=cf
 p.Color=color or C.Metal p.Material=material or Enum.Material.Metal p.Anchored=true
 p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth
 p.CanCollide=collide~=false p.CanTouch=false p.CastShadow=collide~=false
 p.Parent=parent return p
end
local function bar(parent,name,a,b,width,color,mat)
 return part(parent,name,Vector3.new(width,width,(b-a).Magnitude),CFrame.lookAt((a+b)/2,b),color,mat,false)
end
local function cylinder(parent,name,r,h,y,color,mat)
 local p=part(parent,name,Vector3.new(h,r*2,r*2),CFrame.new(0,y,0)*CFrame.Angles(0,0,math.pi/2),color,mat)
 p.Shape=Enum.PartType.Cylinder return p
end
local function ring(parent,name,r,y,width,height,color,segments,mat)
 for i=0,segments-1 do
  local a,b=i*math.pi*2/segments,(i+1)*math.pi*2/segments
  local p0,p1=Vector3.new(math.sin(a)*r,y,math.cos(a)*r),Vector3.new(math.sin(b)*r,y,math.cos(b)*r)
  part(parent,name,Vector3.new(width,height,(p1-p0).Magnitude+.08),CFrame.lookAt((p0+p1)/2,p1),color,mat,false)
 end
end
local function sign(parent,name,size,cf,text,color,face)
 local p=part(parent,name,size,cf,C.Black,Enum.Material.SmoothPlastic,false)
 local gui=Instance.new("SurfaceGui") gui.Name="Display" gui.Face=face or Enum.NormalId.Front
 gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud gui.PixelsPerStud=24
 gui.LightInfluence=.3 gui.Brightness=1.1 gui.MaxDistance=500 gui.Parent=p
 local textLabel=Instance.new("TextLabel") textLabel.Name="Text" textLabel.Size=UDim2.fromScale(.92,.88)
 textLabel.Position=UDim2.fromScale(.04,.06) textLabel.BackgroundTransparency=1
 textLabel.Text=text textLabel.TextColor3=color or C.White textLabel.TextScaled=true textLabel.TextWrapped=true
 textLabel.Font=Enum.Font.GothamMedium textLabel.Parent=gui
 return p,textLabel
end
local function point(parent,brightness,range,color)
 local light=Instance.new("PointLight") light.Brightness=brightness light.Range=range
 light.Color=color or C.Warm light.Shadows=false light.Parent=parent return light
end
local function ceilingLight(parent,size,cf)
 local p=part(parent,"CeilingFixture",size,cf,C.Warm,Enum.Material.Neon,false)
 local light=Instance.new("SurfaceLight") light.Face=Enum.NormalId.Bottom light.Range=42 light.Angle=135
 light.Brightness=.85 light.Color=Color3.fromRGB(255,231,198) light.Shadows=false light.Parent=p
end
local function buildRoom(room)
 local number=room:GetAttribute("RoomNumber") or 1
 room:ClearAllChildren()
 room.WorldPivot=CFrame.identity
 local function p(name,size,position,color,mat,collide)
  return part(room,name,size,CFrame.new(position),color,mat,collide)
 end
 p("Floor",Vector3.new(64,.6,52),Vector3.new(0,.65,0),C.Concrete,Enum.Material.Concrete)
 p("LeftWall",Vector3.new(1.4,32,52),Vector3.new(-32,16.5,0),C.Metal)
 p("RightWall",Vector3.new(1.4,32,52),Vector3.new(32,16.5,0),C.Metal)
 p("BackWall",Vector3.new(64,32,1.4),Vector3.new(0,16.5,26),C.Metal)
 p("Ceiling",Vector3.new(65,1.2,53),Vector3.new(0,33,0),C.Dark)
 for _,x in {-23,23} do
  p("FrontPanel",Vector3.new(16.5,32,2),Vector3.new(x<0 and -23.75 or 23.75,16.5,-26),C.Panel)
  p("PortalJamb",Vector3.new(1.5,22,3.2),Vector3.new(x<0 and -14.75 or 14.75,11.5,-26.4),C.Trim)
  p("DoorwayRecess",Vector3.new(.35,18,.3),Vector3.new(x<0 and -14 or 14,10.8,-28.1),C.Black)
  p("JambStripe",Vector3.new(.23,13,.15),Vector3.new(x<0 and -14 or 14,9,-28.35),C.Amber,Enum.Material.SmoothPlastic,false)
 end
 p("PortalHeader",Vector3.new(31,10,3.2),Vector3.new(0,27.5,-26.4),C.Dark)
 p("HeaderLight",Vector3.new(22,.28,.5),Vector3.new(0,22.3,-28.2),C.Warm,Enum.Material.Neon,false)
 p("Threshold",Vector3.new(28,.08,4),Vector3.new(0,1,-26.5),C.Amber,Enum.Material.DiamondPlate,false)
 sign(room,"NumberSign",Vector3.new(11,8,.16),CFrame.new(-23,14,-27.1),string.format("%02d",number),C.Amber)
 sign(room,"OwnerSign",Vector3.new(26,4,.18),CFrame.new(0,27,-28.1),"AVAILABLE",C.White)
 sign(room,"RoomType",Vector3.new(11,3,.16),CFrame.new(23,14,-27.1),"CREW\nQUARTERS",C.White)
 sign(room,"InnerSign",Vector3.new(19,3,.18),CFrame.new(0,25,25.1)*CFrame.Angles(0,math.pi,0),"VESPER / CREW "..string.format("%02d",number),C.White)
 for _,x in {-31.1,31.1} do
  p("Skirting",Vector3.new(.3,1.1,50),Vector3.new(x,1.5,0),C.Dark)
  p("ServiceConduit",Vector3.new(.45,.45,49),Vector3.new(x,11,0),C.Amber)
  for z=-20,20,10 do
   p("WallPanel",Vector3.new(.16,18,9.2),Vector3.new(x,14,z),C.Panel,Enum.Material.Metal,false)
   p("PanelFrame",Vector3.new(.5,27,.35),Vector3.new(x,15,z+4.8),C.Dark,Enum.Material.Metal,false)
  end
 end
 for x=-24,24,12 do
  p("RearPanel",Vector3.new(11.4,17,.2),Vector3.new(x,15,25.15),C.Panel,Enum.Material.Metal,false)
  p("RearSeam",Vector3.new(.12,26,.2),Vector3.new(x+5.8,14,24.98),C.Dark,Enum.Material.Metal,false)
 end
 for _,x in {-21,21} do
  p("BenchCabinet",Vector3.new(12,3.4,4),Vector3.new(x,2.7,20),C.Dark)
  p("Workbench",Vector3.new(12.6,.3,4.7),Vector3.new(x,4.55,20),C.Trim)
  for dx=-4,4,4 do
   p("Drawer",Vector3.new(3.6,1.1,.15),Vector3.new(x+dx,3.4,17.9),C.Panel,Enum.Material.Metal,false)
   p("DrawerPull",Vector3.new(1,.12,.15),Vector3.new(x+dx,3.4,17.75),C.Amber,Enum.Material.Metal,false)
  end
  sign(room,"Terminal",Vector3.new(4,2.5,.3),CFrame.new(x,6.1,20),"VESPER\nCREW TERMINAL",C.Blue)
  p("MonitorStem",Vector3.new(.4,1,.4),Vector3.new(x,5,20),C.Dark)
  p("BenchStool",Vector3.new(2.2,.5,2.2),Vector3.new(x,2.5,15),C.Panel)
  p("StoolLeg",Vector3.new(.5,2,.5),Vector3.new(x,1.4,15),C.Metal)
 end
 for x=-7.5,7.5,5 do
  p("Locker",Vector3.new(4.6,8,4),Vector3.new(x,5,22.8),C.Dark)
  p("LockerDoor",Vector3.new(4.2,7.5,.18),Vector3.new(x,5,20.65),C.Panel,Enum.Material.Metal,false)
  p("LockerPull",Vector3.new(.15,1.1,.2),Vector3.new(x+1,4.8,20.45),C.Amber,Enum.Material.Metal,false)
  for y=7,8,.5 do p("LockerVent",Vector3.new(2.4,.1,.12),Vector3.new(x,y,20.5),C.Black,Enum.Material.SmoothPlastic,false) end
 end
 for _,x in {-18,18} do ceilingLight(room,Vector3.new(14,.25,2.2),CFrame.new(x,32.2,0)) end
 for _,x in {-6,6} do p("SpawnLane",Vector3.new(.12,.04,21),Vector3.new(x,.98,-3),C.Trim,Enum.Material.SmoothPlastic,false) end
 for _,z in {-13,0,13} do p("FloorSeam",Vector3.new(61,.025,.1),Vector3.new(0,.97,z),C.Dark,Enum.Material.SmoothPlastic,false) end
 local spawn=Instance.new("SpawnLocation") spawn.Name="RoomSpawn" spawn.Size=Vector3.new(6,.2,6)
 spawn.CFrame=CFrame.new(0,1.08,0) spawn.Anchored=true spawn.Transparency=1 spawn.CanCollide=false
 spawn.CanTouch=false spawn.CastShadow=false spawn.Neutral=true spawn.Duration=0 spawn.AllowTeamChangeOnTouch=false spawn.Parent=room
end
local function buildEgg(root)
 require(game.ServerStorage.VesperTools.ExcavationBuilder).Build()
 return root.Egg
end
function Builder.Build()
 assert(game:GetService("RunService"):IsStudio() and not game:GetService("RunService"):IsRunning(),"Edit mode only")
 local root=workspace:FindFirstChild("VesperLab") assert(root,"Existing lab missing")
 for _,name in {"Architecture","FloorMarkings","Dome","Infrastructure","CentralPlatform","OverheadRig","ObservationConsole1","ObservationConsole2","ObservationConsole3","ObservationConsole4","RouteDetails"} do
  local old=root:FindFirstChild(name) if old then old:Destroy() end
 end
 root:SetAttribute("Milestone",2) root:SetAttribute("ArenaDiameter",400) root:SetAttribute("Capacity",12)
 local architecture=model(root,"Architecture")
 cylinder(architecture,"Foundation",264,4,-2,C.Dark,Enum.Material.Concrete)
 cylinder(architecture,"ArenaFloor",260,1,0,C.Concrete,Enum.Material.Concrete)
 local markings=model(root,"FloorMarkings")
 for _,r in {90,150,193} do ring(markings,"FloorExpansionJoint",r,.525,.14,.03,C.Dark,72,Enum.Material.SmoothPlastic) end
 ring(markings,"ContainmentBoundary",62,.54,.35,.04,C.Amber,72,Enum.Material.SmoothPlastic)
 ring(markings,"PerimeterGuide",196,.54,.25,.04,C.Amber,72,Enum.Material.SmoothPlastic)
 local routes=model(root,"RouteDetails")
 for i=0,11 do
  local cf=CFrame.Angles(0,i*math.pi/6,0)
  local bay=model(routes,string.format("Route%02d",i+1))
  for _,x in {-8,8} do
   part(bay,"RouteEdge",Vector3.new(.15,.035,138),cf*CFrame.new(x,.54,130),C.Trim,Enum.Material.SmoothPlastic,false)
  end
  for z=76,193,22 do
   part(bay,"LaneMarker",Vector3.new(1.5,.04,3),cf*CFrame.new(0,.55,z),C.Amber,Enum.Material.SmoothPlastic,false)
  end
  for _,z in {108,174} do
   sign(bay,"FloorNavigation",Vector3.new(9,.04,6),cf*CFrame.new(0,.56,z),string.format("%02d",i+1),C.White,Enum.NormalId.Top)
  end
  for _,r in {92,157} do
   local x=i%2==0 and 12 or -12
   part(bay,"GuideBollard",Vector3.new(1.1,3.5,1.1),cf*CFrame.new(x,2.25,r),C.Dark)
   part(bay,"BollardReflector",Vector3.new(1.2,.28,1.2),cf*CFrame.new(x,3.9,r),C.Amber,Enum.Material.Neon,false)
  end
  task.wait()
 end
 local shell=model(root,"Dome")
 for i=0,47 do
  local a=i*math.pi/24 local cf=CFrame.Angles(0,a,0)
  part(architecture,"OuterWallPanel",Vector3.new(34.3,60,2),cf*CFrame.new(0,30.5,258),i%4==0 and C.Dark or C.Metal)
  part(architecture,"WallPanelSeam",Vector3.new(.5,57,.3),cf*CFrame.new(16.9,30,256.8),C.Dark,Enum.Material.Metal,false)
 end
 local profiles={{260,60},{240,104},{194,150},{128,186},{60,208},{0,214}}
 for band=1,5 do
  local batch=model(shell,"RoofBand"..band)
  local r0,y0=profiles[band][1],profiles[band][2] local r1,y1=profiles[band+1][1],profiles[band+1][2]
  for i=0,47 do
   local a=i*math.pi/24
   local p0,p1=Vector3.new(math.sin(a)*r0,y0,math.cos(a)*r0),Vector3.new(math.sin(a)*r1,y1,math.cos(a)*r1)
   local tangent=Vector3.new(math.cos(a),0,-math.sin(a)) local along=(p1-p0).Unit
   part(batch,"MetalRoofPanel",Vector3.new(r0*2*math.tan(math.pi/48)+.5,.9,(p1-p0).Magnitude+1),CFrame.fromMatrix((p0+p1)/2,tangent,along:Cross(tangent).Unit,-along),band%2==0 and C.Dark or C.Metal,Enum.Material.Metal,false)
  end
  if band<5 then ring(batch,"LatitudeFrame",r1,y1-1.5,1.8,1.5,C.Panel,48) end
  task.wait()
 end
 for i=0,11 do
  local a=i*math.pi/6 local batch=model(shell,"RadialFrame"..i+1)
  for k=1,5 do
   local p,q=profiles[k],profiles[k+1]
   bar(batch,"StructuralSpine",Vector3.new(math.sin(a)*p[1],p[2]-2,math.cos(a)*p[1]),Vector3.new(math.sin(a)*q[1],q[2]-2,math.cos(a)*q[1]),2.4,C.Trim)
  end
 end
 local rooms=root:FindFirstChild("Rooms")
 for i=1,12 do
  local name=string.format("Room%02d",i) local room=rooms:FindFirstChild(name) or model(rooms,name)
  room:SetAttribute("RoomNumber",i) room:SetAttribute("Occupied",false)
  room:SetAttribute("OwnerUserId",nil) room:SetAttribute("OwnerDisplayName",nil)
  buildRoom(room)
  local a=(i-1)*math.pi/6 room:PivotTo(CFrame.new(math.sin(a)*226,0,math.cos(a)*226)*CFrame.Angles(0,a,0))
  task.wait()
 end
 local kit=game.ServerStorage.VesperKit
 local oldTemplate=kit:FindFirstChild("RoomTemplate") if oldTemplate then oldTemplate:Destroy() end
 local template=rooms.Room01:Clone() template.Name="RoomTemplate" template:PivotTo(CFrame.identity) template.Parent=kit
 local infrastructure=model(root,"Infrastructure")
 ring(infrastructure,"CoolingMain",255,44,1.5,1.5,C.Amber,48)
 ring(infrastructure,"CableTray",254,48,2.2,1.2,C.Black,48)
 for i=0,11 do
  local a=(i+.5)*math.pi/6 local cf=CFrame.Angles(0,a,0)
  local bay=model(infrastructure,"UtilityBay"..i+1)
  local function p(name,size,pos,color,mat,collide) return part(bay,name,size,cf*CFrame.new(pos),color,mat,collide) end
  p("Buttress",Vector3.new(5,59,6),Vector3.new(0,30,250),C.Dark)
  p("VerticalCoolant",Vector3.new(1.4,40,1.4),Vector3.new(-5,24,246),C.Amber)
  for y=8,40,16 do p("PipeBand",Vector3.new(2,.6,2),Vector3.new(-5,y,246),C.Trim) end
  p("VentHousing",Vector3.new(15,13,8),Vector3.new(0,7,213),C.Dark)
  for y=3,11,1 do p("VentSlat",Vector3.new(12,.25,.2),Vector3.new(0,y,208.8),C.Panel,Enum.Material.Metal,false) end
  p("EquipmentAccent",Vector3.new(6,.25,.15),Vector3.new(0,12.5,208.7),C.Amber,Enum.Material.SmoothPlastic,false)
  local islandCF=CFrame.Angles(0,a,0)
  p("ServiceSkid",Vector3.new(15,.7,12),Vector3.new(0,.85,132),C.Dark,Enum.Material.DiamondPlate)
  p("PumpHousing",Vector3.new(8,8,6),Vector3.new(0,5.2,132),C.Panel)
  p("PumpInlet",Vector3.new(2.2,12,2.2),Vector3.new(-5,7,133),C.Metal)
  p("PumpReturn",Vector3.new(2.2,4,2.2),Vector3.new(5,3,133),C.Amber)
  p("UpperDuct",Vector3.new(11,2,2),Vector3.new(0,12.5,133),C.Metal)
  for y=3,7,1 do p("PumpVent",Vector3.new(5,.15,.12),Vector3.new(0,y,128.85),C.Black,Enum.Material.SmoothPlastic,false) end
  sign(bay,"EquipmentLabel",Vector3.new(5,1.3,.15),cf*CFrame.new(0,8.5,128.8),"COOLANT / "..string.format("%02d",i+1),C.Blue)
  for _,x in {-8,8} do p("IslandGuard",Vector3.new(.3,3,10),Vector3.new(x,2.5,132),C.Metal) end
  local lamp=p("RouteLamp",Vector3.new(3,.35,3),Vector3.new(0,25,155),C.Warm,Enum.Material.Neon,false)
  point(lamp,.9,56,Color3.fromRGB(255,228,192))
  p("LampPole",Vector3.new(.45,24,.45),Vector3.new(0,12.5,155),C.Dark)
  if i%3==0 then
   sign(bay,"SectorSign",Vector3.new(25,7,.3),cf*CFrame.new(0,43,239),"SECTOR "..string.char(65+i/3).."\nCREW "..string.format("%02d",i+1).." - "..string.format("%02d",i+3),C.Amber)
  end
  task.wait()
 end
 local center=model(root,"CentralPlatform")
 cylinder(center,"SupportDrum",55,.8,.9,C.Dark,Enum.Material.Concrete)
 cylinder(center,"Step01",54,.5,1.4,C.Metal,Enum.Material.DiamondPlate)
 cylinder(center,"Step02",53,.5,1.9,C.Trim,Enum.Material.Metal)
 cylinder(center,"Deck",52,.8,2.3,C.Metal,Enum.Material.DiamondPlate)
 ring(center,"DeckLip",51.5,2.74,.32,.08,C.Amber,96,Enum.Material.SmoothPlastic)
 cylinder(center,"RecessedCradle",13,1.4,3.4,C.Dark,Enum.Material.Metal)
 ring(center,"CradleAccent",13,4.15,.24,.14,C.Warm,64,Enum.Material.Neon)
 ring(center,"SubDeckServiceRing",50,1.2,1.5,.8,C.Dark,64)
 for i=0,71 do
  local a=i*math.pi*2/72 local cf=CFrame.Angles(0,a,0)
  if i%6~=0 and i%6~=5 then
   local p0=Vector3.new(math.sin(a)*55,4.6,math.cos(a)*55)
   local b=(i+.95)*math.pi*2/72 local p1=Vector3.new(math.sin(b)*55,4.6,math.cos(b)*55)
   bar(center,"SafetyHandrail",p0,p1,.22,C.Trim)
   if i%2==0 then part(center,"RailStanchion",Vector3.new(.3,3.5,.3),CFrame.new(p0.X,2.9,p0.Z),C.Metal) end
  end
  if i%3==0 then
   part(center,"SupportRib",Vector3.new(.8,1.3,3),cf*CFrame.new(0,1.25,52.7),C.Dark)
   part(center,"DeckHazard",Vector3.new(.5,.045,2.1),cf*CFrame.new(0,2.75,50.5),C.Amber,Enum.Material.SmoothPlastic,false)
  end
 end
 for i=0,5 do
  local cf=CFrame.Angles(0,i*math.pi/3,0)
  part(center,"CradleClamp",Vector3.new(3,4,4),cf*CFrame.new(0,5.2,12.5),C.Panel)
  part(center,"ClampCap",Vector3.new(2.4,.35,3.2),cf*CFrame.new(0,7.4,12.5),C.Amber,Enum.Material.Metal,false)
  local lamp=part(center,"DeckLamp",Vector3.new(2,.3,2),cf*CFrame.new(0,13,40),C.Warm,Enum.Material.Neon,false)
  point(lamp,.85,48,Color3.fromRGB(255,231,203))
  part(center,"DeckLightStem",Vector3.new(.35,10,.35),cf*CFrame.new(0,7.7,40),C.Dark)
 end
 local overhead=model(root,"OverheadRig")
 ring(overhead,"SuspendedStructure",65,106,2,2,C.Dark,64)
 ring(overhead,"IndustrialLightBand",64,104.8,.6,.6,C.Warm,64,Enum.Material.Neon)
 for i=0,5 do
  local a=i*math.pi/3 local x,z=math.sin(a)*65,math.cos(a)*65
  bar(overhead,"SuspensionCable",Vector3.new(x,107,z),Vector3.new(x,201,z),.35,C.Trim)
  local lamp=part(overhead,"UpperShellLight",Vector3.new(7,.5,4),CFrame.new(x,78,z),C.Warm,Enum.Material.Neon,false)
  point(lamp,.7,60,Color3.fromRGB(255,231,203))
  bar(overhead,"FixtureDrop",Vector3.new(x,104,z),Vector3.new(x,79,z),.2,C.Dark)
 end
 for i=0,3 do
  local cf=CFrame.Angles(0,i*math.pi/2+math.pi/12,0)
  local console=model(root,"ObservationConsole"..i+1)
  part(console,"Cabinet",Vector3.new(10,3.5,4),cf*CFrame.new(0,2.25,72),C.Dark)
  sign(console,"Readout",Vector3.new(9,3,.2),cf*CFrame.new(0,5,72)*CFrame.Angles(0,math.pi,0),"VESPER\nCONTAINMENT 01",C.Warm)
 end
 buildEgg(root)
 local light=game.Lighting
 light.ClockTime=0 light.Brightness=1.3 light.Ambient=Color3.fromRGB(118,126,139)
 light.OutdoorAmbient=Color3.fromRGB(90,101,119) light.ExposureCompensation=0
 light.EnvironmentDiffuseScale=.4 light.EnvironmentSpecularScale=.18
 light.LightingStyle=Enum.LightingStyle.Soft light.PrioritizeLightingQuality=false
 local atmosphere=light:FindFirstChildOfClass("Atmosphere") if atmosphere then atmosphere.Density=.1 atmosphere.Haze=.4 end
 local grade=light:FindFirstChild("VesperGrade") if grade then grade.Contrast=.03 grade.Saturation=-.08 grade.TintColor=Color3.fromRGB(255,251,244) end
 local bloom=light:FindFirstChildOfClass("BloomEffect") if bloom then bloom.Intensity=.1 bloom.Threshold=2 end
 game.StarterPlayer.CameraMaxZoomDistance=40
 workspace.StreamingEnabled=false
 workspace.CurrentCamera.CFrame=CFrame.lookAt(Vector3.new(118,45,137),Vector3.new(0,32,0))
 return root
end
return Builder




