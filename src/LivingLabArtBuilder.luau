-- Compatibility entry points. Superseded v156 interior constructors are removed.
local B = {}
local function interior()
	return require(script.Parent.LabInteriorBuilder)
end
function B.Floor()
	return interior().Floor()
end
function B.Planting()
	return interior().Commons()
end
function B.Frontage()
	return interior().Frontage()
end
function B.Fossils()
	return interior().Specimen()
end
function B.WorkshopAndAccess()
	return { interior().Workshop(), interior().Access() }
end
function B.Exterior()
	error("Exterior frozen; this recipe cannot regenerate scenery")
end
function B.CrownAndLighting()
	error("Crown, glazing and global lighting are preserved; retired recipe")
end
return B
