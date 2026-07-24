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
		love.event.quit(1)
		return function() end
	end
	return base_errhand(msg)
end
local font = love.graphics.newFont("res/fonts/Jamboree.ttf", 32)
font:setFilter("nearest", "nearest")

local mode = "RELEASE"
if DEV then mode = "DEV" end
if PROF then mode = mode .. " PROF" end

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

	if TEST.mode then
		TestRunner.init(TEST.scenario)
	end

	GameStates.switch("Splash")
	-- GameStates.switch("Menu")
	-- GameStates.switch("Intro")
	-- GameStates.switch("Outside")
	-- GameStates.switch("StorageRoom")
	-- GameStates.switch("UtilityRoom")
	-- GameStates.switch("Kitchen")
	-- GameStates.switch("LivingRoom")
	-- GameStates.switch("TotallyDarkRoom")
	-- GameStates.switch("Office1")
	-- GameStates.switch("Office2")

	DevTools.init()
end

function love.update(dt)
	JPROF.push("frame")

	if DevTools.pause then
		return
	end

	if TEST.mode then
		Inputs.apply_pending_releases()
		TestRunner.update(dt)
	end

	Timer.update(dt)
	Flux.update(dt)
	GameStates.update(dt)
	Inputs.update(dt)

	if not GameStates.is_ready then
		LoadingScreen.update(dt)
	end

	if DEV then
		DevTools.update(dt)
	end
end

function love.draw()
	love.graphics.setColor(1, 1, 1, 1)
	GameStates.draw()

	if not GameStates.is_ready then
		LoadingScreen.draw()
	end

	if DEV then
		JPROF.push("dev draw")
		DevTools.draw()
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
		DevTools.end_draw()
		JPROF.pop("dev draw")
	end

	if TEST.mode then
		love.graphics.setColor(1, 0, 0, 1)
		love.graphics.setFont(font)
		love.graphics.print("TEST")
	end

	love.graphics.setColor(1, 1, 1, 1)

	JPROF.pop("frame")
end

function love.quit()
	Log.info("Quitting...")
	Lily.quit()
	JPROF.write("prof.mpack")
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

	-- Main loop time.
	return function()
		-- Process events.

		if love.event then
			love.event.pump()
			for name, a, b, c, d, e, f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a or 0
					end
				end
				love.handlers[name](a, b, c, d, e, f)

				--EVENTS/CALLBACKS

				if DevTools[name] then
					DevTools[name](a, b, c, d, e, f)
				end

				if Inputs[name] then
					Inputs[name](a, b, c, d, e, f)
				end
				if GameStates[name] then
					GameStates[name](a, b, c, d, e, f)
				end
				--END EVENTS/CALLBACKS
			end
		end
		if love.timer then
			dt = love.timer.step()
		end

		if love.update then
			love.update(dt * get_update_speed())
		end

		if love.graphics and love.graphics.isActive() then
			love.graphics.origin()
			love.graphics.clear(love.graphics.getBackgroundColor())
			if love.draw then
				love.draw()
			end

			love.graphics.present()
		end

		if love.timer then
			love.timer.sleep(0.001)
		end
	end
end
