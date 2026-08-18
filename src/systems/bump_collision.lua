local BumpCollision = Concord.system({
	pool = { constructor = Ctor.BumpStorage },
})

local INTERACT_REACH = 0.58
local INTERACT_LEAVE_REACH = 0.48
local WALL_PROBE = 2

local function get_query_rect(self)
	local camera = self.world:getResource("camera")
	local x, y, w, h
	if camera then
		x, y, w, h = camera:getVisible()
	else
		x, y, w, h = 0, 0, love.graphics.getDimensions()
	end

	local function sane(n)
		return type(n) == "number" and n == n and n ~= math.huge and n ~= -math.huge
	end

	if not sane(x) or not sane(y) or not sane(w) or not sane(h) or w <= 0 or h <= 0 then
		Log.warn("BumpCollision: invalid query rect, using window fallback")
		return 0, 0, love.graphics.getDimensions()
	end

	-- Absurd visible size usually means a bad camera scale; avoid scanning millions of cells.
	local MAX_QUERY = 4096
	if w > MAX_QUERY or h > MAX_QUERY then
		Log.warn(
			"BumpCollision: clamping oversized query rect (%.1f x %.1f)",
			w,
			h
		)
		w = math.min(w, MAX_QUERY)
		h = math.min(h, MAX_QUERY)
	end

	return x, y, w, h
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
	local collider = other:get("collider")
	local filter_val = collider.filter
	if not filter_val then
		filter_val = Enums.bump_filter.slide
	end
	return filter_val
end

local function is_blocked_by_wall(pool, e, dir)
	local rx, ry, rw, rh = pool:getRect(e)
	local qx, qy, qw, qh
	if dir > 0 then
		qx = rx + rw
		qy = ry
		qw = WALL_PROBE
		qh = rh
	else
		qx = rx - WALL_PROBE
		qy = ry
		qw = WALL_PROBE
		qh = rh
	end

	local items, len = pool:queryRect(qx, qy, qw, qh)
	for i = 1, len do
		local other = items[i]
		if other ~= e and other:has("wall") then
			pool.freeTable(items)
			return true
		end
	end
	pool.freeTable(items)

	local goal_x = rx + dir * WALL_PROBE
	local cols, plen = pool:project(e, rx, ry, rw, rh, goal_x, ry, filter)
	for i = 1, plen do
		if cols[i].other:has("wall") then
			pool.freeCollisions(cols)
			return true
		end
	end
	pool.freeCollisions(cols)
	return false
end

local function apply_wall_hit_from_dx(pool, e, body)
	assert(pool, pool)
	assert((e.__isEntity and e:has("body")), e)
	assert(body.dx == -1 or body.dx == 0 or body.dx == 1, body.dx)
	if body.dx ~= 0 and not e:has("hit_wall")
		and is_blocked_by_wall(pool, e, body.dx) then
		e:give("hit_wall")
	end
end

local function overlaps_query_rect(pool, e, x, y, w, h)
	local rx, ry, rw, rh = pool:getRect(e)
	return rx < x + w and rx + rw > x and ry < y + h and ry + rh > y
end

local function can_proceed_interact(e, e_other)
	local req = e_other:get("req_col_dir")
	if not req then
		return true
	end
	local body = e:get("body")
	return body.dir == req.value
end

local function is_in_interact_range(e, e_other, pool, reach_scale)
	if not (e:has("collider") and e_other:has("collider")) then
		return false
	end

	reach_scale = reach_scale or INTERACT_REACH
	local ax, ay, aw, ah = pool:getRect(e)
	local bx, by, bw, bh = pool:getRect(e_other)
	local px, py = ax + aw * 0.5, ay + ah * 0.5
	local cx, cy = bx + bw * 0.5, by + bh * 0.5
	local reach = (aw + bw) * reach_scale + (ah + bh) * 0.2
	local dx = px - cx
	local dy = py - cy
	return dx * dx + dy * dy <= reach * reach
end

local function can_interact_with(e, e_other, pool, reach_scale)
	if not (e:has("can_interact") and e_other:has("interactive")) then
		return false
	end
	if not can_proceed_interact(e, e_other) then
		return false
	end
	return is_in_interact_range(e, e_other, pool, reach_scale)
end

function BumpCollision:is_move_blocked_by_wall(e, dir)
	assert((e.__isEntity and e:has("body")), e)
	assert(dir == 1 or dir == -1, dir)
	return is_blocked_by_wall(self.pool, e, dir)
end

function BumpCollision:init(world)
	self.world = world
end

function BumpCollision:preupdate(dt)
	for _, e in ipairs(self.pool:getItems()) do
		e:get("collider").is_hit = false
		if e:has("hit_wall") then
			e:remove("hit_wall")
		end

		e:get("bump").debug_hovered = false
	end
