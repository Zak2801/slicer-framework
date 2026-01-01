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

net.Receive(ZKSlicerFramework.NetUtils.Notification, function()
    local success = net.ReadBool()
    local ent = net.ReadEntity()
    local entName = IsValid(ent) and (ent.PrintName or "Unknown") or "Unknown"

    if success then
        notification.AddLegacy(string.format(language.GetPhrase("zksf.hack.complete"), entName), NOTIFY_GENERIC, 5)
        surface.PlaySound("buttons/button14.wav")
    else
        notification.AddLegacy(string.format(language.GetPhrase("zksf.hack.failed"), entName), NOTIFY_ERROR, 5)
        surface.PlaySound("buttons/button10.wav")
    end
end)