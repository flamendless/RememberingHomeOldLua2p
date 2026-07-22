Concord.component("interactive")
Concord.component("locked")
Concord.component("is_door")

Concord.component("target_interactive", function(c, interactive_e)
	assert(interactive_e.__isEntity, interactive_e)
	assert(interactive_e.interactive, interactive_e)
	interactive_e:ensure("key")
	c.interactive_e = interactive_e
end)

Concord.component("within_interactive", function(c, entity)
	assert(entity.__isEntity, entity)
	assert(entity.id, entity)
	assert(entity.interactive, entity)
	entity:ensure("key")
	c.entity = entity
end)

Concord.component("interactive_req_player_dir", function(c, x, y)
	assert(type(x) == "number", x)
	assert(type(y) == "number", y)
	c.x = x
	c.y = y
end)
