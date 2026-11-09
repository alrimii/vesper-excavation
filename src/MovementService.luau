local Players = game:GetService("Players")
local shared = game.ReplicatedStorage:WaitForChild("VesperShared")
local remote = shared.Remotes:WaitForChild("Sprint")
local settings = require(shared.ExcavationConfig).Movement
local lastStart = {}
local function reset(character)
 local hum = character:WaitForChild("Humanoid")
 hum.WalkSpeed = settings.WalkSpeed
 character:SetAttribute("Sprinting", false)
 hum.Died:Connect(function() character:SetAttribute("Sprinting", false) end)
end
local function join(player)
 player.CharacterAdded:Connect(reset)
 if player.Character then task.spawn(reset, player.Character) end
end
remote.OnServerEvent:Connect(function(player, enabled)
 if typeof(enabled) ~= "boolean" then return end
 local ch = player.Character
 local hum = ch and ch:FindFirstChildOfClass("Humanoid")
 if not hum or hum.Health <= 0 then return end
 if enabled then
  if hum.Sit or os.clock() - (lastStart[player] or -math.huge) < .1 then return end
  lastStart[player] = os.clock()
 end
 ch:SetAttribute("Sprinting", enabled)
 hum.WalkSpeed = enabled and settings.SprintSpeed or settings.WalkSpeed
end)
Players.PlayerAdded:Connect(join)
Players.PlayerRemoving:Connect(function(player) lastStart[player] = nil end)
for _,player in Players:GetPlayers() do join(player) end
