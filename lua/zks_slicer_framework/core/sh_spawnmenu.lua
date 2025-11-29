ZKSlicerFramework = ZKSlicerFramework or {}

if SERVER then
    CreateConVar("sf_database_model", "models/props_lab/reciever01b.mdl", {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_PROTECTED}, "Default model for hackable database")
    CreateConVar("sf_controller_model", "models/props/de_prodigy/desk_console3.mdl", {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_PROTECTED}, "Default model for hackable controller")
    CreateConVar("sf_datapad_model", "models/maxofs2d/hover_rings.mdl", {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_PROTECTED}, "Default model for datapad")
    CreateConVar("sf_config_perms", "superadmin,admin", {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_PROTECTED}, "Allowed usergroups for SF config")

    function ZKSlicerFramework.CanConfigure(ply)
        if not IsValid(ply) then return false end

        local allowed = string.Explode(",", GetConVar("sf_config_perms"):GetString())
        local group = string.lower(ply:GetUserGroup())

        for _, g in ipairs(allowed) do
            if group == string.lower(g) then
                return true
            end
        end

        return false
    end
end

if CLIENT then
    local function GetAllUserGroups()
        local groups = {}

        -- ULX
        if ULib and ULib.ucl and ULib.ucl.groups then
            for name, _ in pairs(ULib.ucl.groups) do
                groups[name] = true
            end

        -- SAM
        elseif sam and sam.ranks and sam.ranks.get_ranks then
            for id, rank in pairs(sam.ranks.get_ranks()) do
                groups[rank.name or id] = true
            end

        -- Sandbox fallback
        elseif not next(groups) then
            for _, ply in ipairs(player.GetAll()) do
                if ply:GetUserGroup() then
                    groups[ply:GetUserGroup()] = true
                end
            end
            -- Ensure defaults
            groups["superadmin"] = true
            groups["admin"] = true
            groups["user"] = false
        end

        -- Convert table to sorted list
        local list = {}
        for g, _ in pairs(groups) do table.insert(list, g) end
        table.sort(list)
        return list
    end

    -- Adds an entry to the spawnmenu "Options" tab
    hook.Add("PopulateToolMenu", "ZKSlicerConsoleOptions", function()
        spawnmenu.AddToolMenuOption(
            "Options",                       -- parent tab
            "ZK's Slicer Framework",          -- category
            "ZKSlicerOptions",               -- unique name
            "Hackable Entities Config",        -- display title
            "", "",                           -- commands
            function(panel)
                panel:ClearControls()

                panel:Help("Admin-only configuration for Hackable Console entities.")

                panel:TextEntry("Database Model", "sf_database_model")
                panel:TextEntry("Controller Model", "sf_controller_model")
            end
        )

        spawnmenu.AddToolMenuOption(
            "Options",
            "ZK's Slicer Framework",
            "ZKSlicerAdmin",
            "Admin Permissions Config",
            "",
            "",
            function(panel)
                panel:ClearControls()
                panel:Help("Choose which usergroups can access the Slicer Framework configuration panel.")

                local groups = GetAllUserGroups()
                local saved = string.Explode(",", GetConVar("sf_config_perms"):GetString())

                -----------------------------------------------------
                -- LEFT LIST — ALL GROUPS
                -----------------------------------------------------
                local listAll = vgui.Create("DListView")
                listAll:SetTall(200)
                listAll:AddColumn("All Groups")

                for _, g in ipairs(groups) do
                    listAll:AddLine(g)
                end

                panel:AddItem(listAll)

                -----------------------------------------------------
                -- BUTTON: ADD
                -----------------------------------------------------
                local addBtn = vgui.Create("DButton")
                addBtn:SetText("Add →")

                panel:AddItem(addBtn)

                -----------------------------------------------------
                -- RIGHT LIST — ALLOWED GROUPS
                -----------------------------------------------------
                local listAllowed = vgui.Create("DListView")
                listAllowed:SetTall(200)
                listAllowed:AddColumn("Allowed")

                -- Fill from ConVar
                for _, g in ipairs(saved) do
                    if g ~= "" then
                        listAllowed:AddLine(g)
                    end
                end

                panel:AddItem(listAllowed)


                addBtn.DoClick = function()
                    local selected = listAll:GetSelected()
                    if not selected or #selected == 0 then return end

                    for _, line in ipairs(selected) do
                        local group = line:GetColumnText(1)

                        -- Check not already in allowed list
                        local exists = false
                        for __, al in ipairs(listAllowed:GetLines()) do
                            if al:GetColumnText(1) == group then
                                exists = true
                                break
                            end
                        end

                        if not exists then
                            listAllowed:AddLine(group)
                        end
                    end
                end

                -----------------------------------------------------
                -- BUTTON: REMOVE
                -----------------------------------------------------
                local removeBtn = vgui.Create("DButton")
                removeBtn:SetText("← Remove")
                removeBtn.DoClick = function()
                    local selected = listAllowed:GetSelected()
                    if not selected or #selected == 0 then return end

                    for _, line in ipairs(selected) do
                        listAllowed:RemoveLine(line:GetID())
                    end
                end

                panel:AddItem(removeBtn)

                -----------------------------------------------------
                -- SAVE BUTTON — Updates convar
                -----------------------------------------------------
                local saveBtn = vgui.Create("DButton")
                saveBtn:SetText("Save Configuration")
                saveBtn.DoClick = function()
                    local allowed = {}

                    for _, line in ipairs(listAllowed:GetLines()) do
                        table.insert(allowed, line:GetColumnText(1))
                    end

                    RunConsoleCommand("sf_config_perms", table.concat(allowed, ","))
                    surface.PlaySound("buttons/button14.wav")
                end

                panel:AddItem(saveBtn)
            end
        )

    end)
end