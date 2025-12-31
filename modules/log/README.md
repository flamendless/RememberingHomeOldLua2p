# log.lua
A tiny logging module for Lua. WITH ADDED SUPPORT FOR LOVE AND VIM USERS!

## Difference with the original repo (rxi's)

* Setup for vim users to correctly display color
* Save output file to appdata (when the game is released) instead of in the project folder
* Allow intercepting function to easily get the string to be printed (for ImGui Console or other custom logging). For usage see: "https://github.com/flamendless/Purrr/blob/da10e0c0479862b8c6c2e1ce44966dd9c7de1ca2/src/debug.lua2p#L286-L301" and this: "https://github.com/flamendless/Purrr/blob/da10e0c0479862b8c6c2e1ce44966dd9c7de1ca2/src/main.lua2p#L22-L26"

## SETUP

Here's a simple setup

* Download and Install this vim [script](https://www.vim.org/scripts/script.php?script_id=302)
* Add this line into your **.vimrc**

```lua
autocmd BufNewFile,BufRead *.log :AnsiEsc
```

```lua
local Log = require("path-to-log.lua")
Log.usecolor = false
Log.lovesave = true
```
When you open the **log.log** file in your love appdata directory, that should be colorized :)

Then call `log.quit(filename)` at `love.quit` to finally write file to the output file
```lua
local Log = require("path-to-log.lua")
Log.lovesave = true

Log.trace("Hello")
Log.info("World")

function love.quit()
	Log.quit("log.txt")
end
```

## Installation
The [log.lua](log.lua?raw=1) file should be dropped into an existing project
and required by it.
```lua
log = require "log"
``` 

## Usage
log.lua provides 6 functions, each function takes all its arguments,
concatenates them into a string then outputs the string to the console and --
if one is set -- the log file:

* **log.trace(...)**
* **log.debug(...)**
* **log.info(...)**
* **log.warn(...)**
* **log.error(...)**
* **log.fatal(...)**


### Additional options
log.lua provides variables for setting additional options:

#### log.usecolor
Whether colors should be used when outputting to the console, this is `true` by
default. If you're using a console which does not support ANSI color escape
codes then this should be disabled.

#### log.outfile
The name of the file where the log should be written, log files do not contain
ANSI colors and always use the full date rather than just the time. By default
`log.outfile` is `nil` (no log file is used). If a file which does not exist is
set as the `log.outfile` then it is created on the first message logged. If the
file already exists it is appended to.

#### log.level
The minimum level to log, any logging function called with a lower level than
the `log.level` is ignored and no text is outputted or written. By default this
value is set to `"trace"`, the lowest log level, such that no log messages are
ignored.

The level of each log mode, starting with the lowest log level is as follows:
`"trace"` `"debug"` `"info"` `"warn"` `"error"` `"fatal"`


## License
This library is free software; you can redistribute it and/or modify it under
the terms of the MIT license. See [LICENSE](LICENSE) for details.

