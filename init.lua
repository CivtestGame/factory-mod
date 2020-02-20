fm = {}

f_util = {}
f_nodes = {}

factory_mod_storage = minetest.get_mod_storage()

minetest.debug("[Factory mod]Initialising as " .. minetest.get_current_modname())

local modpath = minetest.get_modpath(minetest.get_current_modname())

--Various 'libraries'
dofile(modpath .. "/util.lua")
dofile(modpath .. "/network/helper_funcs.lua")
dofile(modpath .. "/network/network.lua")
dofile(modpath .. "/network/io_network.lua")

Network.register_network("electricity", "Watt")
Network.register_network("steam", "liter")

--Nodes
dofile(modpath .. "/nodes/boiler.lua")
dofile(modpath .. "/nodes/turbine.lua")
dofile(modpath .. "/nodes/pipe.lua")
dofile(modpath .. "/nodes/wire.lua")
dofile(modpath .. "/nodes/sample_usage.lua")
dofile(modpath .. "/nodes/smelter.lua")

dofile(modpath .. "/api.lua")

return fm