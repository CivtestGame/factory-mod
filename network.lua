function node_network.get_set(set_name)
    return minetest.deserialize(factory_mod_storage:get_string(set_name .. "_network")) or {}
end

function node_network.save_set(set_name, set)
    factory_mod_storage:set_string(set_name .. "_network", minetest.serialize(set))
end

function node_network.get_network(set_name, pos)
    for key, network in pairs(node_network.get_set(set_name)) do
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

function node_network.save_network(set_name, network, network_key, set)
    set = set or node_network.get_set(set_name)
    set[network_key] = network
    node_network.save_set(set_name, set)
end

function node_network.create_network(set_name, initial_node, set)
    set = set or node_network.get_set(set_name)
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
    node_network.save_set(set_name, set)
    return new_network
end

function node_network.delete_network(set_name, network_key, set)
    set = set or node_network.get_set(set_name)
    table.remove(set, network_key)
    node_network.save_set(set)
end

function node_network.add_node(set_name, node_pos, network, network_key)
    network.min_pos = f_util.get_min_pos(network.min_pos, node_pos)
    network.max_pos = f_util.get_max_pos(network.max_pos, node_pos)
    table.insert(network.nodes, node_pos)
    node_network.save_network(set_name, network, network_key)
end

function node_network.remove_node(set_name, node_pos, network, network_key, ensure_continuity)
    if network == nil then network,network_key = node_network.get_network(set_name, node_pos) end
    minetest.debug("Removing node at " .. f_util.dump(node_pos))
    if network ~= nil then
        --Reset the bounding box to the whole map so it can be shrunk to the right size in the for loop
        network.min_pos = f_util.map_max_pos
        network.max_pos = f_util.map_min_pos
        for key,node in pairs(network.nodes) do
            if f_util.is_same_pos(node,node_pos) then
                table.remove(network.nodes, key)
            else
                network.min_pos = f_util.get_min_pos(network.min_pos, node)
                network.max_pos = f_util.get_max_pos(network.max_pos, node)
            end
        end
        minetest.debug(f_util.dump(network.min_pos))
        minetest.debug(f_util.dump(network.max_pos))

        if table.getn(network.nodes) > 0 then node_network.save_network(set_name, network, network_key)
        else node_network.delete_network(set_name, network_key) end
    end
end