local B = {}
function B.Build(id, _color)
	local source = script.Parent:WaitForChild("SpecimenAssets"):FindFirstChild(id)
	if not source then
		local empty = Instance.new("Model")
		empty.Name = "Unidentified"
		return empty
	end
	local model = source:Clone()
	model.Name = "Specimen"
	model:ScaleTo(0.27)
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
