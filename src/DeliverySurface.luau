-- Match the playable outer plates exactly, including their PBR finish.
local M = {}
function M.Build(egg)
	local model = Instance.new("Model")
	model.Name = "DeliverySurface"
	local count = 0
	for _, section in egg.Sections:GetChildren() do
		if section:GetAttribute("Layer") == 1 then
			local plate = section:FindFirstChild("Plate")
			if plate then
				local copy = plate:Clone()
				copy.Name = section.Name
				copy.Anchored, copy.CanCollide, copy.CanTouch, copy.CanQuery = true, false, false, false
				copy.Transparency, copy.LocalTransparencyModifier = 1, 0
				copy.Parent = model
				count += 1
				if count % 400 == 0 then
					task.wait()
				end
			end
		end
	end
	model:SetAttribute("RestCFrame", model:GetPivot())
	return model
end
return M
