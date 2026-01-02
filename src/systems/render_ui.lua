local Concord = require("modules.concord.concord")
local SortedTable = require("ctor.sorted_table")

local RenderUI = Concord.system({
	pool_text = {
		constructor = SortedTable,
		layer = "text",
		"ui_element",
	},
	pool_hold_key = {
		constructor = SortedTable,
		layer = "hold_key",
		"ui_element",
	},
	pool_dialogue = {
		constructor = SortedTable,
		layer = "dialogue",
		"ui_element",
	},
	pool_hud = {
		constructor = SortedTable,
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
		local hidden = e.hidden
		local culled = e.cullable and e.cullable.value
		if (not hidden) and not culled then
			local text = e.text
			local stext = e.static_text
			local sprite = e.sprite

			if (text or stext) and not e.nf_renderer then
				self.world:emit("draw_text_ex", e)
			end

			if sprite and not e.nf_renderer then
				self.world:emit("draw_sprite_ex", e)
			end
		end
	end
end

function RenderUI:draw_ui_layers()
	for _, pool in ipairs(self.layers) do
		for _, e in ipairs(pool) do
			local hidden = e.hidden
			local culled = e.cullable and e.cullable.value
			if (not hidden) and not culled then
				local text = e.text
				local stext = e.static_text
				local sprite = e.sprite

				if (text or stext) and not e.nf_renderer then
					self.world:emit("draw_text_ex", e)
				end

				if sprite and not e.nf_renderer then
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
