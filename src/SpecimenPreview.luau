local P = {}
function P.Create(view, id, color)
	local world = Instance.new("WorldModel")
	world.Parent = view
	local model = require(script.Parent.SpecimenBuilder).Build(id, color)
	model.Parent = world
	local cf, size = model:GetBoundingBox()
	model:PivotTo(CFrame.new(-cf.Position) * model:GetPivot())
	local camera = Instance.new("Camera")
	camera.FieldOfView = 35
	local distance = math.max(size.X, size.Y, size.Z) * 1.85
	camera.CFrame = CFrame.lookAt(Vector3.new(0.65, 0.3, -1).Unit * distance, Vector3.zero)
	camera.Parent = view
	view.CurrentCamera = camera
	view.Ambient = Color3.fromRGB(210, 220, 230)
	view.LightColor = Color3.fromRGB(255, 239, 210)
	local last
	local control = {}
	function control:SetUnlocked(unlocked)
		if last == unlocked then
			return
		end
		last = unlocked
		view.Visible = true
		view.ImageColor3 = unlocked and Color3.new(1, 1, 1) or Color3.fromRGB(95, 125, 145)
	end
	control:SetUnlocked(false)
	return control
end
return P
