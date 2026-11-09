-- Manifest globals are supplied by the installer; no network fetch or uploaded script.
assert(not game:GetService("RunService"):IsRunning(),"Edit only")
local shared=game.ReplicatedStorage.VesperShared
local cfg=shared.ExcavationConfig:Clone() cfg.Parent=game.ServerStorage local C=require(cfg) cfg:Destroy()
local imported=workspace:FindFirstChild("VesperExpansionV3")
assert(imported,"Blender import must finish first")
local source={}
for _,p in imported:GetDescendants() do if p:IsA("MeshPart") then source[p.Name]=p end end
for _,t in MANIFEST.templates do assert(source[t.name],"Missing intact mesh "..t.name) end
for _,t in FRACTURES do assert(source[t.name],"Missing fracture mesh "..t.name) end
local function vec(v) return Vector3.new(v[1],v[2],v[3]) end
local base=C.Geometry.Base
local stage=Instance.new("Folder") stage.Name="ExpansionAssembly" stage.Parent=game.ServerStorage
local library=Instance.new("Folder",stage) library.Name="EggPlateLibrary"
local fragments=Instance.new("Folder",stage) fragments.Name="FractureLibrary"
local sections=Instance.new("Folder",stage) sections.Name="Sections"
for _,t in MANIFEST.templates do
 local li,row=t.name:match("L(%d)_R(%d+)") li,row=tonumber(li),tonumber(row)
 local layer=C.Layers[li]
 local p=source[t.name]:Clone()
 for _,child in p:GetChildren() do child:Destroy() end
 p.Size=vec(t.size) p.CFrame=CFrame.new(base+vec(t.center))*CFrame.Angles(0,math.pi,0)
 p.PivotOffset=CFrame.identity p.Anchored=true p.CanTouch=false p.CanQuery=true p.CanCollide=true
 p.Color=layer.Color p.Material=layer.Material p.TextureID=li==1 and C.Appearance.ShellIntact or ""
 p.Parent=library
 for col=0,C.Geometry.Columns-1 do
  local rotation=CFrame.new(base)*CFrame.Angles(0,(col+(row%2)*.5)*math.pi*2/C.Geometry.Columns,0)*CFrame.new(-base)
  local section=Instance.new("Model") section.Name=string.format("L%d_R%02d_C%02d",li,row,col)
  local permanent=row<C.Geometry.PermanentRows
  for k,v in {Layer=li,Row=row,Column=col,SectionId=section.Name,Resource=layer.Id,Permanent=permanent,Intact=true,HP=layer.Durability,Exposed=li==1 and not permanent,Center=rotation:PointToWorldSpace(base+vec(t.surfaceCenter))} do section:SetAttribute(k,v) end
  local plate=p:Clone() plate.Name="Plate" plate.CFrame=rotation*p.CFrame plate.Parent=section section.Parent=sections
 end
 task.wait()
end
for i,t in FRACTURES do
 local whole=library[t.template]
 local folder=fragments:FindFirstChild(t.template)
 if not folder then folder=Instance.new("Folder",fragments) folder.Name=t.template end
 local p=source[t.name]:Clone()
 for _,child in p:GetChildren() do child:Destroy() end
 p.Size=vec(t.size) p.CFrame=CFrame.new(base+vec(t.center))*CFrame.Angles(0,math.pi,0)
 p.PivotOffset=CFrame.identity p.Anchored=true p.CanCollide=false p.CanQuery=false p.CanTouch=false
 p.Color=whole.Color p.Material=whole.Material p.TextureID=whole.TextureID
 local contact=CONTACT[t.name]
 local normal=contact and vec(contact.normal) or (p.Position-(base+Vector3.yAxis*C.Geometry.Height*.5)).Unit
 local delta=p.Position-whole.Position delta-=normal*delta:Dot(normal)
 p:SetAttribute("RelativeCFrame",whole.CFrame:ToObjectSpace(p.CFrame))
 p:SetAttribute("SurfaceNormal",p.CFrame:VectorToObjectSpace(normal))
 p:SetAttribute("FractureDirection",whole.CFrame:VectorToObjectSpace(delta.Magnitude>.001 and delta.Unit or Vector3.xAxis))
 p:SetAttribute("RestHeight",contact and contact.restHeight or .35)
 p.Parent=folder
 if i%60==0 then task.wait() end
end
local lab=workspace.VesperLab
if not lab:GetAttribute("ExpansionSpaceV3") then
 local egg,access=lab.Egg,lab.ExcavationAccess
 egg.Parent=stage access.Parent=stage
 lab.PrimaryPart=nil lab.WorldPivot=CFrame.identity
 lab:ScaleTo(lab:GetScale()*1.35)
 egg.Parent=lab access.Parent=lab
 lab:SetAttribute("ExpansionSpaceV3",true)
end
local egg=lab.Egg
egg.Sections:Destroy() sections.Parent=egg
game.ServerStorage.EggPlateLibrary:Destroy() library.Parent=game.ServerStorage
shared.FractureLibrary:Destroy() fragments.Parent=shared
shared.EggAssetPreload:Destroy() local preload=library:Clone() preload.Name="EggAssetPreload" preload.Parent=shared
game.ServerStorage.EggDormant:ClearAllChildren()
egg:SetAttribute("GeometryFit","ExpansionV3")
egg:SetAttribute("SectionCount",C.Geometry.Columns*C.Geometry.Rows*3)
egg:SetAttribute("BreakableSections",C.Geometry.Columns*(C.Geometry.Rows-C.Geometry.PermanentRows)*3)
imported.Name="ExpansionV3ImportedAssets" imported.Parent=game.ServerStorage
stage:Destroy()
return {sections=#sections:GetChildren(),templates=#library:GetChildren(),fractureTemplates=#fragments:GetChildren()}
