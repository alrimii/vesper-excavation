local lab=workspace.VesperLab
local function hash(rows)
 table.sort(rows); local h=0
 for _,row in rows do for i=1,#row do h=(h*31+string.byte(row,i))%2147483647 end end
 return {count=#rows,signature=h}
end
local out={place=game.PlaceId,version=game.PlaceVersion,protected={},scripts={},rooms={},anchors={}}
for _,root in {lab.Egg,lab.ExcavationAccess,lab.CentralPlatform,lab.CrownDeliveryDock,lab.DecorativeExterior,lab.ResourceDepot,game.Lighting.Atmosphere,workspace.Terrain.Clouds} do
 local rows={} local nodes=root:GetDescendants();table.insert(nodes,root)
 for _,p in nodes do
  if p:IsA('BasePart') then table.insert(rows,p:GetFullName()..tostring(p.CFrame)..tostring(p.Size)..tostring(p.Color)..tostring(p.Material)..tostring(p.Transparency)..tostring(p.CanCollide)..(p:IsA('MeshPart') and p.MeshId or '')) end
 end
 out.protected[root:GetFullName()]=hash(rows)
end
for _,root in {game.ServerScriptService,game.ReplicatedStorage,game.StarterPlayer,game.ReplicatedFirst} do
 for _,p in root:GetDescendants() do if p:IsA('LuaSourceContainer') then out.scripts[p:GetFullName()]=hash({p.Source}) end end
end
for _,room in lab.Rooms:GetChildren() do
 local data={pivot={room:GetPivot():GetComponents()},id=room:GetAttribute('RoomNumber'),parts={},poses={}}
 local frontage=room:FindFirstChild('InteriorPortal') or room:FindFirstChild('CompactFrontage')
 for _,p in room:GetDescendants() do
  if p:IsA('BasePart') and (not frontage or not p:IsDescendantOf(frontage)) then
   table.insert(data.parts,p:GetFullName()..tostring(p.Size))
  end
 end
 data.structure=hash(data.parts);data.parts=nil
 for _,n in {'RoomSpawn','Threshold','OwnerSign','NumberSign'} do data.poses[n]={room[n].CFrame:GetComponents()} end
 data.training={room.TrainingStation.PracticeEgg.CFrame:GetComponents()}
 out.rooms[room.Name]=data
end
for _,p in lab.FunctionalAnchors:GetChildren() do out.anchors[p.Name]=p.Value and p.Value:GetFullName() end
local L=game.Lighting
out.light={clock=L.ClockTime,brightness=L.Brightness,exposure=L.ExposureCompensation,ambient=tostring(L.Ambient),outdoor=tostring(L.OutdoorAmbient)}
out.atmosphere={density=L.Atmosphere.Density,haze=L.Atmosphere.Haze,color=tostring(L.Atmosphere.Color),decay=tostring(L.Atmosphere.Decay),glare=L.Atmosphere.Glare,offset=L.Atmosphere.Offset,wind=tostring(workspace.GlobalWind)}
out.clouds={cover=workspace.Terrain.Clouds.Cover,density=workspace.Terrain.Clouds.Density,color=tostring(workspace.Terrain.Clouds.Color)}
return game:GetService('HttpService'):JSONEncode(out)
