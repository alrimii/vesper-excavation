-- Cosmetic only: consumes the existing DeliverySequence sample, never advances a round.
local M = {}
function M.new(parent, dock)
	local rig = { parts = {}, dock = dock }
	local function make(name, size, color)
		local p = Instance.new("Part")
		p.Name = name
		p.Size = size
		p.Color = color
		p.Material = Enum.Material.Metal
		p.Anchored = true
		p.CanCollide = false
		p.CanTouch = false
		p.CanQuery = false
		p.CastShadow = false
		p.Parent = parent
		table.insert(rig.parts, p)
		return p
	end
	function rig:Update(delivering, sample)
		local housing = self.dock and self.dock:FindFirstChild("HoistHousing")
		if housing then
			for _, p in housing:GetChildren() do
				if p.Name:match("^StowedGripper") then
					p.LocalTransparencyModifier = delivering and 1 or 0
				end
			end
		end
		if not delivering then
			for _, p in self.parts do
				p:Destroy()
			end
			table.clear(self.parts)
			self.cables = nil
			self.grips = nil
			self.jaws = nil
			return
		end
		if not self.dock then
			return
		end
		if not self.cables then
			self.cables = {}
			self.grips = {}
			self.jaws = {}
			for i = 1, 4 do
				self.cables[i] = make("AttachedDeliveryCable" .. i, Vector3.one, Color3.fromRGB(39, 51, 50))
				self.grips[i] =
					make("DeliveryGripper" .. i, Vector3.new(3.6, 1.5, 3.6), Color3.fromRGB(121, 132, 123))
				self.jaws[i] = make("GripperJaw" .. i, Vector3.new(1, 4, 1.5), Color3.fromRGB(76, 88, 83))
			end
		end
		local retract = math.clamp((sample.rigLift - sample.eggLift) / 70, 0, 1)
		for i = 1, 4 do
			local socket = self.dock:FindFirstChild("DeliverySocket" .. i)
			if not socket then
				continue
			end
			local top = Vector3.new(socket.Position.X, 238.7, socket.Position.Z)
			local radial = Vector3.new(top.X, 0, top.Z).Unit
			local bottom = Vector3.new(top.X, (101 + sample.eggLift) * (1 - retract) + 237.5 * retract, top.Z)
				+ radial * (sample.open * 4 * (1 - retract))
			local cable = self.cables[i]
			cable.Size = Vector3.new(0.22, 0.22, math.max(0.01, (top - bottom).Magnitude))
			cable.CFrame = CFrame.lookAt((top + bottom) / 2, bottom)
			self.grips[i].CFrame = CFrame.lookAt(bottom, bottom - radial)
			local jaw = self.jaws[i]
			jaw.CFrame = CFrame.lookAt(
				bottom - radial * 1.2 - Vector3.yAxis * (1.6 * (1 - retract)),
				bottom - radial * 2 - Vector3.yAxis * (1.6 * (1 - retract))
			) * CFrame.Angles(math.rad(35) * sample.open, 0, 0)
			jaw.Transparency = retract
		end
	end
	return rig
end
return M
