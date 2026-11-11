-- Shared geometric contact check. Server still owns eligibility, equipment and damage.
local T = {}
function T.Resolve(character, target, point, reach, grace, excluded)
	local head = character and character:FindFirstChild("Head")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not head or not root or typeof(point) ~= "Vector3" then
		return
	end
	if
		point.X ~= point.X
		or point.Y ~= point.Y
		or point.Z ~= point.Z
		or math.abs(point.X) >= 1e5
		or math.abs(point.Y) >= 1e5
		or math.abs(point.Z) >= 1e5
	then
		return
	end
	local delta = point - head.Position
	if
		delta.Magnitude < 0.01
		or delta.Magnitude > reach + grace
		or (point - root.Position).Magnitude > reach + grace + 3
	then
		return
	end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = excluded or { character }
	params.RespectCanCollide = false
	local hit = workspace:Raycast(head.Position, delta.Unit * (delta.Magnitude + 0.7), params)
	if hit and hit.Instance.Parent == target and (hit.Position - point).Magnitude <= 1.3 then
		return hit
	end
end
return T
