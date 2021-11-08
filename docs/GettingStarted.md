---
sidebar_position: 3
---

# Getting Started

# What is Stitch?
**Stitch** is a simple and powerful [Entity Component System (ECS)](https://en.wikipedia.org/wiki/Entity_component_system) built specifically for Roblox game development. 

Stitch allows you to separate the **data** and **behavior** of things in your game. This means your code will be easier to understand and update, and more performant.

# Installation
Follow the [installation guide](Installation.md) to install Stitch. 

# Basic Usage
The basic pattern behind Stitch is to create a single script on the server and a single script on the client. Both scripts will do the same thing - create a new World and register some Systems and Components to it. 

Here's what the simplest example of creating a world would look like:
```lua
-- Change this if you installed Stitch to a different folder
local Stitch = require(game:GetService("ReplicatedStorage").Packages.Stitch) 

local world = Stitch.World.new()
```
We would need to have this code on both the server and client. 

# Entities
An entity is anything in your game. It could be a part, a NPC, or a weapon. Entities can have multiple Components attached to them. Stitch automatically treats Roblox instances as entities, so you don't have to do anything special to use them.

# Registering a new Component
A Component is a way to store data for one aspect of an entity. For example, a `Zombie` npc in your game may have a `Health` component, as well as a `Damage` component. In Stitch, components should **only be used for data**. 

Before they can be used, Components must be registered. Here's how to register a simple Component to the world:

```lua
local Stitch = require(game:GetService("ReplicatedStorage").Packages.Stitch)

local world = Stitch.World.new()

-- Registers a simple component called "velocity" to the world
world:registerComponent({
	name = "velocity"
})
```

Now that we have registered a component, we can now attach it to instances. Let's say you had a part named `Arrow` in `Workspace`. We can use the `velocity` component like this:

```lua
-- Add a velocity component to Arrow:
world:addComponent("velocity", Workspace.Arrow, {
	value = Vector3.new(0, 0, 0)
})

-- Get the velocity component from Arrow:
arrowVelocity = world:getComponent("velocity", Workspace.Arrow)
print(arrowVelocity.value) -- prints Vector3.new(0, 0, 0)

-- Set the data of the component to something else:
world:setComponent("velocity", Workspace.Arrow, {
	value = Vector3.new(1, 0, 0)
})
```

# Adding a System
We can now associate behavior with the `velocity` component using a System. A System is a way to associate behavior to one or many components. A key idea of the ECS pattern is that Systems should not store any state themselves; Data should only be store on Components, and behavior should be handled by Systems.

We previously defined a `velocity` component, and attached it to an Arrow. Let's now define a system that moves anything with the `velocity` component:

```lua
-- add a new system to the world that moves all instances with a velocity component
world:addSystem({
	name = "VelocitySystem",
	onUpdate = function(world, dt) -- onUpdate is passed the world and time since last update
		-- query to iterate through all entities with a velocity component
		world:createQuery():all("velocity"):forEach(function(instance, velocityData)
			instance.Position = instance.Position + velocityData.value * dt
		end)
	end
})
```
If you run the game now, you should see that anything with a `velocity` component is moving.

| ❗ To take full advantage of what Stitch can do, it is recommended to keep each System and Component in a different `ModuleScript`. Please take a look at a more [advanced example](https://github.com/sayhisam1/Stitch/tree/master/examples/tetris) to see how this would work in practice. | 
| ----------------------------------------------------------------------------------------------------- |
