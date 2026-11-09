-- Display choices never change the equipped mining companion.
local S = {}
function S.Normalize(saved, owned, variants)
	local result, used = { "", "", "" }, {}
	if type(saved) ~= "table" then
		local index = 1
		for _, entry in variants do
			if (owned[entry.Id] or 0) > 0 and index <= 3 then
				result[index] = entry.Id
				index += 1
			end
		end
		return result
	end
	for i = 1, 3 do
		local id = saved[i]
		if type(id) == "string" and (owned[id] or 0) > 0 and not used[id] then
			result[i], used[id] = id, true
		end
	end
	return result
end
function S.Assign(slots, owned, index, id)
	if type(index) ~= "number" or index ~= index or index % 1 ~= 0 or index < 1 or index > 3 then
		return false
	end
	if type(id) ~= "string" or (id ~= "" and (owned[id] or 0) < 1) then
		return false
	end
	-- Moving a displayed creature swaps positions rather than discarding the other display.
	if id ~= "" then
		for i = 1, 3 do
			if i ~= index and slots[i] == id then
				slots[i] = slots[index]
				break
			end
		end
	end
	slots[index] = id
	return true
end
return S
