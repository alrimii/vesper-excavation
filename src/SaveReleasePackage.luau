-- Native Roblox binary snapshot of the edited game systems, not a published place.
local root=Instance.new("Folder") root.Name="VesperDenseShellRelease"
for _,entry in {
 {workspace.VesperLab,"Workspace.VesperLab"},
 {game.ReplicatedStorage.VesperShared,"ReplicatedStorage.VesperShared"},
 {game.ServerScriptService.Vesper,"ServerScriptService.Vesper"},
 {game.ServerStorage.VesperKit,"ServerStorage.VesperKit"},
 {game.ServerStorage.EggDormant,"ServerStorage.EggDormant"},
 {game.ServerStorage.EggPlateLibrary,"ServerStorage.EggPlateLibrary"},
 {game.StarterGui.ExcavationHUD,"StarterGui.ExcavationHUD"},
 {game.StarterPlayer.StarterPlayerScripts.ExcavationClient,"StarterPlayer.StarterPlayerScripts.ExcavationClient"},
 {game.ReplicatedFirst.Loading,"ReplicatedFirst.Loading"},
} do
 local clone=entry[1]:Clone() clone:SetAttribute("ReleaseRestorePath",entry[2]) clone.Parent=root
 task.wait()
end
root:SetAttribute("PlaceId",game.PlaceId)
root:SetAttribute("Version","Dense shell correction - 2160 breakable plates")
local ok,result=pcall(function()
 local data=game:GetService("SerializationService"):SerializeInstancesAsync({root})
 local http=game:GetService("HttpService") local enabled=http.HttpEnabled http.HttpEnabled=true
 local sent,response=pcall(http.RequestAsync,http,{Url="http://127.0.0.1:8772/release",Method="POST",Headers={["Content-Type"]="application/octet-stream"},Body=buffer.tostring(data)})
 http.HttpEnabled=enabled assert(sent,response) assert(response.Success,response.Body) return {bytes=buffer.len(data),response=response.Body}
end)
root:Destroy()
assert(ok,result)
return result
