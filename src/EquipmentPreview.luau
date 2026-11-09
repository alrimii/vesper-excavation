-- Lightweight static previews: no per-frame animation or extra render connections.
local M = {}
function M.Create(parent, source, tint)
	if not source then
		return
	end
	local view = Instance.new("ViewportFrame")
	view.Name = "EquipmentPreview"
	view.ZIndex = 3
	view.BackgroundTransparency = 1
	view.Position = UDim2.fromOffset(12, 37)
	view.Size = UDim2.new(1, -24, 0, 105)
	view.Ambient = Color3.fromRGB(190, 205, 219)
	view.LightColor = Color3.fromRGB(255, 230, 191)
	view.LightDirection = Vector3.new(-1, -1, -1)
	view.Parent = parent
	local world = Instance.new("WorldModel")
	world.Parent = view
	local model = Instance.new("Model")
	for _, p in source:GetDescendants() do
		if p:IsA("BasePart") and p.Transparency < 1 then
			local clone = p:Clone()
			for _, child in clone:GetDescendants() do
				if
					child:IsA("JointInstance")
					or child:IsA("WeldConstraint")
					or child:IsA("LuaSourceContainer")
					or child:IsA("BasePart")
					or child:IsA("ParticleEmitter")
					or child:IsA("Light")
				then
					child:Destroy()
				end
			end
			clone.Anchored = true
			clone.CanCollide, clone.CanTouch, clone.CanQuery = false, false, false
			if tint then
				clone.Color = tint
				local surface = clone:FindFirstChildOfClass("SurfaceAppearance")
				if surface then
					surface.Color = tint
				end
			end
			clone.Parent = model
		end
	end
	model.Parent = world
	local cf, size = model:GetBoundingBox()
	model:PivotTo(CFrame.new(-cf.Position) * model:GetPivot())
	local camera = Instance.new("Camera")
	camera.FieldOfView = 32
	camera.CFrame =
		CFrame.lookAt(Vector3.new(0.8, 0.4, -1).Unit * math.max(size.X, size.Y, size.Z) * 2.05, Vector3.zero)
	camera.Parent = view
	view.CurrentCamera = camera
	return view
end
return M
