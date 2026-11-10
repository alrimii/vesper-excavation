-- Retained editor entry point; preserves the actual shop interaction/tool instances.
local B = {}
function B.Build()
	return require(script.Parent.LabInteriorBuilder).Workshop()
end
return B
