-- ====================================================================================
-- FILE: lua\entities\sf_controller_entity.lua
-- ====================================================================================

ENT.Type = "anim"
ENT.Base = "sf_base_entity"
ENT.PrintName = "Hackable Controller"
ENT.Author = "Zaktak"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Category = "ZK's Slicer Framework"


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

    local minigames = util.TableToJSON({"cipher", "sequence", "frequency"})
    self:SetAllowedMinigames(minigames)
    self:SetDifficulty(1)
    self:SetEType("Controller")
end

local function GetLinkedEntities(ent)
    local data = ent:GetLinkedEntity() and ent:GetLinkedEntity() or "[]"
    local ok, tbl = pcall(util.JSONToTable, data)
    if ok and istable(tbl) then return tbl end
    return {}
end

if SERVER then
    AddCSLuaFile()

    -- Called when a player presses E on the entity
    function ENT:Use(activator, caller)
        if not IsValid(activator) or not activator:IsPlayer() then return end

        if self:CanOpenConfig(activator) and !self:CanHack(activator) then --  and activator:KeyDown(IN_RELOAD)?
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
    function ENT:StartHack(ply)
        if not self:CanHack(ply) then return end
        self:SetIsBeingHacked(true)

        net.Start(ZKSlicerFramework.NetUtils.OpenHackInterface)
        net.WriteEntity(self)
        net.Send(ply)

        hook.Run("ZKSF_StartHack", self, ply)

        -- Are we timed here?
        if self:GetHackTime() > 0 then
            timer.Simple(self:GetHackTime(), function() -- TODO: Is there any use for this?
                if not IsValid(self) then return end
            end)
        end
    end

    function ENT:CanHack(ply)
        if !IsValid(self) then return false end
        if self:GetIsBeingHacked() then return false end
        if self:GetIsCompleted() then return false end
        if self:GetIsDisabled() then return false end
        if !IsValid(ply) then return false end
        local wep = ply:GetActiveWeapon():GetClass()
        if wep ~= "wp_zks_slicer" then return false end

        local linkedEnts = self:GetLinkedEntity()
        if !linkedEnts then return end
        return true
    end

    function ENT:OnHackSuccess(ply)
        self:SetIsBeingHacked(false)
        self:SetIsCompleted(true)
        local linkedEnts = GetLinkedEntities(self)

        hook.Run("ZKSF_HackSuccess", self, ply, linkedEnts)

        for _, ent in ipairs(ents.GetAll()) do
            if table.HasValue(linkedEnts, ent:GetCreationID()) then
                if IsValid(ent) then
                    -- If the entity is a hackable entity, let's allow it to be hacked now.
                    if ent.BaseClass and ent.BaseClass.ClassName == "sf_base_entity" then
                        ent:SetIsDisabled(false)
                    else
                        ent:Remove()
                    end
                end
                table.remove(linkedEnts, table.KeyFromValue(linkedEnts, ent:GetCreationID()))
            end
        end
        ply:ChatPrint("[HACKING] Hack complete on " .. (self.PrintName or "unknown device"))
    end

    function ENT:OnHackFailed(ply)
        self:SetIsBeingHacked(false)
        self:SetIsCompleted(false)
        local linkedEnts = GetLinkedEntities(self) or {}
        hook.Run("ZKSF_HackFailure", self, ply, linkedEnts)
        ply:ChatPrint("[HACKING] Hack failed on " .. (self.PrintName or "unknown device"))
    end

    -- Admin config (basic)
    function ENT:OpenConfigMenu(ply)
        net.Start(ZKSlicerFramework.NetUtils.OpenConfigInterface)
        net.WriteEntity(self)
        net.Send(ply)
    end
end