-- Retired after the living-laboratory checkpoint.
assert(not (workspace:FindFirstChild("VesperLab") and workspace.VesperLab:GetAttribute("LivingLabRevision")), "Historical environment recipe retired; use LivingLabBuilder")
-- Edit-time cleanup of the six retired upper-shell lamp housings.
-- Keep the originals outside Workspace for restoration.
assert(not game:GetService("RunService"):IsRunning(), "Edit only")
local lab = workspace.VesperLab
local archive = game.ServerStorage:FindFirstChild("Stage21InterfaceFixtureBackup")
if not archive then
	archive = Instance.new("Folder")
	archive.Name = "Stage21InterfaceFixtureBackup"
	archive.Parent = game.ServerStorage
end
local count = 0
for _, model in lab.FixtureHousings:GetChildren() do
	local housing = model:FindFirstChild("ContinuousHousing")
	if housing and housing.Position.Y > 100 and housing.Position.Y < 110 then
		model.Parent = archive
		count += 1
	end
end
return count
