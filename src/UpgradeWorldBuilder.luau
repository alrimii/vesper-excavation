-- Explicit edit-time installation of generated assets; never a runtime entry script.
local lab = workspace.VesperLab
local kit = game.ServerStorage.VesperKit
local source
for _, m in workspace:GetChildren() do
	if m:IsA("Model") and string.find(m.Name, "premium stylized", 1, true) then
		source = m
		break
	end
end
if source and not kit:FindFirstChild("StarterDrill") then
	source:PivotTo(CFrame.identity)
	local tool = Instance.new("Tool")
	tool.Name = "StarterDrill"
	tool.CanBeDropped = false
	tool.ManualActivationOnly = true
	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.25, 0.8, 0.25)
	handle.Transparency = 1
	handle.CFrame = CFrame.new(0, -0.55, 0.25)
	handle.Parent = tool
	for _, p in source:GetDescendants() do
		if p:IsA("BasePart") then
			local clone = p:Clone()
			clone.Name = p.Name
			clone.Anchored = false
			clone.Massless = true
			clone.CanCollide, clone.CanTouch, clone.CanQuery = false, false, false
			clone.Parent = tool
			local weld = Instance.new("WeldConstraint")
			weld.Part0, weld.Part1 = handle, clone
			weld.Parent = clone
		end
	end
	handle.CanCollide, handle.CanTouch, handle.CanQuery = false, false, false
	handle.Massless = true
	tool.Grip = CFrame.new(0, -0.2, 0) * CFrame.Angles(math.rad(-90), 0, 0)
	tool.Parent = kit
	source.Name = "HelixDrillSource"
	source.Parent = game.ServerStorage
end
if not kit:FindFirstChild("StarterExplosive") then
	local tool = Instance.new("Tool")
	tool.Name = "StarterExplosive"
	tool.CanBeDropped = false
	tool.ManualActivationOnly = true
	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.5, 0.85, 0.5)
	handle.Color = Color3.fromRGB(30, 41, 49)
	handle.Parent = tool
	for i = 1, 4 do
		local p = Instance.new("Part")
		p.Name = "ChargeCell"
		p.Shape = Enum.PartType.Cylinder
		p.Size = Vector3.new(1.1, 0.35, 0.35)
		p.Material = Enum.Material.Metal
		p.Color = Color3.fromRGB(219, 130, 71)
		p.CFrame = CFrame.new((i - 2.5) * 0.34, 0.45, 0) * CFrame.Angles(0, 0, math.pi / 2)
		p.Parent = tool
		local weld = Instance.new("WeldConstraint")
		weld.Part0, weld.Part1 = handle, p
		weld.Parent = p
	end
	for _, p in tool:GetDescendants() do
		if p:IsA("BasePart") then
			p.CanCollide, p.CanTouch, p.CanQuery = false, false, false
			p.Massless = true
		end
	end
	tool.Parent = kit
end
local station = workspace:FindFirstChild("VesperTrainingStation")
if station and not lab:FindFirstChild("TrainingStation") then
	local baked = Instance.new("Model")
	baked.Name = "TrainingStation"
	for _, p in station:GetDescendants() do
		if p:IsA("BasePart") then
			local clone = p:Clone()
			clone.Anchored = true
			clone.CanTouch = false
			clone.Parent = baked
		end
	end
	baked.Parent = lab
	local cf, size = baked:GetBoundingBox()
	baked:PivotTo(CFrame.new(80, 4 + size.Y / 2, 0) * CFrame.new(-cf.Position) * baked:GetPivot())
	local control = baked:FindFirstChild("ConScreen") or baked:FindFirstChildWhichIsA("BasePart")
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "TrainStrength"
	prompt.ActionText = "Train / Stop"
	prompt.ObjectText = "STRENGTH LAB"
	prompt.KeyboardKeyCode = Enum.KeyCode.F
	prompt.MaxActivationDistance = 14
	prompt.RequiresLineOfSight = false
	prompt.Parent = control
	local sign = Instance.new("BillboardGui")
	sign.Name = "TrainingSign"
	sign.Size = UDim2.fromOffset(220, 50)
	sign.StudsOffset = Vector3.new(0, 5, 0)
	sign.MaxDistance = 100
	sign.Parent = control
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundColor3 = Color3.fromRGB(15, 34, 40)
	label.BackgroundTransparency = 0.15
	label.TextColor3 = Color3.fromRGB(109, 236, 208)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 18
	label.Text = "STRENGTH LAB\nPRACTICE  /  GROW STRONGER"
	label.Parent = sign
	station.Name = "TrainingStationGeneratedSource"
	station.Parent = game.ServerStorage
end
return "Tools and training station installed"
