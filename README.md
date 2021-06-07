# Stitch
Stitch is an Entity Component System (https://en.wikipedia.org/wiki/Entity_component_system) built for Roblox.


Stitch was heavily inspired by [Fabric](https://github.com/evaera/Fabric), and differs in several key ways:
- Stitch is built on top of [Rodux](https://github.com/Roblox/Rodux), which means it benefits from immutability
- Stitch has native support for Roblox Instance Attributes - this makes it easier to handle behavior like streaming
- Stitch has real Systems, which means data flows "top-down". this makes it easy to use libraries like [Roact](https://github.com/Roblox/Roact) to render state, and also opens the door to optimizations and complex interactions.
- Stitch defers all actions until the end of the frame. This allows for better optimization and clearer semantics, and also better fits with Roblox's upcoming changes to deferred events.


**Stitch is still highly experimental, and should not be considered stable for production use**I
Issues and Pull Requests are appreciated :)

