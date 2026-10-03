Concord.component("light_ramp", function(c, dur, ease, instant_off)
	assert:type_or_nil(dur, "number")
	if dur ~= nil then
		assert(dur > 0, dur)
	end
	assert:type_or_nil(ease, "string")
	if ease ~= nil then
		assert(Enums.ease[ease], ease)
	end
	assert:type_or_nil(instant_off, "boolean")
	c.duration = dur or 0.2
	c.ease = ease or Enums.ease.expoout
	c.instant_off = instant_off or false
	c.active = false
	c.elapsed = 0
	c.to_on = false
	c.from_pl = 0
	c.from_diff = { 0, 0, 0 }
end)
