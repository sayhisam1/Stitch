local HashMappedTrie = require(script.Parent.Shared.HashMappedTrie)

return function(stitch, roact)
	stitch.Roact = roact
	local roactTree = roact.mount(roact.createFragment({}))
	stitch._maid:giveTask(function()
		roact.unmount(roactTree)
	end)
	local dirty = false

	local storeChanged = stitch._store.changed:connect(function()
		dirty = true
	end)
	stitch._maid:giveTask(storeChanged)
	local StitchComponent = roact.Component:extend("Stitch")

	function StitchComponent:render()
		local patternRenders = {}
		for k, v in pairs(self.props) do
			patternRenders[k] = (v.render and v:render(roact.createElement)) or nil
		end
		return roact.createFragment(patternRenders)
	end

	-- isolate render to make sure it only happens once per frame
	local heartbeatListener = stitch.Heartbeat:connect(function()
		if dirty then
			debug.profilebegin("StitchRoactRenderLoop")
			roact.update(
				roactTree,
				roact.createElement(StitchComponent, HashMappedTrie.getAllKeyValues(stitch._store:getState()))
			)
			debug.profileend()
		end
		dirty = false
	end)
	stitch._maid:giveTask(heartbeatListener)
end
