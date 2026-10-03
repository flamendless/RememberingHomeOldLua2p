local DialogueHandlers = {}

function DialogueHandlers.is_dunder_dialogue_key(key)
	assert:type(key, "string")
	return key:match("^__(.-)__$") ~= nil
end

local function room_switch_lights_off(world, switch_id)
	assert:world(world)
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
	assert:world(world)
	assert:type(dialogue_key, "string")
	if dialogue_key == Enums.dialogue_knot.__light_switch__
		or dialogue_key == Enums.dialogue_knot.__light_switch_min__ then
		local on_knot = Enums.dialogue_knot.__light_switch_on__
		local off_knot = Enums.dialogue_knot.__light_switch_off__
		if dialogue_key == Enums.dialogue_knot.__light_switch_min__ then
			on_knot = Enums.dialogue_knot.__light_switch_on_min__
			off_knot = Enums.dialogue_knot.__light_switch_off_min__
		end
		if room_switch_lights_off(world, "room") then
			return on_knot
		end
		return off_knot
	end
	return dialogue_key
end

return DialogueHandlers
