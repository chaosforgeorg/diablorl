dofile "keybindings.lua"

graphics  = true
fullscreen = true

console_x = 100
console_y = 33

screen_x  = 1024
screen_y  = 768

reveal_town = false

run_delay = 10

-- To enable sound you need the original Diablo game,
-- in particular the DIABDAT.MPQ. Change this value to
-- FMOD or SDL depending on driver (or just DEFAULT)
sound     = "NONE"

-- Provide a full pathname for your DIABDAT.MPQ file
-- Remember that on Windows "\"" needs to be escaped to "\\"
-- e.g. "c:\\Games\\Diablo\\DIABDAT.MPQ"
mpq       = ""

-- Play walk sound (set to false to turn off)
walk_sound        = true

-- Music volume in the range of 0..100
music_volume      = 100

-- Sound volume in the range of 0..100
sound_volume      = 100
