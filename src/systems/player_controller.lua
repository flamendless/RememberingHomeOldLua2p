local PlayerController = Concord.system({
	pool = { "player_controller", "body", "collider" },
})

local function stop_body_motion(e)
	local body = e:get("body")
	body.dx = 0
	body.vel_x = 0
	body.vel_y = 0
	local is_running = e:get("is_running")
	if is_running then
		is_running.value = false
	end
end

function PlayerController:init(world)
	self.world = world
	self.turn_cooldown = 0
	self.on_lighter = false
	self.lighter_opened_this_frame = false

	if DEV then
		self.turn_delay = 0.01
	else
		self.turn_delay = 0.03 -- TODO: finalize value someday
		Log.debug("TODO: finalize value someday")
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
		Items.add(Enums.item_id.flashlight)
		Items.toggle_equip(Enums.item_id.flashlight)
	end
	local has_f = Items.is_equipped(Enums.item_id.flashlight)
	local can_open_door = self.player:get("can_open_door")
	local data, mods = Assemblages.Player.get_multi_anim_data(has_f, can_open_door)
	local animation = self.player:get("animation")
	animation.obj:set_data(data, mods, Enums.anim_state.idle)
	local body = self.player:get("body")
	local tag
	if body.dir == -1 then
		tag = Enums.anim_state.idle_left
	else
		tag = Enums.anim_state.idle
	end
	animation.obj:play(tag, Enums.anim_state.idle, true)
end

-- Player-side animation state actions. These replace the legacy AnimationState
-- system for the player: they drive the Anim instance directly and register
-- callbacks on it instead of giving trigger/signal components.
function PlayerController:anim_idle(e, should_stop)
	if not e then return end
	local animation = e:get("animation")
	if not animation then return end
	assert:type_or_nil(should_stop, "boolean")
	if e:has("override_animation") then return end
	local body = e:get("body")
	if body.dir == -1 then
		animation.obj:play(Enums.anim_state.idle_left, Enums.anim_state.idle)
	else
		animation.obj:play(Enums.anim_state.idle)
	end
	if should_stop then
		stop_body_motion(e)
	end
end

function PlayerController:anim_face_left(e)
	if not e then return end
	local animation = e:get("animation")
	if not animation then return end
	if e:has("override_animation") then return end
	local body = e:get("body")
	body.dir = -1
	animation.obj:play(Enums.anim_state.idle_left, Enums.anim_state.idle)
end

function PlayerController:anim_face_right(e)
	if not e then return end
	local animation = e:get("animation")
	if not animation then return end
	if e:has("override_animation") then return end
	local body = e:get("body")
	body.dir = 1
	animation.obj:play(Enums.anim_state.idle)
end

function PlayerController:anim_open_door(e)
	if not e then return end
	local animation = e:get("animation")
	if not animation then return end
	stop_body_motion(e)
	local obj = animation.obj
	local body = e:get("body")
	local tag
	if body.dir == -1 then
		tag = Enums.anim_state.open_door_left
	else
		tag = Enums.anim_state.open_door
	end
	obj:play(tag)
	obj:on("loop", function()
		obj:pause_at_end()
	end)
	e:give("override_animation")
end

function PlayerController:anim_open_lighter(e)
	if not e then return end
	local animation = e:get("animation")
	if not animation then return end
	stop_body_motion(e)
	local obj = animation.obj
	local body = e:get("body")
	local tag
	if body.dir == -1 then
		tag = Enums.anim_state.open_lighter_left
	else
		tag = Enums.anim_state.open_lighter
	end
	obj:play(tag, Enums.anim_state.open_lighter, true)
	obj:on("loop", function()
		obj:goto_frame(9)
	end)
	e:give("override_animation")
end

function PlayerController:anim_close_lighter(e)
	if not e then return end
	local animation = e:get("animation")
	if not animation then return end
	stop_body_motion(e)
	local obj = animation.obj
	local world = self.world
	local body = e:get("body")
	local tag
	if body.dir == -1 then
		tag = Enums.anim_state.close_lighter_left
	else
		tag = Enums.anim_state.close_lighter
	end
	obj:play(tag, Enums.anim_state.close_lighter, true)
	obj:on("loop", function()
		obj:pause_at_end()
	end)
	obj:once("finish", function()
		world:emit("on_anim_close_lighter_done")
	end)
	e:give("override_animation")
end

function PlayerController:on_close_lighter()
	if not self.player or not self.on_lighter then
		return
	end
	self.last_desired_dir = 0
	self.world:emit("anim_close_lighter", self.player)
	self.on_lighter = false
end

