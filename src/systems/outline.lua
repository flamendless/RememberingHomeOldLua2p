local Outline = Concord.system({
	pool_grouped = { "grouped" },
})

local HIGHLIGHT_CFG = {
	overlay_strength = 0.72,
	speed = 4.0,
	fade_in = 0.18,
	fade_out = 0.26,
}

function Outline:init(world)
	self.world = world
	self.highlighted = {}
	self.fading_out = false
	self.fade_seq = 0
end

function Outline:cancel_highlight_tweens()
	for e in pairs(self.highlighted) do
		if e:has("interactive_highlight") then
			Flux.remove_by_object(e:get("interactive_highlight"))
		end
	end
end

function Outline:fade_in_highlight(e)
	local highlight = e:get("interactive_highlight")
	if not highlight then
		return
	end
	Flux.remove_by_object(highlight)
	Flux.to(highlight, HIGHLIGHT_CFG.fade_in, { opacity = 1 })
end

function Outline:tag_highlight(e)
	if not e:has("interactive_highlight") then
		e:give("interactive_highlight", {
			overlay_strength = HIGHLIGHT_CFG.overlay_strength,
			opacity = 0,
			speed = HIGHLIGHT_CFG.speed,
		})
		self.highlighted[e] = true
	end

	if self.fading_out then
		self.fading_out = false
		self.fade_seq = self.fade_seq + 1
		self:fade_in_highlight(e)
		return
	end

	local highlight = e:get("interactive_highlight")
	if highlight.opacity > 0.99 then
		return
	end

	self:cancel_highlight_tweens()
	self.fade_seq = self.fade_seq + 1
	self:fade_in_highlight(e)
end

function Outline:untag_highlight(e)
	if not e:has("interactive_highlight") then
		return
	end
	local highlight = e:get("interactive_highlight")
	Flux.remove_by_object(highlight)
	e:remove("interactive_highlight")
	self.highlighted[e] = nil
end

function Outline:clear_highlights()
	for e in pairs(self.highlighted) do
		self:untag_highlight(e)
	end
end

function Outline:highlight_entity(e)
	if not (e.__isEntity and e.sprite) then
		return
	end
	self:tag_highlight(e)
end

function Outline:on_change_interactive(e, other)
	self:cancel_highlight_tweens()
	self.fade_seq = self.fade_seq + 1
	self.fading_out = false
	for highlighted_e in pairs(self.highlighted) do
		if highlighted_e ~= other then
			self:untag_highlight(highlighted_e)
		end
	end
	self:on_collide_interactive(e, other)
end

function Outline:on_collide_interactive(_, other)
	if other.grouped then
		for _, e in ipairs(self.pool_grouped) do
			if e.grouped.value == other.grouped.value then
				self:highlight_entity(e)
			end
		end
	else
		self:highlight_entity(other)
	end
end

function Outline:on_leave_interactive()
	self:remove_outlines()
end

function Outline:remove_outlines()
	if self.fading_out then
		return
	end

	self:cancel_highlight_tweens()

	local to_fade = {}
	for e in pairs(self.highlighted) do
		if e:has("interactive_highlight") then
			local highlight = e:get("interactive_highlight")
			if highlight.opacity > 0.001 then
				to_fade[#to_fade + 1] = e
			end
		end
	end

	if #to_fade == 0 then
		if next(self.highlighted) then
			self.fade_seq = self.fade_seq + 1
			self.fading_out = false
			self:clear_highlights()
		end
		return
	end

	self.fading_out = true
	self.fade_seq = self.fade_seq + 1
	local fade_seq = self.fade_seq

	local remaining = #to_fade

	local function on_fade_done(e)
		if self.fade_seq ~= fade_seq then
			return
		end
		self:untag_highlight(e)
		remaining = remaining - 1
		if remaining <= 0 then
			self.fading_out = false
		end
	end

	for _, e in ipairs(to_fade) do
		local highlight = e:get("interactive_highlight")
		Flux.to(highlight, HIGHLIGHT_CFG.fade_out, { opacity = 0 }):oncomplete(function()
			on_fade_done(e)
		end)
	end
end

function Outline:update(dt)
	for e in pairs(self.highlighted) do
		if e:has("interactive_highlight") then
			local highlight = e:get("interactive_highlight")
			highlight.time = highlight.time + dt * highlight.speed
		end
	end
end

function Outline:cleanup()
	self.fading_out = false
	self:clear_highlights()
end

return Outline
