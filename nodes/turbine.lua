local name = minetest.get_current_modname()..":turbine"
f_constants.turbine = {name = name, max_steam_pull = 10, watt_per_steam = 200}

---@param node Node
---@param network IO_network
local function update(node, network, usage)
    minetest.chat_send_all("Turbine update called")
    local n = IO_network(node.pos, "electricity")
    n:update_production(node.pos, usage*10)
    n:save()
end

IO_network.register_usage_node("steam", name, update)
IO_network.register_production_node("electricity", name)

function turbine.get_reg_values()
    return f_constants.turbine.name, {
        description = "Turbine",
        tiles = {"^[colorize:#48a832"},
        groups = {choppy = 2, oddly_breakable_by_hand = 2, wood = 1},
        after_place_node = function(pos, placer, itemstack, pointed_thing)
            IO_network.on_node_place("electricity", {pos = pos}, "prod", 0)
            IO_network.on_node_place("steam",{pos = pos}, "use", 10)
        end,
        on_destruct = function (pos)
            IO_network.on_node_destruction("electricity", {pos = pos}, "prod", true)
            IO_network.on_node_destruction("steam", {pos = pos}, "use", true)
        end,
        on_rightclick = function(pos, node, player, itemstack, pointed_thing)
            --f_util.cdebug(node_network.get_network(f_constants.networks.electricity, pos))
            f_util.cdebug(IO_network(pos, "steam"):get_node(pos))
        end,
    }
end