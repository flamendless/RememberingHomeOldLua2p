local Dialogues = {}

function Dialogues.get(main, sub)
	if not (#main ~= 0 and type(main) == "string") then
		error('Assertion failed: #main ~= 0 and type(main) == "string"')
	end
	if not (#sub ~= 0 and type(sub) == "string") then
		error('Assertion failed: #sub ~= 0 and type(sub) == "string"')
	end
	if not Data.Dialogues[main] then
		error("there is no " .. main .. " in dialogue table")
	end
	if not Data.Dialogues[main][sub] then
		error("there is no " .. sub .. " in dialogue table")
	end
	return tablex.copy(Data.Dialogues[main][sub])
end

function Dialogues.check_signal(str)
	if not (type(str) == "string") then
		error('Assertion failed: type(str) == "string"')
	end
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
	if not (type(dialogue_t) == "table") then
		error('Assertion failed: type(dialogue_t) == "table"')
	end
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
