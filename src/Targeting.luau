-- The indicator and attack share this exact ray solver; no decorative fake crosshair.
local T = {}
function T.new(player, gui, egg, C)
	local UIS = game:GetService("UserInputService")
	local Run = game:GetService("RunService")
	local shared = game.ReplicatedStorage.VesperShared
	local targeter = { confirmedUntil = 0 }
	local highlight = Instance.new("Highlight")
	highlight.Name = "TargetPlate"
	highlight.FillTransparency = 1
	highlight.OutlineTransparency = 0.05
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.Enabled = false
	highlight.Parent = workspace
	local anchor = Instance.new("Part")
	anchor.Name = "LocalHitPoint"
	anchor.Size = Vector3.one * 0.05
	anchor.Transparency = 1
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanTouch = false
	anchor.CanQuery = false
	anchor.Parent = workspace
	local mark = Instance.new("BillboardGui")
	mark.Name = "HitMarker"
	mark.Adornee = anchor
	mark.Size = UDim2.fromOffset(36, 36)
	mark.AlwaysOnTop = false
	mark.Enabled = false
	mark.Parent = gui
	local ring = Instance.new("Frame")
	ring.Size = UDim2.fromScale(0.7, 0.7)
	ring.AnchorPoint = Vector2.new(0.5, 0.5)
	ring.Position = UDim2.fromScale(0.5, 0.5)
	ring.BackgroundTransparency = 1
	ring.Parent = mark
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = ring
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2
	stroke.Parent = ring
	local dot = Instance.new("Frame")
	dot.Size = UDim2.fromOffset(4, 4)
	dot.AnchorPoint = Vector2.new(0.5, 0.5)
	dot.Position = UDim2.fromScale(0.5, 0.5)
	dot.BorderSizePixel = 0
	dot.Parent = mark
	local status = Instance.new("TextLabel")
	status.Name = "TargetStatus"
	status.Size = UDim2.fromOffset(300, 32)
	status.AnchorPoint = Vector2.new(0.5, 1)
	status.Position = UDim2.new(0.5, 0, 1, -118)
	status.BackgroundColor3 = Color3.fromRGB(20, 30, 35)
	status.BackgroundTransparency = 0.18
	status.TextColor3 = Color3.fromRGB(222, 235, 229)
	status.TextSize = 13
	status.Font = Enum.Font.GothamMedium
	status.Visible = false
	status.Parent = gui
	local round = Instance.new("UICorner")
	round.Parent = status
	local hp = Instance.new("Frame")
	hp.Name = "PlateHealth"
	hp.Size = UDim2.new(1, 0, 0, 3)
	hp.Position = UDim2.new(0, 0, 1, -3)
	hp.BorderSizePixel = 0
	hp.Parent = status
	local ready = Color3.fromRGB(126, 228, 190)
	local distant = Color3.fromRGB(246, 177, 72)
	local function blockedByUI()
		if
			gui.Station.Visible
			or player:GetAttribute("LabReady") ~= true
			or player:GetAttribute("CoreMenuOpen")
			or player:GetAttribute("MaterialBagOpen")
			or player:GetAttribute("Training")
			or player:GetAttribute("EggResultsOpen") or player:GetAttribute("ResearchModal")
			or player:GetAttribute("DiscoveryCinematic")
			or UIS:GetFocusedTextBox()
		then
			return true
		end
		if UIS.PreferredInput == Enum.PreferredInput.KeyboardAndMouse then
			local cursor = UIS:GetMouseLocation()
			for _, object in player.PlayerGui:GetGuiObjectsAtPosition(cursor.X, cursor.Y) do
				if object:IsA("GuiButton") or (object:IsA("Frame") and object.Active) then
					return true
				end
			end
		end
		return false
	end
	local function hide()
		highlight.Enabled = false
		mark.Enabled = false
		status.Visible = false
	end
	local function solve()
		if blockedByUI() then
			return
		end
		local ch = player.Character
		local head = ch and ch:FindFirstChild("Head")
		local camera = workspace.CurrentCamera
		if not head or not camera then
			return
		end
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = { ch, anchor }
		local ray = (
			player:GetAttribute("CenteredAim")
			or UIS.PreferredInput ~= Enum.PreferredInput.KeyboardAndMouse
		)
				and camera:ViewportPointToRay(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
			or player:GetMouse().UnitRay
		local hit = workspace:Raycast(ray.Origin, ray.Direction * 300, params)
		local section = hit and hit.Instance.Parent
		if not section or section.Parent ~= egg.Sections or not section:GetAttribute("Intact") then
			return
		end
		local delta = hit.Position - head.Position
		local distance = delta.Magnitude
		local direct = distance > 0.01
			and workspace:Raycast(head.Position, delta.Unit * (distance + 0.35), params)
		local exposed = direct and direct.Instance.Parent == section
		return section,
			(exposed and direct.Position or hit.Position),
			(exposed and direct.Normal or hit.Normal),
			exposed and distance <= C.Mining.Reach and section:GetAttribute("Exposed") == true,
			distance,
			exposed
	end
	function targeter:Get()
		local section, point, _, valid = solve()
		if valid then
			return section, point
		end
	end
	function targeter:Confirm()
		self.confirmedUntil = os.clock() + 0.14
	end
	Run.RenderStepped:Connect(function()
		local ch = player.Character
		local tool = ch and ch:FindFirstChildOfClass("Tool")
		local kind = tool and tool:GetAttribute("ToolKind")
		local camera = workspace.CurrentCamera
		if not camera then
			return
		end
		gui.Crosshair.Visible = kind == "Pickaxe" and not blockedByUI()
		if not gui.Crosshair.Visible then
			hide()
			return
		end
		if
			player:GetAttribute("CenteredAim")
			or UIS.PreferredInput ~= Enum.PreferredInput.KeyboardAndMouse
		then
			local inset = game:GetService("GuiService"):GetGuiInset()
			local center = camera.ViewportSize / 2 - inset
			gui.Crosshair.Position = UDim2.fromOffset(center.X, center.Y)
		else
			local inset = game:GetService("GuiService"):GetGuiInset()
			local cursor = UIS:GetMouseLocation() - inset
			gui.Crosshair.Position = UDim2.fromOffset(cursor.X, cursor.Y)
		end
		if kind == "Pickaxe" then
			local section, point, normal, valid, _distance, exposed = solve()
			if not section then
				hide()
				gui.Crosshair.TextColor3 = Color3.fromRGB(190, 196, 196)
				return
			end
			local color = valid and ready or distant
			if os.clock() < targeter.confirmedUntil then
				color = Color3.new(1, 1, 1)
			end
			gui.Crosshair.TextColor3 = color
			local reactions = workspace:FindFirstChild("LocalShellReactions")
			local adornee = (reactions and reactions:FindFirstChild("Stress_" .. section.Name))
				or section:FindFirstChild("Plate")
			if highlight.Adornee ~= adornee then
				highlight.Adornee = adornee
			end
			highlight.FillColor = color
			highlight.OutlineColor = color
			-- Damaged shell appearance must not depend on the selection pass.
			highlight.Enabled = not (
				section:GetAttribute("Layer") == 1
				and reactions
				and reactions:FindFirstChild("Stress_" .. section.Name)
			)
			anchor.Position = point + normal * 0.06
			stroke.Color = color
			dot.BackgroundColor3 = color
			mark.Enabled = true
			status.Visible = gui.Toast.Text == "" and not gui:GetAttribute("CoreTargetSuppressed")
			local layer = C.Layers[section:GetAttribute("Layer")]
			local maxHealth = section:GetAttribute("MaxHP") or layer.Durability
			local health = section:GetAttribute("HP") or maxHealth
			hp.Size = UDim2.new(math.clamp(health / maxHealth, 0, 1), 0, 0, 3)
			hp.BackgroundColor3 = color
			local permanent = section:GetAttribute("Permanent")
			hp.Visible = not permanent
			local precise = (point - section:GetAttribute("Center")).Magnitude <= C.Precision.Radius
			if valid then
				anchor.Position = section:GetAttribute("Center") + normal * 0.05
				stroke.Color = Color3.fromRGB(255, 200, 90)
				dot.BackgroundColor3 = stroke.Color
			end
			local locked = not section:GetAttribute("Exposed")
			status.Text = permanent and "PERMANENT SHELL BASE"
				or locked and "FINISH THE OUTER LAYER FIRST"
				or not exposed and "BLOCKED - find a clear angle"
				or not valid and "OUT OF RANGE"
				or string.format(
					"%s | %d / %d | %s",
					layer.Id:upper(),
					health,
					maxHealth,
					precise and "PRECISION" or "AIM AT GOLD POINT"
				)
		elseif kind == "Bucket" then
			local root = ch:FindFirstChild("HumanoidRootPart")
			if not root then
				return
			end
			local nearest, distance = nil, C.Collection.Radius
			for _, pile in shared.ResourcePiles:GetChildren() do
				local pos = pile:GetAttribute("Position")
				if pos and workspace:GetServerTimeNow() >= (pile:GetAttribute("SettlesAt") or 0) then
					local d = (root.Position - pos).Magnitude
					if d < distance then
						nearest = pile
						distance = d
					end
				end
			end
			if nearest then
				local full = (player:GetAttribute("BucketUsed") or 0)
					>= (player:GetAttribute("BucketCapacity") or C.Collection.Capacity)
				anchor.Position = nearest:GetAttribute("Position") + Vector3.new(0, 0.4, 0)
				stroke.Color = full and distant or ready
				dot.BackgroundColor3 = stroke.Color
				mark.Enabled = true
				status.Visible = true
				hp.Size = UDim2.fromScale(0, 0)
				status.Text = full and "BUCKET FULL / SELL" or "LOOSE MATERIAL / HOLD TO COLLECT"
			end
		end
	end)
	return targeter
end
return T
