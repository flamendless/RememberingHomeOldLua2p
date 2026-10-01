-- Extends vendored Flux without patching modules/flux/flux.lua.
local BaseFlux = require("modules.flux.flux")

local tweens_for = setmetatable({}, { __mode = "k" })

local Flux = setmetatable({}, { __index = BaseFlux })

local function track(obj, tween)
	local set = tweens_for[obj]
	if not set then
		set = {}
		tweens_for[obj] = set
	end
	set[tween] = true
end

local function untrack(obj, tween)
	local set = tweens_for[obj]
	if not set then
		return
	end
	set[tween] = nil
	if not next(set) then
		tweens_for[obj] = nil
	end
end

function Flux.to(obj, time, vars)
	assert:type(time, "number")
	local tween = BaseFlux.to(obj, time, vars)
	track(obj, tween)
	tween:oncomplete(function()
		untrack(obj, tween)
	end)
	return tween
end

function Flux.update(dt)
	assert:type(dt, "number")
	return BaseFlux.update(dt)
end

function Flux.remove(x)
	assert:type(x, "number")
	return BaseFlux.remove(x)
end

function Flux.remove_by_object(obj)
	local set = tweens_for[obj]
	if not set then
		return
	end
	for tween in pairs(set) do
		tween:stop()
		untrack(obj, tween)
	end
end

function Flux.count()
	local n = 0
	for _, set in pairs(tweens_for) do
		for _ in pairs(set) do
			n = n + 1
		end
	end
	return n
end

return Flux
