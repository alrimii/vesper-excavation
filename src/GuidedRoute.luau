-- A visual route only: never moves the player. Path requests are bounded and cancellable.
local M = {}
local Paths = game:GetService("PathfindingService")
function M.new(parts, world)
	local self = { generation = 0, nextRequest = 0, points = {}, index = 2 }
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.RespectCanCollide = true
	function self:Clear()
		if self.goal then
			self.generation += 1
		end
		self.goal = nil
		self.points = {}
		if self.blocked then
			self.blocked:Disconnect()
			self.blocked = nil
		end
		if self.path then
			self.path:Destroy()
			self.path = nil
		end
		for _, p in parts do
			p.Transparency = 1
		end
	end
	function self:Update(root, goal, character, reduced)
		if not root or not goal then
			self:Clear()
			return
		end
		if self.character ~= character or not self.goal or (self.goal - goal).Magnitude > 5 then
			self:Clear()
			self.character, self.goal, self.nextRequest = character, goal, 0
		end
		local now = os.clock()
		if not self.pending and now >= self.nextRequest then
			self.pending = true
			self.nextRequest = now + 2
			local generation, start = self.generation, root.Position
			local path = Paths:CreatePath({
				AgentRadius = 2,
				AgentHeight = 5,
				AgentCanJump = false,
				WaypointSpacing = 5,
			})
			task.spawn(function()
				local ok = pcall(function()
					path:ComputeAsync(start, goal)
				end)
				self.pending = false
				if self.generation ~= generation or not world.Parent then
					path:Destroy()
					return
				end
				if self.blocked then
					self.blocked:Disconnect()
					self.blocked = nil
				end
				if self.path then
					self.path:Destroy()
				end
				self.path = path
				self.points = ok and path.Status == Enum.PathStatus.Success and path:GetWaypoints() or {}
				self.index = 2
				self.blocked = path.Blocked:Connect(function(index)
					if index >= self.index then
						self.points = {}
						self.nextRequest = 0
					end
				end)
			end)
		end
		params.FilterDescendantsInstances = { character, world }
		local points = self.points
		while points[self.index] and (points[self.index].Position - root.Position).Magnitude < 5 do
			self.index += 1
		end
		local cursor = self.index
		local from = points[cursor - 1] and points[cursor - 1].Position
		local to = points[cursor] and points[cursor].Position
		local distance = 0
		if from and to then
			local segment = to - from
			if segment.Magnitude > 0.01 then
				distance = math.clamp((root.Position - from):Dot(segment.Unit), 0, segment.Magnitude)
			end
		end
		distance += reduced and 2 or 2 + (now * 2) % 3.5
		for _, p in parts do
			p.Transparency = 1
			while from and to and distance > (to - from).Magnitude do
				distance -= (to - from).Magnitude
				cursor += 1
				from, to = to, points[cursor] and points[cursor].Position
			end
			if from and to and (to - from).Magnitude > 0.01 then
				local direction = (to - from).Unit
				local point = from + direction * distance
				local hit = workspace:Raycast(point + Vector3.yAxis * 3, -Vector3.yAxis * 8, params)
				local flat = Vector3.new(direction.X, 0, direction.Z)
				if hit and hit.Normal.Y > 0.55 and flat.Magnitude > 0.01 then
					local pos = hit.Position + Vector3.yAxis * 0.08
					p.CFrame = CFrame.lookAt(pos, pos + flat)
					p.Transparency = 0.25
				end
			end
			distance += 3.5
		end
	end
	world.Destroying:Connect(function()
		self:Clear()
		self.generation += 1
	end)
	return self
end
return M
