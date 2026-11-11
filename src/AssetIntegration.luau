-- Original Blender props imported by the creator; shared gameplay and joints remain intact.
local A = {}
function A.Tools()
	return require(script.Parent.ToolPresentationBuilder).Build()
end
function A.Lighting()
	error("Obsolete independent fixture placement retired; use LabInteriorBuilder")
end
return A
