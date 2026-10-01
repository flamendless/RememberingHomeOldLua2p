--[[
Project: Remembering Home
(2017 - 2030)
By: flamendless studio @flam8studio

Author: Brandon Blanker Lim-it @flamendless
Artist: Conrad Reyes @Shizzy619
Room Designer: Piolo Maurice Laudencia @piotato

Start Date: Tue Mar 17 18:42:00 PST 2020
--]]

require("global")

Log.lovesave = true
Shaders.load_shaders()
local base_errhand = ErrorHandler.callback
love.errhand = function(msg)
	if TEST.mode then
		print("[test] ERROR: " .. tostring(msg))
		print(debug.traceback("", 2))
		return function()
			return 1
		end
	end
	return base_errhand(msg)
end
local font = love.graphics.newFont("res/fonts/Jamboree.ttf", 32)
font:setFilter("nearest", "nearest")

local mode = "RELEASE"
if DEV then mode = "DEV" end
if PROF then mode = mode .. " PROF" end

-- Temporary: set HANG_WATCH false to disable. Last console line before a freeze shows where the loop stopped.
local hang_watch_frame = 0
local hang_watch_file
local hang_watch_last
local hang_watch_buffer = {}

local function hang_watch_flush()
	if not hang_watch_file or #hang_watch_buffer == 0 then
		return
	end
	hang_watch_file:write(table.concat(hang_watch_buffer))
	hang_watch_buffer = {}
	hang_watch_file:flush()
end

global({
	HANG_WATCH = DEV,
	hang_watch = function(msg)
		if not HANG_WATCH then
			return
		end
		hang_watch_last = msg
		if not hang_watch_file then
			return
		end
		hang_watch_buffer[#hang_watch_buffer + 1] = string.format(
			"[hang-watch] frame %d: %s\n",
			hang_watch_frame,
			msg
		)
	end,
})