end

function BumpCollision:update(dt)
	local x, y, w, h = get_query_rect(self)
	local pool = self.pool
	local all, all_len = pool:getItems()

	for i = 1, all_len do
		local e = all[i]
		-- Skip dragged debug bodies; do not abort the whole update.
		if e:has("body") and not e:get("bump").debug_clicked and overlaps_query_rect(pool, e, x, y, w, h) then
			self:update_body(e)
			self:check_col(e)
		end
	end
end

function BumpCollision:update_body(e)
	local body = e:get("body")
	local pos = e:get("pos")
	local pool = self.pool

	if body.vel_x == 0 and body.vel_y == 0 then
		apply_wall_hit_from_dx(pool, e, body)
		return
	end

	if body.vel_x == 0 and body.vel_y > 0 then
		local rx, ry, rw, rh = pool:getRect(e)
		local _, py, cols, len = pool:projectMove(e, rx, ry, rw, rh, rx, ry + body.vel_y, filter)
		pool.freeCollisions(cols)
		if py <= ry + 1e-6 then
			body.vel_y = 0
			apply_wall_hit_from_dx(pool, e, body)
			return
		end
	end

	local goal_x = pos.x + body.vel_x
	local cols, len
	pos.x, pos.y, cols, len = pool:move(
		e,
		goal_x,
		pos.y + body.vel_y,
		filter
	)

	for i = 1, len do
		local c = cols[i]
		local other = c.other
		local other_col = other:get("collider")
		other_col.is_hit = true
		other_col.normal.x = c.normalX
		other_col.normal.y = c.normalY

		if other:has("wall") then
			e:give("hit_wall")
		end
	end
	pool.freeCollisions(cols)

	if body.vel_x ~= 0 and not e:has("hit_wall") then
		local dir = body.vel_x > 0 and 1 or -1
		if is_blocked_by_wall(pool, e, dir) then
			e:give("hit_wall")
		end
	end

	apply_wall_hit_from_dx(pool, e, body)
end

function BumpCollision:check_col(e)
	local cols, len = self:overlap_at(e)
	local pool = self.pool
	local has_collide_with = false
	local active_interact = nil

	local within_int = e:get("within_interactive")
	for i = 1, len do
		local c = cols[i]
		local e_other = c.other
		local other_col = e_other:get("collider")
		other_col.normal.x = c.normalX
		other_col.normal.y = c.normalY

		if can_interact_with(e, e_other, pool, INTERACT_REACH) then
			if not within_int then
				self.world:emit("on_collide_interactive", e, e_other)
			elseif within_int.entity ~= e_other then
				self.world:emit("on_change_interactive", e, e_other)
			end
			active_interact = e_other
		end

		if e_other:has("controller") then
			e:ensure("collide_with", e_other)
			has_collide_with = true
		end
		if e:has("controller") then
			e_other:ensure("collide_with", e)
			has_collide_with = true
		end

		if active_interact then
			break
		end
	end

	if within_int and not active_interact then
		local target = within_int.entity
		if not can_interact_with(e, target, pool, INTERACT_LEAVE_REACH) then
			self.world:emit("on_leave_interactive", e, target)
		end
	end

	if e:has("can_interact") and not active_interact and not e:has("within_interactive") then
		self.world:emit("remove_outlines")
	end

	if not has_collide_with then
		e:remove("collide_with")
	end

	self.pool.freeCollisions(cols)
end

function BumpCollision:overlap_at(e)
	-- pool:check() calls projectMove() and can spin when overlapping at rest.
	local rx, ry, rw, rh = self.pool:getRect(e)
	return self.pool:project(e, rx, ry, rw, rh, rx, ry, filter)
end

function BumpCollision:on_item_use(item)
	assert((item.__isEntity and item:has("item")), item)
	local x, y, w, h = get_query_rect(self)
	local items, len = self.pool:queryRect(x, y, w, h)
	local e_other
	for i = 1, len do
		local e = items[i]
		local cols, c_len = self:overlap_at(e)
		for c = 1, c_len do
			local col = cols[c]
			local other = col.other
			local within_int = e:get("within_interactive")
			if within_int and other:has("interactive") then
				e_other = other
				break
			end
		end
		self.pool.freeCollisions(cols)
	end
	self.world:emit("on_item_use_with", item, e_other)
end

