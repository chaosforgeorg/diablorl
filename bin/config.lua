-- Ordinary options and keyboard bindings are configured in Settings.
-- Apply saves them to settings.lua. This file contains expert configuration.

-- To enable sound you need the original Diablo game,
-- in particular the DIABDAT.MPQ. Change this value to
-- FMOD or SDL depending on driver (or just DEFAULT)
sound     = "NONE"

-- Provide a full pathname for your DIABDAT.MPQ file
-- Remember that on Windows "\"" needs to be escaped to "\\"
-- e.g. "c:\\Games\\Diablo\\DIABDAT.MPQ"
mpq       = ""

-- == Path configuration ==
-- You can use command line switch --config=/something/something/config.lua
-- to load a different config!

-- Uncomment the following paths if needed:

-- This is the directory path to the read only data folder (current dir by
-- default, needs slash at end if changed). --datapath= to override on
-- command line.
--DataPath = ""

-- This is the directory path for writing (save, log) (current dir by
-- default, needs slash at end if changed). --writepath= to override on
-- command line.
--WritePath = ""

-- This is the directory path for score table (by default it will be the
-- same as WritePath, change for multi-user systems. --scorepath= to override
-- on command line.
--ScorePath = ""

-- This is the directory path to the audio files ("sound/" dir by
-- default). --soundpath= to override on command line.
--SoundPath = "sound/"
