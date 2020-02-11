f_constants.turbine = {name = minetest.get_current_modname()..":turbine", max_steam_pull = 10, watt_per_steam = 200}

local function turbine_node_timer(pos, elapsed)
    local connected_pipes = f_util.find_neighbor_pipes(pos)

    if table.getn(connected_pipes) > 0 then
        local steam_per_pipe = f_constants.turbine.max_steam_pull*elapsed / table.getn(connected_pipes)
        local extracted = 0
        for _, pipe in pairs(connected_pipes) do
            extracted = extracted + resource_network.extract(f_constants.pipe.set_values, pipe, steam_per_pipe)
        end
        local produced_watts = extracted*f_constants.turbine.watt_per_steam
        minetest.chat_send_all("Extracted " .. extracted .. " Units of steam, generated " .. produced_watts .. " Watts")
        io_network.update_input(f_constants.wire.set_values, pos, produced_watts)
        if extracted > 0 then return true else return false end
    else return false
    end
end

---@param pos Position
---@param elapsed number
---@return number
function turbine.get_production(pos, elapsed)
    local connected_pipes = f_util.find_neighbor_pipes(pos)

    if table.getn(connected_pipes) > 0 then
        local steam_per_pipe = f_constants.turbine.max_steam_pull*elapsed / table.getn(connected_pipes)
        local extracted = 0
        for _, pipe in pairs(connected_pipes) do
            extracted = extracted + resource_network.extract(f_constants.pipe.set_values, pipe, steam_per_pipe)
        end
        local produced_watts = extracted*f_constants.turbine.watt_per_steam
        minetest.chat_send_all("Extracted " .. extracted .. " Units of steam, generated " .. produced_watts .. " Watts")
        return produced_watts
    else
        return 0
    end
end

function turbine.get_reg_values()
    return f_constants.turbine.name, {
        description = "Turbine",
        tiles = {"^[colorize:#48a832"},
        groups = {choppy = 2, oddly_breakable_by_hand = 2, wood = 1},
        on_timer = turbine_node_timer,
        after_place_node = function(pos, placer, itemstack, pointed_thing)
            node_network.on_node_place({f_constants.pipe.set_values, f_constants.wire.set_values},{pos = pos})
        end,
        on_destruct = function (pos)
        end,
        on_rightclick = function(pos, node, player, itemstack, pointed_thing)
            local timer = minetest.get_node_timer(pos)
            timer:start(1.0) -- in seconds
            f_util.debug(node_network.get_network(f_constants.wire.set_values, pos))
            f_util.debug(node_network.get_network(f_constants.pipe.set_values, pos))
        end,
    }
end