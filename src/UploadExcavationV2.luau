-- Edit-time Blender-to-Studio import. Each uploaded mesh survives place publication.
local asset = game:GetService("AssetService")
local http = game:GetService("HttpService")
assert(not game:GetService("RunService"):IsRunning())
local folder = game.ServerStorage:FindFirstChild("ExcavationV2Assets") or Instance.new("Folder")
folder.Name = "ExcavationV2Assets"
folder.Parent = game.ServerStorage
assert(folder:GetAttribute("Status") ~= "Uploading", "Upload already running")
folder:SetAttribute("Status", "Uploading")
folder:SetAttribute("Error", nil)
task.spawn(function()
 local ok, err = pcall(function()
  local enabled = http.HttpEnabled
  http.HttpEnabled = true
  local fetched, body = pcall(http.GetAsync, http, "http://127.0.0.1:8767/excavation-v2/geometry.json")
  http.HttpEnabled = enabled
  assert(fetched, body)
  local records = http:JSONDecode(body)
  local function vec(v) return Vector3.new(v[1],v[2],v[3]) end
  folder:SetAttribute("Total", #records)
  for index, record in records do
   if not folder:FindFirstChild(record.name) then
    local mesh = assert(asset:CreateEditableMesh())
    local vertices = {}
    for i,v in record.vertices do vertices[i] = mesh:AddVertex(vec(v)) end
    for i,t in record.triangles do
     local face = mesh:AddTriangle(vertices[t.v[1]+1],vertices[t.v[2]+1],vertices[t.v[3]+1])
     local normals,uvs = {},{}
     for j=1,3 do normals[j]=mesh:AddNormal(vec(t.n[j])) uvs[j]=mesh:AddUV(Vector2.new(t.uv[j][1],t.uv[j][2])) end
     mesh:SetFaceNormals(face,normals) mesh:SetFaceUVs(face,uvs)
     if i%500==0 then task.wait() end
    end
    local result,id = asset:CreateAssetAsync(mesh,Enum.AssetType.Mesh,{
     Name="Vesper excavation v2 "..record.name,
     Description="Original Blender authored curved shell plate and matching fracture geometry.",
     CreatorId=game:GetService("StudioService"):GetUserId(),CreatorType=Enum.AssetCreatorType.User,
    })
    mesh:Destroy()
    assert(result==Enum.CreateAssetResult.Success,tostring(result).." / "..tostring(id))
    local part=asset:CreateMeshPartAsync(Content.fromAssetId(id),{CollisionFidelity=Enum.CollisionFidelity.PreciseConvexDecomposition,RenderFidelity=Enum.RenderFidelity.Automatic})
    part.Name=record.name part.Size=vec(record.size) part.CFrame=CFrame.new(vec(record.center))
    part.Anchored=true part.CanCollide=false part.CanQuery=false part.CanTouch=false
    part:SetAttribute("BlenderCenter",vec(record.center))
    part:SetAttribute("AssetId",tostring(id)) part.Parent=folder
   end
   folder:SetAttribute("Completed",index)
   task.wait(0.1)
  end
 end)
 folder:SetAttribute("Status",ok and "Complete" or "Failed")
 if not ok then folder:SetAttribute("Error",tostring(err)) warn(err) end
end)
return "Direct asset upload started; progress is stored on ServerStorage.ExcavationV2Assets"
