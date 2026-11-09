-- Edit-time only. 60 shared shapes replace 1,926 unique CSG assets.
local B={}
local C=require(game.ReplicatedStorage.VesperShared.ExcavationConfig)
local function triangle(parent,a,b,c,thickness,color,material)
 local ab,ac,bc=b-a,c-a,c-b
 if ab:Dot(ab)>ac:Dot(ac) and ab:Dot(ab)>bc:Dot(bc) then c,a=a,c elseif ac:Dot(ac)>bc:Dot(bc) then a,b=b,a end
 ab,ac,bc=b-a,c-a,c-b local cross=ac:Cross(ab) if cross.Magnitude<.0001 then return end
 local right=cross.Unit local back=bc.Unit local up=bc:Cross(right).Unit local height=math.abs(ab:Dot(up))
 for _,v in {{(a+b)/2,right,up,back,math.abs(ab:Dot(back))},{(a+c)/2,-right,up,-back,math.abs(ac:Dot(back))}} do if v[5]>.001 then
  local p=Instance.new("WedgePart") p.Size=Vector3.new(thickness,height,v[5]) p.CFrame=CFrame.fromMatrix(v[1],v[2],v[3],v[4]) p.Anchored=true p.Color=color p.Material=material p.Parent=parent
 end end
end
function B.Build()
 assert(not game:GetService("RunService"):IsRunning(),"Edit construction only")
 local manifest=game.ReplicatedStorage.VesperShared:FindFirstChild("EggManifest")
 if manifest then return require(game.ServerStorage.VesperTools.ImportEgg).Build(game.HttpService:JSONDecode(manifest.Value)) end
 local egg=workspace.VesperLab.Egg local g=C.Geometry local columns=g.Columns local rows=g.Rows
 for _,pair in {{egg,"Sections"},{game.ServerStorage,"EggDormant"},{game.ServerStorage,"EggPlateLibrary"}} do local old=pair[1]:FindFirstChild(pair[2]) if old then old:Destroy() end end
 local sections=Instance.new("Folder") sections.Name="Sections" sections.Parent=egg
 local dormant=Instance.new("Folder") dormant.Name="EggDormant" dormant.Parent=game.ServerStorage
 local library=Instance.new("Folder") library.Name="EggPlateLibrary" library.Parent=game.ServerStorage
 local function surface(theta,phi,depth)
  phi=math.clamp(phi,0,math.pi) local v=-math.cos(phi) local r=g.Radius*math.sin(phi)*(1-.22*v)
  local normal=Vector3.new(math.cos(theta)*math.sin(phi)/g.Radius,v/(g.Height/2)+.22*math.sin(phi)^2/g.Radius,math.sin(theta)*math.sin(phi)/g.Radius).Unit
  return g.Base+Vector3.new(math.cos(theta)*r,g.Height/2*(1+v),math.sin(theta)*r)-normal*depth
 end
 local offsets={{0,-2/3},{.5,-1/3},{.5,1/3},{0,2/3},{-.5,1/3},{-.5,-1/3}}
 for row=0,rows-1 do
  local phi=(row+.5)/rows*math.pi local step=math.pi/rows local width=2*math.pi/columns
  for li,layer in C.Layers do
   local depth=(li-1)*g.LayerPitch local center=surface(0,phi,depth)
   local work=Instance.new("Model") work.Name="Construction" work.Parent=library
   for k,a in offsets do local b=offsets[k%6+1]
    local inset=1-g.SeamInset
    triangle(work,center,surface(a[1]*width*inset,phi+a[2]*step*inset,depth),surface(b[1]*width*inset,phi+b[2]*step*inset,depth),g.PlateThickness,layer.Color,layer.Material)
    triangle(work,surface(0,phi,depth+.31),surface(a[1]*width*inset,phi+a[2]*step*inset,depth+.31),surface(b[1]*width*inset,phi+b[2]*step*inset,depth+.31),.08,layer.Inner,layer.Material)
   end
   local pieces=work:GetChildren() local first=table.remove(pieces,1)
   local template=first:UnionAsync(pieces,Enum.CollisionFidelity.Hull,Enum.RenderFidelity.Automatic)
   template.Name=string.format("L%d_R%02d",li,row) template.Anchored=true template.CanTouch=false template.UsePartColor=false template.CastShadow=false template.Parent=library work:Destroy()
   for column=0,columns-1 do
    local angle=(column+(row%2)*.5)*width local rotation=CFrame.new(g.Base)*CFrame.Angles(0,-angle,0)*CFrame.new(-g.Base)
    local id=string.format("L%d_R%02d_C%02d",li,row,column)
    local m=Instance.new("Model") m.Name=id m:SetAttribute("SectionId",id) m:SetAttribute("Layer",li) m:SetAttribute("Row",row) m:SetAttribute("Column",column) m:SetAttribute("Resource",layer.Id) m:SetAttribute("Intact",true) m:SetAttribute("HP",layer.Durability) m:SetAttribute("Center",rotation:PointToWorldSpace(center)) m.Parent=sections
    local p=template:Clone() p.CFrame=rotation*template.CFrame p:SetAttribute("SectionId",id)
    if li==1 then p.Name="Plate" p.Parent=m else p.Name=id p.Parent=dormant end
   end
   task.wait()
  end
 end
 egg:SetAttribute("SectionCount",columns*rows*#C.Layers) egg:SetAttribute("SurfaceCount",columns*rows) egg:SetAttribute("ShapeLibraryCount",#library:GetChildren())
 local state=game.ReplicatedStorage.VesperShared.RoundState state:SetAttribute("TotalSections",columns*rows*#C.Layers) state:SetAttribute("VisibleSections",columns*rows) state:SetAttribute("Removed",0) state:SetAttribute("Progress",0)
 return {sections=columns*rows*#C.Layers,visible=columns*rows,uniqueShapes=#library:GetChildren()}
end
return B
