-- Target reactions only: ToolMotion owns all character poses.
local M = {}
local Cycle = require(script.Parent.TrainingCycle)
function M.Start(player)
	local devices = {}
	for _, room in workspace.VesperLab.Rooms:GetChildren() do
		local d = room:FindFirstChild("TrainingStation")
		if d and d:FindFirstChild("PracticeEgg") then
			table.insert(devices, { model = d, egg = d.PracticeEgg })
		end
	end
	game:GetService("RunService").PreSimulation:Connect(function()
		local now = workspace:GetServerTimeNow()
		local template = game.ReplicatedStorage.VesperShared:FindFirstChild("DeliveryShell")
		for _, d in devices do
			local egg = d.egg
			local rest, size = egg:GetAttribute("RestCFrame"), egg:GetAttribute("RestSize")
			if not egg.Parent or not rest or not size then
				continue
			end
			if not d.visual and template then
				local visual = template:Clone()
				visual.Name = "PracticeShell"
				local _, bounds = visual:GetBoundingBox()
				visual:ScaleTo(visual:GetScale() * size.Y / bounds.Y)
				local center = visual:GetBoundingBox()
				d.visualOffset = center:ToObjectSpace(visual:GetPivot())
				visual:PivotTo(rest * d.visualOffset)
				for _, surface in visual:GetChildren() do
					if surface:IsA("BasePart") then
						surface.Color = Color3.fromRGB(218, 190, 132)
						surface.Material = Enum.Material.SmoothPlastic
						surface.Reflectance = 0
						surface.Transparency = 0
						surface.CanCollide, surface.CanTouch, surface.CanQuery = false, false, false
					end
				end
				visual.Parent = d.model
				d.visual = visual
				egg.LocalTransparencyModifier = 1
			end
			local started = d.model:GetAttribute("TrainingStartedAt")
			local active = d.model:GetAttribute("TrainingActive") == true
			local family = d.model:GetAttribute("TrainingFamily") or "Pickaxe"
			if active ~= d.lastActive or family ~= d.lastFamily then
				d.lastActive, d.lastFamily = active, family
				local screen = d.model:FindFirstChild("Screen")
				local status = screen and screen:FindFirstChild("TrainingStatus")
				if status then
					status.Status.Text = active and "TRAINING" or "READY"
					status.Subtitle.Text = active and (family:upper() .. " / TAP TO STOP")
						or "START / STOP NEAR THE BENCH"
				end
				local lens = d.model:FindFirstChild("BenchStatusLens", true)
				if lens then
					lens.Color = active and Color3.fromRGB(113, 236, 180) or Color3.fromRGB(101, 157, 146)
				end
			end
			local impact = 0
			if d.model:GetAttribute("TrainingActive") and started then
				local _, _, value = Cycle.Sample(started, now, d.model:GetAttribute("TrainingFamily"))
				impact = value
			end
			local force = player:GetAttribute("ReducedMotion") and impact * 0.2 or impact
			-- Idle stations keep their final pose; do not move 12 models every frame.
			if d.lastForce == force then
				continue
			end
			d.lastForce = force
			-- Recoil into the cradle without replacing the material or changing the silhouette.
			egg.Size = size * Vector3.new(1 + force * 0.012, 1 - force * 0.018, 1 + force * 0.012)
			egg.CFrame = rest
				* CFrame.new(0, -force * 0.06, -force * 0.14)
				* CFrame.Angles(-force * 0.04, 0, 0)
			if d.visual then
				d.visual:PivotTo(egg.CFrame * d.visualOffset)
			end
		end
	end)
end
return M
