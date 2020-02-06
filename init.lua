fm = {}

f_util = {}
node_network = {}
resource_network = {}
io_network = {}
f_steam = {}
boiler = {}
pipe = {}
turbine = {}
wire = {}
f_constants = {}

factory_mod_storage = minetest.get_mod_storage()

minetest.debug("Initialising factory_mod as " .. minetest.get_current_modname())

local modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(modpath .. "/util.lua")
dofile(modpath .. "/network/network.lua")
dofile(modpath .. "/network/resource_network.lua")
dofile(modpath .. "/network/io_network.lua")
dofile(modpath .. "/steam.lua")
dofile(modpath .. "/boiler.lua")
dofile(modpath .. "/turbine.lua")
dofile(modpath .. "/pipe.lua")
dofile(modpath .. "/wire.lua")
dofile(modpath .. "/api.lua")
dofile(modpath .. "/smelter.lua")

return fm
