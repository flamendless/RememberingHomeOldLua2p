--
-- log.lua
--
-- Improved by @flamendless
-- * made it more löve-oriented
-- * fixed indentations
-- * localized standard functions for efficiency
--
-- Copyright (c) 2016 rxi
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.
--

local log = { _version = "0.1.0" }

local insert = table.insert
local floor = math.floor
local ceil = math.ceil
local concat = table.concat
local getinfo = debug.getinfo
local format = string.format
local date = os.date

log.usecolor = true
log.lovesave = false
log.useoutcolor = true
log.level = "trace"
log.intercept_fn = nil
log.intercept_caller = nil

log._logs = {}

local modes = {
	{ name = "trace", color = "\27[34m", },
	{ name = "debug", color = "\27[36m", },
	{ name = "info",  color = "\27[32m", },
	{ name = "warn",  color = "\27[33m", },
	{ name = "error", color = "\27[31m", },
	{ name = "fatal", color = "\27[35m", },
}

local levels = {}
for i, v in ipairs(modes) do
	levels[v.name] = i
end

local round = function(x, increment)
	increment = increment or 1
	x = x/increment
	return (x > 0 and floor(x + 0.5) or ceil(x - 0.5)) * increment
end

local _tostring = tostring

local tostring = function(...)
	local t = {}
	for i = 1, select("#", ...) do
		local x = select(i, ...)
		if type(x) == "number" then
			x = round(x, 0.01)
		end
		t[#t + 1] = _tostring(x)
	end
	return concat(t, " ")
end

for i, x in ipairs(modes) do
	local nameupper = x.name:upper()
	log[x.name] = function(...)
		if i < levels[log.level] then return end

		local msg = tostring(...)
		local info = getinfo(2, "Sl")
		local lineinfo = info.short_src .. ":" .. info.currentline

		local str = format("%s[%-6s%s]%s %s: %s",
			log.usecolor and x.color or "",
			nameupper,
			date("%H:%M:%S"),
			log.usecolor and "\27[0m" or "",
			lineinfo,
			msg)

		print(str)

		if log.intercept_fn and log.intercept_caller then
			local str = format("%s[%s]: %s\n", nameupper, lineinfo, msg)
			log.intercept_fn(str)
		end

		if log.lovesave then
			local str = format("[%-6s%s] %s: %s\n",
				nameupper, date(), lineinfo, msg)
			insert(log._logs, str)
		end
	end
end

function log.quit(out_filename)
	local file = love.filesystem.newFile(out_filename , "a")

	for _, str in ipairs(log._logs) do
		file:write(str)
	end
end

return log
