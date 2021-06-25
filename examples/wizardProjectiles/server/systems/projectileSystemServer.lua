local ProjectileSystemServer = {}

ProjectileSystemServer.name = "ProjectileSystemServer"

function ProjectileSystemServer:onCreate()
	self._touchListeners = {}
	self._entityAdded = self.stitch.entityManager
		:getEntityAddedSignal("projectile")
		:connect(function(entity: Instance, data)
			self._touchListeners[entity] = entity.Touched:connect(function(instance: Instance)
				for _, ignored in pairs(data.ignoreTouchedList) do
					if instance:IsDescendantOf(ignored) then
						return
					end
				end
				entity:destroy()
			end)
		end)
	self._entityRemoved = self.stitch.entityManager:getEntityRemovedSignal("projectile"):connect(function(entity, data)
		if self._touchListeners[entity] then
			self._touchListeners[entity]:disconnect()
			self._touchListeners[entity] = nil
		end
	end)
end

function ProjectileSystemServer:onUpdate() end

function ProjectileSystemServer:onDestroy()
	self._entityAdded:disconnect()
	self._entityRemoved:disconnect()
	for entity, listener in pairs(self._touchListeners) do
		listener:disconnect()
		self._touchListeners[entity] = nil
	end
end

return ProjectileSystemServer
