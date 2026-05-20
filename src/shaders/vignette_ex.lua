local VignetteEx = class({
	name = Enums.shaders.vignette_ex
})

function VignetteEx:new(...)
	self.is_active = false

	self.time = 0
	self.intensity = 0
	self.pulse_strength = 0
	self.darkness = 0
	self.panic = 0

	self.tex_splat = Resources.data.images.vignette_part
	self.tex_splat:setFilter("nearest", "nearest")

	self.shader = love.graphics.newShader(Shaders.paths.vignette_ex)
	self.shader:send("vignette_tex", self.tex_splat)
end

function VignetteEx:survival_on(values)
	assert(type(values) == "table")
	self.intensity = math.max(0, math.min(1, values.intensity or self.intensity))
	self.panic = math.max(0, math.min(1, values.panic or self.panic))
	self.darkness = values.darkness or self.darkness
	self.pulse_strength = values.pulse_strength or self.pulse_strength
end

function VignetteEx:update(dt)
	if not self.is_active then return end
	self.time = self.time + dt
	self.shader:send("time", self.time)
	self.shader:send("intensity", self.intensity)
	self.shader:send("pulse_strength", self.pulse_strength)
	self.shader:send("darkness", self.darkness)
	self.shader:send("panic", self.panic)
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
		UIWrapper.edit_number("time", self.time, false)

		local _
		Slab.Text("Intensity")
		Slab.SameLine()
		self.intensity, _ = UIWrapper.edit_number("intensity", self.intensity, false)

		Slab.Text("Pulse Strength")
		Slab.SameLine()
		self.pulse_strength, _ = UIWrapper.edit_number("pulse_strength", self.pulse_strength, false)

		Slab.Text("Panic")
		Slab.SameLine()
		self.panic, _ = UIWrapper.edit_number("panic", self.panic, false)

		Slab.Text("Darkness")
		Slab.SameLine()
		self.panic, _ = UIWrapper.edit_number("darkness", self.darkness, false)

		Slab.EndWindow()
	end
end

return VignetteEx
