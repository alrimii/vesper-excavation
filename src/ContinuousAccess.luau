-- Edit-time replacement: one uninterrupted walking surface, no crossing galleries.
assert(not game:GetService("RunService"):IsRunning(), "Stop Play before rebuilding access")
local lab=workspace.VesperLab
local access=lab.ExcavationAccess
access:ClearAllChildren()
local steel=Color3.fromRGB(41,53,64)
local trim=Color3.fromRGB(95,120,132)
local amber=Color3.fromRGB(221,173,84)
local function part(name,size,cf,color,collide)
 local p=Instance.new("Part") p.Name=name p.Size=size p.CFrame=cf
 p.Color=color or steel p.Material=Enum.Material.Metal p.Anchored=true
 p.CanCollide=collide==true p.CanQuery=false p.CanTouch=false
 p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth
 p.Parent=access return p
end
local function polar(a,r,y) return Vector3.new(math.cos(a)*r,y,math.sin(a)*r) end
local function beam(name,a,b,w,color)
 return part(name,Vector3.new(w,w,(b-a).Magnitude),CFrame.lookAt((a+b)/2,b),color,false)
end
local function path(t,offset)
 local y=2.55+54.3*t
 local u=math.clamp((y-30)/26.85,0,1)
 -- The upper path tapers gradually; its inner edge stays outside the shell.
 local radius=32-14*u*u*(3-2*u)
 return polar(t*math.pi*6,radius+(offset or 0),y)
end
local segments=288
local maxSlope=0
local function deck(a,b,width,name)
 local delta=b-a
 maxSlope=math.max(maxSlope,math.deg(math.atan2(math.abs(delta.Y),Vector3.new(delta.X,0,delta.Z).Magnitude)))
 local p=part(name,Vector3.new(width,.3,delta.Magnitude+.16),CFrame.lookAt((a+b)/2,b),steel,true)
 p.Material=Enum.Material.DiamondPlate
 return p
end
for i=0,segments-1 do
 local t,u=i/segments,(i+1)/segments
 local p=deck(path(t),path(u),10,"ContinuousRamp")
 p:SetAttribute("RouteIndex",i)
 -- Outer safety wall has a smooth collision surface; visual posts never snag players.
 local a,b=path(t,5),path(u,5)
 local wall=part("SmoothOuterBarrier",Vector3.new(.16,2.8,(b-a).Magnitude+.2),CFrame.lookAt((a+b)/2+Vector3.yAxis*1.55,b+Vector3.yAxis*1.55),steel,true)
 wall.Transparency=1
 beam("OuterHandrail",a+Vector3.yAxis*2.95,b+Vector3.yAxis*2.95,.12,trim)
 beam("EdgeBand",a+Vector3.yAxis*.18,b+Vector3.yAxis*.18,.1,amber)
 if i%8==0 then
  part("RailPost",Vector3.new(.14,2.8,.14),CFrame.new(a+Vector3.yAxis*1.55),trim)
 end
 if i%24==12 then
  local marker=part("DirectionMarker",Vector3.new(1.8,.025,2.8),p.CFrame*CFrame.new(0,.17,0),steel)
  local gui=Instance.new("SurfaceGui",marker) gui.Face=Enum.NormalId.Top gui.CanvasSize=Vector2.new(128,192)
  local label=Instance.new("TextLabel",gui) label.Size=UDim2.fromScale(1,1) label.BackgroundTransparency=1
  label.Text="▲" label.TextSize=110 label.Font=Enum.Font.GothamBold label.TextColor3=amber
 end
 if i%72==0 then task.wait() end
end
-- Level crown platform joins the ramp at exactly the same height and width.
for i=0,47 do
 local a,b=i/48*math.pi,(i+1)/48*math.pi
 deck(polar(a,17,56.85),polar(b,17,56.85),12,"CrownLanding")
 local x,z=polar(a,23,59.8),polar(b,23,59.8)
 beam("CrownHandrail",x,z,.12,trim)
 local wall=part("CrownBarrier",Vector3.new(.16,2.8,(z-x).Magnitude+.2),CFrame.lookAt((x+z)/2-Vector3.yAxis*1.4,z-Vector3.yAxis*1.4),steel,true)
 wall.Transparency=1
 if i%8==0 then part("CrownPost",Vector3.new(.14,2.8,.14),CFrame.new(polar(a,23,58.4)),trim) end
end
local endA,endB=polar(math.pi,11,59.8),polar(math.pi,23,59.8)
beam("LandingEndRail",endA,endB,.12,trim)
local endWall=part("LandingEndBarrier",Vector3.new(.16,2.8,12),CFrame.lookAt((endA+endB)/2-Vector3.yAxis*1.4,endB-Vector3.yAxis*1.4),steel,true)
endWall.Transparency=1
-- Six supports are outboard of both the egg and all walking lanes.
for j=0,5 do
 local angle=j/6*math.pi*2
 local highest=path((2+j/6)/3)
 local top=highest.Y-.4
 part("OutboardSupport",Vector3.new(.45,top-2.7,.45),CFrame.new(polar(angle,38,(top+2.7)/2)),steel)
 part("SupportBase",Vector3.new(1.3,.15,1.3),CFrame.new(polar(angle,38,2.78)),trim)
 for turn=0,2 do
  local t=(turn+j/6)/3
  local edge=path(t,4.8)
  if edge.Y>6 then
   beam("OutboardBrace",polar(angle,38,edge.Y-3),edge-Vector3.yAxis*.35,.22,steel)
  end
 end
end
access:SetAttribute("LayoutVersion","ContinuousV1")
access:SetAttribute("WalkWidth",10)
access:SetAttribute("MaxSlopeDegrees",maxSlope)
return {parts=#access:GetChildren(),width=10,maxSlope=maxSlope}
