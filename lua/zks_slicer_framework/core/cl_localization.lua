--[[-------------------------------------------------------------------------
  lua\zks_slicer_framework\core\cl_localization.lua
  CLIENT
  Loads the appropriate language file based on the client's settings.
---------------------------------------------------------------------------]]

ZKSlicerFramework = ZKSlicerFramework or {}
ZKSlicerFramework.Langs = ZKSlicerFramework.Langs or {}

local function LoadLanguage()
    local langCode = GetConVar("gmod_language"):GetString()
    local path = "zks_slicer_framework/languages/"
    
    local langTable = {}
    
    -- Try to load specific language
    if file.Exists(path .. langCode .. ".lua", "LUA") then
        langTable = include(path .. langCode .. ".lua") or {}
    else
        -- Fallback to English
        if file.Exists(path .. "en.lua", "LUA") then
            langTable = include(path .. "en.lua") or {}
        end
    end

    -- Apply to language library
    for k, v in pairs(langTable) do
        language.Add(k, v)
    end
    
    print("[ZK's Slicer Framework] Loaded language: " .. (langTable["zksf.config.title"] and langCode or "en (Fallback)"))
end

hook.Add("InitPostEntity", "ZKSF_LoadLanguage", LoadLanguage)
-- Also load immediately if reloaded
LoadLanguage()
