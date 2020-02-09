---@class Position
---@field public x number
---@field public y number
---@field public z number
local Position = {} -- This is required to get emmylua to work

---@class SetValue
---@field public save_id string
local SetValue = {} -- This is required to get emmylua to work

---@class Node
---@field public pos Position
local Node = {} -- This is required to get emmylua to work

---@class Network
---@field public nodes Node[]
local Network = {} -- This is required to get emmylua to work

---@param network Network
---@param pos Position
local function delete_node(network, pos)
    for key,node in pairs(network.nodes) do
        if f_util.is_same_pos(node.pos,pos) then
            table.remove(network.nodes, key)
        end
    end 
end

---@param type string
local function create_new_network(type)
    return {
        min_pos = f_util.map_max_pos,
        max_pos = f_util.map_min_pos,
        type = type,
        nodes = {}}
end

--Recursive function to hopefully generate a new network in cases of network splits
---@param network Network
---@param old_network Network
---@param pos Position
local function recursive_add(network, old_network, pos)
    for i, node in pairs(old_network.nodes) do
        if f_util.is_same_pos(node.pos, pos) then
            network.min_pos = f_util.get_min_pos(network.min_pos, pos)
            network.max_pos = f_util.get_max_pos(network.max_pos, pos)
            table.insert(network.nodes, {pos=pos})
            table.remove(old_network.nodes, i)
            for _, node in pairs(f_util.get_adjacent_nodes(pos, network.type)) do
                network, old_network = recursive_add(network, old_network, node)
            end
            return network, old_network
        end
    end
    return network, old_network
end

---@param set_values SetValue
---@return Network[]
local function get_set(set_values)
    return minetest.deserialize(factory_mod_storage:get_string(set_values.save_id .. "_network")) or {}
end

---@param set_values SetValue
---@param set Network[]
local function save_set(set_values, set)
    factory_mod_storage:set_string(set_values.save_id .. "_network", minetest.serialize(set))
end


--Pos is optional if you only want to update one pos
local function update_key_metadata(set_value, network, pos)
    for key, node in pairs(network.nodes) do
        if not pos or (pos and f_util.is_same_pos(pos, node.pos)) then
            local meta = minetest.get_meta(node.pos)
            local name = set_value.save_id .. "_network_key"
            meta:set_int(name, key)
        end
    end
end

---@param set_values any
---@param networks Network[]
---@param node Node
local function merge_networks(set_values, networks, node)
    local set = get_set(set_values)
    local new_network = create_new_network(networks[1].type) -- Might want to change this later
    for _, network in pairs(networks) do
        for i, node in pairs(network.nodes) do
            new_network = node_network.add_node(node, new_network)
        end
        node_network.delete_network(set_values, network.key, set)
    end
    new_network = node_network.add_node(node, new_network)
    --update_key_metadata(set_values, new_network) 
    table.insert(set, new_network)
    save_set(set_values, set)
end

--Start of global methods

---@param set_values SetValue
---@param pos Position
---@return Network, number
function node_network.get_network(set_values, pos)
    for key, network in pairs(get_set(set_values)) do
        --networkArea is used for quickly reducing the search space.
        local networkArea = VoxelArea:new({MinEdge = network.min_pos, MaxEdge = network.max_pos})
        if networkArea:containsp(pos) then
            for _,node in pairs(network.nodes) do
                if f_util.is_same_pos(node.pos,pos) then
                    network.key = key
                    return network, key
                end
            end
        end
    end
end

---@param set_values SetValue
---@param network Network
---@param network_key number | nil
---@param set Network[] | nil
function node_network.save_network(set_values, network, network_key, set)
    network_key = network_key or network.key
    set = set or get_set(set_values)
    set[network_key] = network
    save_set(set_values, set)
end

---@param set_values SetValue
---@param initial_pos Position
---@param set Network[] | nil
---@return Network
function node_network.create_network(set_values, initial_pos, set)
    set = set or get_set(set_values)
    local new_network = create_new_network(minetest.get_node(initial_pos).name)
    new_network = node_network.add_node(initial_pos, new_network)
    --update_key_metadata(set_values, new_network) -- Dont need to add pos since there is only 1 node
    table.insert(set, new_network)
    save_set(set_values, set)
    return new_network
end