function PlayerController:on_open_lighter()
	if not self.player or self.on_lighter then
		return
	end
	if DEV then
		Items.add(Enums.item_id.lighter1)
		Items.toggle_equip(Enums.item_id.lighter1)
	end
	self.last_desired_dir = 0
	self.world:emit("anim_open_lighter", self.player)
	self.on_lighter = true
	self.player:remove(Enums.player_cap.can_lighter)
	self.lighter_opened_this_frame = true
end

function PlayerController:on_toggle_equip_lighter()
	if DEV then
		Items.add(Enums.item_id.lighter1)
		Items.toggle_equip(Enums.item_id.lighter1)
	end
	-- local has_l = Items.is_equipped("lighter1")
	-- self.world:emit("lighter_update_pos", self.player)
	-- self.world:emit("flip_e_id_component", "lighter1", "hidden")
	self.last_desired_dir = 0
	if not self.on_lighter and self.player:has(Enums.player_cap.can_lighter) then
		self.world:emit("anim_open_lighter", self.player)
		self.on_lighter = true
		self.player:remove(Enums.player_cap.can_lighter)
	elseif self.on_lighter and not self.player:has("block_lighter_close") then
		self.world:emit("anim_close_lighter", self.player)
		self.on_lighter = false
	end
end

function PlayerController:on_anim_close_lighter_done()
	self.player:give(Enums.player_cap.can_lighter):remove("override_animation")
end

function PlayerController:is_lighter_opening()
	local e = self.player
	if not e or not e:has("override_animation") then
		return false
	end
	local animation = e:get("animation")
	if not animation then
		return false
	end
	local obj = animation.obj
	if obj.base_tag ~= Enums.anim_state.open_lighter then
		return false
	end
	return obj.is_playing and math.floor(obj.anim8.position) < 9
end

function PlayerController:is_lighter_closing()
	local e = self.player
	if not e or not e:has("override_animation") then
		return false
	end
	local animation = e:get("animation")
	if not animation then
		return false
	end
	return animation.obj.base_tag == Enums.anim_state.close_lighter
end

function PlayerController:spawn_player(fn)
	assert:type_or_nil(fn, "function")
	assert:equal(self.player, nil, "Player already exists")

	local x, y, face = Data.Rooms.get_spawn(GameStates.current_id, GameStates.prev_id)
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
	stop_body_motion(self.player)
	local anim_name = self:player_update_animation()
	self.world:emit("update_speed_data", self.player, anim_name)
end

function PlayerController:update(dt)
	if not self.player then return end

	local skip_lighter_input = self.lighter_opened_this_frame
	self.lighter_opened_this_frame = false

	local lighter_pressed = Inputs.pressed(Enums.input.lighter)
	if lighter_pressed and not skip_lighter_input then
		if self:is_lighter_opening() or self:is_lighter_closing() then
			return
		end
		if self.on_lighter and not self.player:has("block_lighter_close") then
			self:on_toggle_equip_lighter()
			return
		elseif self.player:has(Enums.player_cap.can_lighter) then
			self:on_toggle_equip_lighter()
			return
		end
	end

	if self.player:has("override_animation") then
		stop_body_motion(self.player)
		return
	end
	if not self.player:has("can_move") then return end

	local within_int = self.player:get("within_interactive")
	local body = self.player:get("body")
	body.dx = 0

	if self.player:has("can_run") then
		local is_running = self.player:get("is_running")
		is_running.value = Inputs.down(Enums.input.run_mod)
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

	local left_held = Inputs.held(Enums.input.left)
	local right_held = Inputs.held(Enums.input.right)
	local only_left = self.player:get("can_move_left_only")
	local only_right = self.player:get("can_move_right_only")

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
			if not Inputs.down(Enums.input.left) and not Inputs.down(Enums.input.right) then
				self.last_desired_dir = 0
			end
		end
	end

	if within_int and self.player:has("can_interact") and Inputs.pressed(Enums.input.interact) then
		local other = within_int.entity
		local req = other:get("req_col_dir")
		local proceed = true

		if req and (body.dir ~= req.value) then
			proceed = false
		end

		if proceed then
			if other:has("dialogue_key") then
				self:on_player_interact(self.player, other)
			elseif other:has("is_door") then
				self.world:emit("on_interact_door", self.player, other)
			elseif other:has("candle") then
				self.world:emit("on_interact_candle", self.player, other)
			end
		end
	end

	if self.player:has("override_animation") then
		stop_body_motion(self.player)
	else
		local anim_name = self:player_update_animation()
		self.world:emit("update_speed_data", self.player, anim_name)
	end
	-- self.world:emit("lighter_update_pos", self.player)
end

