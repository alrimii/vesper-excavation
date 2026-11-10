-- Superseded standalone storefront. Keep one canonical world authoring path.
local M={}
function M.Build()
 if workspace.VesperLab:GetAttribute('LivingLabArtRevision') then
  return require(script.Parent.LivingLabArtBuilder).WorkshopAndAccess()
 end
 return require(script.Parent.LivingLabBuilder).Workshop()
end
return M
