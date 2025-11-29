if not CLIENT then return end

ZKSlicerFramework = ZKSlicerFramework or {}
ZKSlicerFramework.NetUtils = ZKSlicerFramework.NetUtils or {}
ZKSlicerFramework.UI = ZKSlicerFramework.UI or {}

net.Receive(ZKSlicerFramework.NetUtils.OpenHackInterface, function()
    local ply = LocalPlayer()
    if !IsValid(ply) then return end
    local hackableEntity = net.ReadEntity()
    if !IsValid(hackableEntity) then return end

    ZKSlicerFramework.UI.OpenHackFrame(hackableEntity)
end)

net.Receive(ZKSlicerFramework.NetUtils.OpenConfigInterface, function()
    local ply = LocalPlayer()
    if !IsValid(ply) then return end
    local hackableEntity = net.ReadEntity()
    if !IsValid(hackableEntity) then return end
    ZKSlicerFramework.UI.OpenConfig(hackableEntity)
end)