local Session = {
	bags = {},
}

function Session.put(namespace, data)
	assert:type(namespace, "string")
	assert:type(data, "table")
	Session.bags[namespace] = data
end

function Session.peek(namespace)
	assert:type(namespace, "string")
	return Session.bags[namespace]
end

function Session.take(namespace)
	assert:type(namespace, "string")
	local data = Session.bags[namespace]
	Session.bags[namespace] = nil
	return data
end

function Session.clear(namespace)
	assert:type(namespace, "string")
	Session.bags[namespace] = nil
end

return Session
