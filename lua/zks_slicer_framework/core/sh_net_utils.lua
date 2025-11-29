
ZKSlicerFramework = ZKSlicerFramework or {}
ZKSlicerFramework.NetUtils = ZKSlicerFramework.NetUtils or {}

local base = "ZKSlicerFramework_"
ZKSlicerFramework.NetUtils = {
    OpenHackInterface = base .. "OpenHackInterface",
    OpenConfigInterface = base .. "OpenConfigInterface",
    SyncEntHackState = base .. "SyncEntHackState",
    HackSuccess = base .. "HackSuccess",
    SyncEntConfig = base .. "SyncEntConfig",
    UpdateDatapadState = base .. "UpdateDatapadState",
}

if SERVER then
    for _, id in pairs(ZKSlicerFramework.NetUtils) do
        util.AddNetworkString(id)
    end
end