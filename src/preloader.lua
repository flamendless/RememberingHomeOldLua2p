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
	assert(type(resources) == "table", resources)
	assert(type(container) == "table", container)
	assert(type(on_complete) == "function", on_complete)
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
					id = id .. "_" .. font_size
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
	assert(type(data) == "table", data)
	local preloader = Lily.loadMulti(data)
	preloader:setUserData(userdata)
	preloader:onLoaded(function(_, _, _)
		local to_load = preloader:getCount()
		local completed = preloader:getLoadedCount()
		Preloader.percent = (completed / to_load) * 100
	end)

	preloader:onComplete(function(id, tbl_data)
		for i, tbl in ipairs(tbl_data) do
			local pid = id[i]
			local pdata = tbl[1]
			local data_type = pdata:type()

			if data_type == "Image" then
				local tt = pdata:getTextureType()
				pdata:setFilter("nearest", "nearest")
				if tt == "array" then
					assert(type(container.array_images) == "table", container.array_images)
					container.array_images[pid] = pdata
				end
				assert(type(container.images) == "table", container.images)
				container.images[pid] = pdata
			elseif data_type == "ImageData" then
				assert(type(container.image_data) == "table", container.image_data)
				container.image_data[pid] = pdata
			elseif data_type == "Source" then
				assert(type(container.sources) == "table", container.sources)
				container.sources[pid] = pdata
			elseif data_type == "Font" then
				assert(type(container.fonts) == "table", container.fonts)
				pdata:setFilter("nearest", "nearest")
				container.fonts[pid] = pdata
			end

			local str = string.format("Loaded: #%i - %s : %s", i, data_type, pid)
			Log.trace(str)
		end

		on_complete()
	end)
end

return Preloader
