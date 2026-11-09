-- Original R15/R6 pose curves: phase, shoulder pitch/yaw/roll, elbow, wrist.
return {
	-- Existing mesh faces -X after its retained 180-degree Y rotation.
	PickaxeGrip = CFrame.new(0, -0.9, 0) * CFrame.Angles(0, math.pi / 2, 0),
	PickaxeStrikeTip = Vector3.new(-1.510829, 1, 0),
	PickaxeIdle = { 18, -4, 7, 18, 0 },
	BucketIdle = { 18, 0, 6, 12, 0 },
	Strike = {
		{ 0, 18, -4, 7, 18, 0 },
		{ 0.2857, 110, -16, 18, 62, -12 },
		{ 0.47619047619, 42, 5, -3, 12, 16 },
		{ 0.54, 32, 8, -4, 14, 20 },
		{ 0.68, 49, -3, 7, 30, 4 },
		{ 1, 18, -4, 7, 18, 0 },
	},
}
