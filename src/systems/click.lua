local Click = Concord.system({
	pool = { "bounding_box", "clickable", "on_click" },
	pool_ui = { "bounding_box", "clickable", "on_click", "ui_element" },
})

function Click:init(world)
	self.world = world
end

function Click:mousepressed(mx, my, mb)
	for _, e in ipairs(self.pool) do
		if not e:has("hidden") and not e:has("ui_element") then
			local on_click = e:get("on_click")

			if mb == on_click.mb then
				local box = e:get("bounding_box")
				local bx, by = Helper.get_real_pos_box(e)
				local bw, bh = box.w, box.h
				local result = Helper.check_point_rect(mx, my, bx, by, bw, bh)

				if result then
					self.world:emit(on_click.signal, unpack(on_click.args))
				end
			end
		end
	end
end

function Click:mousepressed_ui(mx, my, mb)
	for _, e in ipairs(self.pool_ui) do
		if not e:has("hidden") then
			local on_click = e:get("on_click")

			if mb == on_click.mb then
				local box = e:get("bounding_box")
				local bx, by = box.screen_pos:unpack()
				local bw, bh = box.w, box.h
				local result = Helper.check_point_rect(mx, my, bx, by, bw, bh)

				if result then
					self.world:emit(on_click.signal, unpack(on_click.args))
				end
			end
		end
	end
end

return Click
