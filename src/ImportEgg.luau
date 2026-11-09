-- Edit-time integration of persistent assets from the Studio FBX importer.
local I = {}
function I.Build(manifest)
	assert(not game:GetService("RunService"):IsRunning(), "Stop Play before import")
	local found = {}
	for _, o in workspace:GetDescendants() do
		if
			o:IsA("MeshPart")
			and o.Name:match("^L[123]_R%d%d$")
			and not o:IsDescendantOf(workspace.VesperLab)
		then
			found[o.Name] = o
		end
	end
	if next(found) == nil then
		local existing = game.ServerStorage:FindFirstChild("EggPlateLibrary")
		if existing then
			for _, o in existing:GetChildren() do
				if o:IsA("MeshPart") then
					found[o.Name] = o
				end
			end
		end
	end
	for _, t in manifest.templates do
		assert(found[t.name], "Missing imported template: " .. t.name)
		assert(found[t.name].MeshId:match("%d+"), "Mesh upload incomplete: " .. t.name)
	end
	local shared = game.ReplicatedStorage.VesperShared
	local config = require(shared.ExcavationConfig)
	local base = config.Geometry.Base
	local library = Instance.new("Folder")
	library.Name = "EggPlateLibrary_New"
	library.Parent = game.ServerStorage
	local dormant = Instance.new("Folder")
	dormant.Name = "EggDormant_New"
	dormant.Parent = game.ServerStorage
	local sections = Instance.new("Folder")
	sections.Name = "Sections_New"
	sections.Parent = workspace.VesperLab.Egg
	for _, t in manifest.templates do
		local template = found[t.name]:Clone()
		template.Name = t.name
		template.Size = Vector3.new(unpack(t.size))
		template.CFrame = CFrame.new(base + Vector3.new(unpack(t.center))) * CFrame.Angles(0, math.pi, 0)
		template.PivotOffset = CFrame.identity
		template.Anchored, template.CanTouch, template.CastShadow = true, false, false
		template.Parent = library
		local li, row = t.name:match("L(%d)_R(%d+)")
		li, row = tonumber(li), tonumber(row)
		local layer = config.Layers[li]
		template.Color = layer.Color
		template.Material = Enum.Material.SmoothPlastic
		if li == 1 and manifest.colorMaps then
			local old = template:FindFirstChildOfClass("SurfaceAppearance")
			if old then
				old:Destroy()
			end
			local finish = Instance.new("SurfaceAppearance")
			finish.Name = "ShellFinish"
			finish.ColorMap = manifest.colorMaps[row + 1]
			finish.RoughnessMap = manifest.roughnessMap
			finish.Parent = template
			template.Color = Color3.new(1, 1, 1)
		end
		for col = 0, manifest.columns - 1 do
			local angle = (col + (row % 2) * 0.5) * math.pi * 2 / manifest.columns
			local rotation = CFrame.new(base) * CFrame.Angles(0, angle, 0) * CFrame.new(-base)
			local id = string.format("L%d_R%02d_C%02d", li, row, col)
			local m = Instance.new("Model")
			m.Name = id
			for k, v in
				{
					SectionId = id,
					Layer = li,
					Row = row,
					Column = col,
					Resource = layer.Id,
					Intact = true,
					HP = layer.Durability,
					Center = rotation:PointToWorldSpace(base + Vector3.new(unpack(t.surfaceCenter))),
				}
			do
				m:SetAttribute(k, v)
			end
			local p = template:Clone()
			p.CFrame = rotation * template.CFrame
			p:SetAttribute("SectionId", id)
			p.CanCollide, p.CanQuery = li == 1, li == 1
			if li == 1 then
				p.Name = "Plate"
				p.Parent = m
			else
				p.Name = id
				p.Parent = dormant
			end
			m.Parent = sections
		end
		task.wait()
	end
	for _, pair in
		{
			{ workspace.VesperLab.Egg, "Sections", sections },
			{ game.ServerStorage, "EggDormant", dormant },
			{ game.ServerStorage, "EggPlateLibrary", library },
		}
	do
		local old = pair[1]:FindFirstChild(pair[2])
		if old then
			old:Destroy()
		end
		pair[3].Name = pair[2]
	end
	local egg = workspace.VesperLab.Egg
	egg:SetAttribute("SectionCount", manifest.columns * manifest.rows * 3)
	egg:SetAttribute("SurfaceCount", manifest.columns * manifest.rows)
	egg:SetAttribute("ShapeLibraryCount", #manifest.templates)
	egg:SetAttribute("AssetVersion", "BlenderShell01")
	local oldPreload = shared:FindFirstChild("EggAssetPreload")
	if oldPreload then
		oldPreload:Destroy()
	end
	local preload = library:Clone()
	preload.Name = "EggAssetPreload"
	preload.Parent = shared
	local state = shared.RoundState
	state:SetAttribute("LayerRemaining", manifest.columns * manifest.rows)
	state:SetAttribute("LayerTotal", manifest.columns * manifest.rows)
	state:SetAttribute("TotalSections", manifest.columns * manifest.rows * 3)
	state:SetAttribute("ActiveLayer", 1)
	state:SetAttribute("Progress", 0)
	for _, p in found do
		p:Destroy()
	end
	return { sections = manifest.columns * manifest.rows * 3, templates = #manifest.templates }
end
return I
