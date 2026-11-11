-- Original R15/R6 pose curves: phase, shoulder pitch/yaw/roll, elbow, wrist.
return {
	-- Finished pick's measured -X working point; grip origin is the actual hand contact.
	PickaxeGrip = CFrame.Angles(0, math.pi / 2, 0),
	PickaxeStrikeTip = Vector3.new(-1.456642, 1.052610, 0),
	PickaxeIdle = { 22, -8, 14, 20, 0 },
	ChargeIdle = { 12, 0, 6, 65, 8 }, -- Bent elbow, neutral wrist; side strap in the palm.
	BucketIdle = { 18, 0, 6, 12, 0 },
	Strike = {
		{ 0, 22, -8, 14, 20, 0 },
		{ 0.2857, 96, -16, 22, 54, -12 },
		{ 0.47619047619, 42, 5, -3, 12, 16 },
		{ 0.54, 32, 8, -4, 14, 20 },
		{ 0.68, 49, -3, 7, 30, 4 },
		{ 1, 22, -8, 14, 20, 0 },
	},
}
