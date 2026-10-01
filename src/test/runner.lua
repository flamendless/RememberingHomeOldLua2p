local Runner = {
	done = false,
	step_index = 1,
	start_time = 0,
	scenario_name = nil,
	steps = nil,
	step_done_do = false,
	frames_after_do = 0,
	wait_logged = false,
}

local TEST_LABEL_MARGIN = 8

local function log(msg)
	print("[test] " .. msg)
end

function Runner.current_step_label()
	if Runner.done then
		return "done"
	end
	if not Runner.steps then
		return nil
	end
	local step = Runner.steps[Runner.step_index]
	if not step then
		return "complete"
	end
	return step.label
end

function Runner.draw_overlay(font)
	local label = Runner.current_step_label()
	if not label then
		return
	end

	font = font or love.graphics.getFont()
	local ww = love.graphics.getDimensions()
	local text = label
	if Runner.scenario_name then
		text = Runner.scenario_name .. " · " .. label
	end
	local text_w = font:getWidth(text)
	local _, _, _, a = love.graphics.getColor()

	love.graphics.push()
	love.graphics.origin()
	love.graphics.setFont(font)
	love.graphics.setColor(1, 0.85, 0.35, 1)
	love.graphics.print(text, ww - text_w - TEST_LABEL_MARGIN, TEST_LABEL_MARGIN)
	love.graphics.setColor(1, 1, 1, a)
	love.graphics.pop()
end

function Runner.fail(msg)
	if Runner.done then
		return
	end
	Runner.done = true
	log("FAIL: " .. tostring(msg))
	love.event.quit(1)
end

function Runner.pass()
	if Runner.done then
		return
	end
	Runner.done = true
	local elapsed = love.timer.getTime() - Runner.start_time
	log(string.format("PASS %s (%.1fs wall)", Runner.scenario_name, elapsed))
	if not Runner.keep_running then
		love.event.quit(0)
	end
end

function Runner.init(scenario_name)
	Runner.scenario_name = scenario_name
	Runner.start_time = love.timer.getTime()
	Runner.step_index = 1
	Runner.done = false
	Runner.step_done_do = false
	Runner.frames_after_do = 0
	Runner.wait_logged = false

	local ok, scenario = pcall(require, "test.scenarios." .. scenario_name)
	if not ok then
		error("unknown test scenario: " .. tostring(scenario_name) .. " (" .. tostring(scenario) .. ")")
	end
	Runner.steps = scenario.steps
	Runner.keep_running = scenario.keep_running == true
	Runner.on_tick = scenario.on_tick
	if scenario_name == "outside_tutorial" then
		Save.data.outside_intro_done = false
	end
	log("scenario: " .. scenario_name)
	return scenario.state
end

local function reset_step_state()
	Runner.step_done_do = false
	Runner.frames_after_do = 0
	Runner.wait_logged = false
end

local function apply_step_input(step)
	local pump_dialogue = step.pump_dialogue
	if pump_dialogue == nil then
		pump_dialogue = true
	end

	local dialogue_active = pump_dialogue and TestHooks.dialogue_should_pump()
	local skip_hold = dialogue_active and step.hold == "interact"

	if step.hold and not skip_hold then
		Inputs.hold(step.hold)
	end

	if dialogue_active then
		Inputs.pump_dialogue()
	end
end

local function advance_step()
	Inputs.unhold_all()
	Runner.step_index = Runner.step_index + 1
	reset_step_state()
end

function Runner.update(_dt)
	if Runner.done then
		return
	end

	if Runner.on_tick then
		Runner.on_tick()
	end

	local elapsed = love.timer.getTime() - Runner.start_time
	if elapsed > TEST.timeout then
		local step = Runner.steps[Runner.step_index]
		local label = step and step.label or "unknown"
		Runner.fail(string.format("timeout after %.1fs at step: %s", elapsed, label))
		return
	end

	local step = Runner.steps[Runner.step_index]
	if not step then
		Runner.pass()
		return
	end

	if step.pass then
		Runner.pass()
		return
	end

	if step.do_fn and not Runner.step_done_do then
		log("action: " .. step.label)
		step.do_fn()
		Runner.step_done_do = true
		Runner.frames_after_do = 0
		return
	end

	if not Runner.wait_logged then
		log("waiting: " .. step.label)
		Runner.wait_logged = true
	end

	if step.do_fn then
		Runner.frames_after_do = Runner.frames_after_do + 1
		local min_frames = step.min_frames or 1
		if Runner.frames_after_do < min_frames then
			return
		end
	end

	apply_step_input(step)

	local until_fn = step.until_fn
	if not until_fn or until_fn() then
		advance_step()
	end
end

return Runner
