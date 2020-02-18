f_constants.turbine = {name = minetest.get_current_modname()..":turbine", max_steam_pull = 10, watt_per_steam = 200}

---@param pos Position
---@param elapsed number
---@return number
function turbine.get_production(pos, elapsed)
    local connected_pipes = f_util.find_neighbor_pipes(pos)

    if table.getn(connected_pipes) > 0 then
        local steam_per_pipe = f_constants.turbine.max_steam_pull*elapsed / table.getn(connected_pipes)
        local extracted = 0
        for _, pipe in pairs(connected_pipes) do
            extracted = extracted + resource_network.extract(f_constants.networks.pipe, pipe, steam_per_pipe)
        end
        local produced_watts = extracted*f_constants.turbine.watt_per_steam
        return produced_watts
    else
        return 0
    end
end

---@param node Node
---@param network IO_network
function turbine.update(node, network)
    local steam_usage = math.min(10, 10 * network.pdRatio)
    minetest.chat_send_all("Turbine update called")
    network:update_usage(node.pos, steam_usage)
    local n = IO_network(node.pos, f_constants.networks.electricity)
    n:update_production(node.pos, steam_usage*10)
    n:save()
end

function turbine.get_reg_values()
    return f_constants.turbine.name, {
        description = "Turbine",
        tiles = {"^[colorize:#48a832"},
        groups = {choppy = 2, oddly_breakable_by_hand = 2, wood = 1},
        after_place_node = function(pos, placer, itemstack, pointed_thing)
            IO_network.on_node_place(f_constants.networks.electricity, {pos = pos}, "prod", 0)
            IO_network.on_node_place(f_constants.networks.pipe,{pos = pos}, "use", 10)
        end,
        on_destruct = function (pos)
            IO_network.on_node_destruction(f_constants.networks.electricity, {pos = pos}, "prod", true)
            IO_network.on_node_destruction(f_constants.networks.pipe, {pos = pos}, "use", true)
        end,
        on_rightclick = function(pos, node, player, itemstack, pointed_thing)
            --f_util.cdebug(node_network.get_network(f_constants.networks.electricity, pos))
            f_util.cdebug(IO_network(pos, f_constants.networks.pipe):get_node(pos))
        end,
    }
end