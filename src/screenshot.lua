local Screenshot = {
	DEFAULT_SCALE = 2,
	queued = false,
	queued_opts = nil,
	capturing = false,
	last_result = nil,
}

local function copy_png_to_clipboard(abs_path)
	assert:type(abs_path, "string")
	local os_name = love.system.getOS()

	if os_name == "OS X" then
		local cmd = string.format(
			"osascript -e 'set the clipboard to (read (POSIX file %q) as «class PNGf»)'",
			abs_path
		)
		local ok = os.execute(cmd)
		return ok == 0 or ok == true
	end

	if os_name == "Linux" then
		local wl = string.format('wl-copy -t image/png < %q', abs_path)
		local ok = os.execute(wl)
		if ok == 0 or ok == true then
			return true
		end
		local xclip = string.format('xclip -selection clipboard -t image/png -i %q', abs_path)
		ok = os.execute(xclip)
		return ok == 0 or ok == true
	end

	Log.warn("Screenshot: clipboard image not supported on", os_name)
	return false
end

local function log_capture(result)
	local log_data = {
		directory = result.absolute_path,
		size = string.format("%dx%d", result.width, result.height),
		gamestate = GameStates and GameStates.current_id or nil,
		datetime = os.date("%Y-%m-%d %H:%M:%S"),
		bytes_kb = result.bytes / 1024,
		clipboard = result.clipboard and "ok" or "failed",
	}
	Log.info("Screenshot", pretty.string(log_data))
end

local function finish_capture(image_data, opts)
	opts = opts or {}
	local scale = opts.scale or Screenshot.DEFAULT_SCALE
	local save = opts.save ~= false
	local clipboard = opts.clipboard ~= false
	local subdir = opts.subdir or "screenshots"

	local base_w, base_h = image_data:getDimensions()
	if base_w < 1 or base_h < 1 then
		return false, "invalid framebuffer size"
	end
	local target_w = math.floor(base_w * scale)
	local target_h = math.floor(base_h * scale)

	local snapshot = love.graphics.newImage(image_data)
	local prev_canvas = love.graphics.getCanvas()
	local prev_r, prev_g, prev_b, prev_a = love.graphics.getColor()

	local upscale = love.graphics.newCanvas(target_w, target_h)
	upscale:setFilter("nearest", "nearest")

	love.graphics.setCanvas(upscale)
	love.graphics.clear(0, 0, 0, 1)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(snapshot, 0, 0, 0, scale, scale)
	love.graphics.setCanvas(prev_canvas)

	local encoded_data = upscale:newImageData()
	local png = encoded_data:encode("png")
	local png_string = png:getString()
	local bytes = #png_string

	local timestamp = os.date("%Y%m%d_%H%M%S")
	local filename = "screenshot_" .. timestamp .. ".png"
	local relative_path = subdir .. "/" .. filename

	local abs_path = nil
	if save then
		love.filesystem.createDirectory(subdir)
		local write_ok, write_err = love.filesystem.write(relative_path, png_string)
		if not write_ok then
			love.graphics.setColor(prev_r, prev_g, prev_b, prev_a)
			return false, write_err or "failed to write screenshot"
		end
		abs_path = love.filesystem.getSaveDirectory() .. "/" .. relative_path
	end

	local clipboard_ok = false
	if clipboard then
		if abs_path then
			clipboard_ok = copy_png_to_clipboard(abs_path)
		else
			local tmp_dir = subdir
			love.filesystem.createDirectory(tmp_dir)
			local tmp_rel = tmp_dir .. "/.clipboard_tmp.png"
			local write_ok = love.filesystem.write(tmp_rel, png_string)
			if write_ok then
				abs_path = love.filesystem.getSaveDirectory() .. "/" .. tmp_rel
				clipboard_ok = copy_png_to_clipboard(abs_path)
				love.filesystem.remove(tmp_rel)
			end
		end
	end

	love.graphics.setColor(prev_r, prev_g, prev_b, prev_a)

	local result = {
		relative_path = relative_path,
		absolute_path = abs_path,
		width = target_w,
		height = target_h,
		base_width = base_w,
		base_height = base_h,
		scale = scale,
		timestamp = timestamp,
		bytes = bytes,
		clipboard = clipboard_ok,
	}

	return true, result
end

function Screenshot.request_capture(opts)
	Screenshot.queued = true
	Screenshot.queued_opts = opts
end

function Screenshot.flush_queued()
	if not Screenshot.queued or Screenshot.capturing then
		return false
	end
	local opts = Screenshot.queued_opts
	Screenshot.queued = false
	Screenshot.queued_opts = nil
	Screenshot.capture(opts)
	return true
end

function Screenshot.capture(opts)
	if Screenshot.capturing then
		return false, "capture already in progress"
	end

	if not love.graphics.captureScreenshot then
		return false, "love.graphics.captureScreenshot not available"
	end

	Screenshot.capturing = true

	love.graphics.captureScreenshot(function(image_data)
		local ok, result = finish_capture(image_data, opts)
		Screenshot.capturing = false

		if ok then
			Screenshot.last_result = result
			log_capture(result)
		else
			Screenshot.last_result = { error = result }
			Log.warn("Screenshot failed:", result)
		end
	end)

	return true, "pending"
end

return Screenshot
