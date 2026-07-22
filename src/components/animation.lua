Concord.component("override_animation")

local c_anim = Concord.component("animation", function(c, stop_on_last)
	if stop_on_last then
		assert(type(stop_on_last) == "boolean", stop_on_last)
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
	assert(type(new_tag) == "string", new_tag)
	if override then
		assert(type(override) == "boolean", override)
	end
	c.new_tag = new_tag
	c.override = override
end)

Concord.component("animation_pause_at", function(c, at_frame)
	if type(at_frame) == "string" then
		assert(Enums.pause_at[at_frame], "Invalid 'at_frame'. Got " .. at_frame)
	end
	c.at_frame = at_frame
end)

Concord.component("animation_stop", function(c, event)
	assert(type(event) == "string", event)
	c.event = event
end)

Concord.component("current_frame", function(c, max)
	if max then
		assert((type(max) == "number" and max > 0), max)
	end
	c.value = 0
	c.max = max
end)

Concord.component("animation_ev_update", function(c, ev_update)
	assert(type(ev_update) == "string", ev_update)
	c.value = ev_update
end)
