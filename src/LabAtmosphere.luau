local A = {}
function A.BuildDisplays()
	local shared = script.Parent
	local entry = require(shared.DiscoveryCatalog).Specimens[1]
	local Preview = require(shared.SpecimenPreview)
	local items = {}
	local player = game:GetService("RunService"):IsRunning() and game:GetService("Players").LocalPlayer or nil
	local guiParent = player and player:WaitForChild("PlayerGui") or game:GetService("StarterGui")
	local prior = guiParent:FindFirstChild("VesperCrewDisplays")
	if prior then
		prior:Destroy()
	end
	local container = Instance.new("Folder")
	container.Name = "VesperCrewDisplays"
	container.Parent = guiParent
	for _, room in workspace.VesperLab.Rooms:GetChildren() do
		for _, screen in room:GetDescendants() do
			if
				screen:IsA("SurfaceGui")
				and screen.Parent.Name == "Terminal"
				and not screen.Parent:GetAttribute("RoomTerminalPage")
			then
				local old = screen:FindFirstChild("SpecimenPortrait")
				if old then
					old:Destroy()
				end
				-- ViewportFrames on world monitors must render from the player's GUI.
				local display = screen:Clone()
				display.Name = room.Name .. "Archive" .. tostring(#items + 1)
				display.Adornee = screen.Parent
				display.Enabled = true
				display.LightInfluence = 0
				display.Parent = container
				screen.Enabled = false
				local view = Instance.new("ViewportFrame")
				view.Name = "SpecimenPortrait"
				view.BackgroundTransparency = 1
				view.Size = UDim2.fromScale(0.82, 0.72)
				view.Position = UDim2.fromScale(0.09, 0.2)
				view.Parent = display
				local preview = Preview.Create(view, entry.Id, entry.Color)
				local title = display:FindFirstChild("Text")
				if title then
					title.Size = UDim2.fromScale(1, 0.19)
					title.Position = UDim2.fromScale(0, 0)
					title.Text = "VESPER / UNIDENTIFIED LIFEFORM"
					title.TextSize = 34
					title.TextScaled = false
				end
				table.insert(items, {
					room = room,
					view = preview,
					surface = display,
					title = title,
					id = entry.Id,
					name = entry.Name,
				})
			end
		end
	end
	return items
end
function A.Start()
	local items = A.BuildDisplays()
	local players = game:GetService("Players")
	local elapsed = 0
	game:GetService("RunService").Heartbeat:Connect(function(dt)
		elapsed += dt
		if elapsed < 0.15 then
			return
		end
		elapsed = 0
		for _, item in items do
			local localPlayer = players.LocalPlayer
			local character = localPlayer and localPlayer.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			item.surface.Enabled = root ~= nil
				and (root.Position - item.surface.Adornee.Position).Magnitude < 100
			local owner = players:GetPlayerByUserId(item.room:GetAttribute("OwnerUserId") or 0)
			local unlocked = owner and (owner:GetAttribute("Discovery_" .. item.id) or 0) > 0 or false
			item.view:SetUnlocked(unlocked)
			if item.title then
				item.title.Text = unlocked and "DOCUMENTED / " .. item.name:upper()
					or "VESPER / UNIDENTIFIED LIFEFORM"
			end
		end
	end)
end
return A
