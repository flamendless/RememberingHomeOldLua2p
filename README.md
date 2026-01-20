# NOTE

This repo will now be public, this is for anyone who want to check out the usage with Luapreprocess.
Going further with the development, there will be a lot of changes so we will move that to a new repo which
is private for now.

---

# Remembering Home

![](https://img.shields.io/badge/lua-on%20development-green.svg)
![Lua](https://img.shields.io/badge/Lua-JIT%2C%205.1-blue.svg)
![](https://img.shields.io/badge/made%20with-l%C3%B6ve-blueviolet)
![](https://img.shields.io/twitter/follow/flamendless?style=social)

Made with [LOVE](https://love2d.org)

## Building:

1. Go to the `scripts/` folder and then run `./generate_fonts generate_fonts`, `./generate_fonts convert_fonts`, and `./generate_fonts copy_fonts` first. This is only required once.
2. Then run `./build init` to setup the directories and copy the assets to the output directory.
3. Then `./build run` to preprocess and run the game.

When modifying files in the `res/` or in the `modules/` directory, you should update with `./build rebuild` before running again.

For cleaning files and logs `./build clean && ./build clean_logs`

(see [buid.sh](build.sh) for more info)

## Libraries:

* [anim8](https://github.com/kikito/anim8) - for sprite animation
* [Batteries](https://github.com/1bardesign/batteries) - for class, vec2, vec3, math, string, table, etc.
* [beehive](https://github.com/drhayes/beehive.lua) - for behavior trees for AI
* [bitser](https://github.com/gvx/bitser) - for serialization/deserialization of lua data to binary files
* [bump-niji](https://github.com/oniietzschan/bump-niji) - for 2D collision detection
* [Concord](https://github.com/Tjakka5/Concord) - for Entity Component System
* [Enum](https://github.com/Tjakka5/Enum) - for Enums
* [flux](https://github.com/rxi/flux) - for linear interpolation and tweening
* [gamera](https://github.com/kikito/gamera) - for camera
* [HUMP](https://github.com/vrld/hump) - for Timer
* [jprof](https://github.com/pfirsich/jprof) - for profiling
* [lily](https://github.com/MikuAuahDark/lily) - for asynchronous loading of assets
* [log](https://github.com/flamendless/log.lua) - for logging
* [lume](https://github.com/rxi/lume) - for some utility functions
* [love-sdf-text](https://github.com/Tjakka5/love-sdf-text) - for SDF rendering
* [ngrading](https://github.com/MikuAuahDark/NPad93/tree/master/ngrading) - color grading (heavily modified for this project)
* [Outliner](https://love2d.org/forums/viewtopic.php?p=221215#p221215) - for Outline shader (modified for this project)
* [ReflowPrint](https://github.com/josefnpat/reflowprint) - for alignment of text that is shown one character at a time
* [semver](https://github.com/kikito/semver) - for semantic versioning
* [Slab](https://github.com/flamendless/Slab) - for GUI and in-game editor tools
* [splashes](https://github.com/love2d-community/splashes) - for löve splash screen
* [strict.lua](https://github.com/rxi/lite/blob/master/data/core/strict.lua) - tracks accesses and assignments of undefined variables in Lua
* [TimelineEvents](https://github.com/babulous/TimelineEvents) - for coroutine based event system

## Tools:

* [Export-TextureAtlas](https://github.com/EngineerSmith/Export-TextureAtlas) - for generating atlas textures.
* [HotParticles](https://github.com/ReFreezed/HotParticles) - for testing/playing with particle systems.
* [Luapreprocess](https://github.com/ReFreezed/LuaPreprocess) - for preprocessing `.lua2p` files to `.lua`
* [msdf-bmfont](https://www.npmjs.com/package/msdf-bmfont) - for converting `.ttf` font files to SDF
* [love-build](https://github.com/ellraiser/love-build)

## Credits:

* [pixel-keyboard-layout](https://xphere.itch.io/pixel-keyboard-layout) - for the keyboard art (modified)

## Dependencies:

* [LOVE framework](https://love2d.org) - version 11.3 is used for development
* [rsync](https://rsync.samba.org/) - for copying/moving
* [luacheck](https://github.com/mpeterv/luacheck)
* [love-build](https://github.com/ellraiser/love-build)

## Setup:
* `git clone <this_repo>`
* `git submodule init` then `git submodule update`
* `cd libs/ExportTextureAtlas`, `git submodule init` then `git submodule update`
* `./build.sh init`
* `./build.sh get_love_build`

## Coding Style Guide

* [Look at my coding style guide for Lua](https://flamendless.github.io/lua-coding-style-guide/)

## LICENSE:

* Source code is under the MIT license. See [LICENSE](LICENSE) file.
* Assets are under the CC Attribution license. See [LICENSE](res/LICENSE).
* Each library/module has their own license
