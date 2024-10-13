import type { Configuration } from "./Configuration";
import type { Context, CleanupFunction } from "./types";

export declare class HotReloader {
	constructor(configuration?: Configuration);

	static is: (value: unknown) => value is HotReloader;

	readonly _configuration: Configuration;

	readonly _listeners: Map<Instance, RBXScriptConnection>;

	readonly _clonedModules: Map<ModuleScript, ModuleScript>;

	listen(
		module: ModuleScript,
		callback: (newModule: ModuleScript, context: Context) => void,
		cleanup: (previousModule: ModuleScript, context: Context) => void,
	): CleanupFunction;

	scan(
		container: Instance,
		callback: (newModule: ModuleScript, context: Context) => void,
		cleanup: (previousModule: ModuleScript, context: Context) => void,
	): CleanupFunction;
}
