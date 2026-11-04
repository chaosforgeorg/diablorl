#!/usr/bin/lua
xpcall( function() dofile( "config.lua") end, function() end )
VALKYRIE_ROOT = VALKYRIE_ROOT or os.getenv("FPCVALKYRIE_ROOT") or "../fpcvalkyrie/"
dofile (VALKYRIE_ROOT.."scripts/lua_make.lua")

makefile = {
	name = "diablorl",
	fpc_params = {
		"-Fu"..VALKYRIE_ROOT.."src",
		"-Fu"..VALKYRIE_ROOT.."libs",
	},
	fpc_os_params = {
		WINDOWS = {},
		LINUX = {	
			"-TLINUX",
		},
		MACOSX = {	
      "-dOSX_APP_BUNDLE",
			"-k-macosx_version_min -k10.4",
		},
	},
	pre_build = function()
		local v = make.readversion( "bin/version.txt" )
		local s = make.svnrevision()
		make.writeversion( "bin/version.inc", v, s )
		if arg[1] then
			make.svncheck(s)
		end
	end,
	post_build = function()
		os.execute_in_dir( "mpq", "bin" )
	end,
	source_files = { "rl.pas", "mpq.pas" },
	publish = {
		exec = { "rl" },
		os = {
			WINDOWS = { "lua5.1.dll", "SDL3.dll", "StormLib64.dll", "fmod64.dll" },
			LINUX   = {  },
			MACOSX  = {  },
		},
		subdirs = {},
		other = { "font10x18.png", "config.lua", "manual.txt", "version.txt", "readme.txt", "diablorl.mpq" },
	},
	commands = {
		pkg = function()
			make.package( make.publish( (OS_VER_PREFIX or "")..make.version_name() ), PUBLISH_DIR )
		end,
		install = function()
			if OS == "WINDOWS" then	
				make.generate_iss( "diablorl.iss", nil, PUBLISH_DIR ) 
			elseif OS == "MACOSX" then
				make.generate_bundle( nil, PUBLISH_DIR ) 
			end
		end,
		all = function()
			makefile.commands.pkg()
			makefile.commands.install()
		end,
	},	
	install = {
		guid        = "6AC5B3B0-6F09-11E2-9AD0-173B6188709B",
		name        = "DiabloRL",
		publisher   = "ChaosForge",
		license     = "install\\license.txt",
		info_after  = "install\\install_after.txt",
		iss_icon    = "install\\icon256.ico",
		iss_image   = "install\\install-banner.bmp",
		iss_simage  = "install\\install-logo.bmp",
		iss_url     = "http://www.chaosforge.org/",
		iss_nocomp  = { "mpq" },
		iss_eicons  = {
			{ name = "DiabloRL", exe = "rl" },
			{ name = "DiabloRL (console mode)", exe = "rl", parameters = "-console" },
			{ name = "DiabloRL Manual", file = "manual.txt" },
			{ name = "ChaosForge Website", url = "http://www.chaosforge.org/" },
			{ name = "DiabloRL Website", url = "http://diablo.chaosforge.org/" },
			{ name = "DiabloRL Forum", url = "http://forum.chaosforge.org/" },
		},
		dmg_size   = 64000,
		app_icon   = "install/iconfile.icns",
		app_bg     = "install/background.png",
		-- Untested. SDL3.framework is the macos-arm64_x86_64 slice of
		-- SDL3.xcframework from the official SDL3 release .dmg. The executable
		-- loads every library at runtime from Contents/Frameworks.
		app_fworks = {
			"Frameworks/SDL3.framework",
			"Frameworks/libfmod.dylib",
			"Frameworks/StormLib.dylib",
		},
	}
}

make.compile()
make.command( arg[1] )
