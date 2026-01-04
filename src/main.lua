--[[
Project: Going Home: Revisited
(2017 - 2030)
By: flamendless studio @flam8studio

Author: Brandon Blanker Lim-it @flamendless
Artist: Conrad Reyes @Shizzy619
Room Designer: Piolo Maurice Laudencia @piotato

Start Date: Tue Mar 17 18:42:00 PST 2020
--]]

--love.filesystem.setRequirePath(love.filesystem.getRequirePath() .. ";modules/?.lua")
--require("jit.p").start("lz")
require("modules.batteries"):export()

local Flux = require("modules.flux.flux")
local Lily = require("modules.lily.lily")
local Log = require("modules.log.log")
Log.lovesave = true
require("modules.sdf").mount()
local Timer = require("modules.hump.timer")
local TLE = require("modules.tle.timeline")

local Audio = require("audio")
local Config = require("config")
local ErrorHandler = require("error_handler")
love.errhand = ErrorHandler.callback
local GameStates = require("gamestates")
local Info = require("info")
local Inputs = require("inputs")
local LoadingScreen = require("loading_screen")
local Save = require("save")
local Settings = require("settings")
local Shaders = require("shaders")
Shaders.load_shaders()
local WindowMode = require("window_mode")

require("modules.strict")
local DevTools = require("devtools")
local font = love.graphics.newFont("res/fonts/Jamboree.ttf", 32)
font:setFilter("nearest", "nearest")

function love.load()
	Log.info("Starting... Game Version:", Config.this_version)
	Log.info('Commit: "v2026-01-02.020dc1c"')
	love.math.setRandomSeed(love.timer.getTime())
	love.graphics.setDefaultFilter("nearest", "nearest")

	local modules = {
		WindowMode,
		Shaders,
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
end

function love.update(dt)
	if DevTools.pause then
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
		love.graphics.setColor(1, 0, 0, 1)
		if DevTools.show_fps then
			love.graphics.setFont(font)
			love.graphics.print(love.timer.getFPS())
			love.graphics.print("dev", love.graphics.getWidth() - font:getWidth("dev"))
		end
		if DevTools.pause then
			local ww, wh = love.graphics.getDimensions()
			love.graphics.setFont(font)
			love.graphics.printf("PAUSED", 0, wh * 0.5, ww, "center")
		end
		DevTools.end_draw()
	end
end

function love.quit()
	Lily.quit()
	Log.info("Quitting...")
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
			love.update(dt)
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
