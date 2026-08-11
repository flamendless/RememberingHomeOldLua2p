local BgAssetProcessor = {
	initialized = false,
	index = 1,
	dirty = true,
	preview_runtime_pp = false,
	show_original = false,
	save_message = nil,
	save_message_until = 0,
}

local image_cache = {}
local buffer_a = nil
local buffer_b = nil
local buffer_w = 0
local buffer_h = 0

local function ensure_buffers(w, h)
	if buffer_a and buffer_w == w and buffer_h == h then
		return
	end
	buffer_a = love.graphics.newCanvas(w, h)
	buffer_b = love.graphics.newCanvas(w, h)
	buffer_a:setFilter("nearest", "nearest")
	buffer_b:setFilter("nearest", "nearest")
	buffer_w = w
	buffer_h = h
	BgAssetProcessor.dirty = true
end

local function draw_canvas_to_canvas(src, shader)
	love.graphics.setCanvas(buffer_b)
	love.graphics.clear()
	if shader then
		love.graphics.setShader(shader)
	end
	love.graphics.draw(src, 0, 0)
	love.graphics.setShader()
	love.graphics.setCanvas()
	buffer_a, buffer_b = buffer_b, buffer_a
	return buffer_a
end

function BgAssetProcessor.init()
	if BgAssetProcessor.initialized then
		return
	end
	BgAssetProcessor.assets = Data.BgAssets.list
	BgAssetProcessor.cell_grid = Shaders.cell_grid()
	BgAssetProcessor.preview_effects = nil
	BgAssetProcessor.initialized = true
	BgAssetProcessor.dirty = true
end

function BgAssetProcessor.ensure_preview_effects()
	if BgAssetProcessor.preview_effects then
		return true
	end
	local image_data = rawget(Resources.data, "image_data")
	if not image_data or not rawget(image_data, "lut_dusk_16") then
		return false
	end
	BgAssetProcessor.preview_effects = {
		Shaders.ngrading("lut_dusk"),
		Shaders.film_grain(),
	}
	for _, effect in ipairs(BgAssetProcessor.preview_effects) do
		effect.is_active = true
	end
	BgAssetProcessor.preview_effects[2].random_offset = { 0.5, 0.5 }
	return true
end

function BgAssetProcessor.get_current_asset()
	return BgAssetProcessor.assets[BgAssetProcessor.index]
end

function BgAssetProcessor.get_image_for_asset(asset)
	if image_cache[asset.key] then
		return image_cache[asset.key]
	end

	local images = rawget(Resources.data, "images")
	local cached = images and rawget(images, asset.key)
	if cached then
		image_cache[asset.key] = cached
		return image_cache[asset.key]
	end

	local img = love.graphics.newImage(asset.rel_path)
	image_cache[asset.key] = img
	return img
end

function BgAssetProcessor.apply_light_defaults_for(asset)
	if not asset or not asset.light_defaults then
		return
	end
	local defaults = asset.light_defaults
	local params = BgAssetProcessor.cell_grid:get_params()
	if defaults.light_enabled ~= nil then
		params.light_enabled = defaults.light_enabled
	end
	if defaults.light_pos then
		params.light_pos = tablex.copy(defaults.light_pos)
	end
	if defaults.light_radius then
		params.light_radius = defaults.light_radius
	end
	if defaults.light_falloff then
		params.light_falloff = defaults.light_falloff
	end
	BgAssetProcessor.cell_grid:set_params(params)
	BgAssetProcessor.dirty = true
end

function BgAssetProcessor.apply_asset_light_defaults()
	BgAssetProcessor.apply_light_defaults_for(BgAssetProcessor.get_current_asset())
end

local function write_canvas_png(canvas, gen_path)
	local image_data = canvas:newImageData()
	local png = image_data:encode("png")

	local project_dir = love.filesystem.getSourceBaseDirectory()
	local filepath = project_dir .. "/" .. gen_path
	local dir = filepath:match("^(.+)/[^/]+$")
	if dir then
		os.execute('mkdir -p "' .. dir .. '"')
	end

	local file, err = io.open(filepath, "wb")
	if not file then
		return nil, err
	end
	file:write(png:getString())
	file:close()
	return filepath
end

function BgAssetProcessor.set_index(i)
	assert:type(i, "number")
	BgAssetProcessor.index = mathx.wrap_index(i, BgAssetProcessor.assets)
	BgAssetProcessor.apply_asset_light_defaults()
	BgAssetProcessor.dirty = true
