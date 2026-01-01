-- ====================================================================================
-- FILE: lua\entities\sf_datapad.lua
-- ====================================================================================
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Slicer Framework Datapad"
ENT.Author = "Zaktak"
ENT.Spawnable = false
ENT.AdminSpawnable = true
ENT.Category = "[SlicerFramework] - Base Entities"

ZKSlicerFramework = ZKSlicerFramework or {}
ZKSlicerFramework.NetUtils = ZKSlicerFramework.NetUtils or {}
ZKSlicerFramework.Functions = ZKSlicerFramework.Functions or {}

if SERVER then
    function ZKSlicerFramework.Functions.UpdateDatapad(ply, state)
        ply._ZKS_HasDatapad = state
        net.Start(ZKSlicerFramework.NetUtils.UpdateDatapadState)
        net.WriteBool(state)
        net.Send(ply)
    end

    function ENT:Initialize()
        local mdl = GetConVar("sf_datapad_model") and GetConVar("sf_datapad_model"):GetString() or self:GetModel()
        if mdl and mdl ~= "" then
            self:SetModel(mdl)
        else
            self:SetModel("models/maxofs2d/hover_rings.mdl")
        end
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)

        local phys = self:GetPhysicsObject()
        if IsValid(phys) then phys:Wake() end
    end
end


function ENT:Use(activator)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    if activator._ZKS_HasDatapad == true then
        activator:ChatPrint("You already have a datapad!")
        return
    end

    activator:ChatPrint("Picked up a datapad.")
    activator._ZKS_HasDatapad = true
    ZKSlicerFramework.Functions.UpdateDatapad(activator, true)

    -- Mark target
    local target = activator

    -- Make ALL existing NPCs hate the player
    for _, npc in ipairs(ents.FindByClass("npc_*")) do
        if IsValid(npc) and npc.AddEntityRelationship then
            npc:AddEntityRelationship(target, D_HT, 99) -- Hate, highest priority
        end
    end

    -- Make ALL FUTURE NPCs also hate him
    hook.Add("OnEntityCreated", "ZK_SF_Datapad_Aggro", function(ent)
        if not IsValid(ent) or not ent:IsNPC() then return end
        if target._ZKS_HasDatapad ~= true then return end

        timer.Simple(0.1, function()
            if IsValid(ent) and IsValid(target) and ent.AddEntityRelationship then
                ent:AddEntityRelationship(target, D_HT, 99)
            end
        end)
    end)

    hook.Run("ZK_SF_Datapad_PlayerMarked", target)
    self:Remove()
end


hook.Add("PlayerSay", "ZK_SF_Datapad_Check", function(ply, text)
    text = string.lower(text)
    if text == "!hasdatapad" then
        if ply._ZKS_HasDatapad then
            ply:ChatPrint("You have a datapad.")
        else
            ply:ChatPrint("You do NOT have a datapad.")
        end
        return ""
    elseif text == "!dropdatapad" then
        if not ply._ZKS_HasDatapad then
            ply:ChatPrint("You do not have a datapad to drop.")
            return ""
        end
        local datapad = ents.Create("sf_datapad")
        if IsValid(datapad) then
            datapad:SetPos(ply:GetForward() * 35 + ply:GetUp() * 5 + ply:GetPos())
            datapad:Spawn()
            datapad:Activate()
        end
        ZKSlicerFramework.Functions.UpdateDatapad(ply, false)
        ply._ZKS_HasDatapad = nil
        hook.Remove("OnEntityCreated", "ZK_SF_Datapad_Aggro")
        ply:ChatPrint("Your datapad has been dropped.")
        return ""
    end
end)

hook.Add("PostPlayerDeath", "ZK_SF_Datapad_Death", function(ply)
    if ply._ZKS_HasDatapad then
        local datapad = ents.Create("sf_datapad")
        if IsValid(datapad) then
            datapad:SetPos(ply:GetForward() * 35 + ply:GetUp() * 5 + ply:GetPos())
            datapad:Spawn()
            datapad:Activate()
        end
        ZKSlicerFramework.Functions.UpdateDatapad(ply, false)
        ply._ZKS_HasDatapad = nil
        hook.Remove("OnEntityCreated", "ZK_SF_Datapad_Aggro")
        ply:ChatPrint("Your datapad has been dropped.")
    end
end)