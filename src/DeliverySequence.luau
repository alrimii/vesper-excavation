local M = { SelectionDuration = 4.5, DeliveryDuration = 16, Lift = 70 }
local function ease(t)
	t = math.clamp(t, 0, 1)
	return t * t * t * (t * (t * 6 - 15) + 10)
end
M.Ease = ease
function M.Sample(age)
	local lower = ease((age - 0.65) / 4.75)
	local release = ease((age - 6) / 1.15)
	local retract = ease((age - 7.2) / 2.3)
	return {
		eggLift = M.Lift * (1 - lower),
		rigLift = M.Lift * (1 - lower + retract),
		open = release,
		accessDrop = 110 * (1 - math.clamp((age - 9.5) / 4.5, 0, 1)),
		returnCamera = ease((age - 14.7) / 1.2),
		label = age < 0.65 and "LOAD SECURED"
			or age < 5.4 and "CONTROLLED DESCENT"
			or age < 6 and "CRADLE LOAD TRANSFER"
			or age < 7.2 and "CLAMPS DISENGAGING"
			or age < 9.5 and "HOIST RETURNING"
			or age < 14 and "ACCESS PLATFORMS DEPLOYING"
			or "EXCAVATION READY",
	}
end
return M
