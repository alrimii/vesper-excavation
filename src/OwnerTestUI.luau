-- Owner-only compact mode switch, using the existing illustrated UI components.
local M = {}
function M.Attach(player)
	local K = require(script.Parent.InterfaceKit)
	local A = require(script.Parent.SimulatorStyle)
	local remote = script.Parent.Remotes:WaitForChild("OwnerTestMode")
	local gui = K.Make("ScreenGui", player.PlayerGui, {
		Name = "OwnerTestAccess",
		ResetOnSpawn = false,
		ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets,
		DisplayOrder = 40,
	})
	local shell = K.Shell(player, "OwnerTestDialog", "Test Mode", nil, nil, 490)
	shell.HeightCap = 320
	local info = K.Text(
		shell.Body,
		"Explanation",
		"Test play uses a separate owner-only server and temporary progress. Nothing earned there saves. Switching modes rejoins the game. Normal play uses your real save.",
		17,
		K.Ink,
		true
	)
	info.TextWrapped = true
	K.Rect(info, 0, 0, 430, 96)
	info.Size = UDim2.new(1, 0, 0, 96)
	local test = A.Button(shell.Body, "EnableTest", "Test play · rejoin", function()
		remote:FireServer(true)
	end, A.Purple)
	local normal = A.Button(shell.Body, "DisableTest", "Normal play · rejoin", function()
		remote:FireServer(false)
	end)
	test.Position, test.Size = UDim2.fromOffset(0, 106), UDim2.new(0.5, -5, 0, 48)
	normal.Position, normal.Size = UDim2.new(0.5, 5, 0, 106), UDim2.new(0.5, -5, 0, 48)
	test.TextSize, normal.TextSize = 16, 16
	local state = K.Text(shell.Body, "Status", "", 14, K.Muted)
	state.TextWrapped = true
	state.Position, state.Size = UDim2.fromOffset(0, 160), UDim2.new(1, 0, 0, 45)
	local button = A.Button(gui, "TestMode", "Test Mode", function()
		shell:SetOpen(not shell.Open)
	end, A.Purple)
	button.AnchorPoint, button.Position = Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, 116)
	button.Size, button.TextSize = UDim2.fromOffset(174, 44), 18
	local function update()
		local eligible = player:GetAttribute("OwnerTestEligible") == true
		gui.Enabled = eligible
		if not eligible then
			shell:SetOpen(false)
			return
		end
		local active = player:GetAttribute("OwnerTestMode") == true
		local routing = player:GetAttribute("OwnerTestRouting") == true
		button.Text = routing and "Test Mode · rejoining" or active and "Test Mode: ON" or "Test Mode: OFF"
		A.State(test, not routing and not active, "Test play · rejoin")
		A.State(
			normal,
			not routing and (active or player:GetAttribute("ProfileReady") ~= true),
			"Normal play · rejoin"
		)
		state.Text = player:GetAttribute("OwnerTestError")
			or (
				routing and "Joining a different server…"
				or active and "Temporary profile · free ranks · no saves"
				or "Normal profile · ordinary saving"
			)
	end
	for _, key in
		{ "OwnerTestEligible", "OwnerTestMode", "OwnerTestRouting", "OwnerTestError", "ProfileReady" }
	do
		player:GetAttributeChangedSignal(key):Connect(update)
	end
	update()
end
return M
