Concord.component("behavior_tree", function(c, beehive, nodes)
	assert:type(beehive, "function")
	assert:type(nodes, "table")
	c.beehive = beehive
	c.nodes = nodes
	c.current_node = nil
	c.result = ""
end)
