

local WorldInterface = {}
WorldInterface.__index = WorldInterface

function WorldInterface.new()
end

function WorldInterface:destroy()
end

function WorldInterface:registerComponent()
end

function WorldInterface:unregisterComponent()
end

function WorldInterface:createQuery()
end

function WorldInterface:addSystem()
end

function WorldInterface:removeSystem()
end

function WorldInterface:addComponent(): {}
end

function WorldInterface:getComponent(): {}?
end

function WorldInterface:getEntitiesWith()
end

function WorldInterface:setComponent(): {}
end

function WorldInterface:updateComponent(): {}
end

function WorldInterface:removeComponent()
end

function WorldInterface:getComponentAddedSignal()
end

function WorldInterface:getComponentChangedSignal()
end

function WorldInterface:getComponentRemovingSignal()
end

function WorldInterface:getComponents()
end

function WorldInterface:getEntityAddedSignal()
end

function WorldInterface:getEntityChangedSignal()
end

function WorldInterface:getEntityRemovingSignal()
end


return WorldInterface
