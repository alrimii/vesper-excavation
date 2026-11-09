-- Status and its clock arrive as one value, preventing a one-frame restart at handoff.
local M = {}
local Http = game:GetService("HttpService")
local cache = setmetatable({}, { __mode = "k" })
function M.Read(state)
	local encoded = state:GetAttribute("PhaseSnapshot")
	local saved = cache[state]
	if encoded and (not saved or saved.encoded ~= encoded) then
		local ok, value = pcall(Http.JSONDecode, Http, encoded)
		if ok and typeof(value.status) == "string" and typeof(value.started) == "number" then
			saved = { encoded = encoded, status = value.status, started = value.started }
			cache[state] = saved
		end
	end
	if saved then
		return saved.status, saved.started
	end
	return state:GetAttribute("Status") or "Excavating",
		state:GetAttribute("PhaseStartedAt") or workspace:GetServerTimeNow()
end
return M
