-- Edit-time construction only. Fitted triangular wedge plates; no runtime CSG.
local B={}
local C=require(game.ReplicatedStorage.VesperShared.ExcavationConfig)
local function part(parent,name,size,cf,color,material)
 local p=Instance.new("Part") p.Name=name p.Size=size p.CFrame=cf p.Color=color p.Material=material or Enum.Material.Metal p.Anchored=true p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth p.Parent=parent return p
end
local function model(parent,name) local m=Instance.new("Model") m.Name=name m.Parent=parent return m end
local function triangle(parent,a,b,c,thickness,color,material)
 local ab,ac,bc=b-a,c-a,c-b
 if ab:Dot(ab)>ac:Dot(ac) and ab:Dot(ab)>bc:Dot(bc) then c,a=a,c elseif ac:Dot(ac)>bc:Dot(bc) then a,b=b,a end
 ab,ac,bc=b-a,c-a,c-b
 local cross=ac:Cross(ab) if cross.Magnitude<.001 then return end
 local right=cross.Unit local back=bc.Unit local up=bc:Cross(right).Unit
 local height=math.abs(ab:Dot(up))
 for _,v in {{(a+b)/2,right,up,back,math.abs(ab:Dot(back))},{(a+c)/2,-right,up,-back,math.abs(ac:Dot(back))}} do
  if v[5]>.005 then local p=Instance.new("WedgePart") p.Name="Plate" p.Size=Vector3.new(thickness,height,v[5]) p.CFrame=CFrame.fromMatrix(v[1],v[2],v[3],v[4]) p.Anchored=true p.Color=color p.Material=material p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth p.Parent=parent end
 end
end
local function sign(parent,name,pos,text,width)
 local p=part(parent,name,Vector3.new(width or 18,4,.4),CFrame.new(pos)*CFrame.Angles(0,math.pi,0),Color3.fromRGB(26,35,43))
 local gui=Instance.new("SurfaceGui") gui.Face=Enum.NormalId.Front gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud gui.PixelsPerStud=35 gui.Parent=p
 local label=Instance.new("TextLabel") label.Size=UDim2.fromScale(1,1) label.BackgroundTransparency=1 label.Text=text label.TextColor3=Color3.fromRGB(255,211,126) label.Font=Enum.Font.GothamBold label.TextScaled=true label.Parent=gui return p
end
local function prompt(p,name,text,key)
 local q=Instance.new("ProximityPrompt") q.Name=name q.ActionText=text q.ObjectText="VESPER SERVICES" q.KeyboardKeyCode=key or Enum.KeyCode.F q.HoldDuration=.35 q.MaxActivationDistance=C.StationRange q.RequiresLineOfSight=false q.Parent=p
end
function B.FinishStations()
 local depot=workspace.VesperLab.ResourceDepot
 local old=depot:FindFirstChild("FixtureDetails") if old then old:Destroy() end
 local detail=model(depot,"FixtureDetails")
 for _,x in {-15,23} do part(detail,"BannerSupport",Vector3.new(.5,12,.5),CFrame.new(x,6.5,-85),Color3.fromRGB(93,105,109)) end
 for _,name in {"SellTerminal","PowerTerminal","SpeedTerminal","CapacityTerminal","NextTerminal"} do
  local terminal=depot[name] local p=terminal.Position local width=terminal.Size.X
  part(detail,"ControlBezel",Vector3.new(width-.6,.65,2.2),CFrame.new(p+Vector3.new(0,terminal.Size.Y/2+.15,.4))*CFrame.Angles(math.rad(16),0,0),Color3.fromRGB(31,43,47))
  local indicator=part(detail,"StatusStrip",Vector3.new(width-.9,.12,.12),CFrame.new(p+Vector3.new(0,terminal.Size.Y/2+.48,1.4)),Color3.fromRGB(157,218,185),Enum.Material.Neon) indicator.CanCollide=false indicator.CanQuery=false
  for _,x in {-1,1} do part(detail,"CornerFrame",Vector3.new(.16,terminal.Size.Y,.2),CFrame.new(p+Vector3.new(x*(width/2-.1),0,terminal.Size.Z/2+.05)),Color3.fromRGB(130,141,142)) end
 end
 for i=0,10 do part(detail,"UnloadingGrate",Vector3.new(.12,.06,3),CFrame.new(-15+i*.6,.87,-75),Color3.fromRGB(171,140,66)) end
 for _,x in {-12,12} do local lamp=part(detail,"ServiceLight",Vector3.new(5,.2,1),CFrame.new(x,10,-83),Color3.fromRGB(255,221,157),Enum.Material.Neon) local light=Instance.new("PointLight") light.Brightness=.65 light.Range=28 light.Shadows=false light.Color=lamp.Color light.Parent=lamp end
 for _,desc in depot:GetDescendants() do if desc:IsA("SurfaceGui") then desc.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud end end
