-- Atomic, non-yielding session allocation. This module never trusts client input.
local RoomPool = {}
RoomPool.__index = RoomPool
function RoomPool.new(capacity)
 assert(capacity > 0 and capacity % 1 == 0, "capacity must be a positive integer")
 return setmetatable({capacity=capacity, byUser={}, byRoom={}},RoomPool)
end
function RoomPool:Assign(userId)
 local existing=self.byUser[userId]
 if existing then return existing end
 for room=1,self.capacity do
  if self.byRoom[room]==nil then
   self.byRoom[room]=userId
   self.byUser[userId]=room
   return room
  end
 end
 return nil
end
function RoomPool:Release(userId)
 local room=self.byUser[userId]
 if not room then return nil end
 self.byUser[userId]=nil
 if self.byRoom[room]==userId then self.byRoom[room]=nil end
 return room
end
function RoomPool:Get(userId) return self.byUser[userId] end
return RoomPool
