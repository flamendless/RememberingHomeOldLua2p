local Dialogues = {}

function Dialogues.get(main, sub)
	assert((#main ~= 0 and type(main) == "string"), main)
	assert((#sub ~= 0 and type(sub) == "string"), sub)
	assert(Data.Dialogues[main], "there is no " .. main .. " in dialogue table")
	assert(Data.Dialogues[main][sub], "there is no " .. sub .. " in dialogue table")
	return tablex.copy(Data.Dialogues[main][sub])
end

function Dialogues.check_signal(str)
	assert(type(str) == "string", str)
	local bool = stringx.starts_with(str, "_")
	if not bool then
		return false, "", true
	end

	local handle_self = not stringx.starts_with(str, "__")
	local signal
	if handle_self then
		signal = str:sub(2, #str)
	else
		signal = str:sub(3, #str)
	end
	return bool, signal, handle_self
end

function Dialogues.validate(dialogue_t)
	assert(type(dialogue_t) == "table", dialogue_t)
	if #dialogue_t == 0 then
		return true
	end
	local bool = Dialogues.check_signal(dialogue_t[1])
	if bool and #dialogue_t == 1 and dialogue_t.choices == nil then
		return false
	end
	return true
end

return Dialogues
