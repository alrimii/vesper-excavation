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
	if (source:GetAttribute("ToolFamily") or source.Name) == "Pickaxe" then
		local sky = game:GetService("Lighting"):FindFirstChildOfClass("Sky")
		if sky then
			sky:Clone().Parent = view
		end
	end
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
	local camera = Instance.new("Camera")
	camera.FieldOfView = 32
	camera.Parent = view
	view.CurrentCamera = camera
	local function fit()
		require(script.Parent.ToolVisuals).FramePreview(
			camera,
			model,
			source:GetAttribute("ToolFamily") or source.Name,
			view.AbsoluteSize.X / math.max(1, view.AbsoluteSize.Y)
		)
	end
	view:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
	fit()
	return view
end
return M
