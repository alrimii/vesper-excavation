-- Run after the single native FBX import has uploaded the Blender assets.
assert(not game:GetService("RunService"):IsRunning(), "Stop Play before installing assets")
local shared = game.ReplicatedStorage.VesperShared
local copy = shared.ExcavationConfig:Clone()
copy.Parent = game.ServerStorage
local C = require(copy)
copy:Destroy()
local http = game:GetService("HttpService")
local oldHttp = http.HttpEnabled
http.HttpEnabled = true
local ok, body = pcall(http.GetAsync, http, "http://127.0.0.1:8767/excavation-v2/egg-manifest.json")
http.HttpEnabled = oldHttp
assert(ok, body)
local manifest = http:JSONDecode(body)
local found = {}
for _, p in workspace:GetDescendants() do
	if p:IsA("MeshPart") and p.Name:match("^L[123]_R%d%d") and not p:IsDescendantOf(workspace.VesperLab) then
		found[p.Name] = p
	end
end
for _, t in manifest.templates do
	assert(found[t.name] and found[t.name].MeshId:match("%d+"), "Missing uploaded mesh: " .. t.name)
	for i = 1, 3 do
		assert(found[t.name .. "_F" .. i], "Missing fracture: " .. t.name .. "_F" .. i)
	end
end
local base = C.Geometry.Base
local function vec(v)
	return Vector3.new(v[1], v[2], v[3])
end
local function folder(name, parent)
	local f = Instance.new("Folder")
	f.Name = name
	f.Parent = parent
	return f
end
local staging = folder("ExcavationV2Staging", game.ServerStorage)
local plates = folder("EggPlateLibrary", staging)
local sections = folder("Sections", staging)
local fractures = folder("FractureLibrary", staging)
for _, t in manifest.templates do
	local li, row = t.name:match("L(%d)_R(%d+)")
	li, row = tonumber(li), tonumber(row)
	local layer = C.Layers[li]
	local source = found[t.name]
	local p = source:Clone()
	p:ClearAllChildren()
	p.Name = t.name
	p.Size = vec(t.size)
	p.CFrame = CFrame.new(base + vec(t.center)) * CFrame.Angles(0, math.pi, 0)
	p.PivotOffset = CFrame.identity
	p.Anchored = true
	p.CanTouch = false
	p.CastShadow = true
	p.Material = layer.Material
	p.Color = layer.Color
	p.TextureID = li == 1 and C.Appearance.ShellIntact or ""
	p.Parent = plates
	for col = 0, manifest.columns - 1 do
		local rot = CFrame.new(base)
			* CFrame.Angles(0, (col + (row % 2) * 0.5) * math.pi * 2 / manifest.columns, 0)
			* CFrame.new(-base)
		local s = Instance.new("Model")
		s.Name = string.format("L%d_R%02d_C%02d", li, row, col)
		local permanent = row < C.Geometry.PermanentRows
		for k, v in
			{
				SectionId = s.Name,
				Layer = li,
				Row = row,
				Column = col,
				Resource = layer.Id,
				Intact = true,
				HP = layer.Durability,
				Center = rot:PointToWorldSpace(base + vec(t.surfaceCenter)),
				Permanent = permanent,
				Exposed = li == 1 and not permanent,
			}
		do
			s:SetAttribute(k, v)
		end
		local part = p:Clone()
		part.Name = "Plate"
		part.CFrame = rot * p.CFrame
		part:SetAttribute("SectionId", s.Name)
		part.CanCollide = true
		part.CanQuery = true
		part.Parent = s
		s.Parent = sections
	end
	local f = folder(t.name, fractures)
	for i = 1, 3 do
		local fragment = found[t.name .. "_F" .. i]:Clone()
		fragment:ClearAllChildren()
		-- Metadata is set below from the Blender fracture manifest, independent of import scale.
		fragment.Name = t.name .. "_F" .. i
		fragment.Anchored = true
		fragment.CanCollide = false
		fragment.CanQuery = false
		fragment.CanTouch = false
		fragment.Parent = f
	end
	task.wait()
