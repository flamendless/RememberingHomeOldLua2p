local BumpCollision = Concord.system({
	pool = {constructor = Ctor.BumpStorage},
})

local function get_query_rect(self)
	local camera = self.world:getResource("camera")
	if camera then
		return camera:getVisible()
	else
		return 0, 0, love.graphics.getDimensions()
	end
end

local function get_query_point(self)
	local mx, my = love.mouse.getPosition()
	local camera = self.world:getResource("camera")
	if camera then
		mx, my = camera:toWorld(mx, my)
	end
	return mx, my
end

local function filter(item, other)
	return other.collider.filter or Enums.bump_filter.slide
end

function BumpCollision:init(world)
	self.world = world
end

function BumpCollision:preupdate(dt)
	for _, e in ipairs(self.pool:getItems()) do
		e.collider.is_hit = false
		e:remove("hit_wall")
		if DEV then
			e.bump.debug_hovered = false
		end
	end
end

function BumpCollision:update(dt)
	local x, y, w, h = get_query_rect(self)
	local items, len = self.pool:queryRect(x, y, w, h)
	for i = 1, len do
		local e = items[i]
		if e.body then
			if DEV then
				if e.bump.debug_clicked then return end
			end
			self:update_body(e)
			self:check_col(e)
		end
	end
end

function BumpCollision:update_body(e)
	local body = e.body
	local pos = e.pos.pos

	pos:vadd(body.vel)
	local x, y, cols, len = self.pool:move(e, pos.x, pos.y, filter)
	pos:scalar_set(x, y)

	for i = 1, len do
		local c = cols[i]
		local other = c.other
		local other_col = other.collider
		other_col.is_hit = true
		other_col.normal:scalar_set(c.normalX, c.normalY)
		if other.wall then
			e:give("hit_wall")
		end
	end
	self.pool.freeCollisions(cols)
end

function BumpCollision:check_col(e)
	local pos = e.pos.pos
	local _, _, cols, len = self.pool:check(e, pos.x, pos.y, filter)
	local has_collide_with = false

	local within_int = e.within_interactive
	for i = 1, len do
		local c = cols[i]
		local other = c.other
		local other_col = other.collider
		other_col.normal:scalar_set(c.normalX, c.normalY)
		if i == 1 and e.can_interact and other.interactive then
			local proceed = true
			local req = other.req_col_dir

			if req and (e.body.dir ~= req.value) then
				proceed = false
			end

			if proceed then
				if not within_int and other.interactive then
					self.world:emit("on_collide_interactive", e, other)
				elseif within_int and within_int.entity ~= other then
					self.world:emit("on_change_interactive", e, other)
				end
			end
		end

		if other.controller then
			e:ensure("collide_with", other)
			has_collide_with = true
		end
		if e.controller then
			other:ensure("collide_with", e)
			has_collide_with = true
		end
	end

	local col = e.collider
	if not col.is_hit and within_int and len == 0 then
		self.world:emit("on_leave_interactive", e, within_int.entity)
	end

	if not has_collide_with then
		e:remove("collide_with")
	end

	self.pool.freeCollisions(cols)
end

function BumpCollision:on_item_use(item)
	ASSERT(item.__isEntity and item.item)
	local x, y, w, h = get_query_rect(self)
	local items, len = self.pool:queryRect(x, y, w, h)
	local e_other
	for i = 1, len do
		local e = items[i]
		local pos = e.pos.pos
		local _, _, cols, c_len = self.pool:check(e, pos.x, pos.y, filter)
		for c = 1, c_len do
			local col = cols[c]
			local other = col.other
			if e.within_interactive and other.interactive then
				e_other = other
				break
			end
		end
	end
	self.world:emit("on_item_use_with", item, e_other)
end

function BumpCollision:update_collider(e)
	ASSERT(e.__isEntity and e.collider and e.animation)
	if e.skip_collider_update then return end
	local id = e.id
	if id.value ~= "enemy" then return end
	local new_collider = Data.Colliders[id.value]
	local sub_id = id.sub_id
	if sub_id then
		new_collider = new_collider[sub_id]
	end
	new_collider = new_collider[e.animation.current_tag]
	if not new_collider then return end

	local collider = e.collider
	local pos = e.pos.pos:copy()
	local size = vec2(new_collider.w, new_collider.h) or collider.size:copy()

	local col_offset = e.collider_offset
	if col_offset then
		pos:vadd_inplace(col_offset.value)
	end

	collider.size = size
	collider.half_size = collider.size:smul(0.5)

	if new_collider.ox or new_collider.oy then
		local t = e.transform
		t.scale.x = new_collider.sx or t.scale.x
		t.scale.y = new_collider.sy or t.scale.y
		t.offset.x = new_collider.ox or t.offset.x
		t.offset.y = new_collider.oy or t.offset.y
	end

	self.pool:update(e, pos.x, pos.y, collider.size:unpack())
end

