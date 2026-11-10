-- Edit-only normalization after inserting the four actual uploaded models.
-- Pass the decoded export-materials.json table. Never executes gameplay code.
return function(data, names)
	assert(game.PlaceId == 94763223427049 and not game:GetService("RunService"):IsRunning())
	local library = game.ServerStorage.CompactInteriorAssets
	local report = {}
	local function v(a)
		return Vector3.new(table.unpack(a))
	end
	for _, name in names or { "ChargeBundle", "FossilStudy", "Microscope", "EnclosurePanes" } do
		local m = assert(library:FindFirstChild(name))
		assert(not m:GetAttribute("NormalizedFromExport"), "Already normalized: " .. name)
		local expected = data[name]
		local parts = {}
		for _, p in m:GetDescendants() do
			assert(not p:IsA("LuaSourceContainer"), "Unexpected source in imported asset")
			if p:IsA("PackageLink") then
				p:Destroy()
			end
			if p:IsA("BasePart") then
				table.insert(parts, p)
			end
		end
		assert(#parts == #expected.primitives, name .. " imported primitive count mismatch")
		m.PrimaryPart = nil
		local cf, size = m:GetBoundingBox()
		assert(
			cf.RightVector:Dot(Vector3.xAxis) > 0.999 and cf.UpVector:Dot(Vector3.yAxis) > 0.999,
			name .. " unexpected orientation"
		)
		local wanted = v(expected.size)
		local factor = wanted.Magnitude / size.Magnitude
		assert((size * factor - wanted).Magnitude < 0.08, name .. " imported proportions mismatch")
		m.WorldPivot = cf
		m:ScaleTo(m:GetScale() * factor)
		-- This importer bakes a 180-degree Y turn into GLB mesh coordinates.
		-- Restore the authored orientation and verify each primitive's actual bounds below.
		m:PivotTo(CFrame.new(v(expected.center)) * CFrame.Angles(0, math.pi, 0))
		m.WorldPivot = CFrame.identity
		local used, records, maxError = {}, {}, 0
		for _, p in parts do
			local best, score = nil, math.huge
			for i, r in expected.primitives do
				if not used[i] then
					local error = (p.Size - v(r.size)).Magnitude + (p.Position - v(r.center)).Magnitude
					if error < score then
						best, score = i, error
					end
				end
			end
			assert(best and score < 0.08, name .. " mesh correspondence failed: " .. tostring(score))
			used[best] = true
			maxError = math.max(score, maxError)
			local r = expected.primitives[best]
			p.Name = r.node .. "_" .. tostring(r.primitive + 1)
			p.Size, p.CFrame = v(r.size), CFrame.new(v(r.center)) * p.CFrame.Rotation
			p.Color = Color3.fromRGB(table.unpack(r.colorSrgb))
			p.Material = Enum.Material.SmoothPlastic
			p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery = true, false, false, false
			p:SetAttribute("SourceMaterial", r.material)
			p:SetAttribute("SourcePrimitive", best)
			table.insert(records, { name = p.Name, meshId = p.MeshId, color = r.colorSrgb, primitive = best })
		end
		m:SetAttribute("NormalizedFromExport", true)
		m:SetAttribute("AssetLibraryRevision", 1)
		report[name] = {
			meshParts = #parts,
			importScaleCorrection = factor,
			maximumCorrespondenceError = maxError,
			meshes = records,
		}
	end
	return report
end
