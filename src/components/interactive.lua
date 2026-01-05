Concord.component("interactive")
Concord.component("locked")
Concord.component("is_door")

Concord.component("target_interactive", function(c, interactive_e)
	if not interactive_e.__isEntity then
		error("Assertion failed: interactive_e.__isEntity")
	end
	if not interactive_e.interactive then
		error("Assertion failed: interactive_e.interactive")
	end
	interactive_e:ensure("key")
	c.interactive_e = interactive_e
end)

Concord.component("within_interactive", function(c, entity)
	if not entity.__isEntity then
		error("Assertion failed: entity.__isEntity")
	end
	if not entity.id then
		error("Assertion failed: entity.id")
	end
	if not entity.interactive then
		error("Assertion failed: entity.interactive")
	end
	entity:ensure("key")
	c.entity = entity
end)

Concord.component("interactive_req_player_dir", function(c, x, y)
	if not (type(x) == "number") then
		error('Assertion failed: type(x) == "number"')
	end
	if not (type(y) == "number") then
		error('Assertion failed: type(y) == "number"')
	end
	c.x = x
	c.y = y
end)
