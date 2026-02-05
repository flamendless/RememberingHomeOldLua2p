Concord.component("override_animation")

local c_anim = Concord.component("animation", function(c, stop_on_last)
	if stop_on_last then
		if type(stop_on_last) ~= "boolean" then
			error('Assertion failed: type(stop_on_last) == "boolean"')
		end
	end
	c.grid = nil
	c.anim8 = nil
	c.base_tag = "default"
	c.current_tag = "default"
	c.is_playing = true
	c.stop_on_last = (stop_on_last == true) and true or false
end)

function c_anim:serialize()
	return {
		base_tag = self.base_tag,
		current_tag = self.current_tag,
		is_playing = self.is_playing,
		stop_on_last = self.stop_on_last,
	}
end

function c_anim:deserialize(data)
	self:__populate(data.stop_on_last)
end

Concord.component("change_animation_tag", function(c, new_tag, override)
	if type(new_tag) ~= "string" then
		error('Assertion failed: type(new_tag) == "string"')
	end
	if override then
		if type(override) ~= "boolean" then
			error('Assertion failed: type(override) == "boolean"')
		end
	end
	c.new_tag = new_tag
	c.override = override
end)

Concord.component("animation_pause_at", function(c, at_frame)
	if type(at_frame) == "string" then
		if not Enums.pause_at[at_frame] then
			error("Invalid 'at_frame'. Got " .. at_frame)
		end
	elseif type(at_frame) == "number" then
	end
	c.at_frame = at_frame
end)

Concord.component("animation_stop", function(c, event)
	if type(event) ~= "string" then
		error('Assertion failed: type(event) == "string"')
	end
	c.event = event
end)

Concord.component("current_frame", function(c, max)
	if max then
		if not (type(max) == "number" and max > 0) then
			error('Assertion failed: type(max) == "number" and max > 0')
		end
	end
	c.value = 0
	c.max = max
end)

Concord.component("animation_ev_update", function(c, ev_update)
	if type(ev_update) ~= "string" then
		error('Assertion failed: type(ev_update) == "string"')
	end
	c.value = ev_update
end)
