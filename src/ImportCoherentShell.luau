-- Edit-time import of outer-shell geometry baked into native mesh content.
local asset=game:GetService("AssetService")
local http=game:GetService("HttpService")
local folder=game.ServerStorage:FindFirstChild("CoherentShellAssets") or Instance.new("Folder")
folder.Name="CoherentShellAssets" folder.Parent=game.ServerStorage
assert(folder:GetAttribute("Status")~="Uploading","Already importing")
folder:SetAttribute("Status","Uploading")
task.spawn(function()
    local ok,err=pcall(function()
        local enabled=http.HttpEnabled http.HttpEnabled=true
        local fetched,body=pcall(http.GetAsync,http,"http://127.0.0.1:8780/geometry.json") http.HttpEnabled=enabled assert(fetched,body)
        local records={} for _,r in http:JSONDecode(body) do if r.kind=="fracture" then table.insert(records,r) end end
        local function vec(v)return Vector3.new(v[1],v[2],v[3])end
        folder:SetAttribute("Total",#records)
        for index,r in records do
            if not folder:FindFirstChild(r.name) then
                local mesh=assert(asset:CreateEditableMesh()) local vertices={}
                for i,v in r.vertices do vertices[i]=mesh:AddVertex(vec(v)) end
                for i,t in r.triangles do
                    local face=mesh:AddTriangle(vertices[t.v[1]+1],vertices[t.v[2]+1],vertices[t.v[3]+1])
                    local ns,uvs={},{}
                    for j=1,3 do ns[j]=mesh:AddNormal(vec(t.n[j])) uvs[j]=mesh:AddUV(Vector2.new(t.uv[j][1],t.uv[j][2])) end
                    mesh:SetFaceNormals(face,ns) mesh:SetFaceUVs(face,uvs)
                    if i%500==0 then task.wait() end
                end
                local result,content=asset:CreateDataModelContentAsync(Content.fromObject(mesh))
                assert(result==Enum.CreateContentResult.Success,tostring(result))
                local part=asset:CreateMeshPartAsync(content,{CollisionFidelity=Enum.CollisionFidelity.Box,RenderFidelity=Enum.RenderFidelity.Precise})
                mesh:Destroy()
                part.Name=r.name part.Size=vec(r.size) part.CFrame=CFrame.new(vec(r.center)+Vector3.new(0,-10.2,0))*CFrame.Angles(0,math.pi,0)
                part:SetAttribute("BlenderCenter",vec(r.center)) part:SetAttribute("SourceTemplate",r.template or "") part:SetAttribute("BakedContent",true)
                part.Anchored=true part.CanCollide=false part.CanTouch=false part.CanQuery=false part.Parent=folder
            end
            folder:SetAttribute("Completed",index) task.wait(.15)
        end
    end)
    folder:SetAttribute("Status",ok and "Complete" or "Failed")
    if not ok then folder:SetAttribute("Error",tostring(err)) end
end)
return "Blender asset import started"
