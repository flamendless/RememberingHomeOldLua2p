local TestHooks = {}

function TestHooks.state_is(id)
	return GameStates.current_id == id and GameStates.is_ready
end

function TestHooks.get_menu()
	if GameStates.current_id ~= "Menu" or not GameStates.is_ready then
		return nil
	end
	return GameStates.world:getSystem(ECS.get_state_class("Menu"))
end

function TestHooks.get_list()
	if not GameStates.is_ready or not GameStates.world then
		return nil
	end
	return GameStates.world:getSystem(ECS.get_system_class("list"))
end

function TestHooks.menu_ready()
	local menu = TestHooks.get_menu()
	return menu ~= nil and not menu.is_transition
end

function TestHooks.menu_state_is(state_name)
	local menu = TestHooks.get_menu()
	if not menu or menu.is_transition then
		return false
	end
	return menu.current_state == Enums.menu_state[state_name]
end

function TestHooks.menu_mb_done()
	local menu = TestHooks.get_menu()
	return menu ~= nil and not menu.mb.flag_process
end

function TestHooks.menu_main_ready()
	return TestHooks.menu_state_is("menu") and TestHooks.menu_ready() and TestHooks.menu_mb_done()
end

function TestHooks.menu_sub_ready()
	return TestHooks.menu_state_is("sub_menu") and TestHooks.menu_ready()
end

function TestHooks.menu_settings_ready()
	return TestHooks.menu_state_is("settings") and TestHooks.menu_mb_done()
end

function TestHooks.menu_about_ready()
	return TestHooks.menu_state_is("about") and TestHooks.menu_mb_done()
end

function TestHooks.menu_list_cursor(expected)
	local list = TestHooks.get_list()
	if not list or not list.focused then
		return expected and false or nil
	end
	local group = list.groups[list.focused]
	if not group then
		return expected and false or nil
	end
	if expected then
		return group.cursor == expected
	end
	return group.cursor
end

function TestHooks.get_tutorial()
	if not TestHooks.state_is("Outside") then
		return nil
	end
	return GameStates.world:getSystem(ECS.get_system_class("tutorial"))
end

function TestHooks.tutorial_beat_is(name)
	local tutorial = TestHooks.get_tutorial()
	if not tutorial or not tutorial.beat then
		return false
	end
	return tutorial.beat == Enums.tutorial_beat[name]
end

function TestHooks.tutorial_wait_is(kind)
	local tutorial = TestHooks.get_tutorial()
	if not tutorial then
		return false
	end
	return tutorial.wait_kind == kind
end

function TestHooks.tutorial_waiting_dialogue()
	local tutorial = TestHooks.get_tutorial()
	return tutorial ~= nil and tutorial.waiting_dialogue == true
end

function TestHooks.tutorial_step_is(name)
	return TestHooks.tutorial_beat_is(name) or TestHooks.tutorial_wait_is(name)
end

function TestHooks.get_dialogues()
	if not GameStates.is_ready or not GameStates.world then
		return nil
	end
	return GameStates.world:getSystem(ECS.get_system_class("dialogues"))
end

function TestHooks.dialogue_active()
	local dialogues = TestHooks.get_dialogues()
	return dialogues ~= nil and dialogues.current_content ~= nil
end

function TestHooks.dialogue_is_choice()
	local dialogues = TestHooks.get_dialogues()
	if not dialogues or not dialogues.current_content then
		return false
	end
	return dialogues.current_content.type == "choice"
end

function TestHooks.get_player()
	if not GameStates.is_ready or not GameStates.world then
		return nil
	end
	return GameStates.world:getResource("e_player")
end

function TestHooks.player_can_move()
	local player = TestHooks.get_player()
	return player ~= nil and player.can_move ~= nil
end

function TestHooks.tutorial_explore_ready()
	return TestHooks.tutorial_beat_is("explore") and TestHooks.player_can_move()
end

return TestHooks
