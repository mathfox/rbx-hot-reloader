--!strict
--!native
--!optimize 2

local moduleCleanupCallbacks: { [string]: { () -> () } } = {}

return moduleCleanupCallbacks
