local RoomMap = {
	NODE_W = 140,
	NODE_H = 56,
	GAP_X = 320,
	GAP_Y = 150,
}

local function rect_center(rect)
	return rect.x + rect.w / 2, rect.y + rect.h / 2
end

local function rect_edge(rect, tx, ty)
	local cx, cy = rect_center(rect)
	local dx = tx - cx
	local dy = ty - cy
	if dx == 0 and dy == 0 then
		return cx, cy
	end
	local hw = rect.w / 2
	local hh = rect.h / 2
	local scale
	if math.abs(dx) * hh > math.abs(dy) * hw then
		scale = hw / math.abs(dx)
	else
		scale = hh / math.abs(dy)
	end
	return cx + dx * scale, cy + dy * scale
end

local function draw_dashed_line(x1, y1, x2, y2, dash_len, gap_len)
	local dx = x2 - x1
	local dy = y2 - y1
	local len = math.sqrt(dx * dx + dy * dy)
	if len < 0.001 then
		return
	end
	local ux, uy = dx / len, dy / len
	local pos = 0
	local drawing = true
	while pos < len do
		local seg = drawing and dash_len or gap_len
		local next_pos = math.min(pos + seg, len)
		if drawing then
			love.graphics.line(
				x1 + ux * pos, y1 + uy * pos,
				x1 + ux * next_pos, y1 + uy * next_pos
			)
		end
		pos = next_pos
		drawing = not drawing
	end
end

local function draw_arrowhead_dir(ax, ay, dir_x, dir_y, size)
	local len = math.sqrt(dir_x * dir_x + dir_y * dir_y)
	if len < 0.001 then
		return
	end
	dir_x, dir_y = dir_x / len, dir_y / len
	local angle = math.atan(dir_y, dir_x)
	local tip_x = ax + dir_x * size
	local tip_y = ay + dir_y * size
	local back = size * 0.55
	local a1 = angle + math.pi * 0.85
	local a2 = angle - math.pi * 0.85
	love.graphics.polygon("fill",
		tip_x, tip_y,
		ax + math.cos(a1) * back, ay + math.sin(a1) * back,
		ax + math.cos(a2) * back, ay + math.sin(a2) * back
	)
end

local function draw_edge_line(x1, y1, x2, y2, dashed)
	if dashed then
		draw_dashed_line(x1, y1, x2, y2, 8, 6)
	else
		love.graphics.line(x1, y1, x2, y2)
	end
end

local function edge_segment(x1, y1, x2, y2, head_pad)
	local dx = x2 - x1
	local dy = y2 - y1
	local len = math.sqrt(dx * dx + dy * dy)
	if len < 0.001 then
		return nil
	end
	local ux, uy = dx / len, dy / len
	local inset = math.min(head_pad, len * 0.35)
	return {
		x1 = x1 + ux * inset,
		y1 = y1 + uy * inset,
		x2 = x2 - ux * inset,
		y2 = y2 - uy * inset,
		angle_to = math.atan(uy, ux),
	}
end

local function draw_edge_head(seg, size)
	draw_arrowhead_dir(seg.x2, seg.y2, seg.x2 - seg.x1, seg.y2 - seg.y1, size)
end

local function draw_double_edge_heads(seg, size)
	local dx = seg.x2 - seg.x1
	local dy = seg.y2 - seg.y1
	draw_arrowhead_dir(seg.x2, seg.y2, dx, dy, size)
	draw_arrowhead_dir(seg.x1, seg.y1, -dx, -dy, size)
end

local function pair_segment(layout, a, b, head_pad)
	local ra, rb = layout[a], layout[b]
	if not ra or not rb then
		return nil
	end
	local cax, cay = rect_center(ra)
	local cbx, cby = rect_center(rb)
	local first_rect, second_rect = ra, rb
	if cax > cbx or (cax == cbx and cay > cby) then
		first_rect, second_rect = rb, ra
	end
	local fcx, fcy = rect_center(first_rect)
	local scx, scy = rect_center(second_rect)
	local x1, y1 = rect_edge(first_rect, scx, scy)
	local x2, y2 = rect_edge(second_rect, fcx, fcy)
	return edge_segment(x1, y1, x2, y2, head_pad)
