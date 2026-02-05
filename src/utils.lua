local Utils = {
	file = {},
	serial = {},
	hash = {},
	string = {},
	table = {},
	math = {},
}

function Utils.file.read(filename)
	if type(filename) ~= "string" then
		error('Assertion failed: type(filename) == "string"')
	end
	local file = love.filesystem.getInfo(filename)
	Log.info(filename, "exists:", file ~= nil)
	if file then
		local content = love.filesystem.read(filename)
		return content, true
	end

	return false
end

function Utils.file.write(filename, data)
	if type(filename) ~= "string" then
		error('Assertion failed: type(filename) == "string"')
	end
	love.filesystem.write(filename, data)
	Log.info(filename, "written")
end

function Utils.serial.write(filename, data)
	if type(filename) ~= "string" then
		error('Assertion failed: type(filename) == "string"')
	end
	local to_write = Bitser.dumps(data)
	Utils.file.write(filename, to_write)
	return to_write
end

function Utils.serial.read(filename)
	if type(filename) ~= "string" then
		error('Assertion failed: type(filename) == "string"')
	end
	local content, exists = Utils.file.read(filename)
	if exists then
		local data = Bitser.loads(content)
		return data, exists
	end
	return false
end

function Utils.serial.de(content)
	return Bitser.loads(content)
end

function Utils.hash.compare(a, b)
	if type(a) ~= "string" then
		error('Assertion failed: type(a) == "string"')
	end
	if type(b) ~= "string" then
		error('Assertion failed: type(b) == "string"')
	end
	local hashed_a = love.data.hash("md5", a)
	local hashed_b = love.data.hash("md5", b)
	return hashed_a == hashed_b
end

function Utils.string.get_substr(str, sep)
	if type(str) ~= "string" then
		error('Assertion failed: type(str) == "string"')
	end
	if type(sep) ~= "string" then
		error('Assertion failed: type(sep) == "string"')
	end
	local n = string.find(str, sep)
	return string.sub(str, 1, n - 1)
end

function Utils.string.get_widest(t)
	if type(t) ~= "table" then
		error('Assertion failed: type(t) == "table"')
	end
	if #t == 0 then
		error("Assertion failed: #t == 0")
	end
	local widest = 0
	for _, str in ipairs(t) do
		widest = math.max(widest, #str)
	end
	return widest
end

function Utils.table.rotate(t, amount)
	if type(t) ~= "table" then
		error('Assertion failed: type(t) == "table"')
	end
	if type(amount) ~= "number" then
		error('Assertion failed: type(amount) == "number"')
	end
	if amount == 0 then
		return t
	end
	if amount > 0 then
		tablex.push(t, tablex.shift(t))
		return Utils.table.rotate(t, amount - 1)
	elseif amount < 0 then
		tablex.unshift(t, tablex.pop(t))
		return Utils.table.rotate(t, amount + 1)
	end
end

function Utils.table.count_kv(t)
	if type(t) ~= "table" then
		error('Assertion failed: type(t) == "table"')
	end
	if #t ~= 0 then
		return #t
	end
	local count = 0
	for _ in pairs(t) do
		count = count + 1
	end
	return count
end

function Utils.table.pick_random_kv(t, count)
	count = count or Utils.table.count_kv(t)
	local limit = math.floor(love.math.random() * (count - 1)) + 1
	for k, v in pairs(t) do
		limit = limit - 1
		if limit == 0 then
			return k, v
		end
	end
end

function Utils.math.n_digits(x)
	return math.floor(math.log10(x)) + 1
end

function Utils.math.lerp_range(range, t)
	if not (type(range) == "table" and range.min and range.max) then
		error('Assertion failed: type(range) == "table" and range.min and range.max')
	end
	if type(t) ~= "number" then
		error('Assertion failed: type(t) == "number"')
	end
	return mathx.lerp(range.min, range.max, t)
end

function Utils.math.calc_e_controller_origin(e)
	if not e.__isEntity then
		error("Assertion failed: e.__isEntity")
	end
	local anim_data = e.animation_data
	local transform = e.transform
	local pos = e.pos
	local x = pos.x + anim_data.frame_width/2 - transform.ox
	local y = pos.y
	return x, y
end

return Utils