---@param set_values SetValue
---@param network_key number
---@param set Network[] | nil
function node_network.delete_network(set_values, network_key, set)
    set = set or get_set(set_values)
    table.remove(set, network_key)
    save_set(set_values, set)
end

---@param set_values SetValue
---@param pos Position
---@param type string | nil
---@return Network[]
--Type is optional filter to reduce search space
function node_network.get_adjacent_networks(set_values, pos, type)
    local connected_nodes = f_util.get_adjacent_nodes(pos, type)
    local networks = {}
    for _, node in pairs(connected_nodes) do
        local network, network_key = node_network.get_network(set_values, node)
        if network then
            network.key = network_key
            table.insert(networks, network)
        end
    end
    return networks
end

--All netwroks will have to have their network.key set to the correct value
--node is optional, but usefull. Adds the node after the networks are merged

---@param node_pos Position
---@param network Network
---@return Network
function node_network.add_node(node_pos, network)
    network.min_pos = f_util.get_min_pos(network.min_pos, node_pos)
    network.max_pos = f_util.get_max_pos(network.max_pos, node_pos)
    table.insert(network.nodes, {pos = node_pos})   
    return network
end

---@param set_value SetValue
---@param pos Position
---@param network Network | nil
---@return Node, number
function node_network.get_node(set_value, pos, network)
    network = network or node_network.get_network(set_value, pos)
	for key, node in pairs(network.nodes) do
		if(f_util.is_same_pos(node.pos, pos)) then
			return node, key
		end;
	end
end

---@param set_value SetValue
---@param node Node
---@param key number
---@param network Network | nil
---@return Network
function node_network.set_node(set_value, node, key, network)
    network = network or node_network.get_network(set_value, node.pos)
    network.nodes[key] = node
    return network
end

---@param message string
---@param network Network
function node_network.update_infotext(network, message)
    for _, node in pairs(network.nodes) do
        local meta = minetest.get_meta(node.pos)
        meta:set_string("infotext",  message)
    end
end

---@param set_values SetValue
---@param node_pos Position
---@param ensure_continuity boolean
function node_network.on_node_destruction(set_values, node_pos, ensure_continuity)
    local network,network_key = node_network.get_network(set_values, node_pos)
    if network ~= nil then
        if table.getn(f_util.get_adjacent_nodes(node_pos, network.type)) > 1 and ensure_continuity == true then
            local set = get_set(set_values)
            delete_node(network, node_pos)
            while table.getn(network.nodes) > 0 do  
                local initial_node = math.random(table.getn(network.nodes))
                local new_network = create_new_network(network.type)
                new_network, network = recursive_add(new_network, network, network.nodes[initial_node])
                table.insert(set, new_network)
            end
            table.remove(set, network_key)
            save_set(set_values, set)
        else
            --Reset the bounding box to the whole map so it can be shrunk to the right size in the for loop
            network.min_pos = f_util.map_max_pos
            network.max_pos = f_util.map_min_pos
            for key,node in pairs(network.nodes) do
                if f_util.is_same_pos(node.pos,node_pos) then
                    table.remove(network.nodes, key)
                else
                    network.min_pos = f_util.get_min_pos(network.min_pos, node.pos)
                    network.max_pos = f_util.get_max_pos(network.max_pos, node.pos)
                end
            end
            if table.getn(network.nodes) > 0 then node_network.save_network(set_values, network, network_key)
            else node_network.delete_network(set_values, network_key) end
        end
    end
end

--Set values is an array of possible networks that the block can connect to
--Type is an optional paramter which only checks neighbour blocks of a certain type
---@param set_values SetValue[]
---@param pos Position
---@param type string | nil
function node_network.on_node_place(set_values, pos, type)
    for _,set_value in pairs(set_values) do
        f_util.debug(set_value)
        local connected_networks = node_network.get_adjacent_networks(set_value, pos, type)
        if table.getn(connected_networks) == 0 then
            node_network.create_network(set_value, pos)
        elseif table.getn(connected_networks) == 1 then
            local network, network_key = connected_networks[1], connected_networks[1].key
            network = node_network.add_node(pos,network)
            --update_key_metadata(set_values, network, pos) -- Dont need to add pos since there is only 1 node
            node_network.save_network(set_value, network, network_key)
        else
            merge_networks(set_value, connected_networks, pos)
        end
    end
end