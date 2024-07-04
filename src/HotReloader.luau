--!strict
--!native

local globalConfiguration = require(script.Parent.globalConfiguration)
local types = require(script.Parent.types)

type HotReloaderPrototype = types.HotReloaderPrototype
export type HotReloader = types.HotReloader
type Configuration = types.Configuration
type Context = types.Context

local CLONED_MODULE_TAG_NAME = "__HotReloaderClonedModule"

local HotReloader = {}
HotReloader.prototype = {} :: HotReloaderPrototype
HotReloader.prototype.__index = HotReloader.prototype

function HotReloader.new(configuration: Configuration?): HotReloader
	local self = setmetatable({
		_listeners = {},
		_clonedModules = {},
		_configuration = configuration or globalConfiguration,
	}, HotReloader.prototype)

	return self
end

function HotReloader.is(value)
	return type(value) == "table" and getmetatable(value) == HotReloader.prototype
end

function HotReloader.prototype:destroy()
	for _, listener in self._listeners do
		listener:Disconnect()
	end
	table.clear(self._listeners)

	for _, cloned in self._clonedModules do
		cloned:Destroy()
	end
	table.clear(self._clonedModules)
end

--[=[
	Listen to changes from a single module.

	Runs the given `callback` once to start, and then again whenever the module changes.

	Runs the given `cleanup` callback after a module is changed, but before `callback` is run.

	Both are passed a [Context] object, which contains information about the original module
	and whether or not the script is reloading.

	- For `callback`, `Context.isReloading` is true if running as a result of a hot-reload (false indicates first run).
	- For `cleanup`, `Context.isReloading` is true if the module is about to be hot-reloaded (false indicates this is the last cleanup).

	@param module -- The original module to attach listeners to
	@param callback -- A callback that runs when the ModuleScript is added or changed
	@param cleanup -- A callback that runs when the ModuleScript is changed or removed
]=]
function HotReloader.prototype:listen(module, callback, cleanup)
	local configuration = self._configuration

	local moduleChangedConnection = module.Changed:Connect(function()
		local originalStillExists = game:IsAncestorOf(module)

		local cleanupContext = {
			isReloading = originalStillExists,
			originalModule = module,
		}

		if self._clonedModules[module] then
			cleanup(self._clonedModules[module], cleanupContext)
			self._clonedModules[module]:Destroy()
		else
			cleanup(module, cleanupContext)
		end

		if not originalStillExists then
			return
		end

		local cloned = module:Clone()
		cloned:AddTag(CLONED_MODULE_TAG_NAME)
		cloned:AddTag(configuration.props.clonedModuleTagName)
		cloned.Parent = module.Parent
		self._clonedModules[module] = cloned

		callback(cloned, {
			originalModule = module,
			isReloading = true,
		})

		configuration.props.printFunction(`HotReloaded {module:GetFullName()}!`)
	end)

	table.insert(self._listeners, moduleChangedConnection)

	callback(module, {
		originalModule = module,
		isReloading = false,
	})

	return function()
		local index = table.find(self._listeners, moduleChangedConnection)
		if not index then
			return
		end

		table.remove(self._listeners, index)
	end
end

--[=[
	Scans current and new descendants of an object for ModuleScripts, and runs `callback` for each of them.

	This function has the same semantics as [HotReloader:listen].

	@param container -- The root instance
	@param callback -- A callback that runs when the ModuleScript is added or changed
	@param cleanup -- A callback that runs when the ModuleScript is changed or removed
]=]
function HotReloader.prototype:scan(
	container: Instance,
	callback: (ModuleScript, Context) -> (),
	cleanup: (ModuleScript, Context) -> ()
)
	local configuration = self._configuration
	local listenCleanupFunctions = {}

	local function add(module)
		local cleanup = self:listen(module, callback, cleanup)

		table.insert(listenCleanupFunctions, cleanup)
	end

	for _, instance in container:GetDescendants() do
		if instance:IsA("ModuleScript") then
			add(instance)
		end
	end

	local descendantAddedConnection = container.DescendantAdded:Connect(function(instance)
		if
			instance:IsA("ModuleScript")
			and not instance:HasTag(CLONED_MODULE_TAG_NAME)
			and not instance:HasTag(configuration.props.clonedModuleTagName)
		then
			add(instance)
		end
	end)

	table.insert(self._listeners, descendantAddedConnection)

	return function()
		local index = table.find(self._listeners, descendantAddedConnection)
		if not index then
			return
		end

		table.remove(self._listeners, index)

		for _, cleanup in listenCleanupFunctions do
			cleanup()
		end
	end
end

return HotReloader
