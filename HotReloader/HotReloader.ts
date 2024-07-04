import { RunService } from "@rbxts/services";

export type Context = {
	originalModule: ModuleScript;
	isReloading: boolean;
};

export class HotReloader {
	private listeners = new Array<RBXScriptConnection>();

	// OriginalModule: ClonedModule
	private clonedModules = new Map<ModuleScript, ModuleScript>();

	listen(
		module: ModuleScript,
		callback: (module: ModuleScript, context: Context) => void,
		cleanup: (module: ModuleScript, context: Context) => void,
	) {
		callback(module, {
			originalModule: module,
			isReloading: false,
		});

		if (RunService.IsStudio()) {
			const moduleChanged = (module.Changed as RBXScriptSignal).Connect(() => {
				const originalStillExists = game.IsAncestorOf(module);

				const cleanupContext = {
					originalModule: module,
					isReloading: originalStillExists,
				};

				const clonedModule = this.clonedModules.get(module);
				if (clonedModule) {
					cleanup(clonedModule, cleanupContext);
				} else {
					cleanup(module, cleanupContext);
				}

				if (!originalStillExists) return;

				const cloned = module.Clone();
				cloned.AddTag("HotReloadTarget");
				cloned.Parent = module.Parent;

				this.clonedModules.set(module, cloned);

				callback(cloned, {
					originalModule: module,
					isReloading: true,
				});

				warn(`HotReloaded ${module.GetFullName()}`);
			});

			this.listeners.push(moduleChanged);

			return () => {
				const index = this.listeners.findIndex(
					(listener) => listener === moduleChanged,
				);
				this.listeners.remove(index);
				moduleChanged.Disconnect();

				const cloned = this.clonedModules.get(module);
				cloned?.Destroy();
			};
		}

		return () => {};
	}

	destroy() {
		for (const listener of this.listeners) {
			listener.Disconnect();
		}
		this.listeners.clear();

		for (const [_, cloned] of this.clonedModules) {
			cloned.Destroy();
		}
		this.clonedModules.clear();
	}
}
