local M = {}
function M.Start(player, gui)
	local connections = {}
	local rooms = workspace.VesperLab.Rooms
	for _, room in rooms:GetChildren() do
		local function update()
			for _, object in room:GetDescendants() do
				if object:IsA("ProximityPrompt") and object.Name == "RoomTerminalPrompt" then
					object.Enabled = room:GetAttribute("OwnerUserId") == player.UserId
				end
			end
		end
		table.insert(connections, room:GetAttributeChangedSignal("OwnerUserId"):Connect(update))
		table.insert(
			connections,
			room.DescendantAdded:Connect(function(object)
				if object:IsA("ProximityPrompt") and object.Name == "RoomTerminalPrompt" then
					update()
				end
			end)
		)
		update()
	end
	gui.Destroying:Connect(function()
		for _, connection in connections do
			connection:Disconnect()
		end
	end)
end
return M
