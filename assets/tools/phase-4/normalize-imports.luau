-- Run once after importing the recorded owned Model IDs into ServerStorage with these names.
-- Normalizes imported axes/materials; ToolPresentationBuilder owns all active representations.
assert(not game:GetService("RunService"):IsRunning(), "Edit mode only")
local ss = game.ServerStorage
assert(not ss:FindFirstChild("ToolPresentationAssets"), "Canonical assets already installed")
local records = game:GetService("HttpService"):JSONDecode(
	[==[[{"family":"pickaxe","parts":[{"name":"PickGrip","triangles":136,"center":[0.03203538805246353,-0.36604034900665283,-1.4901161193847656e-8],"size":[0.21535880863666534,1.298515796661377,0.13394033908843994],"linearColor":[0.02500000037252903,0.03500000014901161,0.03200000151991844,1]},{"name":"PickTimber","triangles":40,"center":[0.032035842537879944,1.5339596271514893,-1.4901161193847656e-8],"size":[0.1949828565120697,2.501483917236328,0.129052996635437],"linearColor":[0.3100000023841858,0.12999999523162842,0.054999999701976776,1]},{"name":"PickSteel","triangles":144,"center":[-0.011339545249938965,2.5801684856414795,-1.4901161193847656e-8],"size":[2.5686159133911133,0.3723025321960449,0.266790509223938],"linearColor":[0.2800000011920929,0.3400000035762787,0.36000001430511475,1]}]},{"family":"dynamite","parts":[{"name":"SurveyDynamite","triangles":642,"center":[0,0.22297799587249756,0],"size":[0.8031110167503357,1.6576519012451172,0.8031110167503357],"linearColor":[0.800000011920929,0.800000011920929,0.800000011920929,1]}]}]]==]
)
local root = Instance.new("Folder")
root.Name = "ToolPresentationAssets"
root:SetAttribute("DrillBodyTexture", "rbxassetid://100714057797210")
local specs = {
	pickaxe = { "Phase4PickaxeImport", "FieldPickaxe", "https://poly.pizza/m/u4HkEYF35S", "Pichuliru", "CC0" },
	dynamite = {
		"Phase4DynamiteImport",
		"SurveyDynamite",
		"https://poly.pizza/m/HvLXdxqAkB",
		"Neko",
		"CC BY 3.0",
	},
}
local function vec(a)
	return Vector3.new(a[1], a[2], a[3])
end
local function srgb(v)
	return v <= 0.0031308 and 12.92 * v or 1.055 * v ^ (1 / 2.4) - 0.055
end
for _, record in records do
	local spec = specs[record.family]
	local imported = assert(ss:FindFirstChild(spec[1]), "Import recorded model first: " .. spec[1])
	local model = Instance.new("Model")
	model.Name = spec[2]
	for _, part in record.parts do
		local source = assert(imported:FindFirstChild(part.name, true), part.name)
		assert(source:IsA("MeshPart"))
		local p = source:Clone()
		for _, d in p:GetDescendants() do
			if
				d:IsA("PackageLink")
				or d:IsA("LuaSourceContainer")
				or d:IsA("JointInstance")
				or d:IsA("WeldConstraint")
				or d:IsA("Constraint")
			then
				d:Destroy()
			end
		end
		p.Size = vec(part.size)
		p.CFrame = CFrame.new(vec(part.center))
		p.Anchored = true
		p.CanCollide = false
		p.CanTouch = false
		p.CanQuery = false
		p.CastShadow = false
		local c = part.linearColor
		p.Color = record.family == "pickaxe" and Color3.new(srgb(c[1]), srgb(c[2]), srgb(c[3]))
			or Color3.new(1, 1, 1)
		p.Material = part.name == "PickSteel" and Enum.Material.Metal or Enum.Material.SmoothPlastic
		p.Parent = model
	end
	model.WorldPivot = CFrame.identity
	model:SetAttribute("SourceUrl", spec[3])
	model:SetAttribute("SourceAuthor", spec[4])
	model:SetAttribute("License", spec[5])
	model.Parent = root
	imported:Destroy()
end
root.Parent = ss
return "Finished sources normalized; use ToolPresentationBuilder.Build()"
