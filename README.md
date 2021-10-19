<p align="center">
  <strong><a href="https://sayhisam1.github.io/Stitch">Now with Documentation!</a></strong>
</p>

# Stitch
Stitch is an Entity Component System (https://en.wikipedia.org/wiki/Entity_component_system) built for Roblox.


Stitch was heavily inspired by several projects, including [Unity's ECS DOTS](https://unity.com/dots) and [evaera's library Fabric](https://github.com/evaera/Fabric).

Stitch has several key features:
- Stitch is made with simplicity in mind. Behavior should be clear and easy to understand. In addition, user-defined components and systems should require minimal boilerplate or understanding of Stitch
- Stitch has real Systems, which means data flows "top-down". this makes it easy to use libraries like [Roact](https://github.com/Roblox/Roact) to render state, and also opens the door to optimizations and complex interactions.
- Stitch has clear semantics - there are no black magic getters that have strange side-effects.


**Stitch is still highly experimental, and should not be considered stable for production use!**

Issues and Pull Requests are appreciated :)

Planned features:
- Efficient Entity querying
- Signals API to listen to Stitch events
- Built-in support for Replication of component data
- A complete, full game example using Stitch
- Support for Roblox Actors for multithreading
- Helper methods to enable distributing tasks over many frames (prevents lagspikes)
- Complete docs
- A plugin frontend to make Stitch incredibly easy to work with