end
oldHttp = http.HttpEnabled
http.HttpEnabled = true
ok, body = pcall(http.GetAsync, http, "http://127.0.0.1:8767/excavation-v2/fracture-manifest.json")
http.HttpEnabled = oldHttp
assert(ok, body)
for _, r in http:JSONDecode(body) do
	local p = fractures[r.template][r.name]
	local whole = plates[r.template]
	p.Size = vec(r.size)
	p.CFrame = CFrame.new(base + vec(r.center)) * CFrame.Angles(0, math.pi, 0)
	p.PivotOffset = CFrame.identity
	p.Color = whole.Color
	p.Material = whole.Material
	p.TextureID = whole.TextureID
	p.CastShadow = false
	local normal = (whole.Position - (base + Vector3.new(0, C.Geometry.Height / 2, 0)))
	normal = Vector3.new(normal.X, normal.Y * 0.65, normal.Z).Unit
	local delta = p.Position - whole.Position
	delta -= normal * delta:Dot(normal)
	p:SetAttribute("RelativeCFrame", whole.CFrame:ToObjectSpace(p.CFrame))
	p:SetAttribute(
		"FractureDirection",
		whole.CFrame:VectorToObjectSpace(delta.Magnitude > 0.001 and delta.Unit or Vector3.yAxis)
	)
	p:SetAttribute("SurfaceNormal", p.CFrame:VectorToObjectSpace(normal))
	p:SetAttribute("RestHeight", 0.25)
end
local egg = workspace.VesperLab.Egg
for _, pair in
	{
		{ egg, "Sections", sections },
		{ game.ServerStorage, "EggPlateLibrary", plates },
		{ shared, "FractureLibrary", fractures },
	}
do
	local old = pair[1]:FindFirstChild(pair[2])
	if old then
		old:Destroy()
	end
	pair[3].Parent = pair[1]
end
local preload = shared:FindFirstChild("EggAssetPreload")
if preload then
	preload:Destroy()
end
preload = plates:Clone()
preload.Name = "EggAssetPreload"
preload.Parent = shared
game.ServerStorage.EggDormant:ClearAllChildren()
staging:Destroy()
egg:SetAttribute("SectionCount", 576)
egg:SetAttribute("BreakableSections", 432)
egg:SetAttribute("AssetVersion", "BlenderShell02")
-- Fitted spiral access: a broad, continuous route to every breakable height.
local access = workspace.VesperLab.ExcavationAccess
access:ClearAllChildren()
local function path(t, offset)
	local y = 3.15 + t * 56
	local phi = math.acos(math.clamp(1 - 2 * (y + 2 - base.Y) / C.Geometry.Height, -1, 1))
	local r = C.Geometry.Radius * math.sin(phi) * (1 + 0.18 * math.cos(phi)) + 5.5 + offset
	local a = t * math.pi * 9
	return Vector3.new(math.cos(a) * r, y, math.sin(a) * r)
end
for i = 0, 319 do
	local a, b = path(i / 320, 0), path((i + 1) / 320, 0)
	local p = Instance.new("Part")
	p.Name = "ServiceRamp"
	p.Anchored = true
	p.Size = Vector3.new(7, 0.3, (b - a).Magnitude + 0.18)
	p.CFrame = CFrame.lookAt((a + b) / 2, b)
	p.Material = Enum.Material.DiamondPlate
	p.Color = Color3.fromRGB(58, 69, 77)
	p.Parent = access
	local c, d =
		path(i / 320, 3.3) + Vector3.new(0, 2.7, 0), path((i + 1) / 320, 3.3) + Vector3.new(0, 2.7, 0)
	local rail = Instance.new("Part")
	rail.Name = "SafetyRail"
	rail.Anchored = true
	rail.CanQuery = false
	rail.Size = Vector3.new(0.14, 0.14, (d - c).Magnitude + 0.1)
	rail.CFrame = CFrame.lookAt((c + d) / 2, d)
	rail.Color = Color3.fromRGB(212, 159, 66)
	rail.Material = Enum.Material.Metal
	rail.Parent = access
	if i % 80 == 0 then
		task.wait()
	end
end
for _, p in found do
	p:Destroy()
end
return { breakable = 432, perLayer = 144, permanent = 144, templates = #plates:GetChildren(), fractures = 108 }
