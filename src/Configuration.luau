--!strict
--!native

local types = require(script.Parent.types)

type ConfigurationPrototype = types.ConfigurationPrototype
type ConfigurationProps = types.ConfigurationProps
export type Configuration = types.Configuration

local Configuration = {}
Configuration.prototype = {} :: ConfigurationPrototype
Configuration.prototype.__index = Configuration.prototype

function Configuration.new(props: ConfigurationProps): Configuration
	local clonedProps = table.clone(props)

	local self = setmetatable({
		props = clonedProps,
	}, Configuration.prototype)

	return self
end

function Configuration.is(value)
	return type(value) == "table" and getmetatable(value) == Configuration.prototype
end

return Configuration
