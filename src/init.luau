--!strict
--!native
--!optimize 2

local Configuration = require(script.Configuration)
local HotReloader = require(script.HotReloader)
local types = require(script.types)

export type HotReloaderPrototype = HotReloader.HotReloaderPrototype
export type HotReloaderProperties = HotReloader.HotReloaderProperties
export type HotReloader = HotReloader.HotReloader

export type Context = types.Context

local exports = {
	Configuration = Configuration,
	HotReloader = HotReloader,
}

return exports
