-- Phase 5 cleanup: exact retired UI factories, including obsolete recovery copies in the active place.
-- Native recovery is held privately in Backups/InteriorPhase5_20261111.
assert(game.PlaceId==94763223427049 and not game:GetService("RunService"):IsRunning())
local retired={ExcavationChrome=true,ResearchJournal=true,InterfaceStyle=true,NavigationArtwork=true,OutfitterArt=true,OutfitterComponents=true,HUDLayout=true,UIMotion=true,ModalLayout=true}
local replaced={FieldHUD=true,HUDController=true,DiscoveryHUD=true,WorkshopUI=true,SecondaryMenus=true,SkillTreeUI=true,ExpeditionResults=true,MaterialBag=true,EquipmentDock=true,ExcavationUI=true,LoadingView=true,DispatchUI=true}
local removed={}
for _,s in game:GetDescendants() do
 if s:IsA("LuaSourceContainer") then
  local archived=s:IsDescendantOf(game.ServerStorage) and not s:IsDescendantOf(game.ServerStorage.VesperTools)
  if retired[s.Name] or (archived and replaced[s.Name]) then table.insert(removed,s:GetFullName());s:Destroy() end
 end
end
table.sort(removed)
return removed
