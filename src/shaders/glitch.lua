local Glitch = class({
	name = "Glitch",
})

local debug_values = {
	u_dis_amount = 0.1,
	u_dis_size = 0.1,
	u_abb_amount_x = 0.1,
	u_abb_amount_y = 0.1,
	u_max_a = 0.5,
}

local reset_tbl = {
	u_dis_amount = 0,
	u_dis_size = 0.1,
	u_abb_amount_x = 0,
	u_abb_amount_y = 0,
	u_max_a = 1.0,
}

function Glitch:new(values, is_active)
	if values then
		if not (type(values) == "table") then
			error('Assertion failed: type(values) == "table"')
		end
	end
	if is_active then
		if not (type(is_active) == "boolean") then
			error('Assertion failed: type(is_active) == "boolean"')
		end
	end
	self.is_active = not not is_active --default is false
	self.values = values or tablex.copy(reset_tbl)

	self.tex_displacement = Resources.data.images.tex_displacement
	self.shader = love.graphics.newShader(Shaders.paths.glitch)
	self.shader:send("u_tex_displace", self.tex_displacement)
	self:send_values_to_shader(self.values, true)
end

function Glitch:send_values_to_shader(new_values)
	if not (type(new_values) == "table") then
		error('Assertion failed: type(new_values) == "table"')
	end
	for k, v in pairs(new_values) do
		self.values[k] = v
		self.shader:send(k, v)

		debug_values[k] = v
	end
end

function Glitch:do_random_glitch(reset_after)
	if reset_after then
		if not (type(reset_after) == "number") then
			error('Assertion failed: type(reset_after) == "number"')
		end
	end
	self:send_values_to_shader({
		u_dis_amount = love.math.random() * 0.1,
		u_dis_size = love.math.random() * 2.0,
		u_abb_amount_x = love.math.random() * 0.1,
		u_abb_amount_y = love.math.random() * 0.1,
		u_max_a = love.math.random() * 1.0 + 0.5,
	})

	if reset_after then
		self.timer = timer(reset_after, nil, function()
			self:reset_glitch()
			self.timer:reset(reset_after)
		end)
	end
end

function Glitch:reset_glitch()
	self:send_values_to_shader(reset_tbl)
end

function Glitch:update(dt)
	if self.timer then
		self.timer:update(dt)
	end
end

local opt_slider = {
	ReturnOnText = false,
	NumbersOnly = true,
	Precision = 2,
}

function Glitch:debug_slider(id, min, max)
	local val = debug_values[id]
	Slab.Text(id)
	Slab.SameLine()
	if Slab.InputNumberSlider(id, val, min, max, opt_slider) then
		local new_value = Slab.GetInputNumber()
		debug_values[id] = new_value
		self.shader:send(id, new_value)
	end
end

function Glitch:debug_update(dt)
	if not self.debug_show or not self.is_active then
		return
	end
	self.debug_show = Slab.BeginWindow("glitch_shader", {
		Title = "Glitch",
		IsOpen = self.debug_show,
	})
	self:debug_slider("u_dis_amount", 0, 0.1)
	self:debug_slider("u_dis_size", 0.1, 2.0)
	self:debug_slider("u_abb_amount_x", 0, 0.1)
	self:debug_slider("u_abb_amount_y", 0, 0.1)
	self:debug_slider("u_max_a", 0.1, 1.0)
	if self.timer then
		Slab.Text(self.timer:progress())
	end
	if Slab.Button("randomize") then
		self:do_random_glitch()
	end
	Slab.SameLine()
	if Slab.Button("reset") then
		self:reset_glitch()
	end
	Slab.EndWindow()
end

return Glitch
