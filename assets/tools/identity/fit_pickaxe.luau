-- Edit-only fit of the authenticated imported PK-001 model using geometry.json.
-- No reconstruction or modification of authored vertices. Pass decoded metadata.
return function(model, data)
 assert(not game:GetService('RunService'):IsRunning(), 'Edit only')
 for _,x in model:GetDescendants() do if x:IsA('PackageLink') then x:Destroy() end end
 local shaftX=0
 for _,r in data.primitives do if r.name=='PK-001.SHAFT' then shaftX=r.center[1] end end
 local colors={body=Color3.fromRGB(52,134,176),edge=Color3.fromRGB(194,238,249),trim=Color3.fromRGB(255,188,53),shaft=Color3.fromRGB(165,97,47),inset=Color3.fromRGB(30,48,75),grip=Color3.fromRGB(35,46,67),wrap=Color3.fromRGB(190,112,58)}
 for _,r in data.primitives do
  local p=model:FindFirstChild(r.name,true);assert(p and p:IsA('MeshPart'),r.name)
  p.CFrame=CFrame.new(r.center[1]-shaftX,r.center[2],r.center[3]);p.Size=Vector3.new(unpack(r.size))
  p.Color=colors[r.material:match('([^_]+)$')] or Color3.fromRGB(unpack(r.color))
  p.Material=Enum.Material.SmoothPlastic;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false
  p:SetAttribute('AuthoredMaterial',r.material)
 end
 return Vector3.new(data.strikeTip[1]-shaftX,data.strikeTip[2],data.strikeTip[3])
end
