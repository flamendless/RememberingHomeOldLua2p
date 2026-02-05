Concord.component("clickable")

Concord.component("on_click", function(c, mb, signal, ...)
	if not (mb >= 1 and mb <= 3) then
		error("Assertion failed: mb >= 1 and mb <= 3")
	end
	if type(signal) ~= "string" then
		error('Assertion failed: type(signal) == "string"')
	end
	c.mb = mb
	c.signal = signal
	c.args = { ... }
end)
