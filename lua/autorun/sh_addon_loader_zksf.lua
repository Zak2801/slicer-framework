---------------------------------------------------------------
--  lua\autorun\sh_addon_loader_zksm.lua
---------------------------------------------------------------
ZKSlicerFramework = ZKSlicerFramework or {}

ZKSlicerFramework.VERSION = 1
ZKSlicerFramework.VERSION_GITHUB = 0
ZKSlicerFramework.VERSION_TYPE = ".GIT"

function ZKSlicerFramework:GetVersion()
	return ZKSlicerFramework.VERSION
end

function ZKSlicerFramework:CheckUpdates()
	http.Fetch("https://raw.githubusercontent.com/Zak2801/slicer-framework/b44c6d040a001c62a16a1361d279e7915b934ca5/lua/autorun/sh_addon_loader_zksf.lua", function(contents,size) 
		local Entry = string.match( contents, "ZKSlicerFramework.VERSION%s=%s%d+" )

		if Entry then
			ZKSlicerFramework.VERSION_GITHUB = tonumber( string.match( Entry , "%d+" ) ) or 0
		else
			ZKSlicerFramework.VERSION_GITHUB = 0
		end

		if ZKSlicerFramework.VERSION_GITHUB == 0 then
			print("[ZKSlicerFramework] Latest version could not be detected, You have Version: "..ZKSlicerFramework:GetVersion())
		else
			if  ZKSlicerFramework:GetVersion() >= ZKSlicerFramework.VERSION_GITHUB then
				print("[ZKSlicerFramework] up to date. Version: "..ZKSlicerFramework:GetVersion())
			else
				print("[ZKSlicerFramework] a newer version is available! Version: "..ZKSlicerFramework.VERSION_GITHUB..", You have Version: "..ZKSlicerFramework:GetVersion())

				if ZKSlicerFramework.VERSION_TYPE == ".GIT" then
					print("[ZKSlicerFramework] Get the latest version at https://github.com/Zak2801/slicer-framework")
				else
					print("[ZKSlicerFramework] Restart your game/server to get the latest version!")
				end

				if CLIENT then 
					timer.Simple(25, function() 
						chat.AddText( Color( 255, 0, 0 ), "[ZKSlicerFramework] a newer version is available!" )
					end)
				end
			end
		end
	end)
end

function ZKSlicerFramework.LoadDirectory(path)
	local files, folders = file.Find(path .. "/*", "LUA")

	for _, fileName in ipairs(files) do
		local filePath = path .. "/" .. fileName

		if CLIENT then
			include(filePath)
		else
			if fileName:StartWith("cl_") then
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
		resource.AddSingleFile("materials/icon16/sf.png")
		resource.AddSingleFile("materials/vgui/zks_slicer.png")
		resource.AddSingleFile("materials/vgui/datapad.png")
		resource.AddSingleFile("materials/vgui/hack_arrows/up.png")
		resource.AddSingleFile("materials/vgui/hack_arrows/down.png")
		resource.AddSingleFile("materials/vgui/hack_arrows/left.png")
		resource.AddSingleFile("materials/vgui/hack_arrows/right.png")
		resource.AddSingleFile("materials/vgui/frame.png")
		resource.AddSingleFile("materials/slicerframework/physbeam_color.vmt")
		resource.AddFile("resource/fonts/scifie.ttf")
		resource.AddFile("resource/fonts/scifi2ku.ttf")
		resource.AddFile("resource/fonts/scifiebi.ttf")
	end)
end

if CLIENT then
	list.Set( "ContentCategoryIcons", "[SlicerFramework]", "icon16/sf.png" )
	list.Set( "ContentCategoryIcons", "[SlicerFramework] - Base Entities", "icon16/sf.png" )
	list.Set( "ContentCategoryIcons", "[SlicerFramework] - Premade", "icon16/sf.png" )
	list.Set( "ContentCategoryIcons", "[SlicerFramework] - Weapons", "icon16/sf.png" )

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


hook.Add( "InitPostEntity", "!!zks_sf_checkupdates", function()
	timer.Simple(10, function() ZKSlicerFramework:CheckUpdates() end)
end )