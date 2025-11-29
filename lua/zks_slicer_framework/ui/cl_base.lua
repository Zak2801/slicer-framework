
ZKSlicerFramework = ZKSlicerFramework or {}
ZKSlicerFramework.UI = ZKSlicerFramework.UI or {}

function ZKSlicerFramework.UI.OpenConfig(ent)
    if not IsValid(ent) then return end
    if IsValid(ZKSlicerFramework.UI.ConfigFrame) then ZKSlicerFramework.UI.ConfigFrame:Remove() end

    local frame = vgui.Create("HackConfigPanel")
    frame:SetEntity(ent)
    frame:MakePopup()
    ZKSlicerFramework.UI.ConfigFrame = frame
end

function ZKSlicerFramework.UI.OpenHackFrame(ent)
    if not IsValid(ent) then return end
    if IsValid(ZKSlicerFramework.UI.HackFrame) then ZKSlicerFramework.UI.HackFrame:Remove() end

    local hackTime = ent:GetHackTime()
    local hackType = ent:GetClass()
    local difficulty = ent:GetDifficulty()
    local m = ent:GetAllowedMinigames()
    local minigames = util.JSONToTable(m) or {}
    local frame = vgui.Create("HackHackingFrame")
    frame:SetEntity(ent)
    frame:SetHackTime(hackTime)
    frame:SetDifficulty(difficulty)
    frame:SetAllowedMinigames(minigames)
    frame:SetHackType(hackType) -- Calls start
    frame:MakePopup()
    ZKSlicerFramework.UI.HackFrame = frame
end