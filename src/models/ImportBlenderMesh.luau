-- Edit-only importer for our original Blender mesh data. Creates durable mesh assets.
local Import={}
function Import.Upload(kind)
 assert(not game:GetService('RunService'):IsRunning(),'Edit mode only')
 local http=game:GetService('HttpService') local asset=game:GetService('AssetService')
 local enabled=http.HttpEnabled http.HttpEnabled=true
 local ok,text=pcall(function() return http:GetAsync('http://127.0.0.1:8767/'..kind:lower()..'.mesh.json') end)
 http.HttpEnabled=enabled assert(ok,text)
 local data=http:JSONDecode(text) local mesh=assert(asset:CreateEditableMesh(),'Mesh allocation failed')
 local function vec(v) return Vector3.new(v[1],v[2],v[3]) end
 local verts={} for i,v in data.vertices do verts[i]=mesh:AddVertex(vec(v)) end
 local colors={}
 for i,t in data.triangles do
  local f=mesh:AddTriangle(verts[t.v[1]+1],verts[t.v[2]+1],verts[t.v[3]+1])
  local ns,uvs={},{} for j=1,3 do ns[j]=mesh:AddNormal(vec(t.n[j])) uvs[j]=mesh:AddUV(Vector2.new(t.uv[j][1],t.uv[j][2])) end
  mesh:SetFaceNormals(f,ns) mesh:SetFaceUVs(f,uvs)
  local key=table.concat(t.c,',') local color=colors[key]
  if not color then color=mesh:AddColor(Color3.new(t.c[1],t.c[2],t.c[3]),1) colors[key]=color end
  mesh:SetFaceColors(f,{color,color,color})
  if i%1000==0 then task.wait() end
 end
 local center=mesh:GetCenter()
 local success,result,id=pcall(function() return asset:CreateAssetAsync(mesh,Enum.AssetType.Mesh,{Name='Vesper '..kind,Description='Original industrial excavation prop modeled locally in Blender through BlendRelay.',CreatorId=game:GetService('StudioService'):GetUserId(),CreatorType=Enum.AssetCreatorType.User}) end)
 mesh:Destroy()
 assert(success,result) assert(result==Enum.CreateAssetResult.Success,tostring(result)..': '..tostring(id))
 local folder=game.ServerStorage:FindFirstChild('VesperBlenderAssets') or Instance.new('Folder') folder.Name='VesperBlenderAssets' folder.Parent=game.ServerStorage
 local part=asset:CreateMeshPartAsync(Content.fromAssetId(id),{CollisionFidelity=Enum.CollisionFidelity.Box,RenderFidelity=Enum.RenderFidelity.Automatic})
 part.Name=kind part.CFrame=CFrame.new(center) part.Anchored=true part.CanCollide=false part.CanTouch=false part.CanQuery=false part.Color=Color3.new(1,1,1) part.Material=Enum.Material.SmoothPlastic part.Parent=folder
 part:SetAttribute('OriginalAssetId',tostring(id)) part:SetAttribute('ModelingSource','src/models/vesper-tools.blend')
 return {kind=kind,id=id,center=tostring(center),triangles=#data.triangles}
end
return Import
