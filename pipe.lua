f_constants.pipe = {name = minetest.get_current_modname()..":pipe", max_steam = 10}

local function get_pipe_networks()
    return minetest.deserialize(factory_mod_storage:get_string("pipe_networks")) or {}
end

local function pipe_affer_construct(pos,player) --Takes location of a new pipe and figures out what network to add it to
    local connected_pipes = f_util.find_neighbor_pipes(pos)
    if table.getn(connected_pipes) > 0 then
        if table.getn(connected_pipes) > 1 then --Check to see if there is more than one connected pipe
            minetest.chat_send_player(player:get_player_name(),"Nope! Too many pipes")
            return
        end
        local network, network_key = node_network.get_network("pipe", connected_pipes[1])
        if network_key ~= nil then
            node_network.add_node("pipe", pos,network, network_key)
        else
            minetest.debug("Pipe on construct error! Check source code")
        end
    else -- No connected pipes 
        node_network.create_network("pipe", pos)
    end
end

--Start of global methods

function pipe.get_reg_values()
    return f_constants.pipe.name, {
        description = "Pipe",
        tiles = {"^[colorize:#3248a8"},
        groups = {choppy = 2, oddly_breakable_by_hand = 2, wood = 1},
        after_place_node = function(pos, placer, itemstack, pointed_thing)
            pipe_affer_construct(pos,placer)
        end,
        on_destruct = function(pos)
            node_network.remove_node("pipe", pos)
        end,
    }
end

function pipe.get_max_steam(network)
        return table.getn(network.nodes)*f_constants.pipe.max_steam
end

function pipe.update_infotext(network)
    for _, pos in pairs(network.nodes) do
        local meta = minetest.get_meta(pos)
        meta:set_string("infotext",  "Contains " .. network.steam_units .. " units of steam")
    end
end