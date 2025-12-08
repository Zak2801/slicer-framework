if not SERVER then return end

ZKSlicerFramework = ZKSlicerFramework or {}
ZKSlicerFramework.NetUtils = ZKSlicerFramework.NetUtils or {}


------------------------------------------------------------------------------------
--  Helper function to validate entity
------------------------------------------------------------------------------------
local function checkEntityFramework(ent)
    if IsValid(ent) then
        if ent.BaseClass then
             if ent.BaseClass.ClassName == "sf_base_entity" then
                return true
             end
        end
    end
    return false
end

------------------------------------------------------------------------------------
--  Called from client to sync the state of IsBeingHacked
------------------------------------------------------------------------------------
net.Receive(ZKSlicerFramework.NetUtils.SyncEntHackState, function(_, ply)
    local ent = net.ReadEntity()
    if !ent then return end
    if !checkEntityFramework(ent) then return end
    local state = net.ReadBool() or false
    local complete = net.ReadBool()
    ent:SetIsBeingHacked(state)
    if complete ~= nil then
        ent:SetIsCompleted(complete)
    end
end)

------------------------------------------------------------------------------------
--  Called from client to call hack complete
------------------------------------------------------------------------------------
net.Receive(ZKSlicerFramework.NetUtils.HackSuccess, function(_, ply)
    local ent = net.ReadEntity()
    if !ent then return end
    if !checkEntityFramework(ent) then return end
    ent:OnHackSuccess(ply)
end)

------------------------------------------------------------------------------------
--  Called from client to sync the config of an entity
------------------------------------------------------------------------------------
net.Receive(ZKSlicerFramework.NetUtils.SyncEntConfig, function(_, ply)
    local ent = net.ReadEntity()
    if !ent then return end
    if !checkEntityFramework(ent) then return end

    local diffi = net.ReadInt(8)
    local hackTime = net.ReadInt(32)
    local shouldEmitDatapad = net.ReadBool()
    
    ent:SetDifficulty(diffi)
    ent:SetHackTime(hackTime)

    local succ, err = pcall(function() ent:GetEmitDatapad() end)
    if succ then
        ent:SetEmitDatapad(shouldEmitDatapad and 1 or 0)
    end
    
    ent:SetOwner(ply)
end)