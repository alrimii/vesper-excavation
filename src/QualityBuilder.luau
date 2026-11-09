-- Original tools and geodesic dual tessellation. Edit-time CSG only.
local Q={}
local C=require(game.ReplicatedStorage.VesperShared.ExcavationConfig)
local steel=Color3.fromRGB(146,163,169) local dark=Color3.fromRGB(37,49,57) local amber=Color3.fromRGB(210,155,64)
local function part(parent,name,size,cf,color,mat,class)
 local p=Instance.new(class or "Part") p.Name=name p.Size=size p.CFrame=cf p.Color=color p.Material=mat or Enum.Material.Metal p.Anchored=true p.CanTouch=false p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth p.Parent=parent return p
end
local function rod(parent,name,a,b,width,color)
 return part(parent,name,Vector3.new(width,width,(a-b).Magnitude),CFrame.lookAt((a+b)/2,b),color)
end
local function triangle(parent,a,b,c,thickness,color,mat)
 local ab,ac,bc=b-a,c-a,c-b
 if ab:Dot(ab)>ac:Dot(ac) and ab:Dot(ab)>bc:Dot(bc) then c,a=a,c elseif ac:Dot(ac)>bc:Dot(bc) then a,b=b,a end
 ab,ac,bc=b-a,c-a,c-b local cross=ac:Cross(ab) if cross.Magnitude<.0001 then return end
 local right=cross.Unit local back=bc.Unit local up=bc:Cross(right).Unit local h=math.abs(ab:Dot(up))
 for _,v in {{(a+b)/2,right,up,back,math.abs(ab:Dot(back))},{(a+c)/2,-right,up,-back,math.abs(ac:Dot(back))}} do if v[5]>.001 then part(parent,"Facet",Vector3.new(thickness,h,v[5]),CFrame.fromMatrix(v[1],v[2],v[3],v[4]),color,mat,"WedgePart") end end
end
local function fuse(model,name)
 local list=model:GetChildren() local first=table.remove(list,1)
 local result=first:UnionAsync(list,Enum.CollisionFidelity.PreciseConvexDecomposition,Enum.RenderFidelity.Precise)
 for _,p in model:GetChildren() do p:Destroy() end
 result.Name=name result.Anchored=true result.CanTouch=false result.UsePartColor=false result.Parent=model return result
end
function Q.Shell()
 return require(game.ServerStorage.VesperTools.EggBuilder).Build()
