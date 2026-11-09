-- Essential-asset readiness, not a timer pretending to be loading progress.
local Players = game:GetService("Players")
local CP = game:GetService("ContentProvider")
local CAS = game:GetService("ContextActionService")
local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")
player:SetAttribute("LabReady", false)
player:SetAttribute("DiscoveryCinematic", false)
player:SetAttribute("CoreMenuOpen", false)
CAS:UnbindAction("VesperDeliveryLock")
CAS:UnbindAction("DiscoveryRevealLock")
local view = require(script.Parent:WaitForChild("LoadingView")).Build(pg)
local gui, status, enter = view.gui, view.status, view.enter
game:GetService("ReplicatedFirst"):RemoveDefaultLoadingScreen()
CAS:BindActionAtPriority(
	"VesperLoading",
	function()
		return Enum.ContextActionResult.Sink
	end,
	false,
	4000,
	Enum.PlayerActions.CharacterForward,
	Enum.PlayerActions.CharacterLeft,
	Enum.PlayerActions.CharacterBackward,
	Enum.PlayerActions.CharacterRight,
	Enum.PlayerActions.CharacterJump,
	Enum.KeyCode.E,
	Enum.KeyCode.One,
	Enum.KeyCode.Two
)
local resize = game:GetService("RunService").RenderStepped:Connect(function()
	local camera = workspace.CurrentCamera
	local v = camera and camera.ViewportSize or Vector2.new(800, 600)
	view:Resize(v)
end)
local shared = game.ReplicatedStorage:WaitForChild("VesperShared")
local state = shared:WaitForChild("RoundState")
local config = require(shared:WaitForChild("ExcavationConfig"))
local egg = workspace:WaitForChild("VesperLab"):WaitForChild("Egg")
local sections = egg:WaitForChild("Sections")
local hud = pg:WaitForChild("ExcavationHUD")
hud.Enabled = false
if not game:IsLoaded() then
	game.Loaded:Wait()
end
view:Stage(2)
status.Text = "Synchronizing the current egg and your inventory..."
local deadline = os.clock() + 45
while
	not state:GetAttribute("Initialized")
	or not player:GetAttribute("ProfileReady")
	or not player:GetAttribute("GameplayClientReady")
	or not shared:GetAttribute("PresentationReady")
	or not game.ReplicatedStorage.VesperShared:GetAttribute("OuterFracturesReady")
	or not player:GetAttribute("OuterFracturesClientReady")
	or #sections:GetChildren() < (egg:GetAttribute("SectionCount") or 0)
do
	if shared:GetAttribute("PresentationError") then
		status.Text = "The laboratory could not prepare the egg. Please reconnect after setup is corrected."
		enter.Text = "LAB SETUP REQUIRED"
		return
	end
	if shared:GetAttribute("OuterFractureError") then
		status.Text = "The egg could not load. Please reconnect to retry."
		enter.Text = "REJOIN REQUIRED"
		return
	end
	if os.clock() > deadline then
		status.Text = "The laboratory could not synchronize. Please reconnect."
		enter.Text = "REJOIN REQUIRED"
		return
	end
	task.wait(0.25)
end
for _, section in sections:GetChildren() do
	if not section:WaitForChild("Plate", 10) then
		status.Text = "A shell section is unavailable. Please reconnect."
		return
	end
end
local textureIds = {
	config.Appearance.ShellIntact,
	config.Appearance.ShellCrackLight,
	config.Appearance.ShellCrackHeavy,
	config.Appearance.ShellRoughness,
}
local essentials = {}
local temporaryAssets = {}
-- Delivery presentation is not an essential joining gate.
-- Texture instances select the image fetch path; bare IDs may be treated as models.
for _, uri in textureIds do
	if uri == "" then
		continue
	end
	local image = Instance.new("ImageLabel")
	image.Image = uri
	table.insert(essentials, image)
	table.insert(temporaryAssets, image)
end
local rows = {}
for _, asset in shared:WaitForChild("FractureLibrary"):GetDescendants() do
	if asset:IsA("MeshPart") and not asset:GetAttribute("ProgressiveFracture") then
		table.insert(essentials, asset)
	end
end
local eggAssets = shared:FindFirstChild("EggAssetPreload")
if eggAssets then
	for _, asset in eggAssets:GetChildren() do
		if asset:IsA("MeshPart") then
			table.insert(essentials, asset)
		end
	end
end
for _, section in sections:GetChildren() do
	local plate = section:FindFirstChild("Plate")
	if plate then
		local key = section:GetAttribute("Layer") .. ":" .. section:GetAttribute("Row")
		if not rows[key] then
			rows[key] = true
			table.insert(essentials, plate)
		end
	end
