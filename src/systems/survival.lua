local Survival = Concord.system()

-- INFO: zoom in, vignette, silence, pulse/breathing
function Survival:init(world)
	self.world = world

	self.state = false
end

function Survival:survival_on()
	self.state = true

	local e_player = self.world:getResource("e_player")
	assert(e_player)

	local camera = self.world:getResource("camera")
	assert(camera)

	local DUR = 1
	local SCALE = 2

	local cfo = e_player.camera_follow_offset
	if cfo then
		local coll = e_player.collider
		cfo.x = coll.w/2
		cfo.y = coll.h/4
	end

	local prev_scale = camera.scale
	self.world:emit("tween_camera_scale", camera, DUR, prev_scale * SCALE, Enums.ease.cubicout)
end

function Survival:state_update(dt)
	if not self.state then return end
end

function Survival:state_draw()
end

if DEV then
	function Survival:debug_update(dt)
		if not self.debug_show then
			return
		end

		self.debug_show = Slab.BeginWindow("survival", {
			Title = "Survival",
			IsOpen = self.debug_show,
		})
		if Slab.CheckBox(self.state, "state") then
			self.state = not self.state
			if self.state then
				self:survival_on()
			end
		end
		Slab.EndWindow()
	end
end

return Survival
