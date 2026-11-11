-- Read-only baseline/final comparison; no gameplay execution.
local function checksum(s)
 local a,b=1,0
 for i=1,#s do a=(a+string.byte(s,i))%65521;b=(b+a)%65521 end
 return string.format('%08x',b*65536+a)
end
local records={}
local shop=workspace.VesperLab.SharedWorkshop.IntegratedWorkshop
for i,p in workspace.VesperLab:GetDescendants() do
 if p:IsA('BasePart') and not (p:IsDescendantOf(shop.PickaxeDisplay) or p:IsDescendantOf(shop.DrillDisplay) or p:IsDescendantOf(shop.ChargeDisplay)) then
  table.insert(records,table.concat({p:GetFullName(),p.ClassName,tostring(p.CFrame),tostring(p.Size),tostring(p.Color),tostring(p.Material),tostring(p.Transparency),tostring(p.CanCollide),tostring(p.CanQuery),tostring(p.Anchored)},'|'))
 end
 if i%1000==0 then task.wait() end
end
table.sort(records)
local sources={}
for _,root in {game.ServerScriptService,game.ReplicatedStorage,game.StarterPlayer,game.ServerStorage.VesperTools} do
 for _,s in root:GetDescendants() do
  if s:IsA('LuaSourceContainer') then
   local normalized=s.Source:gsub('\r\n','\n'):gsub('%s+$','')..'\n'
   sources[s:GetFullName()]={size=#normalized,checksum=checksum(normalized)}
  end
 end
end
local l=game.Lighting
return {geometryCount=#records,geometryChecksum=checksum(table.concat(records,'\n')),lighting={brightness=l.Brightness,clock=l.ClockTime,ambient=tostring(l.Ambient),outdoor=tostring(l.OutdoorAmbient),exposure=l.ExposureCompensation},sources=sources}
