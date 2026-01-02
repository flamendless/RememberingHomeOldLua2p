local Concord = require("modules.concord.concord")

local Log = require("modules.log.log")

local AnimationSync = Concord.system({
	pool = { "anim_sync_with", "anim_sync_data" },
})

function AnimationSync:init(world)
	self.world = world

	self.pool.onAdded = function(pool, e)
		local e_target = self.world:getEntityByKey(e.anim_sync_with.key)
		local c_name = e.anim_sync_data.c_name
		local target_c = e_target[c_name]
		if not target_c then
			error("sync target must have component: " .. c_name)
		end
		local c_props = e.anim_sync_data.c_props
		for _, prop in ipairs(c_props) do
			if not target_c[prop] then
				error("target component must have property: " .. prop)
			end
		end

		local md = e_target.multi_animation_data
		if md then
			md = md.data
			local data = e.anim_sync_data.data
			for k, v in pairs(data) do
				if not md[k] then
					error("multi_animation_data must have key: " .. k)
				end
				for _, t in ipairs(v) do
					for _, prop in ipairs(c_props) do
						if not t[prop] then
							error("subdata must have property: " .. prop)
						end
					end
				end
			end
		end
	end
end

function AnimationSync:update(dt)
	for _, e in ipairs(self.pool) do
		local e_target = self.world:getEntityByKey(e.anim_sync_with.key)
		local animation = e_target.animation
		local anim_sync_data = e.anim_sync_data
		local data = anim_sync_data.data[animation.base_tag]
		if data then
			local c_props = anim_sync_data.c_props
			local frame = e_target.current_frame.value
			for _, prop in ipairs(c_props) do
				local target_data = data[frame]
				if target_data then
					local target_c = e_target[anim_sync_data.c_name]
					target_c[prop] = target_data[prop]
				end
			end
		else
			Log.warn("there is no animation tag in sync data:", animation.base_tag)
		end
	end
end

return AnimationSync
