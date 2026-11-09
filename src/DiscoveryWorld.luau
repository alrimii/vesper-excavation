local shared = game.ReplicatedStorage:WaitForChild("VesperShared")
local state = shared:WaitForChild("RoundState")
local builder = require(shared.SpecimenBuilder)
local chamber = workspace.VesperLab.Egg.ContainedSpecimen
shared:SetAttribute("PresentationReady", false)
shared:SetAttribute("PresentationError", nil)
-- Never expose an editor preview before the server reaches the reveal phase.
local preview = chamber:FindFirstChild("Specimen")
if preview then
	preview:Destroy()
end
local membrane = require(script.Parent.MembraneBuilder)
local built, prepared = pcall(membrane.Make)
if not built then
	shared:SetAttribute("PresentationError", tostring(prepared))
	warn("[Vesper] Egg presentation could not initialize: " .. tostring(prepared))
	return
end
local priorVeil = chamber:FindFirstChild("HatchingVeil")
if priorVeil then
	priorVeil:Destroy()
end
prepared.Parent = chamber
shared:SetAttribute("PresentationReady", true)
local lastRound, lastStatus
local function refresh()
	local round, status = state:GetAttribute("RoundId"), state:GetAttribute("Status")
	if round == lastRound and status == lastStatus then
		return
	end
	lastRound, lastStatus = round, status
	if status ~= "Revealed" then
		local specimen = chamber:FindFirstChild("Specimen")
		if specimen then
			specimen:Destroy()
		end
		if status == "Selecting" or status == "Delivering" then
			chamber:ClearAllChildren()
			return
		end
		if not chamber:FindFirstChild("HatchingVeil") then
			membrane.Make().Parent = chamber
		end
		return
	end
	local old = chamber:FindFirstChild("Specimen")
	if old then
		old:Destroy()
	end
	local veil = chamber:FindFirstChild("HatchingVeil")
	if veil then
		local seal = veil:FindFirstChild("Seal")
		if seal then
			for _, skin in seal:GetDescendants() do
				if skin:IsA("BasePart") then
					skin.CanCollide = false
				end
			end
		end
		task.delay(2.4, function()
			if veil.Parent then
				veil:Destroy()
			end
		end)
	end
	local model = builder.Build(state:GetAttribute("SpecimenId") or "crownback")
	model:ScaleTo(2.1)
	model:PivotTo(CFrame.new(0, 43.4, 0))
	model:SetAttribute("RestPivot", model:GetPivot())
	local root = Instance.new("Part")
	root.Name = "RigRoot"
	root.Size = Vector3.one
	root.Transparency = 1
	root.Anchored = true
	root.CanCollide, root.CanTouch, root.CanQuery = false, false, false
	root.CFrame = model:GetPivot()
	root.Parent = model
	model.PrimaryPart = root
	local body = model:FindFirstChild("body_geom", true)
	local head = model:FindFirstChild("head_geom", true)
	local tail = model:FindFirstChild("tail_geom", true)
	local function joint(name, parent, child, pivot)
		if not parent or not child then
			return
		end
		local motor = Instance.new("Motor6D")
		motor.Name = name
		motor.Part0, motor.Part1 = parent, child
		motor.C0 = parent.CFrame:ToObjectSpace(pivot)
		motor.C1 = child.CFrame:ToObjectSpace(pivot)
		motor.Parent = parent
		child.Anchored = false
		child.Massless = true
	end
	joint("BodyRoot", root, body, root.CFrame * CFrame.new(0, -22.4, 0))
	joint("Neck", body, head, root.CFrame * CFrame.new(3.36, 7.42, -2.1))
	joint("TailRoot", body, tail, root.CFrame * CFrame.new(0, -9.1, 7))
	local controller = Instance.new("AnimationController")
	controller.Parent = model
	local animator = Instance.new("Animator")
	animator.Parent = controller
	model.Parent = chamber
end
state:GetAttributeChangedSignal("RoundId"):Connect(refresh)
state:GetAttributeChangedSignal("Status"):Connect(refresh)
refresh()
