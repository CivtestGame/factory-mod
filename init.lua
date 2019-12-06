boiler = {}

minetest.debug("Initialising factory_mod")

local modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(modpath .. "/boiler.lua")
dofile(modpath .. "/api.lua")