end
-- Optional HUD artwork must not block egg readiness.
task.spawn(function()
	local icons = {}
	for _, uri in config.Icons do
		local image = Instance.new("ImageLabel")
		image.Image = uri
		table.insert(icons, image)
	end
	pcall(function()
		CP:PreloadAsync(icons)
	end)
	for _, image in icons do
		image:Destroy()
	end
end)
local toolDeadline = os.clock() + 45
local function hasTool()
	local character = player.Character
	local human = character and character:FindFirstChildOfClass("Humanoid")
	if not human or human.Health <= 0 or player:GetAttribute("EquipmentReady") ~= true then
		return false
	end
	-- Reacquire the current Backpack: Roblox replaces it across character lifecycles.
	for _, container in { player:FindFirstChildOfClass("Backpack"), character } do
		if container then
			for _, t in container:GetChildren() do
				local handle = t:FindFirstChild("Handle")
				if
					t:IsA("Tool")
					and t:GetAttribute("OwnerUserId") == player.UserId
					and t:GetAttribute("ToolFamily") == player:GetAttribute("ToolFamily")
					and (not t.RequiresHandle or (handle and handle:IsA("BasePart")))
				then
					return true
				end
			end
		end
	end
	return false
end
while not hasTool() and os.clock() < toolDeadline do
	if player:GetAttribute("EquipmentLoadError") then
		break
	end
	status.Text = "Preparing your equipment..."
	task.wait(0.1)
end
if not hasTool() then
	view:Failure(
		"EQUIPMENT UNAVAILABLE",
		player:GetAttribute("EquipmentLoadError") or "Your equipment did not arrive. Please reconnect."
	)
	return
end
for _, container in { player:FindFirstChildOfClass("Backpack"), player.Character } do
	if container then
		for _, part in container:GetDescendants() do
			if part:IsA("MeshPart") and part:FindFirstAncestorOfClass("Tool") then
				table.insert(essentials, part)
			end
		end
	end
end
-- No timeout silently bypasses essential egg loading. Failed requests can be retried.
local assetsReady, loading, entered = false, false, false
local enterGame
local function prepare()
	if loading then
		return
	end
	loading = true
	enter.Active = false
	enter.AutoButtonColor = false
	enter.Text = "PREPARING EGG..."
	view:Stage(3)
	task.spawn(function()
		local loaded, failed = 0, 0
		local ok, err = pcall(function()
			CP:PreloadAsync(essentials, function(_, fetchStatus)
				loaded += 1
				if fetchStatus ~= Enum.AssetFetchStatus.Success then
					failed += 1
				end
				status.Text = "Loading the egg, equipment, and materials..."
			end)
		end)
		loading = false
		assetsReady = ok and failed == 0
		player:SetAttribute("EggAssetsReady", assetsReady)
		if assetsReady then
			status.Text = "Current egg synchronized. Joining now."
			enter.Text = ""
			view:Stage(4)
			task.defer(function()
				enterGame()
			end)
		else
			warn("[Vesper] Essential preload incomplete", failed, err)
			status.Text = "Some essential assets could not load. Retry to prepare the egg."
			enter.Text = "RETRY LOADING"
		end
		enter.Active = true
		enter.Selectable = true
		enter.AutoButtonColor = true
	end)
end
enterGame = function()
	if entered or loading or not assetsReady then
		return
	end
	-- Asset loading may span a death/respawn; do not release control without current equipment.
	local equipDeadline = os.clock() + 45
	while not hasTool() and os.clock() < equipDeadline do
		status.Text = "Waiting for your character and equipment..."
		if player:GetAttribute("EquipmentLoadError") then
			break
		end
		task.wait(0.1)
	end
	if not hasTool() then
		view:Failure(
			"EQUIPMENT UNAVAILABLE",
			player:GetAttribute("EquipmentLoadError") or "Your equipment did not arrive. Please reconnect."
		)
		return
	end
	entered = true
	status.Text = "Expedition ready"
	hud.Enabled = true
	CAS:UnbindAction("VesperLoading")
	resize:Disconnect()
	for _, asset in temporaryAssets do
		asset:Destroy()
	end
	table.clear(temporaryAssets)
	local human = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	local camera = workspace.CurrentCamera
	if camera and human then
		camera.CameraType, camera.CameraSubject = Enum.CameraType.Custom, human
	end
	player:SetAttribute("GameplayArrivalAt", workspace:GetServerTimeNow())
	player:SetAttribute("LabReady", true)
	gui:Destroy()
end
enter.Activated:Connect(function()
	if not entered and not loading and not assetsReady then
		prepare()
	end
end)
prepare()