end

local function pair_key(a, b)
	if tostring(a) > tostring(b) then
		a, b = b, a
	end
	return tostring(a) .. "\0" .. tostring(b)
end

local function directed_key(from, to)
	return tostring(from) .. "->" .. tostring(to)
end

local function prepare_edge_labels(edges)
	local pair_count = {}
	local pair_totals = {}
	local from_count = {}
	local meta = {}
	local from_totals = {}
	local reverse_lookup = {}

	for _, edge in ipairs(edges) do
		local key = pair_key(edge.from, edge.to)
		pair_totals[key] = (pair_totals[key] or 0) + 1
		from_totals[tostring(edge.from)] = (from_totals[tostring(edge.from)] or 0) + 1
		reverse_lookup[directed_key(edge.from, edge.to)] = true
	end

	for i, edge in ipairs(edges) do
		local key = pair_key(edge.from, edge.to)
		local pair_idx = (pair_count[key] or 0) + 1
		pair_count[key] = pair_idx

		local from_key = tostring(edge.from)
		local from_idx = (from_count[from_key] or 0) + 1
		from_count[from_key] = from_idx

		local bidirectional = pair_totals[key] == 2
			and reverse_lookup[directed_key(edge.to, edge.from)] == true

		meta[i] = {
			pair_idx = pair_idx,
			from_idx = from_idx,
			from_total = from_totals[from_key],
			bidirectional = bidirectional,
		}
	end

	return meta
end

local function edge_label_pos(x1, y1, x2, y2, label_meta, draw_zoom)
	local dx = x2 - x1
	local dy = y2 - y1
	local len = math.sqrt(dx * dx + dy * dy)
	if len < 0.001 then
		return nil
	end

	local ux, uy = dx / len, dy / len
	local nx, ny = -uy, ux
	if ny > 0 then
		nx, ny = -nx, -ny
	end

	local pair_idx = label_meta.pair_idx
	local t = 0.5
	local side = 1

	if label_meta.bidirectional then
		t = (pair_idx == 1) and 0.35 or 0.65
		side = (pair_idx == 1) and 1 or -1
	elseif pair_idx > 1 then
		if pair_idx == 2 then
			t = 0.64
		else
			t = 0.5 + (pair_idx - 2) * 0.1
		end
		if pair_idx % 2 == 0 then
			side = -1
		end
	end

	local label_offset = 18 / draw_zoom
	local from_spread = 0
	if label_meta.from_total > 1 then
		from_spread = (label_meta.from_idx - (label_meta.from_total + 1) / 2)
			* (14 / draw_zoom)
	end

	local mx = x1 + ux * (len * t) + nx * (label_offset * side + from_spread)
	local my = y1 + uy * (len * t) + ny * (label_offset * side + from_spread)
	return mx, my
end

local function edge_endpoints(layout, edge)
	local from_rect = layout[edge.from]
	local to_rect = layout[edge.to]
	if not from_rect or not to_rect then
		return nil
	end
	local tcx, tcy = rect_center(to_rect)
	local x1, y1 = rect_edge(from_rect, tcx, tcy)
	local fcx, fcy = rect_center(from_rect)
	local x2, y2 = rect_edge(to_rect, fcx, fcy)
	return x1, y1, x2, y2
end

local function edge_line(layout, edge)
	return edge_endpoints(layout, edge)
end

