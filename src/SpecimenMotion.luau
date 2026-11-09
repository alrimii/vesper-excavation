-- Cosmetic articulation with fixed head and tail pivots. Feet remain planted.
local M = {}
function M.Start(chamber, state)
	local Run = game:GetService("RunService")
	local model, neck, tailJoint, bodyJoint
	local revealedAt = nil
	local function bind()
		model = chamber:FindFirstChild("Specimen")
		if not model then
			return
		end
		neck = model:FindFirstChild("Neck", true)
		tailJoint = model:FindFirstChild("TailRoot", true)
		bodyJoint = model:FindFirstChild("BodyRoot", true)
	end
	local function reveal()
		revealedAt = state:GetAttribute("Status") == "Revealed" and state:GetAttribute("PhaseStartedAt")
			or nil
	end
	chamber.ChildAdded:Connect(function()
		bind()
		reveal()
	end)
	state:GetAttributeChangedSignal("Status"):Connect(reveal)
	bind()
	reveal()
	Run.PreSimulation:Connect(function()
		if not model or not model.Parent then
			return
		end
		local t = workspace:GetServerTimeNow()
		local age = revealedAt and (t - revealedAt) or 0
		local awaken = revealedAt and math.clamp(age / 2.4, 0, 1) or 0
		awaken = awaken * awaken * (3 - 2 * awaken)
		local breath = math.sin(t * 1.1) * 0.012
		if bodyJoint then
			bodyJoint.Transform = CFrame.Angles(breath * (0.4 + awaken), 0, 0)
		end
		if neck then
			local look = math.sin(t * 0.36) * 0.08 * awaken
			neck.Transform = CFrame.Angles(0.24 * (1 - awaken) + breath, look, -look * 0.25)
		end
		if tailJoint then
			tailJoint.Transform = CFrame.Angles(0, math.sin(t * 0.65) * (0.012 + 0.035 * awaken), 0)
		end
	end)
end
return M
