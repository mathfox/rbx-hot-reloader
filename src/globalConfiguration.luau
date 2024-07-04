--!strict

local Configuration = require(script.Parent.Configuration)

local globalConfiguration = Configuration.new({
	clonedModuleTagName = "HotReloaderClonedModule",
	printFunction = print,
})

return globalConfiguration