function PlayerController:player_force_face_dir(dir)
	assert:type(dir, "number")
	local body = self.player:get("body")
	body.dir = dir
	local anim_name = self:player_update_animation()
	self.world:emit("update_speed_data", self.player, anim_name)
end

function PlayerController:player_update_animation(override_name, override_variant)
	local anim_name = override_name
	local anim_variant = override_variant or ""
	local body = self.player:get("body")

	if not anim_name then
		if body.dx ~= 0 and not self.player:has("hit_wall") then
			local is_running = self.player:get("is_running")
			if is_running.value then
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

	if DEV then
		if DevTools.debug_anim.tag then
			return DevTools.debug_anim.tag
		end
	end
	self.player:get("animation").obj:play(anim_name .. anim_variant, anim_name)

	return anim_name
end

function PlayerController:on_player_interact(player, e_interactive)
	assert((player.__isEntity and player:has("player")), player)
	assert((e_interactive.__isEntity and e_interactive:has("interactive")), e_interactive)
	self.player:get("is_interacting").value = true
	-- self.world:emit("on_interact_or_inventory")
	-- self.world:emit("create_speech_bubble", player)
	-- local d = interactive.dialogue_meta
	-- local dialogues_t = Dialogues.get(d.main, d.sub)
	-- self.world:emit("spawn_dialogue", dialogues_t, d.main, d.sub)

	self.world:emit("start_dialogue", player, e_interactive)
end

function PlayerController:on_interact_or_inventory()
	if not self.player:has("prev_can") then
		self.player:give("prev_can", self.player)
		self.world:emit("anim_idle", self.player, true)
	end
	self.world:emit("toggle_component", self.player, Enums.player_cap.can_move, false)
	self.world:emit("toggle_component", self.player, Enums.player_cap.can_interact, false)
	self.world:emit("toggle_component", self.player, Enums.player_cap.can_run, false)
end

function PlayerController:on_leave_interact_or_inventory()
	local prev_can_comp = self.player:get("prev_can")
	local prev_can
	if prev_can_comp then
		prev_can = prev_can_comp.value
	end
	if not prev_can then
		return
	end
	if prev_can.move then
		self.player:give(Enums.player_cap.can_move)
	end
	if prev_can.run then
		self.player:give(Enums.player_cap.can_run)
	end
	if prev_can.interact then
		GameStates.after(0.5, function()
			if not self.player or not self.player.__isEntity then
				return
			end
			self.player:give(Enums.player_cap.can_interact)
			self.player:get("is_interacting").value = false
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

		local pos = self.player:get("pos")
		Slab.Text("Pos")
		Slab.Indent()
		view_number("x", pos.x, true)
		view_number("y", pos.y)
		Slab.Unindent()

		local transform = self.player:get("transform")
		Slab.Text("Transform")
		Slab.Indent()
		view_number("sx", transform.sx, true)
		view_number("sy", transform.sy)
		view_number("ox", transform.ox, true)
		view_number("oy", transform.oy)
		Slab.Unindent()

		local qt = self.player:get("quad_transform")
		if qt then
			Slab.Text("Quad Transform")
			Slab.Indent()
			view_number("qsx", qt.sx, true)
			view_number("qsy", qt.sy)
			view_number("qox", qt.ox, true)
			view_number("qoy", qt.oy)
			Slab.Unindent()
		end

		local obj = self.player:get("animation").obj
		Slab.Text("animation")
		Slab.Indent()
		Slab.Input("anim_tag", { Text = obj.current_tag, ReadOnly = true })
		Slab.SameLine()
		view_number("frame", obj.frame)
		Slab.Unindent()

		local quad = self.player:get("quad")
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
		local body = self.player:get("body")
		Slab.Indent()
		view_number("dx", body.dx, true)
		view_number("dir", body.dir, false)
		view_number("vel_x", body.vel_x, true)
		view_number("vel_y", body.vel_y, false)
		Slab.Unindent()

		Slab.CheckBox(self.player:get("can_move"), "move")
		Slab.SameLine()
		Slab.CheckBox(self.player:get("can_move_left_only"), "left only")
		Slab.SameLine()
		Slab.CheckBox(self.player:get("can_move_right_only"), "right only")
		Slab.SameLine()
		Slab.CheckBox(self.player:get("can_run"), "run")
		Slab.SameLine()
		Slab.CheckBox(self.player:get("can_interact"), "interact")
		Slab.SameLine()
		Slab.CheckBox(self.player:get("can_open_door"), "open_door")

		Slab.EndWindow()
	end
end

for k, v in pairs(PlayerController) do
	if k:match("^anim_") and not stringx.ends_with(k, "_left") then
		PlayerController[k .. "_left"] = v
	end
end

return PlayerController
