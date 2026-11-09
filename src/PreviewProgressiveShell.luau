-- Temporary static asset comparison; does not start gameplay.
local previous = workspace:FindFirstChild("TemporaryFractureAssetReview")
if previous then
	previous:Destroy()
end
local model = Instance.new("Model")
model.Name = "TemporaryFractureAssetReview"
local source = game.ReplicatedStorage.VesperShared.EggAssetPreload.L1_R18
local original = workspace.VesperLab.Egg.Sections.L1_R18_C00.Plate
local function matchFinish(p)
	local old = p:FindFirstChildOfClass("SurfaceAppearance")
	if old then
		old:Destroy()
	end
	local finish = original:FindFirstChildOfClass("SurfaceAppearance")
	if finish then
		finish:Clone().Parent = p
	end
	p.TextureID = original.TextureID
end
for index, damage in { 0, 0.14, 0.5, 0.85 } do
	local target = CFrame.new(1000, 100, (index - 2.5) * 4.5) * source.CFrame.Rotation
	local transform = target * source.CFrame:Inverse()
	if damage == 0 then
		local p = source:Clone()
		p.CFrame = target
		p.Color, p.Material, p.MaterialVariant = original.Color, original.Material, original.MaterialVariant
		matchFinish(p)
		p.Parent = model
	else
		local lining = source:Clone()
		lining.CFrame = target - Vector3.xAxis * 0.06
		lining.Color = original.Color:Lerp(Color3.fromRGB(31, 24, 18), 0.82)
		lining.Material = Enum.Material.SmoothPlastic
		lining.MaterialVariant, lining.TextureID = "", ""
		for _, child in lining:GetChildren() do
			if child:IsA("SurfaceAppearance") then
				child:Destroy()
			end
		end
		lining.Parent = model
		for _, template in game.ServerStorage.ProgressiveOuterShellStaging.L1_R18:GetChildren() do
			local p = template:Clone()
			local center = p:GetAttribute("FractureCenter")
			local distance = center.Magnitude / (source.Size.Magnitude * 0.55)
			local threshold = 0.015 + math.clamp(distance, 0, 1) * 0.48 + p:GetAttribute("CrackSeed") * 0.12
			local localDamage = damage * 1.35
			local opening = math.clamp((localDamage - threshold) / 0.34, 0, 1)
			local gap = 0.025 * opening + 0.075 * localDamage * opening
			p.CFrame = transform * p.CFrame
				+ target:VectorToWorldSpace(p:GetAttribute("FractureDirection")) * gap
			p.Color, p.Material, p.MaterialVariant =
				original.Color, original.Material, original.MaterialVariant
			matchFinish(p)
			p.Parent = model
		end
	end
end
model.Parent = workspace
return "Static comparison only: intact, light damage, medium damage, heavy damage."
