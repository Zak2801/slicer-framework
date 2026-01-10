--[[-------------------------------------------------------------------------
  lua\zks_slicer_framework\core\sh_utils.lua
  SHARED
  General utility functions for the framework
---------------------------------------------------------------------------]]

ZKSlicerFramework = ZKSlicerFramework or {}
ZKSlicerFramework.Utils = ZKSlicerFramework.Utils or {}

-----------------------------------------------------------------------------
-- Checks if an entity is part of the Slicer Framework (based on sf_base_entity)
-- @param ent Entity The entity to check
-- @return boolean True if it is a Slicer Framework entity
-----------------------------------------------------------------------------
function ZKSlicerFramework.IsSlicerEntity(ent)
    if not IsValid(ent) then return false end
    return scripted_ents.IsBasedOn(ent:GetClass(), "sf_base_entity")
end

-----------------------------------------------------------------------------
-- Checks if an entity is a Slicer Framework Controller (based on sf_controller_entity)
-- @param ent Entity The entity to check
-- @return boolean True if it is a controller
-----------------------------------------------------------------------------
function ZKSlicerFramework.IsController(ent)
    if not IsValid(ent) then return false end
    return scripted_ents.IsBasedOn(ent:GetClass(), "sf_controller_entity") or ent:GetClass() == "sf_controller_entity"
end
