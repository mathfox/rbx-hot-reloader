--!strict

export type Context = {
	originalModule: ModuleScript,
	isReloading: boolean,
}

export type ConfigurationProps = {
	clonedModuleTagName: string,
	printFunction: (message: string) -> (),
}

export type ConfigurationPrototype = {
	__index: ConfigurationPrototype,
}

export type Configuration = typeof(setmetatable(
	{} :: {
		props: ConfigurationProps,
	},
	(nil :: any) :: ConfigurationPrototype
))

export type CleanupFunction = () -> ()

export type HotReloaderPrototype = {
	__index: HotReloaderPrototype,

	destroy: (self: HotReloader) -> (),

	listen: (
		self: HotReloader,
		module: ModuleScript,
		callback: (newModule: ModuleScript, context: Context) -> (),
		cleanup: (previousModule: ModuleScript, context: Context) -> ()
	) -> CleanupFunction,

    scan: (
		self: HotReloader,
		container: Instance,
		callback: (newModule: ModuleScript, context: Context) -> (),
		cleanup: (previousModule: ModuleScript, context: Context) -> ()
	) -> CleanupFunction,
}

export type HotReloader = typeof(setmetatable(
	{} :: {
		_configuration: Configuration,

		_listeners: { RBXScriptConnection },
		--[[
            OriginalModule: ClonedModule
        ]]
		_clonedModules: { [ModuleScript]: ModuleScript },
	},
	(nil :: any) :: HotReloaderPrototype
))

return nil
