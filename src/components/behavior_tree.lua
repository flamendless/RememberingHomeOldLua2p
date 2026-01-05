Concord.component("behavior_tree", function(c, beehive, nodes)
	if not (type(beehive) == "function") then
		error('Assertion failed: type(beehive) == "function"')
	end
	if not (type(nodes) == "table") then
		error('Assertion failed: type(nodes) == "table"')
	end
	c.beehive = beehive
	c.nodes = nodes
	c.current_node = nil
	c.result = ""
end)
