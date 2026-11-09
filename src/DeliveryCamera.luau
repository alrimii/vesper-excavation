-- One camera owner for dispatch; completion or interruption always restores control.
local M = {}
function M.Start(player, state, gui)
	local Run = game:GetService("RunService")
	local CAS = game:GetService("ContextActionService")
	local Phase = require(script.Parent.ExpeditionPhase)
	local owned, suppressed
	local function finish()
		if not owned then
			return
		end
		local saved = owned
		owned = nil
		CAS:UnbindAction("VesperDeliveryLock")
		player:SetAttribute("DiscoveryCinematic", false)
		if saved.camera == workspace.CurrentCamera then
			saved.camera.CameraType = saved.kind
			saved.camera.CFrame = saved.cf
			saved.camera.FieldOfView = saved.fov
		end
	end
	Run:BindToRenderStep("VesperDeliveryCamera", Enum.RenderPriority.Camera.Value + 3, function()
		local status, phaseStarted = Phase.Read(state)
		local active = status == "Selecting" or status == "Delivering"
		local round = state:GetAttribute("RoundId")
		local ch = player.Character
		local hum = ch and ch:FindFirstChildOfClass("Humanoid")
		if not active then
			finish()
			suppressed = nil
			return
		end
		if
			owned
			and (
				ch ~= owned.character
				or not hum
				or hum.Health <= 0
				or workspace.CurrentCamera ~= owned.camera
			)
		then
			suppressed = round
			finish()
		end
		if suppressed == round or not hum or hum.Health <= 0 or not player:GetAttribute("LabReady") then
			return
		end
		local camera = workspace.CurrentCamera
		if not owned then
			if player:GetAttribute("DiscoveryCinematic") then
				return
			end
			owned = {
				camera = camera,
				kind = camera.CameraType,
				cf = camera.CFrame,
				fov = camera.FieldOfView,
				character = ch,
				started = os.clock(),
			}
			player:SetAttribute("DiscoveryCinematic", true)
			game.ReplicatedStorage.VesperShared.Remotes.Action:FireServer("Cancel")
			CAS:BindActionAtPriority(
				"VesperDeliveryLock",
				function()
					return Enum.ContextActionResult.Sink
				end,
				false,
				6000,
				Enum.PlayerActions.CharacterForward,
				Enum.PlayerActions.CharacterBackward,
				Enum.PlayerActions.CharacterLeft,
				Enum.PlayerActions.CharacterRight,
				Enum.PlayerActions.CharacterJump,
				Enum.KeyCode.E,
				Enum.UserInputType.MouseButton1,
				Enum.KeyCode.ButtonR2
			)
			camera.CameraType = Enum.CameraType.Scriptable
		end
		hum:Move(Vector3.zero, false)
		local age = math.max(0, workspace:GetServerTimeNow() - phaseStarted)
		local pose = require(script.Parent.DeliverySequence).Sample(status == "Delivering" and age or 0)
		local reduced = player:GetAttribute("ReducedMotion")
		local portrait = camera.ViewportSize.X < camera.ViewportSize.Y
		local Sequence = require(script.Parent.DeliverySequence)
		local travel = status == "Delivering" and Sequence.Ease(age / 5.4) or 0
		local orbit = status == "Delivering" and Sequence.Ease((age - 5.4) / 4.3) or 0
		local angle = -0.55 + orbit * 0.65
		local radius = (portrait and 225 or 170) - travel * 15
		local focus = Vector3.new(0, 58 + pose.eggLift * 0.72 + orbit * 17, 0)
		local position =
			Vector3.new(math.sin(angle) * radius, 118 - travel * 43 + orbit * 28, -math.cos(angle) * radius)
		if reduced then
			position = Vector3.new(-110, 110, -200)
			focus = Vector3.new(0, 87, 0)
		end
		local shot = CFrame.lookAt(position, focus)
		local intro = Sequence.Ease((os.clock() - owned.started) / 1.1)
		local returning = status == "Delivering" and pose.returnCamera or 0
		camera.CFrame = owned.cf:Lerp(shot, intro):Lerp(owned.cf, returning)
		local targetFov = portrait and 72 or (61 - travel * 6 + orbit * 3)
		camera.FieldOfView = owned.fov + (targetFov - owned.fov) * intro * (1 - returning)
	end)
	gui.Destroying:Connect(function()
		finish()
		Run:UnbindFromRenderStep("VesperDeliveryCamera")
	end)
end
return M
