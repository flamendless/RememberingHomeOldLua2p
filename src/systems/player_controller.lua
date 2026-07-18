local PlayerController = Concord.system({
	pool = { "player_controller", "body", "collider" },
})

local function get_spawn_points(current_id, prev_id)
	local d1 = Data.PlayerSpawnPoints[current_id]
	if not d1[prev_id] then
		prev_id = "default"
	end
	local d = Data.PlayerSpawnPoints[current_id][prev_id]
	if not d then
		error("No data given current_id " .. current_id .. " and prev_id " .. prev_id)
	end
	if not d[3] then
		d[3] = Enums.face_dir.left
	end
	if not (type(d[3]) == "string" and (d[3] == Enums.face_dir.left or d[3] == Enums.face_dir.right)) then
		error('Assertion failed: type(d[3]) == "string" and\
\9\9(d[3] == Enums.face_dir.left or d[3] == Enums.face_dir.right)')
	end
	return unpack(d)
end

function PlayerController:init(world)
	self.world = world
	self.turn_cooldown = 0

	if DEV then
		self.turn_delay = 0.01
	else
		self.turn_delay = 0.03 -- TODO: finalize value someday
	end
	self.last_desired_dir = 0

	-- self.pool.onAdded = function(_, e)
	-- 	local e_player = self.world:getResource("e_player")
	-- 	if not e_player then
	-- 		self.world:setResource("e_player", e)
	-- 	end
	-- end
end

function PlayerController:on_toggle_equip_flashlight()
	if DEV then
		Items.add("flashlight")
		Items.toggle_equip("flashlight")
	end
	local has_f = Items.is_equipped("flashlight")
	self.player:remove("multi_animation_data"):give(
		"multi_animation_data",
		Enums.anim_state.idle,
		Assemblages.Player.get_multi_anim_data(has_f, self.player.can_open_door)
	)
	local tag = (self.player.body.dir == -1) and Enums.anim_state.idle_left or Enums.anim_state.idle
	self.player:give("change_animation_tag", tag, true)
end

function PlayerController:on_toggle_equip_lighter()
	if DEV then
		Items.add("lighter1")
		Items.toggle_equip("lighter1")
	end
	-- local has_l = Items.is_equipped("lighter1")
	self.world:emit("lighter_update_pos", self.player)
	self.world:emit("flip_e_id_component", "lighter1", "hidden")
end

function PlayerController:spawn_player(fn)
	if fn then assert(type(fn) == "function") end
	if self.player ~= nil then error("Player already exists") end

	-- local x, y, face = get_spawn_points(self.world.current_id, self.world.prev_id)
	local x, y, face = get_spawn_points(GameStates.current_id, GameStates.prev_id)
	self.player = Concord.entity(self.world):assemble(Assemblages.Player.room, x, y)
	self.world:__flush()
	if face == Enums.face_dir.left then
		self.world:emit("anim_face_left", self.player)
	elseif face == Enums.face_dir.right then
		self.world:emit("anim_face_right", self.player)
	end
	if fn then
		fn(self.player)
	end

	self.world:setResource("e_player", self.player)
	self.world:emit("spawn_lighter", self.player)
end

function PlayerController:player_stop()
	-- INFO: must remove can_move component first, then flush, before emitting this
	self.last_desired_dir = 0
	local anim_name = self:player_update_animation()
	self.world:emit("update_speed_data", self.player, anim_name)
end

function PlayerController:update(dt)
	if not self.player then return end
	if self.player.override_animation then return end
	if not self.player.can_move then return end

	local within_int = self.player.within_interactive
	local body = self.player.body
	body.dx = 0

	if self.player.can_run then
		self.player.is_running.value = Inputs.down("run_mod")
	end

	-- SIMPLE MOVEMENT (causes left/right spamming to instantly flip)
	-- if Inputs.down("left") then
	-- 	body.dir = -1
	-- 	body.dx = -1
	-- elseif Inputs.down("right") then
	-- 	body.dir = 1
	-- 	body.dx = 1
	-- end

	local turn_cd = self.turn_cooldown
	local turn_delay = self.turn_delay
	self.turn_cooldown = math.max(0, turn_cd - dt)

	local left_held = Inputs.held("left")
	local right_held = Inputs.held("right")
	local only_left = self.player.can_move_left_only
	local only_right = self.player.can_move_right_only

	local desired_dir = 0
	if left_held and (only_right == nil) then
		desired_dir = -1
	elseif right_held and (only_left == nil) then
		desired_dir = 1
	end

	if desired_dir ~= self.last_desired_dir then
		if self.turn_cooldown <= 0 then
			self.last_desired_dir = desired_dir
		end
	end

	if self.turn_cooldown > 0 then
		body.dx = 0
	else
		if desired_dir ~= 0 then
			if desired_dir ~= body.dir then
				body.dir = desired_dir
				self.turn_cooldown = turn_delay
				body.dx = 0
			else
				body.dx = desired_dir
			end
		else
			body.dx = 0
			if not Inputs.down("left") and not Inputs.down("right") then
				self.last_desired_dir = 0
			end
		end
	end

	if within_int and self.player.can_interact and Inputs.pressed("interact") then
		local other = within_int.entity
		local req = other.req_col_dir
		local proceed = true

		if req and (body.dir ~= req.value) then
			proceed = false
		end

		if proceed then
			if other.dialogue_key then
				self:on_player_interact(self.player, other)
			elseif other.is_door then
				self.world:emit("on_interact_door", self.player, other)
			end
		end
	end

	local anim_name = self:player_update_animation()
	self.world:emit("update_speed_data", self.player, anim_name)
	self.world:emit("lighter_update_pos", self.player)
