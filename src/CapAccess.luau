local access=workspace.VesperLab.ExcavationAccess
for _,p in access:GetChildren() do if p.Name=="CapWalkway" then p:Destroy() end end
for i=0,63 do
 local a=i/64*math.pi*2 local b=(i+1)/64*math.pi*2
 local x=Vector3.new(math.cos(a)*16,52,math.sin(a)*16)
 local y=Vector3.new(math.cos(b)*16,52,math.sin(b)*16)
 local p=Instance.new("Part") p.Name="CapWalkway" p.Anchored=true p.Size=Vector3.new(5,0.25,(y-x).Magnitude+0.1)
 p.CFrame=CFrame.lookAt((x+y)/2,y) p.Color=Color3.fromRGB(58,69,77) p.Material=Enum.Material.DiamondPlate p.Parent=access
end
return "Cap access installed"
