--[[
Project: Going Home: Revisited
(2017 - 2030)
By: flamendless studio @flam8studio

Author: Brandon Blanker Lim-it @flamendless
Artist: Conrad Reyes @Shizzy619
Room Designer: Piolo Maurice Laudencia @piotato

Start Date: Tue Mar 17 18:42:00 PST 2020
--]]
--
require("modules.sdf").mount()

function love.load()
	Log.info("Game Version:", GAME_VERSION)
	love.math.setRandomSeed(love.timer.getTime())
	love.graphics.setDefaultFilter("nearest", "nearest")

	for _, module in ipairs({
		Shaders,
		LoadingScreen,
		SystemInfo,
		Save,
		Settings,
		Audio,
		Inputs,
	}) do
		module.init()
	end

	Tle.Attach()

	if DEV then
		-- GameStates.switch("Splash")
		-- GameStates.switch("Menu")
		-- GameStates.switch("Intro")
		-- GameStates.switch("Outside")
		-- GameStates.switch("StorageRoom")
		-- GameStates.switch("UtilityRoom")
		-- GameStates.switch("Kitchen")
		GameStates.switch("LivingRoom")

		DevTools.init()
		Shaders.NGrading.dev_init()
	else
		GameStates.switch("Splash")
	end
end

function love.update(dt)
	if DEV and DevTools.pause then
		return
	end

	Timer.update(dt)
	Flux.update(dt)
	GameStates.update(dt)
	Inputs.update()

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
		DevTools.draw()
	end
end

function love.quit()
	Lily.quit()
	Log.info("Quitting...")

	if not DEV then
		Log.quit("logs")
	end

	if PROF then
		JPROF.popAll()
		JPROF.write("prof.mpack")
	end
end

function love.run()
	if love.load then love.load(love.arg.parseGameArguments(arg), arg) end
	if love.timer then love.timer.step() end
	local dt = 0

	-- Main loop time.
	return function()
		-- Process events.
		-- @@profb("frame")
		-- @@profb("love.run")

		if love.event then
			-- @@profb("love.event")
			love.event.pump()
			for name, a, b, c, d, e, f in love.event.poll() do
				-- @@profb(name)
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a or 0
					end
				end
				love.handlers[name](a, b, c, d, e, f)

				--EVENTS/CALLBACKS
				if DEV then
					if DevTools[name] then
						DevTools[name](a, b, c, d, e, f)
					end
				end

				if Inputs[name] then
					Inputs[name](a, b, c, d, e, f)
				end

				if GameStates[name] then
					GameStates[name](a, b, c, d, e, f)
				end
				--END EVENTS/CALLBACKS
				-- @@profe(name)
			end
			-- @@profe("love.event")
		end
		if love.timer then dt = love.timer.step() end
		if love.update then love.update(dt) end
		if love.graphics and love.graphics.isActive() then
			love.graphics.origin()
			love.graphics.clear(love.graphics.getBackgroundColor())
			if love.draw then love.draw() end
			-- @@profb("present")
			love.graphics.present()
			-- @@profe("present")
		end

		-- @@profb("sleep")
		if love.timer then love.timer.sleep(0.001) end
		-- @@profe("sleep")
		-- @@profe("love.run")
		-- @@profe("frame")
	end
end
