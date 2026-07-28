Concord.component("clickable")

Concord.component("on_click", function(c, mb, signal, ...)
	assert((mb >= 1 and mb <= 3), mb)
	assert:type(signal, "string")
	c.mb = mb
	c.signal = signal
	c.args = { ... }
end)
