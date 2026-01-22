local Light = Concord.system({
	pool = { "id", "pos", "transform", "color", "light", "sprite" },
})

local function randomf(min, max)
	return min + love.math.random() * (max - min)
end

local function generate_recolor(e)
	local light = e.light
	local color = e.color.value
	local timer = e.light_timer
	local range = e.light_recolor.color_range
	local power_range = e.light_recolor.power_range
	local speed_range = e.light_recolor.speed_range

	color[1] = randomf(range.min[1], range.max[1])
	color[2] = randomf(range.min[2], range.max[2])
	color[3] = randomf(range.min[3], range.max[3])

	light.power = randomf(power_range.x, power_range.y)
	timer.value = randomf(speed_range.x, speed_range.y)
end

local function generate_flicker(e)
	local flicker = e.light_flicker.off_chance
	local color = e.color.value
	local r = love.math.random()

	if r < flicker then
		color[4] = 0.3
	else
		color[4] = 1
	end
end

local function manage_offset(shape, transform, sprite)
	local w, h = sprite:getDimensions()

	if shape == Enums.light_shape.round or shape == Enums.light_shape.rectangle then
		transform.ox = w/2
		transform.oy = h/2
	elseif shape == Enums.light_shape.cone then
		transform.ox = 0
		transform.oy = h/2
	end
end

function Light:init(world)
	self.world = world
	self.ambient = { 0, 0, 0 }

	self.pool.onAdded = function(pool, e)
		local light = e.light
		local recolor = e.light_recolor
		local flash = e.light_flash
		local flicker = e.light_flicker

		if recolor or flash or flicker then
			e:give("light_timer")
		end

		manage_offset(light.light_shape, e.transform, e.sprite.image)
	end
end

function Light:set_ambient_light(color)
	if not (type(color) == "table") then
		error('Assertion failed: type(color) == "table"')
	end
	self.ambient = color
end

function Light:create_light_map(x, y, w, h, scale)
	if not (type(x) == "number") then
		error('Assertion failed: type(x) == "number"')
	end
	if not (type(y) == "number") then
		error('Assertion failed: type(y) == "number"')
	end
	if not (type(w) == "number") then
		error('Assertion failed: type(w) == "number"')
	end
	if not (type(h) == "number") then
		error('Assertion failed: type(h) == "number"')
	end
	if scale then
		if not (type(scale) == "number") then
			error('Assertion failed: type(scale) == "number"')
		end
	end
	self.x = x
	self.y = y
	self.w = w
	self.h = h
	self.scale = scale or 1
	self.light_map = love.graphics.newCanvas(w, h)
end

function Light:update_light(dt)
	for _, e in ipairs(self.pool) do
		local light = e.light
		local timer = e.light_timer
		local recolor = e.light_recolor
		local flash = e.light_flash
		local flicker = e.light_flicker
		local disabled = e.light_disabled

		if not disabled and timer then
			if recolor then
				if timer.value > 0 then
					timer.value = timer.value - dt
				else
					generate_recolor(e)
				end
			elseif flash then
				local max_power = flash.max_power
				local speed = flash.speed

				timer.value = timer.value + dt
				if light.power < max_power then
					light.power = (max_power * timer.value) / speed
				else
					--TODO: (Brandon) do not remove the entity
					e:remove()
				end
			elseif flicker then
				if timer.value > 0 then
					timer.value = timer.value - dt
				else
					generate_flicker(e)
				end
			end
		end
	end
end

function Light:draw_light_start()
	love.graphics.setCanvas(self.light_map)
	love.graphics.setBlendMode("add")
	love.graphics.clear(self.ambient)
end

function Light:draw_light()
	local _r, _g, _b, _a = love.graphics.getColor()

	for _, e in ipairs(self.pool) do
		local light = e.light
		local disabled = e.light_disabled
		local hidden = e.hidden

		if not (disabled or hidden) then
			local color = e.color.value
			local sprite = e.sprite.image
			local power = light.power
			local pos = e.pos
			local transform = e.transform
			local quad = e.quad

			love.graphics.setColor(color)
			if quad then
				love.graphics.draw(
					sprite,
					quad.quad,
					pos.x,
					pos.y,
					transform.rot,
					transform.sx * power,
					transform.sy * power,
					transform.ox,
					transform.oy
				)
			else
				love.graphics.draw(
					sprite,
					pos.x,
					pos.y,
					transform.rot,
					transform.sx * power,
					transform.sy * power,
					transform.ox,
					transform.oy
				)
			end
		end
	end

	love.graphics.setColor(_r, _g, _b, _a)
	love.graphics.setBlendMode("alpha")
end

function Light:draw_light_end(x, y)
	love.graphics.setBlendMode("multiply", "premultiplied")
	love.graphics.draw(self.light_map, x, y, 0, self.scale, self.scale)
	love.graphics.setBlendMode("alpha")
end

function Light:cleanup()
	self.world:clear()
	if self.light_map then
		self.light_map:release()
	end
end

function Light:debug_update(dt)
	if not self.debug_show then
		return
	end
	self.debug_show = Slab.BeginWindow("light", {
		Title = "Light",
		IsOpen = self.debug_show,
	})
	local t = { self.ambient[1], self.ambient[2], self.ambient[3], 1 }
	local ret = Slab.ColorPicker({ Color = t })
	--TODO: (Brandon) replace this when Slab got updated
	if ret.Button == 1 then
		self.ambient[1] = ret.Color[1]
		self.ambient[2] = ret.Color[2]
		self.ambient[3] = ret.Color[3]
	end
	Slab.EndWindow()
end

return Light
