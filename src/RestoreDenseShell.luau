assert(not game:GetService("RunService"):IsRunning(), "Edit only")
local http=game:GetService("HttpService")
local assets=game:GetService("AssetService")
local shared=game.ReplicatedStorage.VesperShared
local function read(name)
 local prior=http.HttpEnabled http.HttpEnabled=true
 local ok,data=pcall(http.GetAsync,http,"http://127.0.0.1:8767/"..name)
 http.HttpEnabled=prior assert(ok,data) return http:JSONDecode(data)
end
local manifest=read("egg-manifest.json")
local ids=read("egg-mesh-assets.json")
local fragments=read("fracture-manifest.json")
local fractureIds=read("original-fracture-assets.json")
local stage=game.ServerStorage:FindFirstChild("DenseShellRestore") or Instance.new("Folder") stage.Name="DenseShellRestore" stage.Parent=game.ServerStorage
for _,name in {"Sections","EggPlateLibrary","FractureLibrary"} do
 local old=stage:FindFirstChild(name)
 if old then for _,p in old:GetDescendants() do if p:IsA("MeshPart") then p.Parent=stage end end old:Destroy() end
end
stage:SetAttribute("Status","Loading original uploaded assets")
task.spawn(function()
 local ok,err=pcall(function()
  local requests={}
  for name,id in ids do table.insert(requests,{name=name,id=id}) end
  for name,id in fractureIds do table.insert(requests,{name=name,id=id}) end
  local nextIndex,done,workers=1,0,4
  local errors={}
  for _=1,4 do task.spawn(function()
   while nextIndex<=#requests do
    local index=nextIndex nextIndex+=1 local r=requests[index]
    if stage:FindFirstChild(r.name) then done+=1 continue end
    local success,part=pcall(assets.CreateMeshPartAsync,assets,Content.fromUri(r.id),{CollisionFidelity=Enum.CollisionFidelity.PreciseConvexDecomposition,RenderFidelity=Enum.RenderFidelity.Automatic})
    if success then part.Name=r.name part.Anchored=true part.Parent=stage else table.insert(errors,r.name..": "..tostring(part)) end
    done+=1 stage:SetAttribute("Loaded",done) task.wait()
   end
   workers-=1
  end) end
  while workers>0 do task.wait(0.1) end
  assert(#errors==0,table.concat(errors,"\n"))
  local cfg=shared.ExcavationConfig:Clone() cfg.Parent=stage local C=require(cfg) cfg:Destroy()
  local base=C.Geometry.Base
  local function vec(v) return Vector3.new(v[1],v[2],v[3]) end
  local sections=Instance.new("Folder") sections.Name="Sections" sections.Parent=stage
  local library=Instance.new("Folder") library.Name="EggPlateLibrary" library.Parent=stage
  local fractureLibrary=Instance.new("Folder") fractureLibrary.Name="FractureLibrary" fractureLibrary.Parent=stage
  for _,t in manifest.templates do
   local li,row=t.name:match("L(%d)_R(%d+)") li,row=tonumber(li),tonumber(row)
   local p=stage[t.name] local layer=C.Layers[li]
   p.Size=vec(t.size) p.CFrame=CFrame.new(base+vec(t.center))*CFrame.Angles(0,math.pi,0)
   p.PivotOffset=CFrame.identity p.Material=layer.Material p.Color=layer.Color
   p.TextureID=li==1 and C.Appearance.ShellIntact or "" p.CanTouch=false p.Parent=library
   for col=0,39 do
    local rotation=CFrame.new(base)*CFrame.Angles(0,(col+(row%2)*0.5)*math.pi*2/40,0)*CFrame.new(-base)
    local section=Instance.new("Model") section.Name=string.format("L%d_R%02d_C%02d",li,row,col)
    local permanent=row<6
    for k,v in {Layer=li,Row=row,Column=col,SectionId=section.Name,Resource=layer.Id,Permanent=permanent,Intact=true,HP=layer.Durability,Exposed=li==1 and not permanent,Center=rotation:PointToWorldSpace(base+vec(t.surfaceCenter))} do section:SetAttribute(k,v) end
    local plate=p:Clone() plate.Name="Plate" plate.CFrame=rotation*p.CFrame plate.CanCollide=true plate.CanQuery=true plate.Parent=section section.Parent=sections
   end
   task.wait()
  end
  for i,r in fragments do
   local p=stage[r.name] local whole=library[r.template]
   local f=fractureLibrary:FindFirstChild(r.template)
   if not f then f=Instance.new("Folder") f.Name=r.template f.Parent=fractureLibrary end
   p.Size=vec(r.size) p.CFrame=CFrame.new(base+vec(r.center))*CFrame.Angles(0,math.pi,0)
   p.PivotOffset=CFrame.identity p.CanCollide=false p.CanQuery=false p.CanTouch=false p.CastShadow=false
   p.Color=whole.Color p.Material=whole.Material p.TextureID=whole.TextureID
   local normal=whole.Position-(base+Vector3.new(0,34,0)) normal=Vector3.new(normal.X,normal.Y*0.65,normal.Z).Unit
   local delta=p.Position-whole.Position delta-=normal*delta:Dot(normal)
   p:SetAttribute("RelativeCFrame",whole.CFrame:ToObjectSpace(p.CFrame))
   p:SetAttribute("FractureDirection",whole.CFrame:VectorToObjectSpace(delta.Magnitude>0.001 and delta.Unit or Vector3.yAxis))
   p:SetAttribute("SurfaceNormal",p.CFrame:VectorToObjectSpace(normal)) p:SetAttribute("RestHeight",0.25) p.Parent=f
   if i%36==0 then task.wait() end
  end
  local egg=workspace.VesperLab.Egg
  for _,pair in {{egg,"Sections",sections},{game.ServerStorage,"EggPlateLibrary",library},{shared,"FractureLibrary",fractureLibrary}} do
   local old=pair[1]:FindFirstChild(pair[2]) if old then old:Destroy() end pair[3].Parent=pair[1]
  end
  local old=shared:FindFirstChild("EggAssetPreload") if old then old:Destroy() end
  local preload=library:Clone() preload.Name="EggAssetPreload" preload.Parent=shared
  game.ServerStorage.EggDormant:ClearAllChildren()
  egg:SetAttribute("SectionCount",2880) egg:SetAttribute("BreakableSections",2160) egg:SetAttribute("AssetVersion","DenseShellRestored")
  stage:SetAttribute("Status","Complete")
 end)
 if not ok then stage:SetAttribute("Status","Failed") stage:SetAttribute("Error",tostring(err)) warn(err) end
end)
return "Restoring 72 original plates and 216 matching fracture assets in background"