end
function B.Build()
 assert(game:GetService("RunService"):IsStudio() and not game:GetService("RunService"):IsRunning(),"Edit mode construction only")
 local lab=workspace.VesperLab
 for _,name in {"Egg","ExcavationAccess","ResourceDepot"} do local old=lab:FindFirstChild(name) if old then old:Destroy() end end
 local egg=model(lab,"Egg") local sections=Instance.new("Folder") sections.Name="Sections" sections.Parent=egg
 local g=C.Geometry
 local core=model(egg,"ContainedSpecimen") core:SetAttribute("Placeholder",true)
 local center=g.Base+Vector3.new(0,26,0)
 local pod=part(core,"ContainmentCore",Vector3.new(18,27,18),CFrame.new(center),Color3.fromRGB(84,145,150),Enum.Material.Glass) pod.Shape=Enum.PartType.Ball pod.Transparency=.53
 local body=part(core,"PlaceholderBody",Vector3.new(7,13,6),CFrame.new(center),Color3.fromRGB(27,39,48),Enum.Material.SmoothPlastic) body.Shape=Enum.PartType.Ball
 local head=part(core,"PlaceholderHead",Vector3.new(9,7,7),CFrame.new(center+Vector3.new(0,7,-1)),body.Color,body.Material) head.Shape=Enum.PartType.Ball
 for _,side in {-1,1} do
  local ear=part(core,"SensoryFin",Vector3.new(2,9,3),CFrame.new(center+Vector3.new(side*4,12,0))*CFrame.Angles(0,0,side*-.3),body.Color,body.Material) ear.Shape=Enum.PartType.Ball
  local eye=part(core,"Eye",Vector3.new(.7,.5,.4),CFrame.new(center+Vector3.new(side*2,8,-4.3)),Color3.fromRGB(156,226,201),Enum.Material.Neon) eye.CanCollide=false
 end
 for _,p in core:GetChildren() do if p:IsA("BasePart") and p.Name~="ContainmentCore" then p.CanCollide=false p.CanQuery=false p.CanTouch=false end end
 local access=model(lab,"ExcavationAccess")
 local count=120
 local function path(t) local y=3.15+t*62 local v=math.clamp((y+3-g.Base.Y)/g.Height*2-1,-1,1) local r=g.Radius*math.sqrt(1-v*v)*(1-.22*v)+6 local a=t*math.pi*5 return Vector3.new(math.cos(a)*r,y,math.sin(a)*r) end
 for i=0,count-1 do
  local a,b=path(i/count),path((i+1)/count) local mid=(a+b)/2
  local ramp=part(access,"ServiceRamp",Vector3.new(7,.35,(b-a).Magnitude+.12),CFrame.lookAt(mid,b),Color3.fromRGB(69,77,81),Enum.Material.DiamondPlate)
  local radial=Vector3.new(mid.X,0,mid.Z).Unit
  if i%3==0 then local post=part(access,"OuterStanchion",Vector3.new(.2,3,.2),CFrame.new(mid+radial*3.3+Vector3.new(0,1.4,0)),Color3.fromRGB(220,158,55)) post.CanCollide=false end
  local rail=part(access,"SafetyRail",Vector3.new(.16,.16,(b-a).Magnitude+.15),CFrame.lookAt(mid+radial*3.3+Vector3.new(0,2.7,0),b+radial*3.3+Vector3.new(0,2.7,0)),Color3.fromRGB(220,158,55)) rail.CanCollide=false rail.CanQuery=false
 end
 sign(access,"AccessSign",Vector3.new(34,6,-8),"EXCAVATION ACCESS\nWALK UP SERVICE RAMP",13)
 local depot=model(lab,"ResourceDepot")
 sign(depot,"ServiceBanner",Vector3.new(4,13,-85),"RESOURCE DEPOT  /  EQUIPMENT",38)
 part(depot,"Pad",Vector3.new(40,.3,18),CFrame.new(0,.65,-80),Color3.fromRGB(52,65,70),Enum.Material.DiamondPlate)
 local sell=part(depot,"SellTerminal",Vector3.new(8,4,5),CFrame.new(-12,2.8,-80),Color3.fromRGB(61,105,99)) prompt(sell,"Sell","Unload bucket · sell all",Enum.KeyCode.F)
 sign(depot,"DepotSign",Vector3.new(-11,8,-82),"RESOURCE DEPOT\nSELL BUCKET CONTENTS",17)
 for i,name in {"Power","Speed","Capacity"} do
  local p=part(depot,name.."Terminal",Vector3.new(5,4,4),CFrame.new(-3+(i-1)*7,2.8,-80),Color3.fromRGB(94,81,58)) prompt(p,name,"Upgrade "..name,Enum.KeyCode.F)
  sign(depot,name.."Sign",Vector3.new(p.Position.X,6.3,-81),name:upper(),6)
 end
 local nextP=part(depot,"NextTerminal",Vector3.new(5,3,4),CFrame.new(23,2.3,-80),Color3.fromRGB(61,79,98)) prompt(nextP,"NextRound","Next specimen after reveal",Enum.KeyCode.F)
 sign(depot,"NextSign",Vector3.new(23,6,-81),"NEXT\nSPECIMEN",6)
 B.FinishStations()
 local quality=require(game.ServerStorage.VesperTools.QualityBuilder)
 quality.Tools() quality.Shell() quality.Access()
 local assets=require(game.ServerStorage.VesperTools.AssetIntegration) assets.Tools() assets.Lighting()
 egg:SetAttribute("SectionCount",#egg.Sections:GetChildren()) lab:SetAttribute("Milestone",4)
 return #egg.Sections:GetChildren()
end
return B
