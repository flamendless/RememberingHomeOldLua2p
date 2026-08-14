Concord.component("interactive_highlight", function(c, opts)
	opts = opts or {}
	c.time = 0
	c.overlay_strength = opts.overlay_strength or 0.72
	c.opacity = opts.opacity or 0
	c.speed = opts.speed or 1
end)
