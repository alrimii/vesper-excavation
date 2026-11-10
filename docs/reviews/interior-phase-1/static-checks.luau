local lab=workspace.VesperLab
assert(game.PlaceId==94763223427049 and not game:GetService("RunService"):IsRunning())
local out={entrances={},services={},floor={},roofCount=0,oldSigns={},supportBearings={},anchors={},duplicates={}}
local params=OverlapParams.new()
params.FilterType=Enum.RaycastFilterType.Include params.RespectCanCollide=true params.FilterDescendantsInstances={lab}
local function bounds(pose,size)
 local hits={} for _,p in workspace:GetPartBoundsInBox(pose,size,params) do table.insert(hits,p:GetFullName()) end return hits
end
for _,room in lab.Rooms:GetChildren() do
 out.entrances[room.Name]=bounds(room:GetPivot()*CFrame.new(0,5,-48),Vector3.new(12,6,24))
 if room:FindFirstChild("FinishedRoof") then out.roofCount+=1 end
 if room:FindFirstChild("NumberSign") or room:FindFirstChild("Ceiling") then table.insert(out.oldSigns,room.Name) end
end
local workshop=lab.SharedWorkshop
out.services.Workshop=bounds(CFrame.lookAt(Vector3.new(132.2,0,44),Vector3.new(0,0,44))*CFrame.new(0,5,-11),Vector3.new(44,6,9))
for i,v in {{Vector3.new(44,0,-132.4),Vector3.new(44,0,0)},{Vector3.new(-132.4,0,-44),Vector3.new(0,0,-44)}} do
 out.services["Laboratory"..i]=bounds(CFrame.lookAt(v[1],v[2])*CFrame.new(0,5,-8),Vector3.new(14,7,6))
end
params.FilterDescendantsInstances={lab.ExcavationAccess.Phase1StructuralConnections}
out.ladderNewColliders=bounds(CFrame.new(52.267273,12.825,-10.25),Vector3.new(5.8,18.5,3.4))
local ray=RaycastParams.new() ray.FilterType=Enum.RaycastFilterType.Include ray.RespectCanCollide=true ray.FilterDescendantsInstances={lab.CompactStoneFloor,lab.Architecture.CompactFoundation}
local missed=0 local minY=math.huge
for i=0,239 do local angle=i*math.pi/120
 for _,radius in {73,74.4,76,80} do
  local hit=workspace:Raycast(Vector3.new(math.cos(angle)*radius,1.1,math.sin(angle)*radius),Vector3.new(0,-2,0),ray)
  if not hit then missed+=1 else minY=math.min(minY,hit.Position.Y) end
 end
end
out.floor={samples=960,missing=missed,minimumSurfaceY=minY,finishedSurfaceY=.87,foundationSeamSurfaceY=.675}
local ladder=lab.ExcavationAccess.AccessRevision4.LadderEntrance
for _,name in {"AccessSign","SignPost","LandingColumn"} do if ladder:FindFirstChild(name) then table.insert(out.oldSigns,name) end end
for _,post in lab.ExcavationAccess:GetChildren() do if post.Name=="OutboardSupport" then
 local best=math.huge local contact
 for _,bracket in lab.ExcavationAccess.WalkwaySupportArms:GetChildren() do if bracket.Name=="TopBracket" then
  for _,sign in {-1,1} do local q=bracket.CFrame:PointToWorldSpace(Vector3.new(0,0,sign*bracket.Size.Z/2))
   local distance=(Vector3.new(q.X,0,q.Z)-Vector3.new(post.Position.X,0,post.Position.Z)).Magnitude
   if distance<best then best=distance contact=q end
  end
 end end
 table.insert(out.supportBearings,{horizontalError=best,verticalError=math.abs(post.Position.Y+post.Size.Y/2-(contact.Y-.24))})
end end
for _,root in {lab.SharedWorkshop.IntegratedWorkshop,lab.WallResearchDetails,lab.ExcavationAccess.Phase1StructuralConnections,lab.FinishedRoofJunctions} do
 local count=0 for _,p in root.Parent:GetChildren() do if p.Name==root.Name then count+=1 end end out.duplicates[root:GetFullName()]=count
end
for _,name in {"Console","UpgradeConsole","ApproachZone"} do local p=workshop[name] out.anchors[name]={path=p:GetFullName(),pose={p.CFrame:GetComponents()},size=tostring(p.Size)} end
out.obsoleteLabKiosk=lab:FindFirstChild("SharedLaboratory")~=nil
out.obsoleteWorkshopKiosk=workshop:FindFirstChild("CompactWorkshop")~=nil
out.obsoleteBotanicalSupport=lab:FindFirstChild("CompactBotanicalSupports")~=nil
return game:GetService("HttpService"):JSONEncode(out)
