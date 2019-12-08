fm = {}

f_util = {}
f_steam = {}
boiler = {}
pipe = {}
f_constants = {}

factory_mod_storage = minetest.get_mod_storage()

minetest.debug("Initialising factory_mod as " .. minetest.get_current_modname())

local modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(modpath .. "/util.lua")
dofile(modpath .. "/steam.lua")
dofile(modpath .. "/boiler.lua")
dofile(modpath .. "/pipe.lua")
dofile(modpath .. "/api.lua")
dofile(modpath .. "/smelter.lua")

return fm
