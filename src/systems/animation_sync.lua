local AnimationSync = Concord.system({
	pool = { "anim_sync_with", "anim_sync_data" },
})

function AnimationSync:init(world)
	self.world = world

	self.pool.onAdded = function(pool, e)
		local anim_sync_with = e:get("anim_sync_with")
		local e_target = self.world:getEntityByKey(anim_sync_with.key)
		local anim_sync_data = e:get("anim_sync_data")
		local c_name = anim_sync_data.c_name
		local target_c = e_target:get(c_name)
		assert(target_c, "sync target must have component: " .. c_name)
		local c_props = anim_sync_data.c_props
		for _, prop in ipairs(c_props) do
			assert(target_c[prop] ~= nil, "target component must have property: " .. prop)
		end

		local animation = e_target:get("animation")
		if animation then
			local obj = animation.obj
			if obj and obj.clips then
				local data = anim_sync_data.data
				for k in pairs(data) do
					assert(obj.clips[k], "animation clips must have key: " .. k)
				end
			end
		end
	end
end

function AnimationSync:update(dt)
	for _, e in ipairs(self.pool) do
		local anim_sync_with = e:get("anim_sync_with")
		local e_target = self.world:getEntityByKey(anim_sync_with.key)
		local animation = e_target:get("animation")
		local obj = animation.obj
		local anim_sync_data = e:get("anim_sync_data")
		local data = anim_sync_data.data[obj.base_tag]
		if data then
			local c_props = anim_sync_data.c_props
			local frame = math.floor(obj.frame)
			for _, prop in ipairs(c_props) do
				local target_data = data[frame]
				if target_data then
					local target_c = e_target:get(anim_sync_data.c_name)
					target_c[prop] = target_data[prop]
				end
			end
		end
	end
end

return AnimationSync
