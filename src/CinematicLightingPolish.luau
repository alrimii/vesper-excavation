-- Retired after the living-laboratory checkpoint.
assert(not (workspace:FindFirstChild("VesperLab") and workspace.VesperLab:GetAttribute("LivingLabRevision")), "Historical environment recipe retired; use LivingLabBuilder")
assert(not game:GetService("RunService"):IsRunning(),"Edit only")
local lab=workspace.VesperLab
local lighting=game:GetService("Lighting")
local old=lab:FindFirstChild("CinematicFixtures") if old then old:Destroy() end
local fixtures=Instance.new("Model") fixtures.Name="CinematicFixtures" fixtures.Parent=lab
local floating=lab.Presentation:FindFirstChild("SpecimenKeyLight") if floating then floating:Destroy() end
local function part(name,size,cf,color,material)
 local p=Instance.new("Part") p.Name=name p.Size=size p.CFrame=cf p.Color=color
 p.Material=material or Enum.Material.Metal p.Anchored=true p.CanCollide=false p.CanQuery=false p.CanTouch=false
 p.CastShadow=false p.Parent=fixtures return p
end
-- The old cradle ring sat inside the expanded shell. Recess it outside the footprint.
for _,p in lab.CentralPlatform:GetChildren() do
 if p:IsA("BasePart") and p.Name=="CradleAccent" then
  local radial=Vector3.new(p.Position.X,0,p.Position.Z)
  local oldRadius=radial.Magnitude
  p.Size=Vector3.new(.16,.04,p.Size.Z*44/oldRadius)
  p.CFrame=CFrame.new(radial.Unit*44+Vector3.yAxis*3.685)*p.CFrame.Rotation
  p.Color=Color3.fromRGB(171,143,87) p.Material=Enum.Material.Neon
 end
end
-- Move floor lamps and nearby fixture housings together, beyond the walking structure.
if not lab:GetAttribute("OuterLampFit") then
 local heads={}
 for _,p in lab.CentralPlatform:GetChildren() do if p.Name=="DeckLamp" then table.insert(heads,p.Position) end end
 for _,p in lab:GetDescendants() do
  if p:IsA("BasePart") and (p:IsDescendantOf(lab.CentralPlatform) or p:IsDescendantOf(lab.FixtureHousings)) then
   for _,head in heads do
    local offset=Vector3.new(head.X,0,head.Z).Unit*(67-Vector3.new(head.X,0,head.Z).Magnitude)
    if p.Name=="DeckLightStem" and (Vector3.new(p.Position.X,0,p.Position.Z)-Vector3.new(head.X,0,head.Z)).Magnitude<1
      or (p.Position-head).Magnitude<5 then p.CFrame+=offset break end
   end
  end
 end
 lab:SetAttribute("OuterLampFit",true)
end
for _,p in lab.ExcavationAccess:GetChildren() do
 if p.Name=="DirectionMarker" then p:Destroy() end
end
local strips=0
for _,p in lab.ExcavationAccess:GetChildren() do
 local index=p:GetAttribute("RouteIndex")
 if index and index%8==0 then
  for _,side in {-1,1} do
   local cf=p.CFrame*CFrame.new(side*(p.Size.X/2-.55),.2,0)
   part("GuideLightHousing",Vector3.new(.52,.1,1.7),cf,Color3.fromRGB(25,34,42))
   local lens=part("StairGuideLight",Vector3.new(.24,.055,1.35),cf*CFrame.new(0,.07,0),Color3.fromRGB(203,178,126),Enum.Material.Neon)
   if index%32==0 and side==1 then
    local glow=Instance.new("PointLight",lens) glow.Color=lens.Color glow.Brightness=.32 glow.Range=9 glow.Shadows=false
   end
   strips+=1
  end
 end
end
-- Key and rim fixtures mounted on the existing outer support columns.
for _,entry in {{225,70,Color3.fromRGB(255,222,178),2.4},{45,64,Color3.fromRGB(162,199,235),1.5},{135,42,Color3.fromRGB(235,220,194),.85}} do
 local angle=math.rad(entry[1]) local pos=Vector3.new(math.cos(angle)*61,entry[2],math.sin(angle)*61)
 local cf=CFrame.lookAt(pos,Vector3.new(0,43,0))
 local housing=part("MountedSpecimenLight",Vector3.new(1.6,.9,1.1),cf,Color3.fromRGB(38,47,55))
 local lens=part("SpecimenLightLens",Vector3.new(1.35,.65,.05),cf*CFrame.new(0,0,-.57),entry[3],Enum.Material.Neon)
 local spot=Instance.new("SpotLight",housing) spot.Face=Enum.NormalId.Front spot.Color=entry[3]
 spot.Brightness=entry[4] spot.Range=60 spot.Angle=105 spot.Shadows=true
end
lighting.LightingStyle=Enum.LightingStyle.Soft
lighting.PrioritizeLightingQuality=true lighting.GlobalShadows=true
lighting.ClockTime=14 lighting.Brightness=2
lighting.Ambient=Color3.fromRGB(113,122,138)
lighting.OutdoorAmbient=Color3.fromRGB(125,137,155)
lighting.ExposureCompensation=.12
lighting.EnvironmentDiffuseScale=.65 lighting.EnvironmentSpecularScale=.38
local grade=lighting:FindFirstChild("VesperGrade") or Instance.new("ColorCorrectionEffect",lighting)
grade.Name="VesperGrade" grade.Enabled=true grade.Brightness=0 grade.Contrast=.025 grade.Saturation=.015
grade.TintColor=Color3.fromRGB(255,251,244)
local bloom=lighting:FindFirstChildOfClass("BloomEffect") or Instance.new("BloomEffect",lighting)
bloom.Intensity=.08 bloom.Size=28 bloom.Threshold=1.65
local atmosphere=lighting:FindFirstChildOfClass("Atmosphere")
if atmosphere then atmosphere.Density=.075 atmosphere.Haze=.25 atmosphere.Glare=0 atmosphere.Color=Color3.fromRGB(158,177,196) atmosphere.Decay=Color3.fromRGB(76,88,108) end
local dof=lighting:FindFirstChildOfClass("DepthOfFieldEffect") if dof then dof.Enabled=false end
for _,v in lab.CentralPlatform:GetDescendants() do
 if v:IsA("PointLight") then v.Brightness=.45 v.Range=24 v.Color=Color3.fromRGB(255,221,172) v.Shadows=false end
end
return {guideLights=strips,floatingLightRemoved=true,lowerFixturesRadius=67,creatureScale=2.1}
