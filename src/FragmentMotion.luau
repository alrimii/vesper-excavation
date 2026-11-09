-- Deterministic three-phase fracture: split, fall, settle. No physics or resource authority.
local M = {}
local Geometry = require(script.Parent.ExcavationConfig).Geometry
function M.Prepare(f, settings)
	local surface = f.part:GetAttribute("SurfaceNormal")
	local normal = surface and f.orientation:VectorToWorldSpace(surface).Unit or f.normal.Unit
	local axis = normal:Cross(Vector3.yAxis)
	local angle = math.acos(math.clamp(normal:Dot(Vector3.yAxis), -1, 1))
	local flatten = axis.Magnitude > 0.0001 and CFrame.fromAxisAngle(axis.Unit, angle) or CFrame.identity
	local landing = CFrame.Angles(0, (f.seed - 2) * 0.28, 0) * flatten * f.orientation
	local height = f.part:GetAttribute("RestHeight") or 0.3
	f.finish = Vector3.new(f.finish.X, f.finish.Y + height, f.finish.Z)
	f.landRotation = landing
	local radial = Vector3.new(f.start.X, 0, f.start.Z)
	f.outward = radial.Magnitude > 0.01 and radial.Unit or Vector3.xAxis
	f.peelAxis = normal:Cross(f.lateral)
	if f.peelAxis.Magnitude < 0.001 then
		f.peelAxis = Vector3.xAxis
	end
	f.peelAxis = f.peelAxis.Unit
	f.peelRotation = CFrame.fromAxisAngle(f.peelAxis, 0.12 + f.seed * 0.025) * f.orientation
	f.release = f.start + normal * 0.6 + f.outward * 0.65 + f.lateral * 0.18
	f.delay = (f.seed - 1) * settings.ReleaseStagger
	f.splitTime = settings.FractureTime
	f.fallTime = math.clamp(
		math.sqrt(math.max(0.2, f.release.Y - f.finish.Y) * 2 / settings.Gravity),
		0.25,
		settings.FlightTime - settings.FractureTime - settings.BounceTime - f.delay
	)
	f.duration = f.delay + f.splitTime + f.fallTime + settings.BounceTime
	f.gravity = settings.Gravity
	f.bounceTime = settings.BounceTime
	f.bounceHeight = settings.BounceHeight
	f.upVelocity = (f.finish.Y - f.release.Y + 0.5 * f.gravity * f.fallTime ^ 2) / f.fallTime
end
function M.Sample(f, time)
	time = math.max(0, time - f.delay)
	if time < f.splitTime then
		local t = math.clamp(time / f.splitTime, 0, 1)
		local ease = t * t * (3 - 2 * t)
		return CFrame.new(f.start:Lerp(f.release, ease)) * f.orientation:Lerp(f.peelRotation, ease)
	end
	local elapsed = math.min(time - f.splitTime, f.fallTime)
	local t = elapsed / f.fallTime
	local travel = t * t * (3 - 2 * t)
	local pos = Vector3.new(
		f.release.X + (f.finish.X - f.release.X) * travel,
		f.release.Y + f.upVelocity * elapsed - 0.5 * f.gravity * elapsed ^ 2,
		f.release.Z + (f.finish.Z - f.release.Z) * travel
	)
	-- Keep falling material outside the curved shell rather than tunnelling through it.
	local fraction = (pos.Y - Geometry.Base.Y) / Geometry.Height
	if fraction > 0 and fraction < 1 then
		local phi = math.acos(1 - 2 * fraction)
		local clearance = Geometry.Radius * math.sin(phi) * (1 + 0.18 * math.cos(phi)) + 1.25
		local radial = Vector3.new(pos.X, 0, pos.Z)
		if radial.Magnitude < clearance then
			local outward = radial.Magnitude > 0.01 and radial.Unit
				or Vector3.new(f.finish.X, 0, f.finish.Z).Unit
			local blend = math.clamp(t / 0.12, 0, 1)
			blend = blend * blend * (3 - 2 * blend)
			pos = outward * (radial.Magnitude + (clearance - radial.Magnitude) * blend)
				+ Vector3.yAxis * pos.Y
		end
	end
	local spin = math.sin(t * math.pi)
	local rotation = f.peelRotation:Lerp(f.landRotation, travel)
		* CFrame.Angles(spin * 0.55 * f.seed, spin * (f.seed - 2) * 0.65, spin * 0.22)
	if time >= f.splitTime + f.fallTime then
		local settle = math.clamp((time - f.splitTime - f.fallTime) / f.bounceTime, 0, 1)
		pos = f.finish + Vector3.yAxis * (math.sin(settle * math.pi) * f.bounceHeight * (1 - settle))
		rotation = f.landRotation * CFrame.Angles(0, 0, math.sin(settle * math.pi) * 0.04 * (1 - settle))
	end
	return CFrame.new(pos) * rotation
end
return M