function RoomMap.build(nodes, opts)
	opts = opts or {}
	local node_w = opts.node_w or RoomMap.NODE_W
	local node_h = opts.node_h or RoomMap.NODE_H
	local gap_x = opts.gap_x or RoomMap.GAP_X
	local gap_y = opts.gap_y or RoomMap.GAP_Y
	local root = opts.root

	local edges = {}
	local ids = {}
	local id_set = {}

	local function add_id(id)
		if not id_set[id] then
			id_set[id] = true
			table.insert(ids, id)
		end
	end

	for from, node in pairs(nodes) do
		add_id(from)
		for door_id, edge in pairs(node.doors or {}) do
			add_id(edge.to)
			table.insert(edges, {
				from = from,
				to = edge.to,
				kind = "door",
				label = door_id,
			})
		end
		for entry_id in pairs(node.entries or {}) do
			add_id(entry_id)
			table.insert(edges, {
				from = entry_id,
				to = from,
				kind = "entry",
				label = tostring(entry_id),
			})
		end
	end

	if not root or not id_set[root] then
		table.sort(ids)
		root = ids[1]
	end

	local layer = {}
	local queue = { root }
	layer[root] = 0
	local qi = 1
	while qi <= #queue do
		local cur = queue[qi]
		qi = qi + 1
		local cur_layer = layer[cur]
		for _, edge in ipairs(edges) do
			if edge.from == cur and layer[edge.to] == nil then
				layer[edge.to] = cur_layer + 1
				table.insert(queue, edge.to)
			end
		end
	end

	local max_layer = 0
	for _, l in pairs(layer) do
		if l > max_layer then
			max_layer = l
		end
	end

	-- Place entry sources (e.g. Menu) beside their target room.
	for _, edge in ipairs(edges) do
		if edge.kind == "entry" and layer[edge.to] ~= nil then
			layer[edge.from] = layer[edge.to] - 1
		end
	end

	-- Place virtual door targets beside the room they connect from.
	for _, edge in ipairs(edges) do
		if edge.kind == "door" and nodes[edge.from] and not nodes[edge.to] then
			if layer[edge.from] ~= nil then
				layer[edge.to] = layer[edge.from] + 1
			end
		end
	end

	for _, id in ipairs(ids) do
		if layer[id] == nil then
			max_layer = max_layer + 1
			layer[id] = max_layer
		end
	end

	local min_layer = 0
	for _, l in pairs(layer) do
		if l < min_layer then
			min_layer = l
		end
		if l > max_layer then
			max_layer = l
		end
	end

	local dark_room = opts.dark_room_id
	local living_room = opts.living_room_id
	if dark_room and living_room and layer[dark_room] and layer[living_room] then
		layer[dark_room] = layer[living_room]
	end

	local layers = {}
	for _, id in ipairs(ids) do
		local l = layer[id]
		layers[l] = layers[l] or {}
		table.insert(layers[l], id)
	end
	for _, group in pairs(layers) do
		table.sort(group)
	end

	local layout = {}
	local min_x, min_y = math.huge, math.huge
	local max_x, max_y = -math.huge, -math.huge

	for l = min_layer, max_layer do
		local group = layers[l]
		if group then
			local count = #group
			for i, id in ipairs(group) do
				local x = (l - min_layer) * gap_x
				local y = (i - (count + 1) / 2) * gap_y
				if dark_room and id == dark_room then
					y = y + gap_y * 0.5
				end
				layout[id] = {
					x = x,
					y = y,
					w = node_w,
					h = node_h,
				}
				min_x = math.min(min_x, x)
				min_y = math.min(min_y, y)
				max_x = math.max(max_x, x + node_w)
				max_y = math.max(max_y, y + node_h)
			end
		end
	end

	-- Align entry sources and virtual targets on the same row as their partner.
	for _, edge in ipairs(edges) do
		if edge.kind == "entry" and layout[edge.from] and layout[edge.to] then
			layout[edge.from].y = layout[edge.to].y
		elseif edge.kind == "door" and not nodes[edge.to]
			and layout[edge.from] and layout[edge.to] then
			layout[edge.to].y = layout[edge.from].y
		end
	end

	local cx = (min_x + max_x) / 2
	local cy = (min_y + max_y) / 2
	for _, rect in pairs(layout) do
		rect.x = rect.x - cx
		rect.y = rect.y - cy
	end

	local virtual = {}
	for id in pairs(layout) do
		virtual[id] = nodes[id] == nil
	end

	return {
		layout = layout,
		edges = edges,
		virtual = virtual,
		edge_label_meta = prepare_edge_labels(edges),
	}
end

