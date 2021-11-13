---
sidebar_position: 2
---

# Installation

### Method 1 (recommended) - Using [Wally](https://wally.run/) and [Rojo](https://rojo.space/)
1. Add `Stitch = "sayhisam1/stitch@0.11.0"` under the [dependencies] section in `wally.toml`
2. Use `wally install` to automatically download Stitch
3. Update your [Rojo configuration](https://rojo.space/docs/6.x/project-format/) to point to the appropriate path and sync the file in.

### Method 2 - Manual
1. Visit the [latest release page](https://github.com/sayhisam1/Stitch/releases/latest)
2. Under *Assets*, click `Stitch.rbxm` to download it
3. - Using [Rojo](https://rojo.space/)? Put `Stitch.rbxm` in your game source directly.
   - Using Roblox Studio? In the Explorer, navigate to where you wish to insert Stitch into (typically under `ReplicatedStorage`). Right-click and select `Insert from file` in menu.

### Method 3 - Git Submodule
1. Add the Stitch repository as a git submodule (ideally within a folder called `submodules`) (tutorial [here](https://gist.github.com/gitaarik/8735255))
2. Update your [Rojo configuration](https://rojo.space/docs/6.x/project-format/) to point to the appropriate path and sync the file in.