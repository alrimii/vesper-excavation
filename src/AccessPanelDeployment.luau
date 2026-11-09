-- Hinged sections unfold along the helix after the incoming egg has landed.
local M = {}
local function ease(t)
	t = math.clamp(t, 0, 1)
	return t * t * (3 - 2 * t)
end
function M.new(lab)
	local groups = {}
	for _, model in lab.ExcavationAccess.DeploymentSections:GetChildren() do
		local group = {
			parts = {},
			rest = {},
			hinge = model:GetAttribute("Hinge"),
			rank = model:GetAttribute("Rank"),
			sign = model:GetAttribute("FoldSign"),
			previous = -1,
		}
		for _, p in model:GetDescendants() do
			if p:IsA("BasePart") then
				table.insert(group.parts, p)
				table.insert(group.rest, p.CFrame)
			end
		end
		table.insert(groups, group)
	end
	local controller = {}
	function controller:Update(drop)
		local deployed = 1 - math.clamp(drop / 110, 0, 1)
		local parts, poses = {}, {}
		for _, g in groups do
			local open = ease((deployed - g.rank * 0.76) / 0.24)
			if open == g.previous then
				continue
			end
			g.previous = open
			local transform = g.hinge
				* CFrame.Angles(0, 0, g.sign * (1 - open) * math.pi / 2)
				* g.hinge:Inverse()
			for i, p in g.parts do
				table.insert(parts, p)
				table.insert(poses, open == 1 and g.rest[i] or transform * g.rest[i])
				p.LocalTransparencyModifier = 1 - math.clamp(open / 0.12, 0, 1)
			end
		end
		if #parts > 0 then
			workspace:BulkMoveTo(parts, poses, Enum.BulkMoveMode.FireCFrameChanged)
		end
	end
	return controller
end
return M
