-- Edit-time only. Installs persistent, Blender-authored outer fragments.
local shared = game.ReplicatedStorage.VesperShared
local archive = game.ServerStorage.RoomRebuildArchive
local originalLibrary = archive.FracturesBeforeVoronoi
local http = game:GetService("HttpService")
local enabled = http.HttpEnabled
http.HttpEnabled = true
local fetched, body = pcall(http.GetAsync, http, "http://127.0.0.1:8780/outer-fragments.json")
http.HttpEnabled = enabled
assert(fetched, body)
local manifest = http:JSONDecode(body)
assert(#manifest == 90)
local staged = Instance.new("Folder")
staged.Name = "OuterShellStage1"
for _, r in manifest do
	local previous = originalLibrary[r.template][r.name]
	assert(previous.MeshId:match("rbxassetid://"), r.name)
	local original = workspace.VesperLab.Egg.Sections[r.template .. "_C00"].Plate
	-- Fragment offsets belong to the unrotated asset template. Odd world rows
	-- already include a half-column stagger, which must not enter this offset.
	local restTemplate = shared.EggAssetPreload[r.template]
	local group = staged:FindFirstChild(r.template)
	if not group then
		group = Instance.new("Folder")
		group.Name = r.template
		group.Parent = staged
	end
	local p = previous:Clone()
	p.Size = Vector3.new(unpack(r.size))
	p.CFrame = CFrame.new(Vector3.new(unpack(r.center)) + Vector3.new(0, -10.2, 0))
		* CFrame.Angles(0, math.pi, 0)
	p.PivotOffset = CFrame.identity
	p:SetAttribute("RelativeCFrame", restTemplate.CFrame:ToObjectSpace(p.CFrame))
	p.Color, p.Material, p.MaterialVariant = original.Color, original.Material, original.MaterialVariant
	p.Reflectance, p.TextureID, p.CastShadow = original.Reflectance, original.TextureID, original.CastShadow
	local old = p:FindFirstChildOfClass("SurfaceAppearance")
	if old then old:Destroy() end
	local finish = original:FindFirstChildOfClass("SurfaceAppearance")
	if finish then finish:Clone().Parent = p end
	p.Anchored = true
	p.CanCollide, p.CanTouch, p.CanQuery = false, false, false
	p.Transparency, p.LocalTransparencyModifier = 0, 0
	p:SetAttribute("OuterShellStage", 1)
	p.Parent = group
end
assert(#staged:GetChildren() == 30)
local backup = Instance.new("Folder")
backup.Name = "OuterShellBeforeStage1"
assert(not archive:FindFirstChild(backup.Name), "Stage 1 already installed")
backup.Parent = archive
for _, group in staged:GetChildren() do
	assert(#group:GetChildren() == 3, group.Name)
	shared.FractureLibrary[group.Name].Parent = backup
	group.Parent = shared.FractureLibrary
end
staged:Destroy()
shared.FractureLibrary:SetAttribute("OuterShellRevision", "Stage1_PersistentMatchedFragments")
return { templates = 30, persistentFragments = 90, innerLayersChanged = false }
