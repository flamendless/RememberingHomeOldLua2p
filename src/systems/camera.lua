local Camera = Concord.system({
	pool = { "camera" },
	pool_clip = { "camera", "camera_clip" },
})

local DUR_TRANSITION = 0.15

function Camera:init(world)
	self.world = world
	self.main_camera = nil
	self.to_follow = nil
	self.clip = false
	self.follow = false
	self.bars = false
	self.state = Enums.camera_state.zoomed_out

	self.pool.onAdded = function(pool, e)
		local camera = e.camera
		if e.camera_transform then
			local t = e.camera_transform
			camera.camera:setAngle(t.rot)
			camera.camera:setScale(t.scale)
		end

		if camera.is_main then
			self.e_camera = e
			self.main_camera = camera.camera
			self.world:emit("ev_main_camera_setup", self.main_camera)
		end
		self.scale = self.main_camera:getScale()
		self.world:setResource("camera", self.main_camera)
		self.world:setResource("e_camera", e)
	end

	self.pool_clip.onAdded = function(pool, e)
		self.clip = true
	end

	self.pool_clip.onRemoved = function(pool, e)
		self.clip = #pool == 0
	end
end

function Camera:update(dt)
	if self.follow and self.to_follow then
		local x, y = self:get_follow_coords(self.to_follow)
		self.main_camera:setPosition(x, y)
	end
end

function Camera:set_camera_transform(camera, t)
	assert(Gamera.isCamera(camera), camera)
	assert(type(t) == "table", t)
	if t.x then
		assert(type(t.x) == "number", t.x)
	end
	if t.y then
		assert(type(t.y) == "number", t.y)
	end
	if t.scale then
		assert(type(t.scale) == "number", t.scale)
	end
	--INFO: ALWAYS SET SCALE FIRST BEFORE POSITION
	local scale = camera:getScale()
	camera:setScale(t.scale or scale)
	local x, y = camera:getPosition()
	camera:setPosition(t.x or x, t.y or y)
end

function Camera:get_follow_coords(target)
	assert(target.__isEntity, target)
	local pos = target.pos
	local x, y = pos.x, pos.y
	if target.camera_follow_offset then
		local offset = target.camera_follow_offset
		x = x + offset.x
		y = y + offset.y
	end
	return x, y
end

function Camera:camera_unfollow()
	self.follow = false
end

function Camera:camera_follow(target, dur)
	assert(target.__isEntity, target)
	assert(type(dur) == "number", dur)
	self.follow = true
	local cx, cy = self.main_camera:getPosition()
	local tx, ty = self:get_follow_coords(target)
	local dt = { x = cx, y = cy }

	Flux.to(dt, dur or 1, { x = tx, y = ty })
		:onupdate(function()
			self.main_camera:setPosition(dt.x, dt.y)
		end)
		:oncomplete(function()
			self.to_follow = target
		end)
end

function Camera:draw_clip()
	if not self.clip then
		return
	end
	for _, e in ipairs(self.pool_clip) do
		local cam = e.camera.camera
		local cx, cy, cw, ch = cam:getWindow()
		local scale = cam:getScale()
		local diff = (ch - e.camera_clip.h * scale)/2
		love.graphics.setColor(e.camera_clip.color)
		love.graphics.rectangle("fill", cx, cy, cw, diff)
		love.graphics.rectangle("fill", cx, ch - diff, cw, diff)
	end

	if self.bars then
		local bt = self.bar_top
		local bb = self.bar_bot
		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.rectangle("fill", bt.x, bt.y, bt.w, bt.h)
		love.graphics.rectangle("fill", bb.x, bb.y, bb.w, bb.h)
	end
end

function Camera:force(dir)
	assert((type(dir) == "number" and (dir == 1 or dir == -1)), dir)
	self.flux:stop()
	self.main_camera:setScale(self.target_scale)
	self.state = self.target_state
	self.target_scale = nil
	self.target_state = nil
	self.flux = nil
end

function Camera:tween_camera(dir)
	assert((type(dir) == "number" and (dir == 1 or dir == -1)), dir)
	local cs = self.main_camera:getScale()
	self.target_scale = dir == 1 and cs + 0.25 or cs - 0.25
	self.target_state = dir == 1 and Enums.camera_state.zoomed_in or Enums.camera_state.zoomed_out

	self.flux = Flux.to(self, DUR_TRANSITION, { scale = self.target_scale })
		:ease("circout")
		:onupdate(function()
			self.main_camera:setScale(self.scale)
		end)
		:oncomplete(function()
			self.state = self.target_state
			self.target_scale = nil
			self.target_state = nil
			self.flux = nil
		end)
end

function Camera:on_interact_or_inventory()
	if self.flux then
		self:force(1)
		return
	end
	if self.state ~= Enums.camera_state.zoomed_out then
		return
	end
	self:tween_camera(1)
	self:display_bars()
