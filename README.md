# Stitch
Stitch is an Entity Component System (https://en.wikipedia.org/wiki/Entity_component_system) built for Roblox.


Stitch was heavily inspired by [Fabric](https://github.com/evaera/Fabric), and differs in several key ways:
- Stitch is built on top of [Rodux](https://github.com/Roblox/Rodux), which means it benefits from immutability. For performance reasons, immutability is only guaranteed in between flushes (which happen once per frame by default, but can happen more often and on user specification if needed). Stitch also has built-in support for atomic transactions.
- Stitch has native support for Roblox Instance Attributes - this makes it easier to handle behavior like streaming
- Stitch has real Systems, which means data flows "top-down". this makes it easy to use libraries like [Roact](https://github.com/Roblox/Roact) to render state, and also opens the door to optimizations and complex interactions.
- Stitch has clear semantics - there are no black magic getters that have strange side-effects.
- Stitch defers all actions until the end of the frame. This allows for better optimization and clearer semantics, and also better fits with Roblox's upcoming changes to deferred events.


**Stitch is still highly experimental, and should not be considered stable for production use!**

Issues and Pull Requests are appreciated :)

