local ANIM_STATE = Enums.anim_state

local AnimationState = Concord.system()

function AnimationState:init(world)
	self.world = world
end

function AnimationState:anim_idle(e, should_stop)
	if not (e.__isEntity and e:has("animation") and e:has("body") and e:has("animation_ev_update")) then return end
	assert:type_or_nil(should_stop, "boolean")
	if e:has("override_animation") then
		return
	end
	local body = e:get("body")
	local animation_ev_update = e:get("animation_ev_update")
	if body.dir == -1 then
		self.world:emit(animation_ev_update.value, ANIM_STATE.idle, "_left")
	else
		self.world:emit(animation_ev_update.value, ANIM_STATE.idle)
	end
	if should_stop then
		body.dx = 0
		body.vel_x = 0
		body.vel_y = 0
	end
end

function AnimationState:anim_face_left(e)
	if not (e.__isEntity and e:has("animation") and e:has("body") and e:has("animation_ev_update")) then return end
	if e:has("override_animation") then
		return
	end
	local body = e:get("body")
	body.dir = -1
	self.world:emit(e:get("animation_ev_update").value, ANIM_STATE.idle, "_left")
end

function AnimationState:anim_face_right(e)
	if not (e.__isEntity and e:has("animation") and e:has("body") and e:has("animation_ev_update")) then return end
	if e:has("override_animation") then
		return
	end
	local body = e:get("body")
	body.dir = 1
	self.world:emit(e:get("animation_ev_update").value, ANIM_STATE.idle)
end

function AnimationState:anim_open_door(e)
	if not (e.__isEntity and e:has("animation") and e:has("body")) then return end
	local body = e:get("body")
	local tag
	if body.dir == -1 then
		tag = ANIM_STATE.open_door_left
	else
		tag = ANIM_STATE.open_door
	end
	e:give("change_animation_tag", tag):give("override_animation"):give("animation_on_loop", "anim_pause_at_end", 0, e)
end

function AnimationState:anim_open_locked_door(e)
	if not (e.__isEntity and e:has("animation") and e:has("body")) then return end
	local body = e:get("body")
	local tag
	if body.dir == -1 then
		tag = ANIM_STATE.open_locked_door_left
	else
		tag = ANIM_STATE.open_locked_door
	end
	e:give("change_animation_tag", tag):give("override_animation"):give("animation_on_loop", "anim_pause_at_end", 0, e)
end

function AnimationState:anim_open_lighter(e)
	if not (e.__isEntity and e:has("animation") and e:has("body")) then return end
	local body = e:get("body")
	local tag
	if body.dir == -1 then
		tag = ANIM_STATE.open_lighter_left
	else
		tag = ANIM_STATE.open_lighter
	end
	e:give("change_animation_tag", tag):give("override_animation"):give(
		"animation_on_loop",
		"anim_loop_over_to",
		0,
		e,
		9 -- frame
	)
end

function AnimationState:anim_close_lighter(e)
	if not (e.__isEntity and e:has("animation") and e:has("body")) then return end
	local body = e:get("body")
	local tag
	if body.dir == -1 then
		tag = ANIM_STATE.close_lighter_left
	else
		tag = ANIM_STATE.close_lighter
	end
	e:give("change_animation_tag", tag)
		:give("override_animation")
		:give("animation_on_loop", "anim_pause_at_end", 0, e)
		:give("animation_on_finish", "on_anim_close_lighter_done")
end

for k, v in pairs(AnimationState) do
	if k ~= "init" and not stringx.ends_with(k, "_left") then
		AnimationState[k .. "_left"] = v
	end
end

return AnimationState
