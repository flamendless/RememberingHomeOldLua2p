local DialogueHandlers = {}

function DialogueHandlers.is_dunder_dialogue_key(key)
	assert:type(key, "string")
	return key:match("^__(.-)__$") ~= nil
end

local function room_switch_lights_off(world, switch_id)
	assert:type(world, "table")
	assert:type_or_nil(switch_id, "string")
	switch_id = switch_id or "room"
	local ls = world:getSystem(ECS.get_system_class("light_switch"))
	if not ls or not ls.pool_lights then
		return true
	end

	local matched = false
	local any_on = false
	for _, e in ipairs(ls.pool_lights) do
		if e:has("light_switch_id") and e:get("light_switch_id").value == switch_id then
			matched = true
			if not e:has("light_disabled") then
				any_on = true
			end
		end
	end

	if not matched then
		return true
	end
	return not any_on
end

function DialogueHandlers.resolve_interact_dialogue_key(world, dialogue_key)
	assert:type(world, "table")
	assert:type(dialogue_key, "string")
	if dialogue_key == Enums.dialogue_knot.__light_switch__ then
		local lights_off = room_switch_lights_off(world, "room")
		world:emit("toggle_light_switch")
		if lights_off then
			return Enums.dialogue_knot.__light_switch_on__
		end
		return Enums.dialogue_knot.__light_switch_off__
	end
	return dialogue_key
end

return DialogueHandlers
