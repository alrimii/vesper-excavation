-- Shared appearance and surface frame. This module never applies gameplay effects.
local V = {}
V.Revision = "Phase4_20261111"
V.PreviewDirections = {
	Pickaxe = Vector3.new(0.45, 0.20, -1),
	Drill = Vector3.new(1, 0.32, -0.65),
	Explosive = Vector3.new(0.65, 0.30, -1),
}
function V.Clone(source, name)
	local model = Instance.new("Model")
	model.Name = name or source.Name
	local handle = source:FindFirstChild("Handle")
	local origin = handle and handle.CFrame or source:GetPivot()
	for _, part in source:GetDescendants() do
		if part:IsA("BasePart") and part.Transparency < 1 then
			local copy = part:Clone()
			for _, child in copy:GetDescendants() do
				if
					child:IsA("JointInstance")
					or child:IsA("WeldConstraint")
					or child:IsA("Constraint")
					or child:IsA("LuaSourceContainer")
					or child:IsA("BasePart")
					or child:IsA("ParticleEmitter")
					or child:IsA("Light")
				then
					child:Destroy()
				end
			end
			copy.CFrame = origin:ToObjectSpace(part.CFrame)
			copy.Anchored, copy.Massless, copy.CastShadow = true, true, false
			copy.CanCollide, copy.CanTouch, copy.CanQuery = false, false, false
			copy.Parent = model
		end
	end
	model.WorldPivot = CFrame.identity
	model:SetAttribute("ToolVisualRevision", V.Revision)
	return model
end
function V.SurfaceFrame(point, normal)
	local n = normal.Unit
	local up = math.abs(n:Dot(Vector3.yAxis)) > 0.94 and Vector3.zAxis or Vector3.yAxis
	up = (up - n * up:Dot(n)).Unit
	-- Model +Z is its back. 0.40156 is the measured bundle half-depth; 0.012 is seating clearance.
	local center = point + n * 0.41356
	return CFrame.lookAt(center, center + n, up)
end
function V.FramePreview(camera, model, family, aspect)
	local cf, size = model:GetBoundingBox()
	local direction = (V.PreviewDirections[family] or Vector3.new(0.65, 0.25, -1)).Unit
	local rotation = CFrame.lookAt(Vector3.zero, -direction)
	local half = size / 2
	local extentX, extentY, depth = 0, 0, 0
	for _, x in { -1, 1 } do
		for _, y in { -1, 1 } do
			for _, z in { -1, 1 } do
				local v = rotation:VectorToObjectSpace(cf:VectorToWorldSpace(half * Vector3.new(x, y, z)))
				extentX = math.max(extentX, math.abs(v.X))
				extentY = math.max(extentY, math.abs(v.Y))
				depth = math.max(depth, math.abs(v.Z))
			end
		end
	end
	local distance = math.max(extentY, extentX / math.max(0.25, aspect or 1))
			/ math.tan(math.rad(camera.FieldOfView / 2))
		+ depth
	camera.CFrame = CFrame.lookAt(cf.Position + direction * distance * 1.12, cf.Position)
end
return V
