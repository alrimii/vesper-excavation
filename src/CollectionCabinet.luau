-- One shared Edit/runtime shelf recipe; discovery ownership stays in existing profiles.
local M = {}
local Shared = game.ReplicatedStorage.VesperShared
local Rules = require(Shared.ProgressionRules)
function M.Place(model, pedestal)
	local _, size = model:GetBoundingBox()
	model:ScaleTo(model:GetScale() * 5.6 / math.max(size.X, size.Y, size.Z))
	local bounds, scaled = model:GetBoundingBox()
	model:PivotTo(pedestal.CFrame * CFrame.new(0, pedestal.Size.Y/2 + scaled.Y/2 + 0.05, 0)
		* CFrame.Angles(0, math.pi, 0) * bounds:ToObjectSpace(model:GetPivot()))
end
function M.Build(room)
	local old = room:FindFirstChild("CollectionShelf")
	if old then old:Destroy() end
	local model = Instance.new("Model")
	model.Name = "CollectionShelf"
	local basis = room:GetPivot() * CFrame.new(-39.1, 0, 5) * CFrame.Angles(0, -math.pi/2, 0)
	local floor = room:GetPivot():PointToObjectSpace(room.Floor.Position).Y + room.Floor.Size.Y/2
	local rows = math.max(2, math.ceil(#Rules.CreatureVariants/3))
	local cream, steel, dark = Color3.fromRGB(211,202,176), Color3.fromRGB(74,108,111), Color3.fromRGB(37,51,57)
	local function part(name, size, pos, color, collide)
		local p = Instance.new("Part")
		p.Name, p.Size, p.CFrame = name, size, basis*CFrame.new(pos)
		p.Color, p.Material = color, Enum.Material.SmoothPlastic
		p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery = true, collide == true, false, false
		p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
		p.Parent = model
		return p
	end
	local function label(p, value, size)
		local gui = Instance.new("SurfaceGui")
		gui.Name, gui.Face, gui.CanvasSize = "Identification", Enum.NormalId.Front, Vector2.new(600,100)
		gui.LightInfluence, gui.MaxDistance = 0, 70
		gui.Parent = p
		local t = Instance.new("TextLabel")
		t.Size, t.BackgroundTransparency = UDim2.fromScale(1,1), 1
		t.Text, t.TextSize, t.Font = value, size, Enum.Font.GothamBold
		t.TextColor3, t.TextWrapped = cream, true
		t.Parent = gui
		return t
	end
	local top = floor + rows*8 + 1.6
	part("WallBack", Vector3.new(29,top-floor,0.35), Vector3.new(0,(floor+top)/2,2.8), steel)
	for _, x in {-14.6,-4.85,4.85,14.6} do
		part("ShelfUpright",Vector3.new(0.3,top-floor,6),Vector3.new(x,(floor+top)/2,0),cream,true)
	end
	local slots = {}
	for row=0,rows-1 do
		local y = floor+0.6+row*8
		part("ShelfDeck",Vector3.new(29.5,0.35,6),Vector3.new(0,y,0),cream,true)
		for col=1,3 do
			local index, x = row*3+col,(col-2)*9.7
			local entry = Rules.CreatureVariants[index]
			local pedestal = part("Display"..index,Vector3.new(8.7,0.18,5.3),Vector3.new(x,y+0.27,0),dark)
			local plaque = part("Plaque"..index,Vector3.new(8.7,0.95,0.15),Vector3.new(x,y+1,-3),steel)
			local text = label(plaque,entry and "UNDISCOVERED" or "ROOM TO GROW",28)
			local accent = part("RarityAccent"..index,Vector3.new(8.7,0.1,0.12),Vector3.new(x,y+0.42,-2.7),steel)
			if entry then table.insert(slots,{part=pedestal,accent=accent,label=text,entry=entry}) end
		end
	end
	part("Crown",Vector3.new(29.5,0.4,6),Vector3.new(0,top,0),cream,true)
	label(part("Title",Vector3.new(27,1.6,0.3),Vector3.new(0,top+1,-2.6),steel),"DISCOVERIES",44)
	model.Parent=room
	return {model=model,slots=slots,basis=basis}
end
function M.Refresh(display, owner)
	for _, slot in display.slots do
		local entry=slot.entry
		local known=owner ~= nil and (owner:GetAttribute("Creature_"..entry.Id) or 0)>0
		local favorite=false
		for i=1,3 do favorite=favorite or (known and owner:GetAttribute("DisplaySlot"..i)==entry.Id) end
		slot.label.Text=known and (entry.Name.."\n"..entry.Rarity..(favorite and " / FAVORITE" or "")) or "UNDISCOVERED"
		slot.label.TextColor3=known and entry.Color or Color3.fromRGB(192,200,199)
		slot.accent.Color=known and entry.Color or Color3.fromRGB(74,108,111)
		local key=entry.Id..tostring(known)
		if slot.id~=key then
			if slot.model then slot.model:Destroy() end
			local specimen=require(Shared.SpecimenBuilder).Build("crownback")
			for _, p in specimen:GetDescendants() do
				if not known and (p:IsA("SurfaceAppearance") or p:IsA("Texture") or p:IsA("Decal")) then p:Destroy()
				elseif p:IsA("BasePart") then
					p.CanCollide,p.CanTouch,p.CanQuery=false,false,false
					if known then
						p.Color=p.Color:Lerp(entry.Color,0.35)
						local appearance=p:FindFirstChildOfClass("SurfaceAppearance")
						if appearance then appearance.Color=entry.Color end
					else
						p.Color,p.Material,p.Reflectance=Color3.fromRGB(24,35,41),Enum.Material.SmoothPlastic,0
						if p:IsA("MeshPart") then p.TextureID="" end
					end
				end
			end
			M.Place(specimen,slot.part)
			specimen.Name=known and entry.Id or "Undiscovered_"..entry.Id
			specimen.Parent,slot.model,slot.id=display.model,specimen,key
		end
	end
end
return M
