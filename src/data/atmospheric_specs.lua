local AtmosphericSpecs = {}

AtmosphericSpecs.defaults = {
	enabled = true,
	direction_offset = 0.14,
	drift_x = { min = 5, max = 12 },
	gravity = { min = 6, max = 14 },
	speed = { min = 8, max = 16 },
	spread = 0.08,
	emission_rate = 10,
	emission_height = 8,
	lifetime = { min = 4, max = 10 },
	size_min = 0.45,
	size_max = 1.1,
	size_variation = 0.35,
	spin_min = -0.3,
	spin_max = 0.3,
	spin_variation = 0.2,
	color = { 0.28, 0.25, 0.2, 1 },
	blend_mode = "alpha",
}

function AtmosphericSpecs.get(room_id)
	local config = tablex.copy(AtmosphericSpecs.defaults)
	if not room_id or not AtmosphericSpecs[room_id] then
		return config
	end

	for k, v in pairs(AtmosphericSpecs[room_id]) do
		config[k] = v
	end
	return config
end

return AtmosphericSpecs
