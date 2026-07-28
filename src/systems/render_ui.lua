local RenderUI = Concord.system({
	pool_text = {
		constructor = Ctor.SortedTable,
		layer = "text",
		"ui_element",
	},
	pool_hold_key = {
		constructor = Ctor.SortedTable,
		layer = "hold_key",
		"ui_element",
	},
	pool_dialogue = {
		constructor = Ctor.SortedTable,
		layer = "dialogue",
		"ui_element",
	},
	pool_hud = {
		constructor = Ctor.SortedTable,
		layer = "hud",
		"ui_element",
	},
	pool_ui = { "ui_element", "pos", "!layer" },
})

function RenderUI:init(world)
	self.world = world
	self.layers = {
		self.pool_text,
		self.pool_hold_key,
		self.pool_dialogue,
		self.pool_hud,
	}
end

function RenderUI:draw_ui_default()
	for _, e in ipairs(self.pool_ui) do
		local culled = false
		if e:has("cullable") then
			culled = e:get("cullable").value
		end
		if not e:has("hidden") and not culled then
			local has_text = e:has("text")
			local has_stext = e:has("static_text")
			local has_sprite = e:has("sprite")

			if (has_text or has_stext) and not e:has("nf_renderer") then
				self.world:emit("draw_text_ex", e)
			end

			if has_sprite and not e:has("nf_renderer") then
				self.world:emit("draw_sprite_ex", e)
			end
		end
	end
end

function RenderUI:draw_ui_layers()
	for _, pool in ipairs(self.layers) do
		for _, e in ipairs(pool) do
			local culled = false
			if e:has("cullable") then
				culled = e:get("cullable").value
			end
			if not e:has("hidden") and not culled then
				local has_text = e:has("text")
				local has_stext = e:has("static_text")
				local has_sprite = e:has("sprite")

				if (has_text or has_stext) and not e:has("nf_renderer") then
					self.world:emit("draw_text_ex", e)
				end

				if has_sprite and not e:has("nf_renderer") then
					self.world:emit("draw_sprite_ex", e)
				end
			end
		end
	end
end

function RenderUI:draw_ui()
	self:draw_ui_default()
	self:draw_ui_layers()
end

function RenderUI:cleanup()
	for _, pool in ipairs(self.layers) do
		pool:clear()
	end
end

return RenderUI