end

function PlayerController:player_force_face_dir(dir)
	assert(type(dir) == "number", dir)
	self.player.body.dir = dir
	local anim_name = self:player_update_animation()
	self.world:emit("update_speed_data", self.player, anim_name)
end

function PlayerController:player_update_animation(override_name, override_variant)
	local anim_name = override_name
	local anim_variant = override_variant or ""
	local body = self.player.body

	if not anim_name then
		if body.dx ~= 0 and not self.player.hit_wall then
			if self.player.is_running.value then
				anim_name = Enums.anim_state.run
			else
				anim_name = Enums.anim_state.walk
			end
		else
			anim_name = Enums.anim_state.idle
		end
	end

	if body.dir == -1 then
		anim_variant = "_left"
	end

	self.world:emit("switch_animation_tag", self.player, anim_name .. anim_variant, anim_name)

	return anim_name
end

function PlayerController:on_player_interact(player, e_interactive)
	if not (player.__isEntity and player.player) then
		error("Assertion failed: player.__isEntity and player.player")
	end
	if not (e_interactive.__isEntity and e_interactive.interactive) then
		error("Assertion failed: interactive.__isEntity and interactive.interactive")
	end
	self.player.is_interacting.value = true
	-- self.world:emit("on_interact_or_inventory")
	-- self.world:emit("create_speech_bubble", player)
	-- local d = interactive.dialogue_meta
	-- local dialogues_t = Dialogues.get(d.main, d.sub)
	-- self.world:emit("spawn_dialogue", dialogues_t, d.main, d.sub)

	self.world:emit("start_dialogue", player, e_interactive)
end

function PlayerController:on_interact_or_inventory()
	if not self.player.prev_can then
		self.player:give("prev_can", self.player)
		self.world:emit("anim_idle", self.player, true)
	end
	self.world:emit("toggle_component", self.player, "can_move", false)
	self.world:emit("toggle_component", self.player, "can_interact", false)
	self.world:emit("toggle_component", self.player, "can_run", false)
end

function PlayerController:on_leave_interact_or_inventory()
	local prev_can = self.player.prev_can and self.player.prev_can.value
	if not prev_can then
		return
	end
	if prev_can.move then
		self.player:give("can_move")
	end
	if prev_can.run then
		self.player:give("can_run")
	end
	if prev_can.interact then
		Timer.after(0.5, function()
			self.player:give("can_interact")
			self.player.is_interacting.value = false
		end)
	end
	self.player:remove("prev_can")
	-- self.world:emit("remove_speech_bubble")
end

if DEV then
	local function view_number(id, value, sameline)
		Slab.Text(id)
		Slab.SameLine()
		Slab.Input(id, { Text = value, ReadOnly = true, NumbersOnly = true })
		if sameline then
			Slab.SameLine()
		end
	end

	function PlayerController:debug_update(dt)
		if not self.debug_show then
			return
		end
		self.debug_show = Slab.BeginWindow("player", {
			Title = "PlayerController",
			IsOpen = self.debug_show,
		})

		if self.player == nil then
			if Slab.Button("Spawn Player") then
				self:spawn_player()
			end
			Slab.EndWindow()
			return
		end

		local pos = self.player.pos
		Slab.Text("Pos")
		Slab.Indent()
		view_number("x", pos.x, true)
		view_number("y", pos.y)
		Slab.Unindent()

		local transform = self.player.transform
		Slab.Text("Transform")
		Slab.Indent()
		view_number("sx", transform.sx, true)
		view_number("sy", transform.sy)
		view_number("ox", transform.ox, true)
		view_number("oy", transform.oy)
		Slab.Unindent()

		local qt = self.player.quad_transform
		if qt then
			Slab.Text("Quad Transform")
			Slab.Indent()
			view_number("qsx", qt.sx, true)
			view_number("qsy", qt.sy)
			view_number("qox", qt.ox, true)
			view_number("qoy", qt.oy)
			Slab.Unindent()
		end

		local current_frame = self.player.current_frame
		Slab.Text("animation")
		Slab.Indent()
		Slab.Input("anim_tag", { Text = self.player.animation.current_tag, ReadOnly = true })
		Slab.SameLine()
		view_number("frame", current_frame.value)
		Slab.Unindent()

		local quad = self.player.quad
		local qx, qy, qw, qh = quad.quad:getViewport()
		local qsw, qsh = quad.quad:getTextureDimensions()
		Slab.Text("quad")
		Slab.Indent()
		view_number("x", qx, true)
		view_number("y", qy)
		view_number("w", qw, true)
		view_number("h", qh)
		view_number("rw", qsw, true)
		view_number("rh", qsh)
		Slab.Unindent()

		Slab.Text("body")
		local body = self.player.body
		Slab.Indent()
		view_number("dx", body.dx, true)
		view_number("dir", body.dir, false)
		view_number("vel_x", body.vel_x, true)
		view_number("vel_y", body.vel_y, false)
		Slab.Unindent()

		Slab.CheckBox(self.player.can_move, "move")
		Slab.SameLine()
		Slab.CheckBox(self.player.can_move_left_only, "left only")
		Slab.SameLine()
		Slab.CheckBox(self.player.can_move_right_only, "right only")
		Slab.SameLine()
		Slab.CheckBox(self.player.can_run, "run")
		Slab.SameLine()
		Slab.CheckBox(self.player.can_interact, "interact")
		Slab.SameLine()
		Slab.CheckBox(self.player.can_open_door, "open_door")

		Slab.EndWindow()
	end
end

return PlayerController