end

function Camera:on_leave_interact_or_inventory()
	if self.flux then
		self:force(-1)
		return
	end
	if self.state ~= Enums.camera_state.zoomed_in then
		return
	end
	self:tween_camera(-1)
	self:hide_bars()
end

function Camera:display_bars()
	local l, t, w, h = self.main_camera:getWindow()
	self.bars = true
	self.bar_top = { x = l, y = t, w = w, h = 0 }
	self.bar_bot = { x = l, y = h, w = w, h = 0 }
	Flux.to(self.bar_top, DUR_TRANSITION, { h = h * CAM_BAR_RATIO }):ease("circout")
	Flux.to(self.bar_bot, DUR_TRANSITION, { h = -h * CAM_BAR_RATIO }):ease("circout")
	for _, e in ipairs(self.pool) do
		e:give("bar_height", h * CAM_BAR_RATIO)
	end
end

function Camera:hide_bars()
	Flux.to(self.bar_top, DUR_TRANSITION, { h = 0 }):ease("circout")
	Flux.to(self.bar_bot, DUR_TRANSITION, { h = 0 }):ease("circout"):oncomplete(function()
		self.bars = false
		self.world:emit("ev_on_hide_bars_complete")
	end)
end

function Camera:prepare_screen_shake()
	self.init_screen_shake = {}
	self.init_screen_shake.x, self.init_screen_shake.y = self.main_camera:getPosition()
	self.init_screen_shake.scale = self.main_camera:getScale()
	self.init_screen_shake.rotation = self.main_camera:getAngle()
end

function Camera:finalize_screen_shake(very_final)
	if very_final then assert(type(very_final) == "boolean", very_final) end
	assert(self.init_screen_shake ~= nil, "make sure to emit 'prepare_screen_shake' first")
	self.main_camera:setPosition(self.init_screen_shake.x, self.init_screen_shake.y)
	self.main_camera:setScale(self.init_screen_shake.scale)
	self.main_camera:setAngle(self.init_screen_shake.rotation)
	if very_final then
		self.init_screen_shake = nil
	end
end

function Camera:screen_shake(dur, intensity)
	assert(type(dur) == "number" and dur > 0, dur)
	assert(type(intensity) == "number" and intensity > 0.0 and intensity < 1.0, intensity)
	assert(self.init_screen_shake ~= nil, "make sure to emit 'prepare_screen_shake' first")
	Timer.during(
		dur,
		function()
			local x = self.init_screen_shake.x + love.math.random(intensity) * mathx.random_sign()
			local y = self.init_screen_shake.y + love.math.random(intensity) * mathx.random_sign()
			local scale = self.init_screen_shake.scale + love.math.random(intensity) * mathx.random_sign()
			local rotation = self.init_screen_shake.rotation + math.rad(love.math.random(intensity)) * mathx.random_sign()
			self.main_camera:setPosition(x, y)
			self.main_camera:setScale(scale)
			self.main_camera:setAngle(rotation)
		end,
		function()
			self:finalize_screen_shake()
		end)
end

