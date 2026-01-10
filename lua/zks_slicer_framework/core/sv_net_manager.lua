--[[-------------------------------------------------------------------------
  lua\zks_slicer_framework\core\sv_net_manager.lua
  SERVER
  Server-side network manager for handling entity synchronization and events
---------------------------------------------------------------------------]]

if not SERVER then return end

ZKSlicerFramework = ZKSlicerFramework or {}
ZKSlicerFramework.NetUtils = ZKSlicerFramework.NetUtils or {}

-----------------------------------------------------------------------------
-- Called from client to sync the state of IsBeingHacked
-- @param len number Length of the message (unused)
-- @param ply Player The player sending the message
-- @return nil
-----------------------------------------------------------------------------
net.Receive(ZKSlicerFramework.NetUtils.SyncEntHackState, function(_, ply)
    local ent = net.ReadEntity()
    if not ent then return end
    if not ZKSlicerFramework.IsSlicerEntity(ent) then return end

    -- Distance check (approx 200 units)
    if ent:GetPos():DistToSqr(ply:GetPos()) > 40000 then return end
    
    local state = net.ReadBool() or false
    local complete = net.ReadBool()
    
    ent:SetIsBeingHacked(state)
    if complete ~= nil then
        ent:SetIsCompleted(complete)
    end
end)

-----------------------------------------------------------------------------
-- Called from client to call hack complete
-- @param len number Length of the message (unused)
-- @param ply Player The player sending the message
-- @return nil
-----------------------------------------------------------------------------
net.Receive(ZKSlicerFramework.NetUtils.HackSuccess, function(_, ply)
    local ent = net.ReadEntity()
    if not ent then return end
    if not ZKSlicerFramework.IsSlicerEntity(ent) then return end

    -- 1. Distance check
    if ent:GetPos():DistToSqr(ply:GetPos()) > 40000 then return end

    -- 2. Weapon check
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) or wep:GetClass() ~= "wp_zks_slicer" then return end

    -- 3. Timing check (prevent instant hack or over the max hack)
    local startTime = ent.HackStartTime or 0
    if CurTime() - startTime < 1.2 then return end

    local maxTime = ent:GetHackTime()
    if maxTime and maxTime > 0 then
        if CurTime() - startTime > maxTime + 1 then return end
    end
    
    ent:OnHackSuccess(ply)
end)

-----------------------------------------------------------------------------
-- Called from client to sync the config of an entity
-- @param len number Length of the message (unused)
-- @param ply Player The player sending the message
-- @return nil
-----------------------------------------------------------------------------
net.Receive(ZKSlicerFramework.NetUtils.SyncEntConfig, function(_, ply)
    local ent = net.ReadEntity()
    if not ent then return end
    if not ZKSlicerFramework.IsSlicerEntity(ent) then return end

    -- Permission check
    if not ZKSlicerFramework.CanConfigure(ply) then return end
    
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