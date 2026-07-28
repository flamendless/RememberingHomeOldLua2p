Concord.component("dust", function(c, opts)
	assert:type_or_nil(opts, "table")
	opts = opts or {}
	c.direction = opts.direction or math.pi / 2
	c.color = opts.color or Palette.get("dust", 1)
	c.size = opts.size or 1.1
	c.strength = opts.strength or 1.0
	c.size_variation = opts.size_variation or 0.5
end)
