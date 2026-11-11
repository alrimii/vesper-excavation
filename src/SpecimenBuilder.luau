local B = {}
function B.Source(id)
	local assets = script.Parent:WaitForChild("SpecimenAssets")
	local source = assets:FindFirstChild(id)
	if not source then
		local entry = require(script.Parent.ProgressionRules).Creature(id)
		source = entry and assets:FindFirstChild(entry.ModelId or "crownback")
	end
	return source
end
function B.Build(id, _color)
	local source = B.Source(id)
	if not source then
		local empty = Instance.new("Model")
		empty.Name = "Unidentified"
		return empty
	end
	local model = source:Clone()
	model.Name = "Specimen"
	model:SetAttribute("CatalogId", id)
	model:ScaleTo(source:GetAttribute("DefaultScale") or 0.27)
	model:PivotTo(CFrame.identity)
	for _, p in model:GetDescendants() do
		if p:IsA("BasePart") then
			p.Anchored = true
			p.CanCollide = false
			p.CanQuery = false
			p.CanTouch = false
		end
	end
	return model
end
return B
