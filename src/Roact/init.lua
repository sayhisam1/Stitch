return function(stitch, roact)
	stitch.roact = roact
	local roactTree = roact.mount(roact.createFragment({}))

	stitch:on("destroyed", function()
		roact.unmount(roactTree)
	end)

	local dirty = {}
	local roactElements = {}
	stitch:on("patternUpdated", function(uuid)
		if dirty[uuid] ~= nil then
			dirty[uuid] = true
		end
	end)
	stitch:on("patternConstructed", function(uuid)
		local pattern = stitch:lookupPatternByUuid(uuid)
		if pattern.render then
			dirty[uuid] = true
		end
	end)
	stitch:on("patternDeconstructed", function(uuid)
		dirty[uuid] = nil
		roactElements[uuid] = nil
	end)

	-- isolate render to make sure it only happens once per frame
	local heartbeatListener = stitch.Heartbeat:connect(function()
		debug.profilebegin("StitchRoactRenderLoop")
		for uuid, isDirty in pairs(dirty) do
			if isDirty then
				local pattern = stitch:lookupPatternByUuid(uuid)
				dirty[uuid] = false
				roactElements[uuid] = pattern:render(roact.createElement)
			end
		end
		roact.update(roactTree, roact.createFragment(roactElements))
		debug.profileend()
	end)

	stitch:on("destroyed", function()
		heartbeatListener:disconnect()
		dirty = nil
		roactElements = nil
	end)
end