function RoomMap.build_from_rooms(rooms)
	return RoomMap.build(rooms.nodes, {
		root = Enums.game_state.Outside,
		dark_room_id = Enums.game_state.TotallyDarkRoom,
		living_room_id = Enums.game_state.LivingRoom,
	})
end

function RoomMap.get_bounds(graph, font, padding)
	padding = padding or 0
	local layout = graph.layout
	local edges = graph.edges
	local edge_label_meta = graph.edge_label_meta
	local min_x, min_y = math.huge, math.huge
	local max_x, max_y = -math.huge, -math.huge

	local function include(x, y)
		min_x = math.min(min_x, x)
		min_y = math.min(min_y, y)
		max_x = math.max(max_x, x)
		max_y = math.max(max_y, y)
	end

	for _, rect in pairs(layout) do
		include(rect.x, rect.y)
		include(rect.x + rect.w, rect.y + rect.h)
	end

	for i, edge in ipairs(edges) do
		local x1, y1, x2, y2 = edge_line(layout, edge)
		if x1 then
			include(x1, y1)
			include(x2, y2)

			local mx, my = edge_label_pos(x1, y1, x2, y2, edge_label_meta[i], 1)
			if mx then
				local label_w = font:getWidth(edge.label)
				local label_h = font:getHeight()
				include(mx - label_w / 2 - 2, my - label_h / 2 - 1)
				include(mx + label_w / 2 + 2, my + label_h / 2 + 1)
			end
		end
	end

	return min_x - padding, min_y - padding, max_x + padding, max_y + padding
end

function RoomMap.draw(graph, opts)
	opts = opts or {}
	local layout = graph.layout
	local edges = graph.edges
	local virtual = graph.virtual
	local edge_label_meta = graph.edge_label_meta
	local current_id = opts.current_id
	local draw_zoom = opts.zoom or 1
	local map_font = opts.font or love.graphics.getFont()
	local head_size = 10 / draw_zoom
	local head_pad = head_size + 4
	local drawn_bidirectional = {}

	for i, edge in ipairs(edges) do
		local meta = edge_label_meta[i]
		local x1, y1, x2, y2 = edge_line(layout, edge)
		local seg = x1 and edge_segment(x1, y1, x2, y2, head_pad)
		if seg then
			if edge.kind == "entry" then
				love.graphics.setColor(0.4, 0.9, 1, 0.9)
			else
				love.graphics.setColor(0.85, 0.85, 0.85, 0.9)
			end
			love.graphics.setLineWidth(2 / draw_zoom)

			if meta.bidirectional then
				local key = pair_key(edge.from, edge.to)
				if not drawn_bidirectional[key] then
					drawn_bidirectional[key] = true
					local pair_seg = pair_segment(layout, edge.from, edge.to, head_pad)
					if pair_seg then
						draw_edge_line(pair_seg.x1, pair_seg.y1, pair_seg.x2, pair_seg.y2, edge.kind == "entry")
					end
				end
			else
				draw_edge_line(seg.x1, seg.y1, seg.x2, seg.y2, edge.kind == "entry")
			end
		end
	end

	for id, rect in pairs(layout) do
		local is_current = id == current_id
		local is_virtual = virtual[id]

		if is_current then
			love.graphics.setColor(0.2, 0.75, 0.35, 0.95)
		elseif is_virtual then
			love.graphics.setColor(0.35, 0.2, 0.2, 0.9)
		else
			love.graphics.setColor(0.15, 0.15, 0.2, 0.95)
		end
		love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h, 4, 4)

		if is_current then
			love.graphics.setColor(0.5, 1, 0.6, 1)
			love.graphics.setLineWidth(3 / draw_zoom)
		elseif is_virtual then
			love.graphics.setColor(1, 0.45, 0.35, 1)
			love.graphics.setLineWidth(2 / draw_zoom)
		else
			love.graphics.setColor(1, 1, 1, 0.9)
			love.graphics.setLineWidth(2 / draw_zoom)
		end
		love.graphics.rectangle("line", rect.x, rect.y, rect.w, rect.h, 4, 4)

		local label = tostring(id)
		local label_w = map_font:getWidth(label)
		local label_h = map_font:getHeight()
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.print(
			label,
			rect.x + (rect.w - label_w) / 2,
			rect.y + (rect.h - label_h) / 2
		)
	end

	drawn_bidirectional = {}
	for i, edge in ipairs(edges) do
		local meta = edge_label_meta[i]
		if edge.kind == "entry" then
			love.graphics.setColor(0.4, 0.9, 1, 0.9)
		else
			love.graphics.setColor(0.85, 0.85, 0.85, 0.9)
		end

		if meta.bidirectional then
			local key = pair_key(edge.from, edge.to)
			if not drawn_bidirectional[key] then
				drawn_bidirectional[key] = true
				local seg = pair_segment(layout, edge.from, edge.to, head_pad)
				if seg then
					draw_double_edge_heads(seg, head_size)
				end
			end
		else
			local x1, y1, x2, y2 = edge_line(layout, edge)
			local seg = x1 and edge_segment(x1, y1, x2, y2, head_pad)
			if seg then
				draw_edge_head(seg, head_size)
			end
		end
	end

	for i, edge in ipairs(edges) do
		local x1, y1, x2, y2 = edge_line(layout, edge)
		if x1 then
			local mx, my = edge_label_pos(x1, y1, x2, y2, edge_label_meta[i], draw_zoom)
			if mx then
				local label_w = map_font:getWidth(edge.label)
				local label_h = map_font:getHeight()
				love.graphics.setColor(0, 0, 0, 0.6)
				love.graphics.rectangle(
					"fill",
					mx - label_w / 2 - 2,
					my - label_h / 2 - 1,
					label_w + 4,
					label_h + 2
				)
				love.graphics.setColor(1, 1, 1, 0.85)
				love.graphics.print(edge.label, mx - label_w / 2, my - label_h / 2)
			end
		end
	end
