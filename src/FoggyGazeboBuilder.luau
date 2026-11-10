-- Edit-only assembly of the selected source-scene adaptation. Constituent rights remain unresolved.
local Builder = {}
function Builder.Build()
 assert(game.PlaceId == 94763223427049 and not game:GetService('RunService'):IsRunning(), 'Original Edit place only')
 local lab=workspace.VesperLab
 local exterior=lab.DecorativeExterior
 local assets=game.ServerStorage:FindFirstChild('FoggyGazeboAssets')
 assert(assets and #assets:GetChildren()>40,'Converted source templates required')
 local old=exterior:FindFirstChild('FoggyGazeboExterior');local prior=old and old:GetAttribute('RemovedLegacyRoots');if old then old:Destroy()end
 local removed={}
 for _,o in exterior:GetChildren()do
  if o.Name=='ScenicBase' then continue end
  local cf
  if o:IsA('Model')then cf=o:GetBoundingBox()elseif o:IsA('BasePart')then cf=o.CFrame end
  if cf then
   local bearing=math.deg(math.atan2(cf.X,cf.Z))
   if o.Name=='EastValleySector' or (bearing>=-35 and bearing<=147)then
    table.insert(removed,o.Name);o:Destroy()
   end
  end
 end
 local root=Instance.new('Model');root.Name='FoggyGazeboExterior';root:SetAttribute('SceneryOnly',true);root:SetAttribute('SourceAsset','dc5632f8-2513-4b53-9f5f-096fd493e261');root:SetAttribute('ConstituentRights','Unresolved; see source inventory');root.Parent=exterior
 local groups={}
 for _,name in {'AuthoredTerrain','GazeboAndFurnishings','ForegroundVegetation','ForestWings','BakedDistantForest'}do local m=Instance.new('Model');m.Name=name;m.Parent=root;groups[name]=m end
 local basis=CFrame.Angles(0,math.rad(56),0)
 local sorted=assets:GetChildren();table.sort(sorted,function(a,b)return a.Name<b.Name end)
 for i,t in sorted do if t:IsA('MeshPart')then
  -- Retained privately/native templates for review, not displayed: soft alpha is culled by
  -- the existing Glass dome; the cutout alternative exposes floating source forest cards.
  if t.Name:match('^Backdrop') then continue end
  local p=t:Clone();local center=t:GetAttribute('SourceCenter');assert(center,'SourceCenter missing: '..t.Name)
  center+=Vector3.new(0,t:GetAttribute('SeatingOffset') or 0,0)
  -- Distant setting: preserve the corrected terrain/assembly relationship with one transform.
  p.Size*=.85;center=Vector3.new(center.X*.85,center.Y*.85,center.Z*.85+400)
  p.CFrame=basis*CFrame.new(center);p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false
  p.Color=Color3.new(1,1,1);p.Material=Enum.Material.SmoothPlastic;p.DoubleSided=true;p.Reflectance=0
  local group=p.Name:match('^Backdrop')and 'BakedDistantForest' or p.Name:match('Landscape')and 'AuthoredTerrain' or p.Name:match('^Source')and 'GazeboAndFurnishings' or p.Name:match('^Wing')and 'ForestWings' or 'ForegroundVegetation'
  if group=='BakedDistantForest' then
   -- Distant forest ridge clears the retained perimeter roof sightline; no raised foreground shelf.
   p.CFrame+=Vector3.new(0,350,0)
   local sa=Instance.new('SurfaceAppearance');sa.ColorMap=p.TextureID;sa.RoughnessMap='rbxassetid://113355786572368';sa.AlphaMode=Enum.AlphaMode.Transparency;sa.Parent=p;p.TextureID=''
  end
  if p.Name:match('_leaf$') then
   local sa=Instance.new('SurfaceAppearance');sa.ColorMap='rbxassetid://137012180294436';sa.RoughnessMap='rbxassetid://113355786572368';sa.AlphaMode=Enum.AlphaMode.Transparency;sa.Parent=p;p.TextureID=''
  elseif group=='ForegroundVegetation' or group=='ForestWings' then
   p.TextureID='';p.Color=p.Name:match('_wood$')and Color3.fromRGB(70,95,77)or Color3.fromRGB(65,108,77)
  elseif group=='GazeboAndFurnishings' then
   p.TextureID='';p.Color=p.Name=='Source_Cone'and Color3.fromRGB(56,103,98)or Color3.fromRGB(84,110,96)
  end
  p.Parent=groups[group]
  if i%12==0 then task.wait()end
 end end
 lab:SetAttribute('FoggyGazeboRevision',2)
 lab:SetAttribute('ValleySectorRevision',1)
 root:SetAttribute('RemovedLegacyRoots',#removed>0 and table.concat(removed,', ') or prior or 'EastValleySector; LandscapeGroup1/4/10; four overlapping legacy mountains')
 return {removed=removed,templates=#sorted}
end
return Builder