if DEV then
	local format = string.format
	local flags = {
		center = true,
		visible = false,
		world = false,
		window = false,
		clip = false,
	}

	function Camera:toggle_debug_show(id)
		assert(type(id) == "string")
		if id == "camera" then
			self.debug_show = not self.debug_show
		end
	end

	function Camera:debug_update(dt)
		if not self.debug_show then
			return
		end
		self.debug_show = Slab.BeginWindow("camera", {
			Title = "Camera",
			IsOpen = self.debug_show,
		})
		local camera = self.main_camera
		if camera then
			local x, y = camera:getPosition()
			local scale = camera:getScale()
			local wx, wy, ww, wh = camera:getWorld()
			local sx, sy, sw, sh = camera:getWindow()
			local vx, vy, vw, vh = camera:getVisible()
			local str_world = format("World: (%d, %d, %d, %d)", wx, wy, ww, wh)
			local str_window = format("Window: (%d, %d, %d, %d)", sx, sy, sw, sh)
			local str_visible = format("Visible: (%d, %d, %d, %d)", vx, vy, vw, vh)
			Slab.Text("Pos:")
			Slab.Indent()
			Slab.Text("x:")
			Slab.SameLine()
			if
				Slab.InputNumberSlider("x", x, 0, sw, {
					ReturnOnText = false,
					NumbersOnly = true,
					Precision = 1,
				})
			then
				self.follow = false
				x = Slab.GetInputNumber()
				self.main_camera:setPosition(x, y)
			end
			Slab.Text("y:")
			Slab.SameLine()
			if
				Slab.InputNumberSlider("y", y, 0, sh, {
					ReturnOnText = false,
					NumbersOnly = true,
					Precision = 1,
				})
			then
				self.follow = false
				y = Slab.GetInputNumber()
				self.main_camera:setPosition(x, y)
			end
			Slab.Unindent()

			Slab.Text("Scale:")
			Slab.SameLine()
			if
				Slab.InputNumberSlider("scale", scale, 1, 10, {
					ReturnOnText = false,
					NumbersOnly = true,
					Precision = 2,
				})
			then
				scale = Slab.GetInputNumber()
				self.main_camera:setScale(scale)
			end

			Slab.Text(str_world)
			Slab.Text(str_window)
			Slab.Text(str_visible)

			if Slab.CheckBox(self.follow, "Follow") then
				self.follow = not self.follow
			end

			if self.to_follow then
				Slab.Indent()
				Slab.Text("to follow id: " .. self.to_follow.id.value)
				Slab.Unindent()
			end

			if Slab.CheckBox(self.clip, "Clip") then
				self.clip = not self.clip
			end
			if Slab.CheckBox(flags.clip, "Debug Clip") then
				flags.clip = not flags.clip
				for _, e in ipairs(self.pool_clip) do
					local clip = e.camera_clip
					if flags.clip then
						clip.debug_prev = clip.color
						clip.color = { 1, 0, 0, 1 }
					else
						clip.color = clip.debug_prev
					end
				end
			end
			Slab.SameLine()
			if Slab.CheckBox(flags.center, "Center") then
				flags.center = not flags.center
			end
			if Slab.CheckBox(flags.world, "World") then
				flags.world = not flags.world
			end
			Slab.SameLine()
			if Slab.CheckBox(flags.window, "Window") then
				flags.window = not flags.window
			end
			if Slab.CheckBox(flags.visible, "Visible") then
				flags.visible = not flags.visible
			end
		else
			Slab.Text("No camera in current state")
		end
		Slab.EndWindow()

		local speed = 64
		if love.keyboard.isDown("lshift") then
			speed = 128
		end

		local dx, dy = 0, 0
		if Inputs.down("camera_down") then
			dy = 1
		elseif Inputs.down("camera_up") then
			dy = -1
		end
		if Inputs.down("camera_left") then
			dx = -1
		elseif Inputs.down("camera_right") then
			dx = 1
		end

		if dx ~= 0 or dy ~= 0 then
			local x, y = self.main_camera:getPosition()
			x = x + speed * dt * dx
			y = y + speed * dt * dy
			self.follow = false
			self.main_camera:setPosition(x, y)
		end
	end

	function Camera:debug_draw()
		if not self.debug_show then
			return
		end
		local scale = self.main_camera:getScale()
		local wx, wy, ww, wh = self.main_camera:getWorld()
		local sx, sy, sw, sh = self.main_camera:getWindow()
		local vx, vy, vw, vh = self.main_camera:getVisible()

		love.graphics.setLineWidth(1 / scale)
		if flags.world then
			love.graphics.setColor(0, 0, 1, 0.7)
			love.graphics.rectangle("line", wx, wy, ww, wh)
			if flags.center then
				love.graphics.line(wx + ww/2, wy, wx + ww/2, wy + wh)
				love.graphics.line(wx, wy + wh/2, wx + ww, wy + wh/2)
				love.graphics.circle("line", wx + ww/2, wy + wh/2, 1)
			end
		end

		if flags.window then
			love.graphics.setColor(0, 1, 0, 0.7)
			love.graphics.rectangle("line", sx, sy, sw, sh)
			if flags.center then
				love.graphics.line(sw/2, sy, sw/2, sh)
				love.graphics.line(sx, sh/2, sw, sh/2)
				love.graphics.circle("line", sw/2, sh/2, 1)
			end
		end

		if flags.visible then
			love.graphics.setColor(1, 1, 0, 0.7)
			love.graphics.rectangle("line", vx, vy, vw, vh)
			if flags.center then
				love.graphics.line(vx + vw/2, vy, vx + vw/2, vy + vh)
				love.graphics.line(vx, vy + vh/2, vx + vw, vy + vh/2)
				love.graphics.circle("line", vx + vw/2, vy + vh/2, 1)
			end
		end
	end

	function Camera:debug_on_drag(bool)
		assert(type(bool) == "boolean", bool)
		self.follow = not bool
	end

	function Camera:debug_wheelmoved(wx, wy)
		if not self.debug_show then
			return
		end
		if not self.main_camera then
			return
		end
		local scale = self.main_camera:getScale()
		local dy = scale + wy * 0.15
		self.main_camera:setScale(dy)
	end

	function Camera:debug_on_toggle(event)
		if event ~= "camera" then return end
		self.debug_show = not self.debug_show
	end
end

return Camera
