f_constants.pipe = {name = minetest.get_current_modname()..":pipe", max_steam = 10}

local function pipe_affer_construct(pos,player) --Takes location of a new pipe and figures out what network to add it to
    local connected_pipes = f_util.find_neighbor_pipes(pos)
    if table.getn(connected_pipes) > 0 then
        if table.getn(connected_pipes) > 1 then --Check to see if there is more than one connected pipe
            local networks = {}
            local network, network_key
            for _, node in pairs(connected_pipes) do
                network, network_key = node_network.get_network("pipe", node)
                network.key = network_key
                table.insert(networks, network)
            end
            minetest.debug(f_util.dump(networks))
            minetest.debug(f_util.dump(table.getn(networks)))
            if table.getn(networks) > 1 then
                node_network.merge_networks("pipe", networks)
            elseif table.getn(networks) == 1 then
                -- In this case the network and network_key above can be used
                network = node_network.add_node(pos,network)
                node_network.save_network("pipe", network, network_key)
            else
                minetest.debug("Error in pipe.lua line 18")
            end
        end
        local network, network_key = node_network.get_network("pipe", connected_pipes[1])
        if network_key ~= nil then
            network = node_network.add_node(pos,network)
            node_network.save_network("pipe", network, network_key)
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
        after_destruct = function(pos, old_node)
            node_network.remove_node("pipe", pos, nil, nil, true)
        end,
        on_rightclick = function(pos, node, player, itemstack, pointed_thing)
            minetest.chat_send_all(f_util.dump(node_network.get_network("pipe",pos).nodes))
        end
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