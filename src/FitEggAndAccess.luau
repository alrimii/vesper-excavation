assert(not game:GetService("RunService"):IsRunning(), "Edit only")
local lab=workspace.VesperLab
local shared=game.ReplicatedStorage.VesperShared
-- Transform the intact plates and their matching fracture assets together, once.
local function position(p) return Vector3.new(p.X,(p.Y-3.2)*.9-5,p.Z) end
local function transform(p)
 p.Size=Vector3.new(p.Size.X,p.Size.Y*.9,p.Size.Z)
 p.CFrame=CFrame.new(position(p.Position))*p.CFrame.Rotation
 local rel=p:GetAttribute("RelativeCFrame")
 if rel then p:SetAttribute("RelativeCFrame",CFrame.new(rel.X,rel.Y*.9,rel.Z)*rel.Rotation) end
 local n=p:GetAttribute("SurfaceNormal")
 if n then p:SetAttribute("SurfaceNormal",Vector3.new(n.X,n.Y/.9,n.Z).Unit) end
 local d=p:GetAttribute("FractureDirection")
 if d then p:SetAttribute("FractureDirection",Vector3.new(d.X,d.Y*.9,d.Z).Unit) end
end
if lab.Egg:GetAttribute("GeometryFit")~="RecessedV1" then
 for i,s in lab.Egg.Sections:GetChildren() do
  transform(s.Plate)
  local center=s:GetAttribute("Center") if center then s:SetAttribute("Center",position(center)) end
  if i%240==0 then task.wait() end
 end
 for _,folder in {game.ServerStorage.EggPlateLibrary,shared.EggAssetPreload,shared.FractureLibrary} do
  for _,p in folder:GetDescendants() do if p:IsA("BasePart") then transform(p) end end
 end
 lab.Egg:SetAttribute("GeometryFit","RecessedV1")
end
-- Retire the close-fitting spiral and its finish details.
lab.ExcavationAccess:ClearAllChildren()
local finish=lab:FindFirstChild("PlatformFinish")
if finish then
 for _,p in finish:GetChildren() do
  if string.find(p.Name,"Ramp") or string.find(p.Name,"RailFoot") or string.find(p.Name,"AccessSupport") or string.find(p.Name,"SupportShoe") or string.find(p.Name,"SupportKnee") then p:Destroy() end
 end
end
local legacy=lab.CentralPlatform:FindFirstChild("LowerShellAccessSteps") if legacy then legacy:Destroy() end
local access=lab.ExcavationAccess
local steel=Color3.fromRGB(43,54,63)
local gold=Color3.fromRGB(207,160,76)
local function part(name,size,cf,color,collide)
 local p=Instance.new("Part") p.Name=name p.Size=size p.CFrame=cf p.Color=color or steel
 p.Material=Enum.Material.Metal p.Anchored=true p.CanCollide=collide==true p.CanQuery=false p.CanTouch=false
 p.Parent=access return p
end
local function beam(name,a,b,w,color)
 return part(name,Vector3.new(w,w,(b-a).Magnitude),CFrame.lookAt((a+b)/2,b),color,false)
end
local function point(a,r,y) return Vector3.new(math.cos(a)*r,y,math.sin(a)*r) end
local function path(t) return point(t*math.pi*5,33,2.9+t*39.1) end
for i=0,239 do
 local a,b=path(i/240),path((i+1)/240)
 local cf=CFrame.lookAt((a+b)/2,b)
 local deck=part("OuterServiceRamp",Vector3.new(7,.3,(b-a).Magnitude+.12),cf,steel,true)
 deck.Material=Enum.Material.DiamondPlate
 local angle=(i+.5)/240*math.pi*5
 local outward=point(angle,1,0)
 local outer=(a+b)/2+outward*3.45
 beam("OuterHandrail",a+point(i/240*math.pi*5,3.45,2.7),b+point((i+1)/240*math.pi*5,3.45,2.7),.16,gold)
 if i%4==0 then
  part("OuterRailPost",Vector3.new(.16,2.7,.16),CFrame.new(outer+Vector3.yAxis*1.35),gold)
  part("TreadNosing",Vector3.new(6.7,.025,.1),cf*CFrame.new(0,.165,0),gold)
 end
 if i%80==0 then task.wait() end
end
-- Straight columns are entirely outside the shell's widest radius (24.4 studs).
for i=0,11 do
 local a=i/12*math.pi*2
 local base=point(a,37,2.7)
 part("ExternalTower",Vector3.new(.6,39.4,.6),CFrame.new(base+Vector3.yAxis*19.7),steel)
 part("TowerFoot",Vector3.new(1.6,.2,1.6),CFrame.new(base),steel)
 for _,y in {15.93,28.97,42} do
  beam("OutboardBracket",point(a,37,y-3),point(a,31,y-.2),.3,steel)
 end
end
local function ring(radius,y,width)
 for i=0,95 do
  local a,b=i/96*math.pi*2,(i+1)/96*math.pi*2
  local x,z=point(a,radius,y),point(b,radius,y)
  local p=part("WorkGallery",Vector3.new(width,.3,(z-x).Magnitude+.12),CFrame.lookAt((x+z)/2,z),steel,true)
  p.Material=Enum.Material.DiamondPlate
  beam("GalleryRail",point(a,radius+width/2,y+2.7),point(b,radius+width/2,y+2.7),.16,gold)
  if i%6==0 then part("GalleryPost",Vector3.new(.16,2.7,.16),CFrame.new(point(a,radius+width/2,y+1.35)),gold) end
 end
 task.wait()
end
ring(33,15.93,7) ring(33,28.97,7) ring(24,49,6)
-- Upper crown access stays above the shell; four broad ramps provide every approach.
ring(14,57,6)
for i=0,3 do
 local a=i*math.pi/2
 local x,z=point(a,33,42),point(a,14,57)
 local cf=CFrame.lookAt((x+z)/2,z)
 local p=part("CrownBridge",Vector3.new(6,.35,(z-x).Magnitude+.2),cf,steel,true)
 p.Material=Enum.Material.DiamondPlate
 for _,side in {-1,1} do
  local offset=cf.RightVector*side*2.9
  beam("BridgeHandrail",x+offset+Vector3.yAxis*2.7,z+offset+Vector3.yAxis*2.7,.16,gold)
  for j=0,4 do part("BridgePost",Vector3.new(.16,2.7,.16),CFrame.new(x:Lerp(z,j/4)+offset+Vector3.yAxis*1.35),gold) end
 end
end
return "Recessed egg and external access installed"
