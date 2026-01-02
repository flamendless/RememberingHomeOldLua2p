local Cache = require("cache")
local Enums = require("enums")
local Palette = require("palette")

local Inventory = {}

local CACHE_ID = "calculated"

function Inventory.bg(e, x, y, scale)
	e:give("id", "inventory_bg")
		:give("pos", x, y)
		:give("sprite", "bg_inventory")
		:give("transform", 0, scale, scale, 0.5, 0.5)
		:give("color", { 1, 1, 1, 1 })
		:give("ui_element")
end

function Inventory.choice(e, str, x, y)
	e:give("id", "inventory_choice_" .. string.lower(str))
		:give("font", "inventory_choice")
		:give("static_text", str)
		:give("pos", x, y)
		:give("alpha_range", 0.25, 0.5)
		:give("color", { 0, 0, 0, 0.25 })
		:give("list_item")
		:give("list_group", "inventory_choices")
		:give("transform", 0.1745329, 1, 1, 0.5, 0.5, -0.25)
		:give("ui_element")
end

function Inventory.border(e, i, x, y, rw, rh, ih, is_horizontal)
	local id = "inventory_border" .. i
	local cached = Cache.get(CACHE_ID, id)
	local r, sy
	if not cached then
		if is_horizontal then
			r = 4.7123889803847
			sy = rw / ih
		else
			r = 0
			sy = rh / ih
		end
		Cache.store(CACHE_ID, id, { r, sy })
	else
		r, sy = unpack(cached)
	end
	e:give("id", id)
		:give("sprite", "inventory_border")
		:give("pos", x, y)
		:give("transform", r, 0.5, sy, 0.5, 0, -0.05, -0.05)
		:give("textured_line")
		:give("ui_element")
		:give("color", { 1, 1, 1, 1 })
end

function Inventory.dline(e, i, x1, y1, x2, y2)
	local id = "inventory_dline" .. i
	local cached = Cache.get(CACHE_ID, id)
	local r = cached
	if not cached then
		local dx, dy = x2 - x1, y2 - y1
		r = math.atan2(dy, dx) - 1.5707963267949
		Cache.store(CACHE_ID, id, r)
	end
	e:give("id", id)
		:give("sprite", "inventory_border")
		:give("pos", x1, y1)
		:give("transform", r, 0.25, 1, 0.5, 0, 0.05, 0.05)
		:give("textured_line")
		:give("ui_element")
		:give("color", { 1, 1, 1, 1 })
end

function Inventory.cell(e, i, x, y, w, h)
	e:give("id", "cell_" .. i)
		:give("list_item")
		:give("list_group", "inventory_cells")
		:give("pos", x, y)
		:give("rect", w, h)
		:give("draw_mode", Enums.draw_mode.fill)
		:give("color", Palette.get("inventory_cell", 0.4))
		:give("alpha_range", 0, 0.4)
		:give("ui_element")
end

return Inventory
