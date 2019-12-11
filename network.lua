function network.get_set(set_name)
    return minetest.deserialize(factory_mod_storage:get_string(set_name)) or {}
end

function network.save_set(set_name, set)
    factory_mod_storage:set_string(set_name, minetest.serialize(set))
end

function network.get_network(set_name, pos)
    for key, network in pairs(network.get_set(set_name)) do
        local networkArea = VoxelArea:new({MinEdge = network.min_pos, MaxEdge = network.max_pos})
        if networkArea:containsp(pos) then
            for _,node in pairs(network.nodes) do
                if f_util.is_same_pos(node,pos) then
                    return network, key
                end
            end
        end
    end 
end

function network.save_network(set_name, network, network_key, set)
    set = set or network.get_set(set_name)
    set[network_key] = network
    network.save_set(set_name, set)
end

function network.create_network(set_name, initial_node, set)
    set = set or network.get_set(set_name)
    local new_network = {}
    new_network.min_pos = initial_node
    new_network.max_pos = initial_node
    new_network.nodes = {initial_node}
    
    -- THis code can probably be replaced with table.getn()
    local count = 0
    local new_name = true
    while new_name do
        count = count + 1
        if set[count] == nil then new_name = false end
    end
    set[count] = new_network
    network.save_set(set_name, set)
    return new_network
end

function network.delete_network(set_name, network_key, set)
    set = set or network.get_set(set_name)
    table.remove(set, network_key)
    network.save_set(set)
end

function network.add_node(set_name, node_pos, network, network_key)
    network.min_pos = f_util.get_min_pos(network.min_pos, node_pos)
    network.max_pos = f_util.get_max_pos(network.max_pos, node_pos)
    table.insert(network.nodes, node_pos)
    network.save_network(set_name, network, network_key)
end

function network.remove_node(set_name, node_pos, network, network_key)
    if network == nil then network,network_key = network.get_network(set_name, node_pos) end
    minetest.debug("Removing node at " .. f_util.dump(node_pos))
    if network ~= nil then
        --If yes, for every edge we are on, subtract 1
        local update_min = false
        local update_max = false
        --We might need these values if we have to upadte the min/max pos
        local new_min_pos = network.nodes[1]
        local new_max_pos = network.nodes[1]
        --Check if the node we are removing is on the edge of the network. If it is we will have to update the corresponding max/min position
        local x_diff = network.min_pos.x ~= network.max_pos.x
        local y_diff = network.min_pos.y ~= network.max_pos.y
        local z_diff = network.min_pos.z ~= network.max_pos.z
        if (x_diff and network.min_pos.x == node_pos.x) or (y_diff and network.min_pos.y == node_pos.y) or (z_diff and network.min_pos.z == node_pos.z) then update_min = true end
        if (x_diff and network.max_pos.x == node_pos.x) or (y_diff and network.max_pos.y == node_pos.y) or (z_diff and network.max_pos.z == node_pos.z) then update_max = true end
        minetest.debug("Update min/max is " .. tostring(update_min) .. tostring(update_max))
        for key,node in pairs(network.nodes) do
            if f_util.is_same_pos(node,node_pos) then
                table.remove(network.nodes, key)
            else
                if update_min then new_min_pos = f_util.get_min_pos(new_min_pos, node) end
                if update_max then new_max_pos = f_util.get_max_pos(new_max_pos, node) end
            end
        end
        minetest.debug(f_util.dump(new_min_pos))
        minetest.debug(f_util.dump(new_max_pos))
        if update_min then network.min_pos = new_min_pos end
        if update_max then network.max_pos = new_max_pos end

        if table.getn(network.nodes) > 0 then network.save_network(set_name, network, network_key)
        else network.delete_network(set_name, network_key) end
    end
end