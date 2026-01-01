--[[-------------------------------------------------------------------------
  lua\entities\sf_controller_entity.lua
  SHARED
  Controller entity that manages linked entities and triggers the hack
---------------------------------------------------------------------------]]

ENT.Type = "anim"
ENT.Base = "sf_base_entity"
ENT.PrintName = "Hackable Controller"
ENT.Author = "Zaktak"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Category = "ZK's Slicer Framework"

-----------------------------------------------------------------------------
-- Initialize the entity
-----------------------------------------------------------------------------
function ENT:Initialize()
    self.BaseClass.Initialize(self)

    local mdl = GetConVar("sf_controller_model") and GetConVar("sf_controller_model"):GetString() or self:GetModel()
    if mdl and mdl ~= "" then
        self:SetModel(mdl)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)

        local phys = self:GetPhysicsObject()
        if IsValid(phys) then phys:Wake() end
    else
        self:SetModel("models/props/de_prodigy/desk_console3.mdl")
    end

    local keys = ZKSlicerFramework.Minigames.GetKeys()
    -- Default fallback if registry is empty for some reason
    if #keys == 0 then keys = {"cipher", "sequence", "frequency"} end
    
    local minigames = util.TableToJSON(keys)
    self:SetAllowedMinigames(minigames)
    self:SetDifficulty(1)
    self:SetEType("Controller")
end

-----------------------------------------------------------------------------
-- Helper to parse linked entities from JSON
-- @param ent Entity The controller entity
-- @return table List of CreationIDs
-----------------------------------------------------------------------------
local function GetLinkedEntities(ent)
    local data = ent:GetLinkedEntity() and ent:GetLinkedEntity() or "[]"
    local ok, tbl = pcall(util.JSONToTable, data)
    if ok and istable(tbl) then return tbl end
    return {}
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
        self.BaseClass.StartHack(self, ply) -- Call base to set state and time

        net.Start(ZKSlicerFramework.NetUtils.OpenHackInterface)
        net.WriteEntity(self)
        net.Send(ply)

        hook.Run("ZKSF_StartHack", self, ply)
    end

    -----------------------------------------------------------------------------
    -- Checks if the entity can be hacked
    -- @param ply Player The player attempting the hack
    -- @return boolean
    -----------------------------------------------------------------------------
    function ENT:CanHack(ply)
        if not IsValid(self) then return false end
        if self:GetIsBeingHacked() then return false end
        if self:GetIsCompleted() then return false end
        if self:GetIsDisabled() then return false end
        if not IsValid(ply) then return false end
        local wep = ply:GetActiveWeapon():GetClass()
        if wep ~= "wp_zks_slicer" then return false end

        local linkedEnts = self:GetLinkedEntity()
        if not linkedEnts then return end
        return true
    end

    -----------------------------------------------------------------------------
    -- Called when the hack is successful
    -- @param ply Player The player who succeeded
    -----------------------------------------------------------------------------
    function ENT:OnHackSuccess(ply)
        self:SetIsBeingHacked(false)
        self:SetIsCompleted(true)
        local linkedEnts = GetLinkedEntities(self)
        local remaining = #linkedEnts

        hook.Run("ZKSF_HackSuccess", self, ply, linkedEnts)

        -- Optimized lookup: Stop once we find all linked entities
        if remaining > 0 then
            local toFind = {}
            for _, id in ipairs(linkedEnts) do toFind[id] = true end

            for _, ent in ipairs(ents.GetAll()) do
                local id = ent:GetCreationID()
                if toFind[id] then
                    if IsValid(ent) then
                        if ent.BaseClass and ent.BaseClass.ClassName == "sf_base_entity" then
                            ent:SetIsDisabled(false)
                        else
                            ent:Remove()
                        end
                    end
                    toFind[id] = nil
                    remaining = remaining - 1
                    if remaining <= 0 then break end
                end
            end
        end

        ply:ChatPrint("[HACKING] Hack complete on " .. (self.PrintName or "unknown device"))
    end

    -----------------------------------------------------------------------------
    -- Called when the hack fails
    -- @param ply Player The player who failed
    -----------------------------------------------------------------------------
    function ENT:OnHackFailed(ply)
        self:SetIsBeingHacked(false)
        self:SetIsCompleted(false)
        local linkedEnts = GetLinkedEntities(self) or {}
        hook.Run("ZKSF_HackFailure", self, ply, linkedEnts)
        ply:ChatPrint("[HACKING] Hack failed on " .. (self.PrintName or "unknown device"))
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
