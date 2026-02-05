local Preloader = {
	percent = 0,
}

local keys = {
	images = "newImage",
	image_data = "newImageData",
	array_images = "newArrayImage",
	sources = "newSource",
	fonts = "newFont",
}

function Preloader.start(resources, container, on_complete)
	if type(resources) ~= "table" then
		error('Assertion failed: type(resources) == "table"')
	end
	if type(container) ~= "table" then
		error('Assertion failed: type(container) == "table"')
	end
	if type(on_complete) ~= "function" then
		error('Assertion failed: type(on_complete) == "function"')
	end
	Preloader.percent = 0
	local i = 1
	local data = {}
	local userdata = {}
	for kind, t in pairs(resources) do
		for j = 1, #t do
			local id = t[j][1]
			local path = t[j][2]

			if kind == "images" or kind == "image_data" then
				data[i] = { keys[kind], path }
			elseif kind == "array_images" then
				data[i] = { keys[kind], { path } }
			elseif kind == "sources" then
				local source_type = t[j][3]
				data[i] = { keys[kind], path, source_type }
			elseif kind == "fonts" then
				local font_size = t[j][3]
				local font_sub = t[j][4]
				if not font_sub then
					id = id .. "_" .. (font_sub or font_size)
				end
				data[i] = { keys[kind], path, font_size }
			end
			userdata[i] = id
			i = i + 1
		end
	end

	Preloader.load(data, userdata, container, on_complete)
end

function Preloader.load(data, userdata, container, on_complete)
	if type(data) ~= "table" then
		error('Assertion failed: type(data) == "table"')
	end
	local preloader = Lily.loadMulti(data)
	preloader:setUserData(userdata)
	preloader:onLoaded(function(id, i, data)
		local to_load = preloader:getCount()
		local completed = preloader:getLoadedCount()
		Preloader.percent = (completed / to_load) * 100
	end)

	preloader:onComplete(function(id, tbl_data)
		for i, tbl in ipairs(tbl_data) do
			local id = id[i]
			local data = tbl[1]
			local data_type = data:type()

			if data_type == "Image" then
				local tt = data:getTextureType()
				data:setFilter("nearest", "nearest")
				if tt == "array" then
					if type(container.array_images) ~= "table" then
						error('Assertion failed: type(container.array_images) == "table"')
					end
					container.array_images[id] = data
				end
				if type(container.images) ~= "table" then
					error('Assertion failed: type(container.images) == "table"')
				end
				container.images[id] = data
			elseif data_type == "ImageData" then
				if type(container.image_data) ~= "table" then
					error('Assertion failed: type(container.image_data) == "table"')
				end
				container.image_data[id] = data
			elseif data_type == "Source" then
				if type(container.sources) ~= "table" then
					error('Assertion failed: type(container.sources) == "table"')
				end
				container.sources[id] = data
			elseif data_type == "Font" then
				if type(container.fonts) ~= "table" then
					error('Assertion failed: type(container.fonts) == "table"')
				end
				data:setFilter("nearest", "nearest")
				container.fonts[id] = data
			end

			local str = string.format("Loaded: #%i - %s : %s", i, data_type, id)
			Log.trace(str)
		end

		on_complete()
	end)
end

return Preloader
