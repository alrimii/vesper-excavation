-- Shared visual clock; progression remains server-owned.
local M = { Duration = 2.5, VisualDuration = 1.25, SwingDuration = 0.95 }
function M.ContactPoint(frame, size, from)
	local direction = frame:PointToObjectSpace(from)
	if direction.Magnitude < 0.001 then
		direction = Vector3.new(0, 0, 1)
	end
	direction = direction.Unit
	local radii = size * 0.5
	local distance = 1
		/ math.sqrt((direction.X / radii.X) ^ 2 + (direction.Y / radii.Y) ^ 2 + (direction.Z / radii.Z) ^ 2)
	return frame:PointToWorldSpace(direction * (distance + 0.03))
end
local function smooth(t)
	t = math.clamp(t, 0, 1)
	return t * t * (3 - 2 * t)
end
function M.Sample(started, now, family)
	local elapsed = math.max(0, now - started)
	local cycle = math.floor(elapsed / M.VisualDuration)
	local t = elapsed % M.VisualDuration
	local contact = family == "Explosive" and M.SwingDuration * 0.5 or M.SwingDuration * 0.4762
	local age = t - contact
	local impact = age >= 0 and math.exp(-age * 12) or 0
	local drive = family == "Drill" and t >= 0.15 and t < 1.1
	local pressure = family == "Drill" and smooth((t - 0.15) / 0.11) * (1 - smooth((t - 0.95) / 0.15)) or 0
	if family == "Drill" then
		impact = pressure * (0.3 + 0.2 * math.sin(t * 48))
	end
	return cycle, t, impact, drive, pressure
end
return M
