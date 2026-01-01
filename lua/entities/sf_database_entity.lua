--[[-------------------------------------------------------------------------
  lua\entities\sf_database_entity.lua
  SHARED
  Hackable database entity that yields a datapad reward
---------------------------------------------------------------------------]]

ENT.Type = "anim"
ENT.Base = "sf_base_entity"
ENT.PrintName = "Hackable Database"
ENT.Author = "Zaktak"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Category = "[SlicerFramework] - Base Entities"

DEFINE_BASECLASS("sf_base_entity")

ZKSlicerFramework = ZKSlicerFramework or {}
ZKSlicerFramework.NetUtils = ZKSlicerFramework.NetUtils or {}
ZKSlicerFramework.Minigames = ZKSlicerFramework.Minigames or {}

-----------------------------------------------------------------------------
-- Setup data tables
-----------------------------------------------------------------------------
function ENT:SetupDataTables()
    BaseClass.SetupDataTables(self)
    self:NetworkVar("Int", 2, "EmitDatapad")    -- Datapad to give on success
end

-----------------------------------------------------------------------------
-- Initialize the entity
-----------------------------------------------------------------------------
function ENT:Initialize()
    BaseClass.Initialize(self)

    local mdl = GetConVar("sf_database_model") and GetConVar("sf_database_model"):GetString() or self:GetModel()
    if mdl and mdl ~= "" then
        self:SetModel(mdl)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)

        local phys = self:GetPhysicsObject()
        if IsValid(phys) then phys:Wake() end
    end

    -- Dynamic minigame loading
    local keys = ZKSlicerFramework.Minigames.GetKeys and ZKSlicerFramework.Minigames.GetKeys() or {}
    -- Default fallback if registry is empty
    if #keys == 0 then keys = {"cipher", "sequence", "frequency"} end
    
    local minigames = util.TableToJSON(keys)
    self:SetAllowedMinigames(minigames)
    self:SetEmitDatapad(0)
    self:SetEType("Database")
end


if SERVER then
    AddCSLuaFile()

    -----------------------------------------------------------------------------
    -- Called when a player presses E on the entity
    -- @param activator Entity The entity activating it (player)
    -- @param caller Entity The entity calling the use
    -----------------------------------------------------------------------------
    function ENT:Use(activator, caller)
        if not IsValid(activator) or not activator:IsPlayer() then return end
        
        if self:CanOpenConfig(activator) and not self:CanHack(activator) then
            self:OpenConfigMenu(activator)
            return
        end

        if self:GetIsBeingHacked() then return end
        -- Start hack attempt
        self:StartHack(activator)
    end

    -- ==========================
    -- HACK FLOW
    -- ==========================

    -----------------------------------------------------------------------------
    -- Starts the hacking process
    -- @param ply Player The player starting the hack
    -----------------------------------------------------------------------------
    function ENT:StartHack(ply)
        if not self:CanHack(ply) then return end
        
        -- Call base to set state (IsBeingHacked) and HackStartTime
        BaseClass.StartHack(self, ply)

        net.Start(ZKSlicerFramework.NetUtils.OpenHackInterface)
        net.WriteEntity(self)
        net.Send(ply)

        -- Base class handles ZKSF_OnStartHack hook
    end

    -----------------------------------------------------------------------------
    -- Called when the hack is successful
    -- @param ply Player The player who succeeded
    -----------------------------------------------------------------------------
    function ENT:OnHackSuccess(ply)
        self:SetIsBeingHacked(false)
        self:SetIsCompleted(true)

        if self:GetEmitDatapad() ~= 0 then
            local datapad = ents.Create("sf_datapad")
            if IsValid(datapad) then
                datapad:SetPos(self:GetForward() * 30 + self:GetUp() * 10 + self:GetPos())
                datapad:Spawn()
                datapad:Activate()
                ply:ChatPrint("[CONSOLE] You have received a datapad!")
                
                -- Call standard base logic (prints success msg and runs global hook)
                BaseClass.OnHackSuccess(self, ply) 
                
                -- Additional hook for datapad specifically? 
                -- or just rely on the global hook. 
                -- We'll just stick to base class behavior for consistency.
                return
            end
        end
        
        BaseClass.OnHackSuccess(self, ply)
    end

    -----------------------------------------------------------------------------
    -- Called when the hack fails
    -- @param ply Player The player who failed
    -----------------------------------------------------------------------------
    function ENT:OnHackFailed(ply)
        self:SetIsBeingHacked(false)
        self:SetIsCompleted(false)
        
        BaseClass.OnHackFailed(self, ply)
    end

    -----------------------------------------------------------------------------
    -- Opens the configuration menu
    -- @param ply Player The admin player
    -----------------------------------------------------------------------------
    function ENT:OpenConfigMenu(ply)
        net.Start(ZKSlicerFramework.NetUtils.OpenConfigInterface)
        net.WriteEntity(self)
        net.Send(ply)
    end
end