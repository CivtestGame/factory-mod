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
usage = {}
f_constants = {}

factory_mod_storage = minetest.get_mod_storage()

minetest.debug("[Factory mod]Initialising as " .. minetest.get_current_modname())

local modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(modpath .. "/util.lua")
dofile(modpath .. "/network/class.lua")
dofile(modpath .. "/network/network.lua")
dofile(modpath .. "/network/resource_network.lua")
dofile(modpath .. "/network/io_network.lua")
dofile(modpath .. "/steam.lua")
dofile(modpath .. "/nodes/boiler.lua")
dofile(modpath .. "/nodes/turbine.lua")
dofile(modpath .. "/nodes/pipe.lua")
dofile(modpath .. "/nodes/wire.lua")
dofile(modpath .. "/nodes/sample_usage.lua")
dofile(modpath .. "/init_network_vals.lua")
dofile(modpath .. "/api.lua")
dofile(modpath .. "/nodes/smelter.lua")

return fm
