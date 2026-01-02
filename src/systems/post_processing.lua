local Concord = require("modules.concord.concord")
local Log = require("modules.log.log")

local Canvas = require("canvas")

local DevTools

local PostProcessing = Concord.system()

function PostProcessing:init(world)
	DevTools = require("devtools")

	self.world = world
	self.buffer1 = Canvas.create_main()
	self.buffer2 = Canvas.create_main()
	self.effects = {}
end

function PostProcessing:setup_post_process(t)
	if not (type(t) == "table" and #t > 0) then
		error('Assertion failed: type(t) == "table" and #t > 0')
	end
	local t_names = functional.map(t, function(v)
		return v:type()
	end)
	Log.info("Setup post processing effects:", table.concat(t_names, ","))
	self.effects = t

	DevTools.pp_effects = self.effects
	functional.foreach(DevTools.pp_effects, function(effect)
		effect.debug_show = effect.is_active
	end)
end

function PostProcessing:set_post_process_effect(id, bool)
	if not (type(id) == "string") then
		error('Assertion failed: type(id) == "string"')
	end
	if not (type(bool) == "boolean") then
		error('Assertion failed: type(bool) == "boolean"')
	end
	for _, effect in ipairs(self.effects) do
		local t = effect.get_type and effect:get_type() or effect:type()
		if t == id then
			effect.is_active = bool
			return
		end
	end
	if not false then
		error(id .. " not found in registered pp effects")
	end
end

function PostProcessing:ev_pp_invoke(id, str_fn, ...)
	if not (type(id) == "string") then
		error('Assertion failed: type(id) == "string"')
	end
	if not (type(str_fn) == "string") then
		error('Assertion failed: type(str_fn) == "string"')
	end
	for _, effect in ipairs(self.effects) do
		local t = effect.get_type and effect:get_type() or effect:type()
		if t == id then
			effect[str_fn](effect, ...)
			return
		end
	end
	if not false then
		error(id .. " was not registered")
	end
end

function PostProcessing:update(dt)
	for _, effect in ipairs(self.effects) do
		effect.debug_show = effect.is_active

		if effect.update then
			effect:update(dt)
		end
	end
end

function PostProcessing:apply_post_process(canvas)
	if not (canvas:type() == "CustomCanvas") then
		error('Assertion failed: canvas:type() == "CustomCanvas"')
	end
	love.graphics.setCanvas(self.buffer1.canvas)
	love.graphics.clear()
	canvas:render_n()
	love.graphics.setCanvas()

	for _, effect in ipairs(self.effects) do
		if effect.is_active then
			love.graphics.setCanvas(self.buffer2.canvas)
			love.graphics.clear()
			love.graphics.setShader(effect.shader)
			self.buffer1:render_n()
			love.graphics.setShader()
			love.graphics.setCanvas()
			self.buffer1, self.buffer2 = self.buffer2, self.buffer1
		end
	end

	self.buffer1:render_n()
end

local Slab = require("modules.slab")

function PostProcessing:debug_update(dt)
	if not self.debug_show then
		return
	end

	self.debug_show = Slab.BeginWindow("pp", {
		Title = "PostProcessing",
		IsOpen = self.debug_show,
	})

	for i, effect in ipairs(self.effects) do
		local b
		local str = effect.get_type and effect:get_type() or effect:type()

		if Slab.CheckBox(effect.debug_show, str) then
			effect.is_active = not effect.is_active
		end
		Slab.SameLine()

		if Slab.Button("up") then
			b = mathx.wrap_index(i - 1, self.effects)
		end

		Slab.SameLine()
		if Slab.Button("down") then
			b = mathx.wrap_index(i + 1, self.effects)
		end

		if b then
			self.effects[i], self.effects[b] = self.effects[b], self.effects[i]
		end
	end
	Slab.EndWindow()
end

return PostProcessing
