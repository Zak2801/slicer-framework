--[[-------------------------------------------------------------------------
  lua\entities\sf_base_entity.lua
  SHARED
  Base entity for all hackable devices in the framework
---------------------------------------------------------------------------]]

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Base"
ENT.Author = "Zaktak"
ENT.Spawnable = false
ENT.AdminSpawnable = true
ENT.Category = "ZK's Slicer Framework"
ENT.IsZKSlicerEntity = true

ZKSlicerFramework = ZKSlicerFramework or {}

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "Difficulty")         -- affects hack time / chance
    self:NetworkVar("Int", 1, "HackTime")           -- total seconds to hack
    self:NetworkVar("Bool", 0, "IsBeingHacked")
    self:NetworkVar("Bool", 1, "IsCompleted")
    self:NetworkVar("Bool", 2, "IsDisabled")
    self:NetworkVar("String", 0, "LinkedEntity")    -- optional target (for controllers)
    self:NetworkVar("String", 1, "AllowedMinigames")
    self:NetworkVar("String", 2, "EType")
end

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/props_combine/breenconsole.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)

        local phys = self:GetPhysicsObject()
        if IsValid(phys) then phys:Wake() end

        self:SetDifficulty(1)
        self:SetHackTime(0)
        self:SetIsCompleted(false)
        self:SetIsBeingHacked(false)
        self:SetIsDisabled(false)
    end
    if CLIENT then
        self:SetEType("Base")
    end
end

if CLIENT then
    function ENT:Draw(flags)
        self:DrawModel(flags)

        local ply = LocalPlayer()
        if not IsValid(ply) then return end

        if ply:GetPos():DistToSqr(self:GetPos()) > 500 * 500 then return end

        local pos = self:GetPos() + Vector(0,0,35)

        -- Rotate text to face the player
        local ang = (ply:EyePos() - self:GetPos()):Angle()
        ang:RotateAroundAxis(ang:Right(), 90)
        ang:RotateAroundAxis(ang:Up(), 90)
        
        cam.Start3D2D(pos, Angle(0, ang.y, 90), 0.08)

            draw.SimpleTextOutlined(
                string.upper(language.GetPhrase("zksf.status.hackable") .. " " .. self:GetEType()),
                "ZKSlicerFramework.UI.Primary",
                0, 0,
                Color(255, 255, 255, 255),
                TEXT_ALIGN_CENTER,
                TEXT_ALIGN_TOP,
                1,
                Color(0, 0, 0, 255)
            )

            local txt = language.GetPhrase("zksf.status.available")
            local col = Color(255,100,0)
            if self:GetIsCompleted() then
                txt = language.GetPhrase("zksf.status.hacked")
                col = Color(0,255,0)
            elseif self:GetIsBeingHacked() then 
                txt = language.GetPhrase("zksf.status.unavailable")
                col = Color(255,50,0)
            elseif self:GetIsDisabled() then 
                txt = language.GetPhrase("zksf.status.locked")
                col = Color(0,50,250)
            end

            draw.SimpleTextOutlined(
                string.upper(txt),
                "ZKSlicerFramework.UI.PrimaryItalic",
                0, 40,
                col,
                TEXT_ALIGN_CENTER,
                TEXT_ALIGN_TOP,
                1,
                Color(0, 0, 0, 255)
            )

        cam.End3D2D()
    end
end

if SERVER then
    AddCSLuaFile()

    -- Called when a player presses E on the entity
    function ENT:Use(activator, caller)
        if not IsValid(activator) or not activator:IsPlayer() then return end
        if self:GetIsBeingHacked() then return end

        -- Example: staff config access
        if self:CanOpenConfig(activator) and activator:KeyDown(IN_RELOAD) then
            self:OpenConfigMenu(activator)
            return
        end

        -- Start hack attempt
        self:StartHack(activator)
    end

    -----------------------------------------------------------------------------
    -- Checks if a player can open the configuration menu
    -- @param ply Player The player to check
    -- @return boolean Returns true if allowed
    -----------------------------------------------------------------------------
    function ENT:CanOpenConfig(ply)
        -- Override in derived entities if needed
        if not IsValid(self) then return false end
        if not IsValid(ply) then return false end
        if not ZKSlicerFramework then return false end
        return ZKSlicerFramework.CanConfigure(ply)
    end

    -- ==========================
    -- HACK FLOW
    -- ==========================

    -----------------------------------------------------------------------------
    -- Checks if a player can hack this entity
    -- @param ply Player The player attempting to hack
    -- @return boolean Returns true if hackable
    -----------------------------------------------------------------------------
    function ENT:CanHack(ply)
        -- Override in derived entities if needed
        if not IsValid(self) then return false end
        if self:GetIsBeingHacked() then return false end
        if self:GetIsCompleted() then return false end
        if self:GetIsDisabled() then return false end
        if not IsValid(ply) then return false end
        local wep = ply:GetActiveWeapon():GetClass()
        if wep ~= "wp_zks_slicer" then return false end
        return true
    end

    -----------------------------------------------------------------------------
    -- Starts the hacking process
    -- @param ply Player The player starting the hack
    -- @return nil
    -----------------------------------------------------------------------------
    function ENT:StartHack(ply)
        if not self:CanHack(ply) then return end
        self:SetIsBeingHacked(true)
        self.HackStartTime = CurTime()
        hook.Run("ZKSF_OnStartHack", self, ply)
    end

    -----------------------------------------------------------------------------
    -- Called when a hack is successfully completed
    -- @param ply Player The player who completed the hack
    -- @return nil
    -----------------------------------------------------------------------------
    function ENT:OnHackSuccess(ply)
        -- Override in derived entities
        net.Start(ZKSlicerFramework.NetUtils.Notification)
        net.WriteBool(true)
        net.WriteEntity(self)
        net.Send(ply)
        hook.Run("ZKSF_OnHackSuccess", self, ply)
    end

    -----------------------------------------------------------------------------
    -- Called when a hack fails
    -- @param ply Player The player who failed the hack
    -- @return nil
    -----------------------------------------------------------------------------
    function ENT:OnHackFailed(ply)
        -- Override in derived entities
        net.Start(ZKSlicerFramework.NetUtils.Notification)
        net.WriteBool(false)
        net.WriteEntity(self)
        net.Send(ply)
        hook.Run("ZKSF_OnHackFailed", self, ply)
    end

    -- Admin config (basic)
    function ENT:OpenConfigMenu(ply)
        --
    end

    -- Optional persistence / cleanup
    function ENT:OnRemove()
        if self:GetIsBeingHacked() then
            self:SetIsBeingHacked(false)
        end
    end
end