Concord.component("enemy", function(c, enemy_type)
	assert:type(enemy_type, "string")
	c.enemy_type = enemy_type
end)