end

function BgAssetProcessor.prev()
	BgAssetProcessor.set_index(BgAssetProcessor.index - 1)
end

function BgAssetProcessor.next()
	BgAssetProcessor.set_index(BgAssetProcessor.index + 1)
end

function BgAssetProcessor.mark_dirty()
	BgAssetProcessor.dirty = true
end

function BgAssetProcessor.apply_cell_grid_only(source_image)
	local w, h = source_image:getDimensions()
	ensure_buffers(w, h)

	love.graphics.setCanvas(buffer_a)
	love.graphics.clear()
	love.graphics.draw(source_image, 0, 0)
	love.graphics.setCanvas()

	local cell = BgAssetProcessor.cell_grid
	cell:send_values(w, h)
	return draw_canvas_to_canvas(buffer_a, cell.shader)
end

function BgAssetProcessor.apply_preview_runtime_pp(canvas)
	if not BgAssetProcessor.preview_runtime_pp then
		return canvas
	end
	if not BgAssetProcessor.ensure_preview_effects() then
		return canvas
	end

	BgAssetProcessor.preview_effects[2]:update(1 / 60)

	for _, effect in ipairs(BgAssetProcessor.preview_effects) do
		if effect.is_active then
			canvas = draw_canvas_to_canvas(canvas, effect.shader)
		end
	end
	return canvas
end

function BgAssetProcessor.render()
	local asset = BgAssetProcessor.get_current_asset()
	local source = BgAssetProcessor.get_image_for_asset(asset)
	local cell_canvas = BgAssetProcessor.apply_cell_grid_only(source)
	BgAssetProcessor.result_canvas = BgAssetProcessor.apply_preview_runtime_pp(cell_canvas)
	BgAssetProcessor.dirty = false
	return BgAssetProcessor.result_canvas
end

function BgAssetProcessor.get_preview_canvas()
	if BgAssetProcessor.dirty or not BgAssetProcessor.result_canvas then
		BgAssetProcessor.render()
	end
	return BgAssetProcessor.result_canvas
end

function BgAssetProcessor.export_asset(asset)
	if not BgAssetProcessor.initialized then
		BgAssetProcessor.init()
	end

	BgAssetProcessor.apply_light_defaults_for(asset)
	local source = BgAssetProcessor.get_image_for_asset(asset)
	local canvas = BgAssetProcessor.apply_cell_grid_only(source)
	local filepath, err = write_canvas_png(canvas, asset.gen_path)
	if not filepath then
		return nil, err
	end
	Log.info("BG asset saved:", filepath)
	return filepath
end

function BgAssetProcessor.export_current()
	local asset = BgAssetProcessor.get_current_asset()
	local filepath, err = BgAssetProcessor.export_asset(asset)
	if filepath then
		BgAssetProcessor.save_message = asset.gen_path
		BgAssetProcessor.save_message_until = love.timer.getTime() + 3
	end
	return filepath, err
end

function BgAssetProcessor.export_all()
	if not BgAssetProcessor.initialized then
		BgAssetProcessor.init()
	end

	local total = #BgAssetProcessor.assets
	local ok_count = 0
	local errors = {}

	for _, asset in ipairs(BgAssetProcessor.assets) do
		local filepath, err = BgAssetProcessor.export_asset(asset)
		if filepath then
			ok_count = ok_count + 1
		else
			errors[#errors + 1] = { key = asset.key, err = err }
			Log.warn("BG asset failed:", asset.key, err)
		end
	end

	BgAssetProcessor.apply_asset_light_defaults()
	BgAssetProcessor.mark_dirty()

	local message = string.format("Generated %d/%d assets", ok_count, total)
	if #errors > 0 then
		message = message .. string.format(" (%d failed)", #errors)
	end
	BgAssetProcessor.save_message = message
	BgAssetProcessor.save_message_until = love.timer.getTime() + 5

	return ok_count, errors
end

function BgAssetProcessor.reload_shader()
	if not BgAssetProcessor.initialized then
		BgAssetProcessor.init()
		return
	end
	local params = BgAssetProcessor.cell_grid:get_params()
	BgAssetProcessor.cell_grid = Shaders.cell_grid(params)
	BgAssetProcessor.mark_dirty()
end

return BgAssetProcessor
