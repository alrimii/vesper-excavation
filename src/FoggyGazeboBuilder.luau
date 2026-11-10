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
  local p=t:Clone();local center=t:GetAttribute('SourceCenter');assert(center,'SourceCenter missing: '..t.Name)
  if not p.Name:match('^Backdrop') and not p.Name:match('Landscape') then center+=Vector3.new(0,(t:GetAttribute('TerrainLift') or 0),0) end
  p.CFrame=basis*CFrame.new(center);p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false
  p.Color=Color3.new(1,1,1);p.Material=Enum.Material.SmoothPlastic;p.DoubleSided=true;p.Reflectance=0
  local group=p.Name:match('^Backdrop')and 'BakedDistantForest' or p.Name:match('Landscape')and 'AuthoredTerrain' or p.Name:match('^Source')and 'GazeboAndFurnishings' or p.Name:match('^Wing')and 'ForestWings' or 'ForegroundVegetation'
  if group=='BakedDistantForest' then
   p.Size=Vector3.new(p.Size.X*.65,1100,p.Size.Z*.65);center=Vector3.new(center.X*.65,650,340+(center.Z-340)*.65);p.CFrame=basis*CFrame.new(center)
   local sa=Instance.new('SurfaceAppearance');sa.ColorMap=p.TextureID;sa.RoughnessMap='rbxassetid://113355786572368';sa.Parent=p;p.TextureID=''
   local cap=p:Clone();cap:ClearAllChildren();cap.Name=p.Name..'_MistSky';cap.Size=Vector3.new(p.Size.X*1.006,2048,p.Size.Z*1.006);cap.CFrame=p.CFrame+Vector3.new(0,1050,0)+Vector3.new(p.Position.X,0,p.Position.Z).Unit*4;cap.Color=Color3.fromRGB(193,217,216);cap.TextureID='';cap.Parent=groups[group]
  end
  if p.Name:match('_leaf$') then local sa=Instance.new('SurfaceAppearance');sa.ColorMap=p.TextureID;sa.AlphaMode=Enum.AlphaMode.Transparency;sa.Parent=p;p.TextureID='' end
  p.Parent=groups[group]
  if i%12==0 then task.wait()end
 end end
 local hero=groups.GazeboAndFurnishings;hero.WorldPivot=hero.Source_Cube_074.CFrame;hero:ScaleTo(1.25)
 lab:SetAttribute('FoggyGazeboRevision',1)
 lab:SetAttribute('ValleySectorRevision',1)
 root:SetAttribute('RemovedLegacyRoots',#removed>0 and table.concat(removed,', ') or prior or 'EastValleySector; LandscapeGroup1/4/10; four overlapping legacy mountains')
 return {removed=removed,templates=#sorted}
end
return Builder
