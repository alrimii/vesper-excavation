-- Compatibility entry points. Superseded v149 enclosure/frontage/floor constructors are removed.
local B = {}
local function interior()
	return require(script.Parent.LabInteriorBuilder)
end
function B.FloorAndAccess()
	return { interior().Floor(), interior().Access() }
end
function B.Workshop()
	return interior().Workshop()
end
function B.BaysAndRooms()
	return interior().Frontage()
end
function B.Envelope()
	return interior().Enclosure()
end
function B.Exterior()
	error("Exterior frozen; this recipe cannot regenerate scenery")
end
function B.Anchors()
	error("Existing functional anchor references are preserved, not rebuilt")
end
return B
