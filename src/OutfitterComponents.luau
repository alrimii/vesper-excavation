-- Shop-only visual vocabulary. No HUD/tree dependencies and no flattened clickable artwork.
local M={}
M.Ink=Color3.fromRGB(62,42,32)
M.Wood=Color3.fromRGB(108,63,41)
M.Paper=Color3.fromRGB(247,231,197)
M.Pale=Color3.fromRGB(255,246,219)
M.Sand=Color3.fromRGB(221,196,154)
M.Gold=Color3.fromRGB(235,174,66)
M.Green=Color3.fromRGB(68,113,86)
M.Muted=Color3.fromRGB(114,93,71)
M.Error=Color3.fromRGB(155,53,41)
M.Heading=Enum.Font.FredokaOne
M.Body=Enum.Font.GothamMedium
function M.Make(class,parent,properties)
	local o=Instance.new(class)
	for k,v in properties do o[k]=v end
	o.Parent=parent
	return o
end
function M.Surface(parent,name,color,radius)
	local f=M.Make("Frame",parent,{Name=name,BackgroundColor3=color or M.Paper,BorderSizePixel=0})
	M.Make("UICorner",f,{CornerRadius=UDim.new(0,radius or 12)})
	return f
end
function M.Edge(o,color,width)
	return M.Make("UIStroke",o,{Color=color or M.Ink,Thickness=width or 2,ApplyStrokeMode=Enum.ApplyStrokeMode.Border})
end
function M.Text(parent,name,value,size,color,heading)
	return M.Make("TextLabel",parent,{Name=name,Text=value,TextSize=size or 18,TextColor3=color or M.Ink,
		Font=heading and M.Heading or M.Body,BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,
		TextYAlignment=Enum.TextYAlignment.Center,TextWrapped=true})
end
function M.Icon(parent,name,id)
	return M.Make("ImageLabel",parent,{Name=name,Image=id,BackgroundTransparency=1,ScaleType=Enum.ScaleType.Fit})
end
function M.Button(parent,name,value,color)
	local b=M.Make("TextButton",parent,{Name=name,Text=value,TextSize=19,TextColor3=M.Pale,Font=M.Heading,
		BackgroundColor3=color or M.Green,BorderSizePixel=0,AutoButtonColor=true,Selectable=true})
	M.Make("UICorner",b,{CornerRadius=UDim.new(0,10)})
	M.Edge(b,M.Ink,2)
	return b
end
function M.Preview(parent,source)
	local v=M.Make("ViewportFrame",parent,{Name="ActualEquipment",BackgroundTransparency=1,
		Ambient=Color3.fromRGB(198,187,160),LightColor=Color3.fromRGB(255,237,197),LightDirection=Vector3.new(-1,-1,-1)})
	local world=M.Make("WorldModel",v,{Name="Display"})
	local model=M.Make("Model",world,{Name=source.Name})
	for _,p in source:GetDescendants() do if p:IsA("BasePart") and p.Transparency<1 then
		local c=p:Clone()
		for _,child in c:GetDescendants() do
			if child:IsA("JointInstance") or child:IsA("Constraint") or child:IsA("LuaSourceContainer")
				or child:IsA("BasePart") or child:IsA("ParticleEmitter") or child:IsA("Light") then child:Destroy() end
		end
		c.Anchored,c.CanCollide,c.CanTouch,c.CanQuery=true,false,false,false
		c.Parent=model
	end end
	local cf,size=model:GetBoundingBox()
	model:PivotTo(CFrame.new(-cf.Position)*model:GetPivot())
	local camera=M.Make("Camera",v,{FieldOfView=32})
	-- Upright, large, three-quarter view of the actual equipped asset. No invented tier.
	camera.CFrame=CFrame.lookAt(Vector3.new(0.65,0.25,-1).Unit*math.max(size.X,size.Y,size.Z)*1.85,Vector3.zero)
	v.CurrentCamera=camera
	local function fit()
		local ratio=v.AbsoluteSize.X/math.max(1,v.AbsoluteSize.Y)
		local span=math.max(size.Y,size.X/math.max(0.5,ratio),size.Z)
		camera.CFrame=CFrame.lookAt(Vector3.new(0.65,0.25,-1).Unit*span*1.85,Vector3.zero)
	end
	v:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
	return v
end
return M
