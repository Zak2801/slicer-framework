-- ====================================================================================
-- FILE: lua\entities\sf_database_entity.lua
-- ====================================================================================

ENT.Type = "anim"
ENT.Base = "sf_base_entity"
ENT.PrintName = "Hackable Database"
ENT.Author = "Zaktak"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Category = "ZK's Slicer Framework"


function ENT:SetupDataTables()
    self.BaseClass.SetupDataTables(self)
    self:NetworkVar("Int", 2, "EmitDatapad")    -- Datapad to give on success
end

function ENT:Initialize()
    self.BaseClass.Initialize(self)

    local mdl = GetConVar("sf_database_model") and GetConVar("sf_database_model"):GetString() or self:GetModel()
    if mdl and mdl ~= "" then
        self:SetModel(mdl)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)

        local phys = self:GetPhysicsObject()
        if IsValid(phys) then phys:Wake() end
    end

    local minigames = util.TableToJSON({"cipher", "sequence", "frequency"})
    self:SetAllowedMinigames(minigames)
    self:SetEmitDatapad(0)
    self:SetEType("Database")
end


if SERVER then
    AddCSLuaFile()

    -- Called when a player presses E on the entity
    function ENT:Use(activator, caller)
        if not IsValid(activator) or not activator:IsPlayer() then return end
        
        if self:CanOpenConfig(activator) and !self:CanHack(activator) then
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

    function ENT:OnHackSuccess(ply)
        self:SetIsBeingHacked(false)
        self:SetIsCompleted(true)
        ply:ChatPrint("[HACKING] Hack complete on " .. (self.PrintName or "unknown device"))

        if self:GetEmitDatapad() ~= 0 then
            local datapad = ents.Create("sf_datapad")
            if IsValid(datapad) then
                datapad:SetPos(self:GetForward() * 30 + self:GetUp() * 10 + self:GetPos())
                datapad:Spawn()
                datapad:Activate()
                ply:ChatPrint("[CONSOLE] You have received a datapad!")
                hook.Run("ZKSF_HackSuccess", self, ply, {datapad})
                return
            end
        end
        hook.Run("ZKSF_HackSuccess", self, ply)
    end

    function ENT:OnHackFailed(ply)
        self:SetIsBeingHacked(false)
        self:SetIsCompleted(false)
        hook.Run("ZKSF_HackFailure", self, ply)
        ply:ChatPrint("[HACKING] Hack failed on " .. (self.PrintName or "unknown device"))
    end

    -- Admin config (basic)
    function ENT:OpenConfigMenu(ply)
        net.Start(ZKSlicerFramework.NetUtils.OpenConfigInterface)
        net.WriteEntity(self)
        net.Send(ply)
    end
end

