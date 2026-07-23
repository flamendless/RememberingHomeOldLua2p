local ANIM_STATE = Enums.anim_state

local AnimationState = Concord.system()

function AnimationState:init(world)
	self.world = world
end

function AnimationState:anim_idle(e, should_stop)
	assert(e.__isEntity and e.animation and e.body and e.animation_ev_update)
	if should_stop then assert(type(should_stop) == "boolean", should_stop) end
	if e.override_animation then
		return
	end
	local body = e.body
	if body.dir == -1 then
		self.world:emit(e.animation_ev_update.value, ANIM_STATE.idle, "_left")
	else
		self.world:emit(e.animation_ev_update.value, ANIM_STATE.idle)
	end
	if should_stop then
		body.dx = 0
		body.vel_x = 0
		body.vel_y = 0
	end
end

function AnimationState:anim_face_left(e)
	assert(e.__isEntity and e.animation and e.body and e.animation_ev_update)
	if e.override_animation then
		return
	end
	e.body.dir = -1
	self.world:emit(e.animation_ev_update.value, ANIM_STATE.idle, "_left")
end

function AnimationState:anim_face_right(e)
	assert(e.__isEntity and e.animation and e.body and e.animation_ev_update)
	if e.override_animation then
		return
	end
	e.body.dir = 1
	self.world:emit(e.animation_ev_update.value, ANIM_STATE.idle)
end

function AnimationState:anim_open_door(e)
	assert(e.__isEntity and e.animation and e.body)
	local tag = (e.body.dir == -1) and ANIM_STATE.open_door_left or ANIM_STATE.open_door
	e:give("change_animation_tag", tag):give("override_animation"):give("animation_on_loop", "anim_pause_at_end", 0, e)
end

function AnimationState:anim_open_locked_door(e)
	assert(e.__isEntity and e.animation and e.body)
	local tag = (e.body.dir == -1) and ANIM_STATE.open_locked_door_left or ANIM_STATE.open_locked_door
	e:give("change_animation_tag", tag):give("override_animation"):give("animation_on_loop", "anim_pause_at_end", 0, e)
end

function AnimationState:anim_open_lighter(e)
	assert(e.__isEntity and e.animation and e.body)
	local tag = (e.body.dir == -1) and ANIM_STATE.open_lighter_left or ANIM_STATE.open_lighter
	e:give("change_animation_tag", tag):give("override_animation"):give(
		"animation_on_loop",
		"anim_loop_over_to",
		0,
		e,
		9 -- frame
	)
end

function AnimationState:anim_close_lighter(e)
	assert(e.__isEntity and e.animation and e.body)
	local tag = (e.body.dir == -1) and ANIM_STATE.close_lighter_left or ANIM_STATE.close_lighter
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