function love.load()
	Log.info("Starting... Game Version:", Config.this_version)
	Log.info("Commit:", GIT_COMMIT ~= "" and GIT_COMMIT or "unknown")
	love.math.setRandomSeed(TEST.mode and TEST.seed or love.timer.getTime())
	love.graphics.setDefaultFilter("nearest", "nearest")

	local modules = {
		WindowMode,
		Shaders,
		BloodBar,
		LoadingScreen,
		Info,
		Save,
		Settings,
		Audio,
		Inputs,
	}
	for _, module in ipairs(modules) do
		module.init()
	end

	TLE.Attach()

	if GEN_BG_ASSETS then
		BgAssetProcessor.init()
		local ok_count, errors = BgAssetProcessor.export_all()
		Log.info(string.format("Generated %d/%d BG assets", ok_count, #BgAssetProcessor.assets))
		for _, entry in ipairs(errors) do
			Log.warn("BG asset failed:", entry.key, entry.err)
		end
		love.event.quit(#errors > 0 and 1 or 0)
		return
	end

	if TEST.mode then
		local state = TestRunner.init(TEST.scenario)
		GameStates.switch(state)
	else
		-- GameStates.switch(Enums.game_state.Splash)
		-- GameStates.switch(Enums.game_state.Menu)
		-- GameStates.switch(Enums.game_state.Intro)
		-- GameStates.switch(Enums.game_state.Outside)
		GameStates.switch(Enums.game_state.Shed)
		-- GameStates.switch(Enums.game_state.StorageRoom)
		-- GameStates.switch(Enums.game_state.UtilityRoom)
		-- GameStates.switch(Enums.game_state.Kitchen)
		-- GameStates.switch(Enums.game_state.LivingRoom)
		-- GameStates.switch(Enums.game_state.TotallyDarkRoom)
		-- GameStates.switch(Enums.game_state.Office1)
		-- GameStates.switch(Enums.game_state.Office2)
	end

	DevTools.init()

	if HANG_WATCH then
		hang_watch_file = io.open("hang_watch.log", "w")
		print("[hang-watch] logging to hang_watch.log (tail -f hang_watch.log)")
	end
end

local MAX_UPDATE_STEP = 1 / 60

function love.update(dt)
	assert:type(dt, "number")
	JPROF.push("frame")

	if DEV and DevTools.pause then
		return
	end

	local frame_dt = dt

	if TEST.mode then
		Inputs.apply_pending_releases()
		TestRunner.update(frame_dt)
	end

	-- Only Timer/Flux need substeps (large dt bursts them). DevTools/Slab must run once per frame.
	while dt > 0 do
		local step = math.min(dt, MAX_UPDATE_STEP)
		hang_watch("timer")
		Timer.update(step)
		hang_watch("timer ok")

		hang_watch("flux " .. Flux.count())
		Flux.update(step)
		hang_watch("flux ok")

		dt = dt - step
	end

	hang_watch("gamestates")
	GameStates.update(frame_dt)
	hang_watch("gamestates ok")

	hang_watch("inputs")
	Inputs.update(frame_dt)
	hang_watch("inputs ok")

	if not GameStates.is_ready then
		hang_watch("loading")
		LoadingScreen.update(frame_dt)
		hang_watch("loading ok")
	end

	if DEV then
		hang_watch("devtools")
		DevTools.update(frame_dt)
		hang_watch("devtools ok")
	end
end

function love.draw()
	love.graphics.setColor(1, 1, 1, 1)
	hang_watch("draw:gamestates")
	GameStates.draw()
	hang_watch("draw:gamestates ok")

	if not GameStates.is_ready then
		hang_watch("draw:loading")
		LoadingScreen.draw()
		hang_watch("draw:loading ok")
	end

	if DEV then
		JPROF.push("dev draw")
		hang_watch("draw:devtools")
		DevTools.draw()
		hang_watch("draw:devtools ok")
		love.graphics.setColor(1, 0, 0, 1)
		if DevTools.show_fps then
			love.graphics.setFont(font)
			love.graphics.print(mode)
		end

		if DevTools.pause then
			local ww, wh = love.graphics.getDimensions()
			love.graphics.setFont(font)
			love.graphics.printf("DEV PAUSED", 0, wh/2, ww, "center")
		end

		if GameStates.is_ready and GameStates.world then
			GameStates.world:emit("draw_debug_overlay")
		end

		hang_watch("draw:devtools end")
		DevTools.end_draw()
		hang_watch("draw:devtools end ok")
		JPROF.pop("dev draw")
	end

	if TEST.mode then
		love.graphics.setColor(1, 0, 0, 1)
		love.graphics.setFont(font)
		love.graphics.print("TEST")
		TestRunner.draw_overlay(font)
		Inputs.draw_test_input_overlay()
	end

	love.graphics.setColor(1, 1, 1, 1)

	JPROF.pop("frame")
end

function love.quit()
	Log.info("Quitting...")
	hang_watch_flush()
	if hang_watch_file then
		hang_watch_file:close()
		hang_watch_file = nil
	end
	Lily.quit()
	if PROF then
		JPROF.write("prof.mpack")
	end
end

local function get_update_speed()
	if TEST.mode and not GameStates.is_ready then
		return 1
	end
	return GAME_SPEED_MULT
end

function love.run()
	if love.load then
		love.load(love.arg.parseGameArguments(arg), arg)
	end
	if love.timer then
		love.timer.step()
	end
	local dt = 0

	local function dispatch_event(name, a, b, c, d, e, f)
		assert:type(name, "string")
		if name == "quit" then
			if not love.quit or not love.quit() then
				return false, a or 0
			end
		end

		if love.handlers[name] then
			love.handlers[name](a, b, c, d, e, f)
		end

		--EVENTS/CALLBACKS

		if DevTools[name] then
			DevTools[name](a, b, c, d, e, f)
		end

		local block_input = DEV and DevTools.blocks_input and DevTools.blocks_input()
		if Inputs[name] and not block_input then
			Inputs[name](a, b, c, d, e, f)
		end
		if GameStates[name] and not block_input then
			GameStates[name](a, b, c, d, e, f)
		end
		--END EVENTS/CALLBACKS

		return true
	end

	return function()
		hang_watch_frame = hang_watch_frame + 1
		hang_watch("enter events")

		if love.event then
			love.event.pump()
			hang_watch("pump ok")

			local events = {}
			local coalesced_mousemoved = nil
			local raw_event_count = 0

			for name, a, b, c, d, e, f in love.event.poll() do
				raw_event_count = raw_event_count + 1
				if name == "mousemoved" then
					if coalesced_mousemoved then
						coalesced_mousemoved[3] = coalesced_mousemoved[3] + c
						coalesced_mousemoved[4] = coalesced_mousemoved[4] + d
						coalesced_mousemoved[1] = a
						coalesced_mousemoved[2] = b
						coalesced_mousemoved[5] = e
						coalesced_mousemoved[6] = f
					else
						coalesced_mousemoved = { a, b, c, d, e, f }
					end
				else
					events[#events + 1] = { name, a, b, c, d, e, f }
				end
			end

			if coalesced_mousemoved then
				events[#events + 1] = {
					"mousemoved",
					coalesced_mousemoved[1],
					coalesced_mousemoved[2],
					coalesced_mousemoved[3],
					coalesced_mousemoved[4],
					coalesced_mousemoved[5],
					coalesced_mousemoved[6],
				}
			end

			if raw_event_count > 1 then
				hang_watch(string.format(
					"events %d raw -> %d dispatch",
					raw_event_count,
					#events
				))
			end

			for i = 1, #events do
				local ev = events[i]
				local name = ev[1]
				hang_watch("event " .. name)
				local ok, code = dispatch_event(name, ev[2], ev[3], ev[4], ev[5], ev[6], ev[7])
				if not ok then
					return code
				end
				hang_watch("event " .. name .. " ok")
			end
		end
		hang_watch("events ok")

		if love.timer then
			dt = love.timer.step()
		end

		hang_watch("enter update")
		if love.update then
			love.update(dt * get_update_speed())
		end
		hang_watch("update ok")

		if love.graphics and love.graphics.isActive() then
			hang_watch("enter draw")
			love.graphics.origin()
			love.graphics.clear(love.graphics.getBackgroundColor())
			if love.draw then
				love.draw()
			end
			hang_watch("draw ok")

			hang_watch("enter present")
			love.graphics.present()
			hang_watch("present ok")
		end

		if love.timer then
			love.timer.sleep(0.001)
		end
		hang_watch("frame end")
		hang_watch_flush()
	end
end
