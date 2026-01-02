local Concord = require("modules.concord.concord")

local Dialogues = require("dialogues")

Concord.component("text_can_proceed")
Concord.component("text_skipped")

Concord.component("has_choices", function(c, ...)
	c.value = { ... }

	if not (#c.value ~= 0) then
		error("Assertion failed: #c.value ~= 0")
	end
	for _, str in ipairs(c.value) do
		if not (type(str) == "string") then
			error('Assertion failed: type(str) == "string"')
		end
	end

	if not (#c.value ~= 0) then
		error("Assertion failed: #c.value ~= 0")
	end
end)

Concord.component("dialogue_item")
Concord.component("dialogue_meta", function(c, main, sub)
	if not (type(main) == "string") then
		error('Assertion failed: type(main) == "string"')
	end
	if not (type(sub) == "string") then
		error('Assertion failed: type(sub) == "string"')
	end
	if not (Dialogues.get(main, sub)) then
		error("Assertion failed: Dialogues.get(main, sub)")
	end
	c.main = main
	c.sub = sub
end)