end
function Q.Tools()
 local kit=game.ServerStorage.VesperKit
 for _,name in {"StarterPickaxe","CollectionBucket"} do local old=kit:FindFirstChild(name) if old then old:Destroy() end end
 local function tool(name,kind,grip)
  local t=Instance.new("Tool") t.Name=name t.CanBeDropped=false t.ManualActivationOnly=true t.TextureId=C.Icons[kind] t.ToolTip=kind=="Pickaxe" and "Aim at exposed plates and strike" or "Hold to collect loose resources" t.Grip=grip t:SetAttribute("ToolKind",kind) t.Parent=kit return t
 end
 local pick=tool("StarterPickaxe","Pickaxe",CFrame.new(0,-.6,0)*CFrame.Angles(0,math.pi/2,math.rad(-7)))
 local handle=part(pick,"Handle",Vector3.new(.3,3.4,.35),CFrame.new(),dark)
 handle.Transparency=1
 local function cylinder(parent,name,length,diameter,pos,color,mat)
  local p=part(parent,name,Vector3.new(length,diameter,diameter),CFrame.new(pos)*CFrame.Angles(0,0,math.pi/2),color,mat) p.Shape=Enum.PartType.Cylinder return p
 end
 cylinder(pick,"ForgedShaft",3.6,.32,Vector3.new(0,.05,0),Color3.fromRGB(84,110,115))
 cylinder(pick,"GripCore",1.45,.41,Vector3.new(0,-.91,0),dark,Enum.Material.SmoothPlastic)
 for i=0,10 do cylinder(pick,"GripWrap",.045,.435,Vector3.new(0,-1.55+i*.13,0),Color3.fromRGB(67,77,78),Enum.Material.SmoothPlastic) end
 cylinder(pick,"Pommel",.19,.49,Vector3.new(0,-1.75,0),steel)
 cylinder(pick,"SafetyCollar",.23,.43,Vector3.new(0,.95,0),amber)
 local head=Instance.new("Model") head.Name="Forging" head.Parent=kit
 for _,side in {-1,1} do
  local function edge(t,upper) local width=.42*(1-t)+.025 return Vector3.new(side*(.05+1.7*t),1.8-.82*t*t+(upper and width/2 or -width/2),0) end
  for i=0,9 do local a,b,c,d=edge(i/10,true),edge((i+1)/10,true),edge((i+1)/10,false),edge(i/10,false)
   local thickness=.56*(1-i/10)+.045 triangle(head,a,b,c,thickness,steel,Enum.Material.Metal) triangle(head,a,c,d,thickness,steel,Enum.Material.Metal)
  end
 end
 local forged=fuse(head,"CurvedPickHead") forged.UsePartColor=true forged.Color=Color3.fromRGB(174,190,192) forged.Parent=pick head:Destroy()
 part(pick,"HeadSocket",Vector3.new(.56,.69,.66),CFrame.new(0,1.58,0),dark)
 for _,x in {-.16,.16} do local bolt=part(pick,"Rivet",Vector3.new(.11,.11,.08),CFrame.new(x,1.58,-.36),amber) bolt.Shape=Enum.PartType.Ball end
 local tip=Instance.new("Attachment") tip.Name="StrikeTip" tip.Position=Vector3.new(1.75,.98,0) tip.Parent=handle
 local bucket=tool("CollectionBucket","Bucket",CFrame.new(0,-.05,0)*CFrame.Angles(0,0,math.rad(7)))
 part(bucket,"Handle",Vector3.new(1,.18,.2),CFrame.new(),dark)
 local body=Instance.new("Model") body.Name="BucketCasting" body.Parent=kit
 for i=0,23 do local a=i*math.pi/12 local cf=CFrame.new(math.cos(a)*.94,-1.65,math.sin(a)*.94)*CFrame.Angles(0,-a,0)
  part(body,"Wall",Vector3.new(.13,1.45,.265),cf*CFrame.Angles(0,0,-.08),Color3.fromRGB(139,161,160))
 end
 local base=part(body,"Floor",Vector3.new(.16,1.76,1.76),CFrame.new(0,-2.35,0)*CFrame.Angles(0,0,math.pi/2),dark) base.Shape=Enum.PartType.Cylinder
 local casting=fuse(body,"TaperedBucketBody") casting.Parent=bucket body:Destroy()
 local rim=Instance.new("Model") rim.Name="RolledLip" rim.Parent=kit
 for i=0,23 do local a,b=i*math.pi/12,(i+1)*math.pi/12 rod(rim,"Lip",Vector3.new(math.cos(a),-.92,math.sin(a)),Vector3.new(math.cos(b),-.92,math.sin(b)),.13,steel) end
 local lip=fuse(rim,"RolledSteelLip") lip.Parent=bucket rim:Destroy()
 local bail=Instance.new("Model") bail.Name="CarryHandle" bail.Parent=kit
 for i=0,15 do local a,b=i*math.pi/16,(i+1)*math.pi/16 rod(bail,"Arc",Vector3.new(math.cos(a)*1.02,-.95+math.sin(a)*1.07,0),Vector3.new(math.cos(b)*1.02,-.95+math.sin(b)*1.07,0),.11,steel) end
 local arch=fuse(bail,"CurvedCarryHandle") arch.Parent=bucket bail:Destroy()
 part(bucket,"IdentificationBadge",Vector3.new(.55,.44,.04),CFrame.new(0,-1.55,-1.04),amber)
 for _,side in {-1,1} do local hinge=part(bucket,"Hinge",Vector3.new(.15,.23,.23),CFrame.new(side*1.03,-.96,0),dark) hinge.Shape=Enum.PartType.Ball end
 local fill=part(bucket,"Fill",Vector3.new(.1,1.6,1.6),CFrame.new(0,-2.2,0)*CFrame.Angles(0,0,math.pi/2),C.Layers[1].Color,Enum.Material.Limestone) fill.Shape=Enum.PartType.Cylinder fill.Transparency=1
 for i=1,9 do local a=i*2.4 local chip=part(bucket,"Contents"..i,Vector3.new(.35,.15,.3),CFrame.new(math.cos(a)*.5,-2,math.sin(a)*.5),C.Layers[1].Color,Enum.Material.Limestone,"WedgePart") chip:SetAttribute("ContentIndex",i) chip.Transparency=1 end
 for _,t in {pick,bucket} do
  local h=t.Handle
  for _,p in t:GetChildren() do if p:IsA("BasePart") then p.Anchored=false p.Massless=true p.CanCollide=false p.CanQuery=false p.CanTouch=false p.CastShadow=false if p~=h then local w=Instance.new("Weld") w.Name="AssemblyJoint" w.Part0=h w.Part1=p w.C0=h.CFrame:ToObjectSpace(p.CFrame) w.Parent=p end end end
 end
 return "Original pickaxe and bucket assembled"
end
function Q.Access()
 local root=workspace.VesperLab.ExcavationAccess
 for _,p in root:GetChildren() do if p.Name=="ServiceRamp" or p.Name=="SafetyRail" or p.Name=="RampPanels" then p:Destroy() end end
 local panels=Instance.new("Model") panels.Name="RampPanels" panels.Parent=root
 local g=C.Geometry local count=120
 local function path(t,offset)
  local y=3.15+t*62 local v=math.clamp((y+3-g.Base.Y)/g.Height*2-1,-1,1)
  local r=g.Radius*math.sqrt(1-v*v)*(1-.22*v)+6+offset local a=t*math.pi*5
  return Vector3.new(math.cos(a)*r,y,math.sin(a)*r)
 end
 for i=0,count-1 do
  local t,u=i/count,(i+1)/count local a,b,c,d=path(t,-3.5),path(t,3.5),path(u,3.5),path(u,-3.5)
  triangle(panels,a,b,c,.25,Color3.fromRGB(69,77,81),Enum.Material.Metal)
  triangle(panels,a,c,d,.25,Color3.fromRGB(69,77,81),Enum.Material.Metal)
  local rail=rod(root,"SafetyRail",path(t,3.3)+Vector3.new(0,2.7,0),path(u,3.3)+Vector3.new(0,2.7,0),.16,amber) rail.CanCollide=false rail.CanQuery=false
 end
 return "Continuous fitted ramp panels and rail joints"
end
return Q

