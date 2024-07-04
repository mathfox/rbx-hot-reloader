export type Context = {
	originalModule: ModuleScript;
	isReloading: boolean;
};

export type ConfigurationProps = {
	clonedModuleTagName: string;
    printFunction: (message: string) => void;
};

export declare class Configuration {
    static is: (value: unknown) => value is Configuration

	props: ConfigurationProps;
}

export type CleanupFunction = () => void

export declare class HotReloader {
    static is: (value: unknown) => value is HotReloader

    _configuration: Configuration;

	_listeners: Array<RBXScriptConnection>;

	_clonedModules: Map<ModuleScript, ModuleScript>;

	listen(
		module: ModuleScript,
		callback: (newModule: ModuleScript, context: Context) => void,
		cleanup: (previousModule: ModuleScript, context: Context) => void,
	): CleanupFunction

    scan(
		container: ModuleScript,
		callback: (newModule: ModuleScript, context: Context) => void,
		cleanup: (previousModule: ModuleScript, context: Context) => void,
	): CleanupFunction
}
