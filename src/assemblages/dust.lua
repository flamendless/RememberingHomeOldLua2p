local AsmDust = {}

function AsmDust.emitter(e, id, x, y, w, h, opts)
	assert(e.__isEntity, e)
	assert:type(id, "string")
	assert:type(x, "number")
	assert:type(y, "number")
	assert:type(w, "number")
	assert:type(h, "number")
	assert:type_or_nil(opts, "table")

	e:give("id", id)
		:give("dust", opts)
		:give("pos", x, y)
		:give("size", w, h)
end

return AsmDust
