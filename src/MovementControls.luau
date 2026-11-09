local M = {}
function M.Start(player, gui)
	local UIS = game:GetService("UserInputService")
	local Run = game:GetService("RunService")
	local GuiService = game:GetService("GuiService")
	local remote = game.ReplicatedStorage.VesperShared.Remotes:WaitForChild("Sprint")
	local locked, sprinting, focused = false, false, true
	local held = {}
	local touchSprint = false
	local ownedHumanoid, priorRotate
	local mouseOwned = false
	local priorMouseIcon = UIS.MouseIconEnabled
	local function sprint(on)
		if sprinting == on then
			return
		end
		sprinting = on
		remote:FireServer(on)
	end
	local function blocked()
		local ch = player.Character
		local hum = ch and ch:FindFirstChildOfClass("Humanoid")
		local help = gui:FindFirstChild("FieldGuidePanel")
		return not focused
			or UIS:GetFocusedTextBox() ~= nil
			or GuiService.MenuIsOpen
			or player:GetAttribute("LabReady") ~= true
			or player:GetAttribute("ResearchModal")
			or player:GetAttribute("CoreMenuOpen")
			or player:GetAttribute("MaterialBagOpen")
			or player:GetAttribute("DiscoveryCinematic")
			or player:GetAttribute("Training")
			or gui.Station.Visible
			or (help and help.Visible)
			or not hum
			or hum.Health <= 0
			or hum.Sit
	end
	local function release()
		touchSprint = false
		table.clear(held)
		sprint(false)
	end
	UIS.InputBegan:Connect(function(input, processed)
		if processed or blocked() then
			return
		end
		local key = input.KeyCode
		if key == Enum.KeyCode.LeftControl or key == Enum.KeyCode.RightControl then
			locked = not locked
		elseif key == Enum.KeyCode.ButtonL3 then
			touchSprint = not touchSprint
			sprint(touchSprint)
		elseif key == Enum.KeyCode.LeftShift or key == Enum.KeyCode.RightShift then
			held[key] = true
			sprint(true)
		end
	end)
	UIS.InputEnded:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
			held[input.KeyCode] = nil
			sprint(next(held) ~= nil and not blocked())
		end
	end)
	UIS.WindowFocusReleased:Connect(function()
		focused = false
		release()
	end)
	UIS.WindowFocused:Connect(function()
		focused = true
	end)
	UIS.TextBoxFocused:Connect(release)
	GuiService.MenuOpened:Connect(release)
	player.CharacterAdded:Connect(function()
		locked = false
		release()
	end)
	local sprintButton = Instance.new("TextButton")
	sprintButton.Name = "SprintToggle"
	sprintButton.Size = UDim2.fromOffset(76, 44)
	sprintButton.Position = UDim2.new(1, -92, 1, -212)
	sprintButton.Text = "SPRINT"
	sprintButton.BackgroundColor3 = Color3.fromRGB(28, 66, 73)
	sprintButton.TextColor3 = Color3.new(1, 1, 1)
	sprintButton.Font = Enum.Font.GothamBold
	sprintButton.TextSize = 12
	sprintButton.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = sprintButton
	sprintButton.Activated:Connect(function()
		if not blocked() then
			touchSprint = not touchSprint
			sprint(touchSprint)
		end
	end)
	local function applyMouse()
		sprintButton.Visible = UIS.PreferredInput == Enum.PreferredInput.Touch and not blocked() and gui.Toast.Text == ""
		-- Clear both the native jump control and the mining action button.
		local size = gui.AbsoluteSize
		if not gui:GetAttribute("CoreHUDManaged") then
			sprintButton.Position = size.Y < 500 and size.X >= 600 and UDim2.fromOffset(12, 128)
				or UDim2.new(1, -96, 1, -238)
		end
		sprintButton.Text = touchSprint and "WALK" or "SPRINT"
		local active = locked and not blocked() and UIS.PreferredInput == Enum.PreferredInput.KeyboardAndMouse
		player:SetAttribute("CenteredAim", active)
		if active then
			if not mouseOwned then
				priorMouseIcon = UIS.MouseIconEnabled
			end
			UIS.MouseIconEnabled = false
			UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
			mouseOwned = true
		elseif mouseOwned then
			UIS.MouseIconEnabled = priorMouseIcon
			UIS.MouseBehavior = Enum.MouseBehavior.Default
			mouseOwned = false
		end
		return active
	end
	-- Set before native orbit reads mouse delta, and enforce after native camera updates.
	Run:BindToRenderStep("VesperLockInput", Enum.RenderPriority.Camera.Value - 2, applyMouse)
	Run:BindToRenderStep("VesperMovement", Enum.RenderPriority.Camera.Value + 1, function(dt)
		if blocked() then
			release()
		end
		local active = applyMouse()
		local ch = player.Character
		local hum = ch and ch:FindFirstChildOfClass("Humanoid")
		local root = ch and ch:FindFirstChild("HumanoidRootPart")
		local camera = workspace.CurrentCamera
		if active and hum and root and camera then
			if ownedHumanoid ~= hum then
				if ownedHumanoid and ownedHumanoid.Parent then
					ownedHumanoid.AutoRotate = priorRotate
				end
				ownedHumanoid, priorRotate = hum, hum.AutoRotate
			end
			hum.AutoRotate = false
			local look = camera.CFrame.LookVector * Vector3.new(1, 0, 1)
			if look.Magnitude > 0.001 then
				root.CFrame = root.CFrame:Lerp(
					CFrame.lookAt(root.Position, root.Position + look),
					1 - math.exp(-18 * dt)
				)
			end
		elseif ownedHumanoid then
			if ownedHumanoid.Parent then
				ownedHumanoid.AutoRotate = priorRotate
			end
			ownedHumanoid = nil
		end
	end)
end
return M
