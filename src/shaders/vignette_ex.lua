local VignetteEx = class({
	name = Enums.shaders.vignette_ex
})

function VignetteEx:new(...)
	self.is_active = false

	--TODO: from vorn - Each texture should have a different,
	--                  uh, oscillation, possibly still in phase but different move and loiter timing
	self.effects = tablex.copy(Data.Vignette.values.zero)
	self.effects.time = 0

	--TODO: find a better texture?
	self.tex_splat = Resources.data.images.vignette_part
	self.tex_splat:setFilter("nearest", "nearest")
	self.tex_splat:setWrap("clampzero", "clampzero")

	self.shader = love.graphics.newShader(Shaders.paths.vignette_ex)
	self.shader:send("tex_vignette", self.tex_splat)
	self.shader:send("layers", self.effects.layers)
	self.shader:send("rot_speed", self.effects.rot_speed)
end

function VignetteEx:update_effects(values)
	assert(type(values) == "table")
	for k, v in pairs(values) do
		if self.effects[k] == nil then
			error("attempt to set non-existing field " .. k)
		end
		self.effects[k] = v
	end
end

function VignetteEx:update(dt)
	if not self.is_active then return end
	self.effects.time = self.effects.time + dt
	for k, v in pairs(self.effects) do
		self.shader:send(k, v)
	end
end

if DEV then
	function VignetteEx:debug_update(dt)
		if not self.debug_show then return end
		if not self.is_active then return end

		self.debug_show = Slab.BeginWindow("vignette", {
			Title = self:type(),
			IsOpen = self.debug_show,
		})

		Slab.Text("Time")
		Slab.SameLine()
		UIWrapper.edit_number("time", self.effects.time, false)

		local _
		self.effects.intensity, _ = UIWrapper.edit_range("intensity", self.effects.intensity, 0, 1, false)
		self.effects.pulse_strength, _ = UIWrapper.edit_range("pulse_strength", self.effects.pulse_strength, 0, 1, false)
		self.effects.darkness, _ = UIWrapper.edit_range("darkness", self.effects.darkness, 0, 3, false)
		self.effects.panic, _ = UIWrapper.edit_range("panic", self.effects.panic, 0, 1, false)
		self.effects.scale, _ = UIWrapper.edit_range("scale", self.effects.scale, 0.1, 5.0, false)
		self.effects.layers, _ = UIWrapper.edit_range("layers", self.effects.layers, 1, 10, true)
		self.effects.rot_speed, _ = UIWrapper.edit_range("rot_speed", self.effects.rot_speed, 0.1, 3, false)
		self.effects.noise_intensity, _ = UIWrapper.edit_range("noise_intensity", self.effects.noise_intensity, 0.0, 2.0,
			false)

		if Slab.Button("Print") then
			print("intensity", self.effects.intensity)
			print("pulse_strength", self.effects.pulse_strength)
			print("darkness", self.effects.darkness)
			print("panic", self.effects.panic)
			print("scale", self.effects.scale)
			print("layers", self.effects.layers)
			print("rot_speed", self.effects.rot_speed)
			print("noise_intensity", self.effects.noise_intensity)
		end

		Slab.EndWindow()
	end
end

return VignetteEx
