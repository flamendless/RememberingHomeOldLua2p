local Camera = Concord.system({
	pool = {"camera"},
	pool_clip = {"camera", "camera_clip"},
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

	self.pool.onAdded = function(_, e)
		local camera = e.camera
		if e.camera_transform then
			local t = e.camera_transform
			camera.camera:setAngle(t.rot)
			camera.camera:setScale(t.scale)
		end

		if camera.is_main then
			self.e_camera = e
			self.main_camera = camera.camera
		end
		self.scale = self.main_camera:getScale()
		self.world:setResource("camera", self.main_camera)
		self.world:setResource("e_camera", e)
	end

	self.pool_clip.onAdded = function(_, e)
		self.clip = true
	end

	self.pool_clip.onRemoved = function(pool, e)
		self.clip = #pool == 0
	end
end

function Camera:update(dt)
	if self.follow and self.to_follow then
		local pos = self:get_follow_coords(self.to_follow)
		self.main_camera:setPosition(pos:unpack())
	end
end

function Camera:set_camera_transform(camera, t)
	ASSERT(Gamera.isCamera(camera))
	ASSERT(type(t) == "table")
	SASSERT(t.pos, t.pos:type() == "vec2")
	SASSERT(t.scale, type(t.scale) == "number")
	local scale = camera:getScale()
	camera:setScale(t.scale or scale)
	local x, y = camera:getPosition()
	local dx, dy = t.pos:unpack()
	camera:setPosition(dx or x, dy or y)
end

function Camera:get_follow_coords(target)
	ASSERT(target.__isEntity)
	local pos = target.pos.pos:copy()
	if target.camera_follow_offset then
		local offset = target.camera_follow_offset.pos
		pos:vadd_inplace(offset)
	end
	return pos
end

function Camera:camera_follow(target, dur)
	ASSERT(target.__isEntity)
	ASSERT(type(dur) == "number")
	self.follow = true
	local dt = vec2(self.main_camera:getPosition())
	local pos = self:get_follow_coords(target)

	Flux.to(dt, dur or 1, {x = pos.x, y = pos.y})
		:onupdate(function()
			self.main_camera:setPosition(dt.x, dt.y)
		end)
		:oncomplete(function()
			self.to_follow = target
		end)
end

function Camera:draw_clip()
	if not self.clip then return end
	for _, e in ipairs(self.pool_clip) do
		local cam = e.camera.camera
		local cx, cy, cw, ch = cam:getWindow()
		local scale = cam:getScale()
		local diff = (ch - e.camera_clip.size.y * scale) * 0.5
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
	ASSERT(type(dir) == "number" and (dir == 1 or dir == -1))
	self.flux:stop()
	self.main_camera:setScale(self.target_scale)
	self.state = self.target_state
	self.target_scale = nil
	self.target_state = nil
	self.flux = nil
end

function Camera:tween_camera(dir)
	ASSERT(type(dir) == "number" and (dir == 1 or dir == -1))
	local cs = self.main_camera:getScale()
	self.target_scale = dir == 1 and cs + 0.25 or cs - 0.25
	self.target_state = dir == 1 and
		Enums.camera_state.zoomed_in or Enums.camera_state.zoomed_out

	self.flux = Flux.to(self, DUR_TRANSITION, {scale = self.target_scale})
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
	if self.flux then self:force(1) return end
	if self.state ~= Enums.camera_state.zoomed_out then return end
	self:tween_camera(1)
	self:display_bars()
end

function Camera:on_leave_interact_or_inventory()
	if self.flux then self:force(-1) return end
	if self.state ~= Enums.camera_state.zoomed_in then return end
	self:tween_camera(-1)
	self:hide_bars()
end

function Camera:display_bars()
	local l, t, w, h = self.main_camera:getWindow()
	local p = 0.15
	self.bars = true
	self.bar_top = {x = l, y = t, w = w, h = 0}
	self.bar_bot = {x = l, y = h, w = w, h = 0}
	Flux.to(self.bar_top, DUR_TRANSITION, {h = h * p}):ease("circout")
	Flux.to(self.bar_bot, DUR_TRANSITION, {h = -h * p}):ease("circout")
	for _, e in ipairs(self.pool) do
		e:give("bar_height", h * p)
	end
end

function Camera:hide_bars()
	Flux.to(self.bar_top, DUR_TRANSITION, {h = 0}):ease("circout")
	Flux.to(self.bar_bot, DUR_TRANSITION, {h = 0}):ease("circout")
		:oncomplete(function()
			self.bars = false
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

	function Camera:debug_update(dt)
		if not self.debug_show then return end
		self.debug_show = Slab.BeginWindow("camera", {
			Title = "Camera",
			IsOpen = self.debug_show
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
			if Slab.InputNumberSlider("x", x, 0, sw, {
				ReturnOnText = false,
				NumbersOnly = true,
				Precision = 1,
			}) then
				self.follow = false
				x = Slab.GetInputNumber()
				self.main_camera:setPosition(x, y)
			end
			Slab.Text("y:")
			Slab.SameLine()
			if Slab.InputNumberSlider("y", y, 0, sh, {
				ReturnOnText = false,
				NumbersOnly = true,
				Precision = 1,
			}) then
				self.follow = false
				y = Slab.GetInputNumber()
				self.main_camera:setPosition(x, y)
			end
			Slab.Unindent()

			Slab.Text("Scale:")
			Slab.SameLine()
			if Slab.InputNumberSlider("scale", scale, 1, 10, {
				ReturnOnText = false,
				NumbersOnly = true,
				Precision = 2,
			}) then
				scale = Slab.GetInputNumber()
				self.main_camera:setScale(scale)
			end

			Slab.Text(str_world)
			Slab.Text(str_window)
			Slab.Text(str_visible)

			if Slab.CheckBox(self.follow, "Follow") then self.follow = not self.follow end
			Slab.SameLine()
			if Slab.CheckBox(self.clip, "Clip") then self.clip = not self.clip end
			if Slab.CheckBox(flags.clip, "Debug Clip") then
				flags.clip = not flags.clip
				for  _, e in ipairs(self.pool_clip) do
					local clip = e.camera_clip
					if flags.clip then
						clip.debug_prev = clip.color
						clip.color = {1, 0, 0, 1}
					else
						clip.color = clip.debug_prev
					end
				end
			end
			Slab.SameLine()
			if Slab.CheckBox(flags.center, "Center") then flags.center = not flags.center end
			if Slab.CheckBox(flags.world, "World") then flags.world = not flags.world end
			Slab.SameLine()
			if Slab.CheckBox(flags.window, "Window") then flags.window = not flags.window end
			if Slab.CheckBox(flags.visible, "Visible") then flags.visible = not flags.visible end
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
		if not self.debug_show then return end
		local scale = self.main_camera:getScale()
		local wx, wy, ww, wh = self.main_camera:getWorld()
		local sx, sy, sw, sh = self.main_camera:getWindow()
		local vx, vy, vw, vh = self.main_camera:getVisible()

		love.graphics.setLineWidth(1/scale)
		if flags.world then
			love.graphics.setColor(0, 0, 1, 0.7)
			love.graphics.rectangle("line", wx, wy, ww, wh)
			if flags.center then
				love.graphics.line(wx + ww * 0.5, wy, wx + ww * 0.5, wy + wh)
				love.graphics.line(wx, wy + wh * 0.5, wx + ww, wy + wh * 0.5)
				love.graphics.circle("line", wx + ww * 0.5, wy + wh * 0.5, 1)
			end
		end

		if flags.window then
			love.graphics.setColor(0, 1, 0, 0.7)
			love.graphics.rectangle("line", sx, sy, sw, sh)
			if flags.center then
				love.graphics.line(sw * 0.5, sy, sw * 0.5, sh)
				love.graphics.line(sx, sh * 0.5, sw, sh * 0.5)
				love.graphics.circle("line", sw * 0.5, sh * 0.5, 1)
			end
		end

		if flags.visible then
			love.graphics.setColor(1, 1, 0, 0.7)
			love.graphics.rectangle("line", vx, vy, vw, vh)
			if flags.center then
				love.graphics.line(vx + vw * 0.5, vy, vx + vw * 0.5, vy + vh)
				love.graphics.line(vx, vy + vh * 0.5, vx + vw, vy + vh * 0.5)
				love.graphics.circle("line", vx + vw * 0.5, vy + vh * 0.5, 1)
			end
		end
	end

	function Camera:debug_on_drag(bool)
		ASSERT(type(bool) == "boolean")
		self.follow = not bool
	end

	function Camera:debug_wheelmoved(wx, wy)
		if not self.debug_show then return end
		if not self.main_camera then return end
		local scale = self.main_camera:getScale()
		local dy = scale + wy * 0.15
		self.main_camera:setScale(dy)
	end
end

return Camera
