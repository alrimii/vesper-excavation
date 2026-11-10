-- Superseded standalone storefront. Keep one canonical world authoring path.
local M={}
function M.Build()
 return require(script.Parent.LivingLabBuilder).Workshop()
end
return M
