-- Shared appearance and surface frame. This module never applies gameplay effects.
local V = {}
V.Revision = "AuthoredTools_20261111"
V.PickaxeRevision = "RodinSelected_20261111"
V.PickaxeIcon = "rbxassetid://92425113043430"
V.PreviewDirections = {
	Pickaxe = Vector3.new(0.34, 0.22, 1),
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
	model:SetAttribute(
		"ToolVisualRevision",
		source:GetAttribute("ToolFamily") == "Pickaxe" and V.PickaxeRevision or V.Revision
	)
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
	local cf = model:GetBoundingBox()
	local direction = (V.PreviewDirections[family] or Vector3.new(0.65, 0.25, -1)).Unit
	local rotation = CFrame.lookAt(Vector3.zero, -direction)
	local tan = math.tan(math.rad(camera.FieldOfView / 2))
	local distance = 0
	for _, part in model:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end
		for _, x in { -1, 1 } do
			for _, y in { -1, 1 } do
				for _, z in { -1, 1 } do
					local point = part.CFrame:PointToWorldSpace(part.Size * Vector3.new(x, y, z) / 2)
						- cf.Position
					local v = rotation:VectorToObjectSpace(point)
					distance = math.max(
						distance,
						v.Z + math.abs(v.Y) / tan,
						v.Z + math.abs(v.X) / (tan * math.max(0.25, aspect or 1))
					)
				end
			end
		end
	end
	camera.CFrame = CFrame.lookAt(cf.Position + direction * distance * 1.04, cf.Position)
end
return V
