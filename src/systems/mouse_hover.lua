local MouseHover = Concord.system({
	pool_bb = { "bounding_box", "hoverable", "pos" },
	pool_bb_ui = { "bounding_box", "hoverable", "pos", "ui_element" },
	pool_bb_emit = { "bounding_box", "hoverable", "pos", "hover_emit" },
})

function MouseHover:init(world)
	self.world = world
end

function MouseHover:update(dt)
	for _, e in ipairs(self.pool_bb_emit) do
		local hoverable = e.hoverable

		if hoverable.prev_hovered and not hoverable.is_hovered then
			hoverable.prev_hovered = false

			local item = e.item

			if item then
				self.world:emit("mouse_unhovered_item", e)
			end
		end
	end
end

function MouseHover:check_mouse_hover(mx, my)
	for _, e in ipairs(self.pool_bb) do
		if not e.hidden and not e.ui_element then
			local hoverable = e.hoverable
			local bx, by = Helper.get_real_pos_box(e)
			local bw, bh = Helper.get_real_size(e)
			local result = Helper.check_point_rect(mx, my, bx, by, bw, bh)
			hoverable.is_hovered = result
		end
	end
end

function MouseHover:check_mouse_hover_ui(mx, my)
	for _, e in ipairs(self.pool_bb_ui) do
		if not e.hidden then
			local hoverable = e.hoverable
			local hover_emit = e.hover_emit
			local box = e.bounding_box
			local bx, by = box.screen_pos:unpack()
			local bw, bh = box.w, box.h
			local result = Helper.check_point_rect(mx, my, bx, by, bw, bh)

			hoverable.is_hovered = result

			if result and hover_emit then
				if not hoverable.prev_hovered then
					hoverable.prev_hovered = true

					local item = e.item

					if item then
						self.world:emit("mouse_hovered_item", e)
					end
				end
			end
		end
	end
end

return MouseHover
