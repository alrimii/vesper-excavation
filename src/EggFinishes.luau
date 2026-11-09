-- Shared organic shell PBR, projected from a Studio material study and finished in Blender.
local rows = {}
for row = 0, 39 do
 local height = row / 39
 local tint = height < 0.52
  and Color3.fromRGB(208, 188, 146):Lerp(Color3.fromRGB(245, 230, 199), height / 0.52)
  or Color3.fromRGB(245, 230, 199):Lerp(Color3.fromRGB(255, 250, 234), (height - 0.52) / 0.48)
 rows[row] = { Color = "rbxassetid://99715008374450", Roughness = "rbxassetid://73986333820756", Tint = tint }
end
return {Default = {DisplayName = "Ancient nacre shell", Normal = "rbxassetid://85174688266648", Metalness = "rbxassetid://71317019076258", Rows = rows}}
