local Entity = Concord.system({
	pool = {"id"}
})

function Entity:init(world)
	self.world = world
end

function Entity:hide_entity(e)
	assert(e.__isEntity)
	e:give("hidden")
end

function Entity:destroy_entity(e)
	assert(e.__isEntity)
	e:destroy()
end

--INFO: I realize it's bad naming. Apt would be "set_component_value"...
--      This is the reason why we have flip_component now...
function Entity:toggle_component(e, prop, bool)
	assert(e.__isEntity)
	assert(type(prop) == "string", prop)
	assert(type(bool) == "boolean", bool)
	if bool then
		e:give(prop)
	else
		e:remove(prop)
	end
end

function Entity:toggle_visibility(e_id)
	assert(type(e_id) == "string", e_id)
end

function Entity:flip_e_component(e, component)
	assert(e.__isEntity, e)
	assert(type(component) == "string")
	if e:has(component) then
		e:remove(component)
	else
		e:give(component)
	end
end

function Entity:flip_e_id_component(e_id, component)
	assert(type(e_id) == "string")
	assert(type(component) == "string")
	for _, e in ipairs(self.pool) do
		if e.id.value == e_id then
			self:flip_e_component(e, component)
			return
		end
	end
	if DEV then
		Log.error("Failed to flip component", component, "for id", e_id, "(non-existing)")
	end
end

return Entity
