fm = {}

f_util = {}
f_nodes = {}

factory_mod_storage = minetest.get_mod_storage()

minetest.debug("[Factory mod]Initialising as " .. minetest.get_current_modname())

local modpath = minetest.get_modpath(minetest.get_current_modname())

--Various 'libraries'
dofile(modpath .. "/util.lua")

NodeNetwork.register_network("electricity", "Watt", NodeNetwork.IO_network)
NodeNetwork.register_network("steam", "liter", NodeNetwork.IO_network)

--Nodes
dofile(modpath .. "/nodes/boiler.lua")
dofile(modpath .. "/nodes/turbine.lua")
dofile(modpath .. "/nodes/pipe.lua")
dofile(modpath .. "/nodes/wire.lua")
dofile(modpath .. "/nodes/sample_usage.lua")
dofile(modpath .. "/nodes/smelter.lua")

dofile(modpath .. "/api.lua")

return fm