end

function RoomMap.export_png(graph, filepath, opts)
	opts = opts or {}
	local font = opts.font or love.graphics.getFont()
	local padding = opts.padding or 48
	local min_x, min_y, max_x, max_y = RoomMap.get_bounds(graph, font, padding)
	local w = math.ceil(max_x - min_x)
	local h = math.ceil(max_y - min_y)
	if w < 1 or h < 1 then
		return nil, "nothing to export"
	end

	local bg = opts.background or { 0.08, 0.08, 0.12, 1 }
	local canvas = love.graphics.newCanvas(w, h)
	local prev_canvas = love.graphics.getCanvas()
	local prev_font = love.graphics.getFont()
	local prev_r, prev_g, prev_b, prev_a = love.graphics.getColor()
	local prev_line_width = love.graphics.getLineWidth()

	love.graphics.setCanvas(canvas)
	love.graphics.push()
	love.graphics.origin()
	love.graphics.clear(bg[1], bg[2], bg[3], bg[4] or 1)
	love.graphics.translate(-min_x, -min_y)
	love.graphics.setFont(font)
	RoomMap.draw(graph, {
		current_id = opts.current_id,
		zoom = 1,
		font = font,
	})
	love.graphics.pop()
	love.graphics.setCanvas(prev_canvas)

	local image_data = canvas:newImageData()
	local png = image_data:encode("png")

	if not filepath then
		local timestamp = os.date("%Y%m%d_%H%M%S")
		local filename = "room_map_" .. timestamp .. ".png"
		local project_dir = opts.output_dir or love.filesystem.getSourceBaseDirectory()
		local dir = project_dir .. "/dev"
		os.execute('mkdir -p "' .. dir .. '"')
		filepath = dir .. "/" .. filename
	end

	local file, err = io.open(filepath, "wb")
	if not file then
		love.graphics.setFont(prev_font)
		love.graphics.setColor(prev_r, prev_g, prev_b, prev_a)
		love.graphics.setLineWidth(prev_line_width)
		return nil, err
	end
	file:write(png:getString())
	file:close()

	love.graphics.setFont(prev_font)
	love.graphics.setColor(prev_r, prev_g, prev_b, prev_a)
	love.graphics.setLineWidth(prev_line_width)

	return filepath
end

return RoomMap