if DEV then
	local flags = {
		ids = false,
		bodies = true,
		drag = false,
		visible_only = true,
		fill = false,
	}
	local fnt = love.graphics.newFont(8)
	fnt:setFilter("nearest", "nearest")

	local function edit(id, value, t)
		Slab.Text(id .. ":")
		Slab.SameLine()
		if Slab.Input(id, {
			Text = tostring(value),
			ReturnOnText = false,
			NumbersOnly = true,
		}) then
			value = Slab.GetInputNumber()
			t[id] = math.floor(value)
		end
		return value
	end

	local tbl_n = {Text = "", ReturnOnText = false, NumbersOnly = true}

	function BumpCollision:debug_update(dt)
		if not self.debug_show then
			flags.bodies = false
			return
		end
		self.debug_show = Slab.BeginWindow("BumpCollision", {
			Title = self.debug_title,
			IsOpen = self.debug_show
		})
		tbl_n.Text = tostring(self.pool:countItems())
		Slab.Input("bump_n", tbl_n)
		if Slab.CheckBox(flags.bodies, "Bodies") then
			flags.bodies = not flags.bodies
		end
		Slab.SameLine()
		if Slab.CheckBox(flags.ids, "IDs") then
			flags.ids = not flags.ids
		end
		Slab.SameLine()
		if Slab.CheckBox(flags.drag, "Drag") then
			flags.drag = not flags.drag
			self.world:emit("debug_on_drag", flags.drag)
		end
		if Slab.CheckBox(flags.visible_only, "Visible Only") then
			flags.visible_only = not flags.visible_only
		end
		Slab.SameLine()
		if Slab.CheckBox(flags.fill, "Fill") then
			flags.fill = not flags.fill
		end

		if Slab.BeginTree("List", {Title = "List"}) then
			Slab.Indent()
			local items, len
			if flags.visible_only then
				local x, y, w, h = get_query_rect(self)
				items, len = self.pool:queryRect(x, y, w, h)
			else
				items, len = self.pool:getItems()
			end

			for i = 1, len do
				local e = items[i]
				local id = e.id.value
				if Slab.BeginTree(id, {Title = id, IsOpen = e.bump.debug_selected}) then
					Slab.Indent()
					local x, y, w, h = self.pool:getRect(e)
					local pos = e.pos.pos
					local size = e.collider.size
					x = edit("x", x, pos)
					y = edit("y", y, pos)
					w = edit("w", w, size)
					h = edit("h", h, size)
					self.pool:update(e, x, y, w, h)
					Slab.EndTree()
				end
			end
			Slab.EndTree()
		end

		local mx, my = get_query_point(self)
		local items, len = self.pool:queryPoint(mx, my)
		for i = 1, len do
			local e = items[i]
			e.bump.debug_hovered = true
			e.bump.debug_selected = love.mouse.isDown(2)
			if love.keyboard.isDown("lshift") and e.bump.debug_selected then
				self.world:emit("debug_e_right_clicked", e)
			end
		end
		Slab.EndWindow()
	end

	function BumpCollision:debug_draw()
		if not flags.bodies then return end
		local camera = self.world:getResource("camera")
		local scale = (camera and camera:getScale()) or 1
		love.graphics.setFont(fnt)
		local x, y, w, h = get_query_rect(self)
		local items, len = self.pool:queryRect(x, y, w, h)
		for i = 1, len do
			local e = items[i]
			local id = e.id.value
			local rx, ry, rw, rh = self.pool:getRect(e)

			if flags.fill then
				love.graphics.setColor(1, 0, 0, 0.3)
				love.graphics.rectangle("fill", rx, ry, rw, rh)
			end

			love.graphics.setLineWidth(1/scale)
			if e.bump.debug_hovered or
				(e.interactive and e.collider.is_hit) then
				love.graphics.setColor(1, 1, 0, 0.7)
			else
				love.graphics.setColor(1, 0, 0, 0.7)
			end
			love.graphics.rectangle("line", rx, ry, rw, rh)

			if flags.ids then
				love.graphics.print(id, rx, ry)
			end
		end
	end

	function BumpCollision:debug_mousemoved(_, _, dx, dy)
		if flags.drag then
			local mx, my = get_query_point(self)
			local x, y, w, h = get_query_rect(self)
			local items, len = self.pool:queryRect(x, y, w, h)
			for i = 1, len do
				local e = items[i]
				if e.bump.debug_clicked then
					local _, _, rw, rh = self.pool:getRect(e)
					e.pos.pos:scalar_set(math.floor(mx), math.floor(my))
					self.pool:update(e, e.pos.x, e.pos.y, rw, rh)
				end
			end
		end
	end

	function BumpCollision:debug_mousepressed(_, _, mb)
		if not flags.drag then return end
		if mb ~= 1 then return end
		local mx, my = get_query_point(self)
		local items, len = self.pool:queryPoint(mx, my)
		for i = 1, len do
			local e = items[i]
			if e.bump.debug_hovered then
				e.bump.debug_clicked = true
			end
		end
	end

	function BumpCollision:debug_mousereleased(_, _, mb)
		if flags.drag and mb == 1 then
			local mx, my = get_query_point(self)
			local x, y, w, h = get_query_rect(self)
			local items, len = self.pool:queryRect(x, y, w, h)
			for i = 1, len do
				local e = items[i]
				if e.bump.debug_clicked then
					local _, _, rw, rh = self.pool:getRect(e)
					e.pos.pos:scalar_set(math.floor(mx), math.floor(my))
					e.bump.debug_clicked = false
					self.pool:update(e, e.pos.x, e.pos.y, rw, rh)
				end
			end
		end
	end
end

return BumpCollision
