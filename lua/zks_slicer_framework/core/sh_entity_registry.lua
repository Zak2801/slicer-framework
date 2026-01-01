--[[-------------------------------------------------------------------------
  lua\zks_slicer_framework\core\sh_entity_registry.lua
  SHARED
  Registers pre-configured entity tiers for easier admin usage
---------------------------------------------------------------------------]]

local Tiers = {
    {
        Id = "easy",
        Name = "Easy",
        Difficulty = 1,
        HackTime = 15,
        EmitDatapad = 0,
        SortOrder = 1
    },
    {
        Id = "medium",
        Name = "Medium",
        Difficulty = 2,
        HackTime = 45,
        EmitDatapad = 0,
        SortOrder = 2
    },
    {
        Id = "hard",
        Name = "Hard",
        Difficulty = 3,
        HackTime = 90,
        EmitDatapad = 1, -- Hard databases give datapad
        SortOrder = 3
    },
    {
        Id = "expert",
        Name = "Expert",
        Difficulty = 4,
        HackTime = 180,
        EmitDatapad = 1,
        SortOrder = 4
    }
}

-- Register Controller Tiers
for _, tier in ipairs(Tiers) do
    local ENT = {}
    ENT.Base = "sf_controller_entity"
    ENT.PrintName = "Controller (" .. tier.Name .. ")"
    ENT.Category = "[SlicerFramework] - Premade"
    ENT.Spawnable = true
    ENT.AdminSpawnable = true

    function ENT:Initialize()
        if self.BaseClass and self.BaseClass.Initialize then
            self.BaseClass.Initialize(self)
        end

        if SERVER then
            self:SetDifficulty(tier.Difficulty)
            self:SetHackTime(tier.HackTime)
        end
    end

    scripted_ents.Register(ENT, "sf_controller_" .. tier.Id)
end

-- Register Database Tiers
for _, tier in ipairs(Tiers) do
    local ENT = {}
    ENT.Base = "sf_database_entity"
    ENT.PrintName = "Database (" .. tier.Name .. ")"
    ENT.Category = "[SlicerFramework] - Premade"
    ENT.Spawnable = true
    ENT.AdminSpawnable = true

    function ENT:Initialize()
        if self.BaseClass and self.BaseClass.Initialize then
            self.BaseClass.Initialize(self)
        end

        if SERVER then
            self:SetDifficulty(tier.Difficulty)
            self:SetHackTime(tier.HackTime)
            self:SetEmitDatapad(tier.EmitDatapad)
        end
    end

    scripted_ents.Register(ENT, "sf_database_" .. tier.Id)
end

MsgC(Color(0, 255, 100), "[ZKSF] Registered entity tiers.\n")