function BumpCollision:update_collider(e)
	assert((e.__isEntity and e:has("collider") and e:has("animation")), e)
	if e:has("skip_collider_update") then
		return
	end
	local id = e:get("id")
	if id.value ~= "enemy" then
		return
	end
	local new_collider = Data.Colliders[id.value]
	local sub_id = id.sub_id
	if sub_id then
		new_collider = new_collider[sub_id]
	end
	local animation = e:get("animation")
	new_collider = new_collider[animation.obj.current_tag]
	if not new_collider then
		return
	end

	local collider = e:get("collider")
	local pos = e:get("pos")
	local w = new_collider.w
	if not w then
		w = collider.w
	end
	local h = new_collider.h
	if not h then
		h = collider.h
	end
	local col_offset = e:get("collider_offset")
	if col_offset then
		pos.x = pos.x + col_offset.ox
		pos.y = pos.y + col_offset.oy
	end

	collider.w, collider.h = w, h
	collider.w_h = w / 2
	collider.h_h = h / 2

	if new_collider.ox or new_collider.oy then
		local t = e:get("transform")
		local sx = new_collider.sx
		if sx then
			t.sx = sx
		end
		local sy = new_collider.sy
		if sy then
			t.sy = sy
		end
		local ox = new_collider.ox
		if ox then
			t.ox = ox
		end
		local oy = new_collider.oy
		if oy then
			t.oy = oy
		end
	end

	self.pool:update(e, pos.x, pos.y, w, h)
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

	local tbl_n = { Text = "", ReturnOnText = false, NumbersOnly = true }

	function BumpCollision:debug_update(dt)
		if not self.debug_show then
			flags.bodies = false
			return
		end
		self.debug_show = Slab.BeginWindow("BumpCollision", {
			Title = self.debug_title,
			IsOpen = self.debug_show,
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
			DevTools.debug_bump_drag = flags.drag
			self.world:emit("debug_on_drag", flags.drag)
		end
		if Slab.CheckBox(flags.visible_only, "Visible Only") then
			flags.visible_only = not flags.visible_only
		end
		Slab.SameLine()
		if Slab.CheckBox(flags.fill, "Fill") then
			flags.fill = not flags.fill
		end

		if Slab.BeginTree("List", { Title = "List" }) then
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
				local id = e:get("id").value
				if Slab.BeginTree(id, { Title = id, IsOpen = e:get("bump").debug_selected }) then
					Slab.Indent()
					local x, y, w, h = self.pool:getRect(e)
					x = edit("x", x, e:get("pos"))
					y = edit("y", y, e:get("pos"))
					w = edit("w", w, e:get("collider"))
					h = edit("h", h, e:get("collider"))
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
			e:get("bump").debug_hovered = true
			e:get("bump").debug_selected = love.mouse.isDown(2)
			if love.keyboard.isDown("lshift") and e:get("bump").debug_selected then
				self.world:emit("debug_e_right_clicked", e)
			end
		end
		Slab.EndWindow()
	end

	function BumpCollision:debug_draw()
		if not flags.bodies then
			return
		end
		local camera = self.world:getResource("camera")
		local scale = (camera and camera:getScale()) or 1
		love.graphics.setFont(fnt)
		local x, y, w, h = get_query_rect(self)
		local items, len = self.pool:queryRect(x, y, w, h)
		for i = 1, len do
			local e = items[i]
			local id = e:get("id").value
			local rx, ry, rw, rh = self.pool:getRect(e)

			if flags.fill then
				love.graphics.setColor(1, 0, 0, 0.3)
				love.graphics.rectangle("fill", rx, ry, rw, rh)
			end

			love.graphics.setLineWidth(1 / scale)
			local bump = e:get("bump")
			local collider = e:get("collider")
			if bump.debug_hovered or (e:has("interactive") and collider.is_hit) then
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
				local bump = e:get("bump")
				if bump.debug_clicked then
					local pos = e:get("pos")
					local _, _, rw, rh = self.pool:getRect(e)
					pos.x = math.floor(mx)
					pos.y = math.floor(my)
					self.pool:update(e, pos.x, pos.y, rw, rh)
				end
			end
		end
	end

	function BumpCollision:debug_mousepressed(_, _, mb)
		if not flags.drag then
			return
		end
		if mb ~= 1 then
			return
		end
		local mx, my = get_query_point(self)
		local items, len = self.pool:queryPoint(mx, my)
		for i = 1, len do
			local e = items[i]
			local bump = e:get("bump")
			if bump.debug_hovered then
				bump.debug_clicked = true
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
				local bump = e:get("bump")
				if bump.debug_clicked then
					local pos = e:get("pos")
					local _, _, rw, rh = self.pool:getRect(e)
					pos.x = math.floor(mx)
					pos.y = math.floor(my)
					bump.debug_clicked = false
					self.pool:update(e, pos.x, pos.y, rw, rh)
				end
			end
		end
	end
end

return BumpCollision
