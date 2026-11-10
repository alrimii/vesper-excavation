-- Authorized environment-only checkpoint. No room/architecture/gameplay rebuilds.
return {
	Build = function()
		assert(
			game.PlaceId == 94763223427049 and not game:GetService("RunService"):IsRunning(),
			"Original Edit place only"
		)
		local t = script.Parent
		return {
			require(t.ExteriorCompositionBuilder).Build(),
			require(t.IntegratedGreeneryBuilder).Build(),
			require(t.WorldLightingBuilder).Build(),
		}
	end,
}
