-- Idempotent edit-time finish pass; preserves mining geometry and access surfaces.
local lab = workspace.VesperLab
local old = lab:FindFirstChild("PlatformFinish")
if old then old:Destroy() end
local model = Instance.new("Model")
model.Name = "PlatformFinish"
model.Parent = lab
local steel = Color3.fromRGB(32, 43, 53)
local edge = Color3.fromRGB(88, 108, 115)
local amber = Color3.fromRGB(224, 168, 73)
local teal = Color3.fromRGB(85, 199, 197)
local function part(name, size, cf, color, material, collide)
 local p = Instance.new("Part")
 p.Name = name p.Size = size p.CFrame = cf p.Color = color
 p.Material = material or Enum.Material.Metal
 p.Anchored = true p.CanCollide = collide == true p.CanQuery = false
 p.TopSurface = Enum.SurfaceType.Smooth p.BottomSurface = Enum.SurfaceType.Smooth
 p.Parent = model
 return p
end
local function beam(name, a, b, width, color)
 return part(name, Vector3.new(width,width,(b-a).Magnitude), CFrame.lookAt((a+b)/2,b),color)
end
local function radial(a,r,y)
 return Vector3.new(math.cos(a)*r,y,math.sin(a)*r)
end
local platform = lab.CentralPlatform
for _,p in platform:GetChildren() do
 if p:IsA("BasePart") then
  if p.Name == "ClampCap" then p.Position = Vector3.new(p.Position.X,4.85,p.Position.Z) end
  if p.Name == "SafetyHandrail" or p.Name == "RailStanchion" then
   local entry = math.min(math.abs(p.Position.X),math.abs(p.Position.Z)) < 7.5
   p.Transparency = entry and 1 or 0 p.CanCollide = not entry and p.Name == "RailStanchion"
  end
  if p.Name == "Deck" then p.Color = Color3.fromRGB(38,48,56) end
  if p.Name == "SupportDrum" then p.Color = steel end
 end
end
-- Four broad, shallow entrances with flush tread nosings and side stringers.
for n = 0,3 do
 local a = n*math.pi/2
 local cf = CFrame.new(radial(a,57,0))*CFrame.Angles(0,-a+math.pi/2,0)
 for step=1,6 do
  local top = step*0.45
  local z = 5.4-(step-1)*1.8
  part("EntryTread",Vector3.new(13,top,1.85),cf*CFrame.new(0,top/2,z),steel,Enum.Material.DiamondPlate,true)
  part("EntryNosing",Vector3.new(12.7,0.035,0.16),cf*CFrame.new(0,top+0.025,z+0.72),amber)
  for _,x in {-6.65,6.65} do
   part("StairCheek",Vector3.new(0.25,top+0.15,1.8),cf*CFrame.new(x,(top+0.15)/2,z),edge)
  end
 end
 for _,x in {-6.65,6.65} do
  for _,step in {1,3,6} do
   local z=5.4-(step-1)*1.8 local top=step*.45
   part("EntryRailPost",Vector3.new(.22,3,.22),cf*CFrame.new(x,top+1.5,z),edge)
  end
  beam("EntryHandrail",(cf*CFrame.new(x,3.45,5.4)).Position,(cf*CFrame.new(x,5.7,-3.6)).Position,.22,amber)
 end
 -- Inlaid approach lane and a numbered plaque on the deck.
 for _,x in {-5.5,5.5} do
  part("ApproachInlay",Vector3.new(.13,.035,12),cf*CFrame.new(x,2.73,-13),teal,Enum.Material.Neon)
 end
 local plaque = part("BayNumber",Vector3.new(7,.035,3),cf*CFrame.new(0,2.735,-13),steel)
 local surface = Instance.new("SurfaceGui",plaque) surface.Face=Enum.NormalId.Top surface.CanvasSize=Vector2.new(700,300)
 local label=Instance.new("TextLabel",surface) label.Size=UDim2.fromScale(1,1) label.BackgroundTransparency=1
 label.Text=string.format("BAY  %02d",n+1) label.TextColor3=Color3.fromRGB(188,211,214) label.TextSize=78 label.Font=Enum.Font.GothamBold
end
-- Segmented deck seams and restrained luminous registration marks.
for i=0,47 do
 local a=i/48*math.pi*2
 local cf=CFrame.new(radial(a,45,2.735))*CFrame.Angles(0,-a,0)
 part("DeckSeam",Vector3.new(10,.025,.055),cf,Color3.fromRGB(20,29,36))
 if i%3==0 then
  part("DeckRegistration",Vector3.new(1.8,.04,.2),CFrame.new(radial(a,48.8,2.76))*CFrame.Angles(0,-a,0),teal,Enum.Material.Neon)
  local base=CFrame.new(radial(a,53.3,1.35))*CFrame.Angles(0,-a,0)
  part("DeckButtress",Vector3.new(2.2,2.1,1.2),base,steel)
  part("ButtressPlate",Vector3.new(.12,1.35,.7),base*CFrame.new(1.15,0,0),amber)
 end
end
-- Add structural rhythm to the existing spiral without changing its walking surface.
local ramps={}
for _,p in lab.ExcavationAccess:GetChildren() do
 if p.Name=="ServiceRamp" then table.insert(ramps,p) end
end
table.sort(ramps,function(a,b) return a.Position.Y<b.Position.Y end)
for i,p in ramps do
 local cf=p.CFrame
 if i%2==0 then
  part("RampTreadEdge",Vector3.new(6.7,.025,.09),cf*CFrame.new(0,.165,p.Size.Z*.36),edge)
 end
 if i%4==0 then
  -- Determine the outward side geometrically so both helical handednesses work.
  local side=cf.RightVector:Dot(Vector3.new(p.Position.X,0,p.Position.Z))>0 and 1 or -1
  local foot=p.Position+cf.RightVector*side*3.3
  part("RampRailPost",Vector3.new(.16,2.7,.16),CFrame.new(foot+Vector3.new(0,1.35,0)),edge)
  part("RailFoot",Vector3.new(.42,.1,.42),CFrame.new(foot+Vector3.new(0,.18,0)),steel)
  part("RampOuterFascia",Vector3.new(.16,.65,p.Size.Z*4),cf*CFrame.new(side*3.45,-.32,0),steel)
 end
 if i%40==20 then
  local side=cf.RightVector:Dot(Vector3.new(p.Position.X,0,p.Position.Z))>0 and 1 or -1
  local foot=p.Position+cf.RightVector*side*3.15
  local h=foot.Y-2.7
  if h>1 then
   part("AccessSupport",Vector3.new(.48,h,.48),CFrame.new(foot.X,2.7+h/2,foot.Z),steel)
   part("SupportShoe",Vector3.new(1.3,.18,1.3),CFrame.new(foot.X,2.8,foot.Z),edge)
   beam("SupportKnee",Vector3.new(foot.X,foot.Y-3,foot.Z),p.Position,.24,edge)
  end
 end
 if i%80==0 then task.wait() end
end
return "Platform finish installed: "..#model:GetChildren().." details"
