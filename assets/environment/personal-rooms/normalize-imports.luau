return function(data)
	assert(game.PlaceId == 94763223427049 and not game:GetService("RunService"):IsRunning())
	local library=game.ServerStorage:FindFirstChild("PersonalRoomAssets") or Instance.new("Folder")
	library.Name,library.Parent="PersonalRoomAssets",game.ServerStorage
	local function v(a)return Vector3.new(table.unpack(a))end
	local report={}
	for _,name in {"LabTable","CareBench","ArchiveDesk"}do
		local m=assert(game.ServerStorage:FindFirstChild(name))
		local expected=data[name]
		local parts={}
		for _,p in m:GetDescendants()do
			assert(not p:IsA("LuaSourceContainer"),"Unexpected imported source")
			if p:IsA("PackageLink")then p:Destroy()end
			if p:IsA("BasePart")then table.insert(parts,p)end
		end
		table.sort(parts,function(a,b)return a.Name<b.Name end)
		assert(#parts==#expected.primitives)
		m.PrimaryPart=nil
		local cf,size=m:GetBoundingBox()
		local factor=v(expected.size).Magnitude/size.Magnitude
		assert((size*factor-v(expected.size)).Magnitude<.1,"Proportions mismatch")
		m.WorldPivot=cf
		m:ScaleTo(m:GetScale()*factor)
		m:PivotTo(CFrame.new(v(expected.center))*CFrame.Angles(0,math.pi,0))
		m.WorldPivot=CFrame.identity
		local used,records={},{}
		for _,p in parts do
			local best,score=nil,math.huge
			for i,r in expected.primitives do
				if not used[i]then
					local error=(p.Size-v(r.size)).Magnitude+(p.Position-v(r.center)).Magnitude
					if error<score then best,score=i,error end
				end
			end
			assert(best and score<.12,"Mesh correspondence: "..name.." "..tostring(score))
			used[best]=true
			local r=expected.primitives[best]
			p.Color=Color3.fromRGB(table.unpack(r.colorSrgb))
			if name=="CareBench" and r.primitive==1 then p.Color=Color3.fromRGB(100,121,102)end
			p.Material=Enum.Material.SmoothPlastic
			p.Anchored,p.CanCollide,p.CanTouch,p.CanQuery=true,true,false,true
			p.CollisionFidelity=Enum.CollisionFidelity.Hull
			p:SetAttribute("SourcePrimitive",best)
			table.insert(records,{name=p.Name,meshId=p.MeshId,color={p.Color.R,p.Color.G,p.Color.B},error=score})
		end
		m:SetAttribute("Source","Kenney CC0; see assets/environment/personal-rooms")
		m:SetAttribute("NormalizedFromExport",true)
		m.Parent=library
		report[name]=records
	end
	return report
end
