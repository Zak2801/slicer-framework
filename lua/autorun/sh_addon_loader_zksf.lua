---------------------------------------------------------------
--  lua\autorun\sh_addon_loader_zksm.lua
---------------------------------------------------------------
ZKSlicerFramework = ZKSlicerFramework or {}

function ZKSlicerFramework.LoadDirectory(path)
	local files, folders = file.Find(path .. "/*", "LUA")

	for _, fileName in ipairs(files) do
		local filePath = path .. "/" .. fileName

		if CLIENT then
			include(filePath)
		else
			if string.find(path, "languages") then
				AddCSLuaFile(filePath)
			elseif fileName:StartWith("cl_") then
				AddCSLuaFile(filePath)
			elseif fileName:StartWith("sh_") then
				AddCSLuaFile(filePath)
				include(filePath)
			else
				include(filePath)
			end
		end
	end

	return files, folders
end

function ZKSlicerFramework.LoadDirectoryRecursive(basePath)
	local _, folders = ZKSlicerFramework.LoadDirectory(basePath)
	for _, folderName in ipairs(folders) do
		ZKSlicerFramework.LoadDirectoryRecursive(basePath .. "/" .. folderName)
	end
end

ZKSlicerFramework.LoadDirectoryRecursive("zks_slicer_framework")

if SERVER then
	timer.Simple( .1, function()
		resource.AddSingleFile("materials/entities/sf_controller_entity.png")
		resource.AddSingleFile("materials/entities/sf_database_entity.png")
		resource.AddSingleFile("materials/entities/wp_zks_slicer.png")
		resource.AddSingleFile("materials/vgui/zks_slicer.png")
		resource.AddSingleFile("materials/vgui/datapad.png")
		resource.AddSingleFile("materials/vgui/hack_arrows/up.png")
		resource.AddSingleFile("materials/vgui/hack_arrows/down.png")
		resource.AddSingleFile("materials/vgui/hack_arrows/left.png")
		resource.AddSingleFile("materials/vgui/hack_arrows/right.png")
		resource.AddSingleFile("materials/vgui/frame.png")
		resource.AddFile("resource/fonts/scifie.ttf")
		resource.AddFile("resource/fonts/scifi2ku.ttf")
		resource.AddFile("resource/fonts/scifiebi.ttf")
	end)
end

if CLIENT then
	surface.CreateFont( "ZKSlicerFramework.UI.Primary", {
		font = "Sci Fied",
		size = 32,
		weight = 500,
		antialias = true,
		shadow = false,
	} )

	surface.CreateFont( "ZKSlicerFramework.UI.PrimarySmall", {
		font = "Sci Fied",
		size = 24,
		weight = 500,
		antialias = true,
		shadow = false,
	} )

	surface.CreateFont( "ZKSlicerFramework.UI.PrimaryItalic", {
		font = "Sci Fied BoldItalic",
		size = 32,
		weight = 500,
		antialias = true,
		shadow = false,
	} )

	surface.CreateFont( "ZKSlicerFramework.UI.Secondary", {
		font = "Sci Fied 2002 Ultra",
		size = 32,
		weight = 500,
		antialias = true,
		shadow = false,
	} )

	surface.CreateFont( "ZKSlicerFramework.UI.SecondarySmall", {
		font = "Sci Fied 2002 Ultra",
		size = 24,
		weight = 500,
		antialias = true,
		shadow = false,
	} )
end

local version = "v0.1"
MsgC( "\n", Color( 255, 255, 255 ), "---------------------------------- \n" )
MsgC( Color( 180, 130, 245 ), "[Zaktak's Slicer Framework]\n" )
MsgC( Color( 255, 255, 255 ), "Loading Files.......\n" )
MsgC( Color( 255, 255, 255 ), "Version........ "..version.."\n" )
MsgC( Color( 255, 255, 255 ), "---------------------------------- \n" )