---@param save_id string
---@return Network_save[]
local function get_set(save_id)
    return minetest.deserialize(factory_mod_storage:get_string(save_id .. "_network")) or {}
end

---@param save_id string
---@param set Network_save[]
local function save_set(save_id, set)
    minetest.chat_send_all("Saving")
    factory_mod_storage:set_string(save_id .. "_network", minetest.serialize(set))
end

--Recursive function to hopefully generate a new network in cases of network splits
---@param network Network
---@param old_network Network
---@param pos Position
---@param types string[]
local function recursive_add(network, old_network, pos, types)
    for i, node in pairs(old_network.nodes) do
        if f_util.is_same_pos(node.pos, pos) then
            network:add_node(node)
            old_network:delete_node(node.pos, i)
            for _, adj_pos in pairs(f_util.get_adjacent_nodes(pos, types)) do
                network, old_network = recursive_add(network, old_network, adj_pos, types)
            end
            return network, old_network
        end
    end
    return network, old_network
end

---@param networks Network[]
---@param extra_node Node
---@param n_class Network | IO_network
---@param save_id string
---@return number
local function merge_networks(networks, extra_node, n_class, save_id)
    local new_network = n_class(nil, save_id)
    for _, network in pairs(networks) do
        new_network:merge(network)
        network:delete()
    end
    local key = new_network:add_node(extra_node)
    new_network:save()
    return key
end

---@param n Network
---@param pos Position | nil
---@param save_id string
local function construct(n, pos, save_id)
    n.set_value = Network.set_values[save_id]
    n.loaded = false
    if pos then n.loaded = n:load(pos) end
    if not n.loaded then
        n.min_pos = f_util.map_max_pos
        n.max_pos = f_util.map_min_pos
        n.nodes = {}
    end
end

---@class Network
---@field public set_value SetValue
---@field public nodes Node[]
---@field public min_pos Position
---@field public max_pos Position
---@field public key number
Network = class(construct)

---@param pos Position
---@return boolean
function Network:load(pos)
    f_util.cdebug("Load called in network")
    for key, network in pairs(get_set(self.set_value.save_id)) do
        --networkArea is used for quickly reducing the search space.
        local networkArea = VoxelArea:new({MinEdge = network.min_pos, MaxEdge = network.max_pos})
        if networkArea:containsp(pos) then
            for _,node in pairs(network.nodes) do
                if f_util.is_same_pos(node.pos,pos) then
                    self.key = key
                    self:from_save(network)
                    return true
                end
            end
        end
    end
    return false    
end

---@param network Network_save
function Network:from_save(network)
    self.nodes = network.nodes
    self.min_pos = network.min_pos
    self.max_pos = network.max_pos
end

function Network:save()
    local set = get_set(self.set_value.save_id)
    if self.key then
        set[self.key] = self:to_save()
    else
        table.insert(set, self:to_save())
        self.key = table.getn(set)
    end
    save_set(self.set_value.save_id, set)
end

---@return Network_save
function Network:to_save()
    local v = {}
    v.nodes = self.nodes
    v.min_pos = self.min_pos
    v.max_pos = self.max_pos
    return v
end

function Network:delete()
    if self.key then
        local set = get_set(self.set_value.save_id)
        table.remove(set, self.key)
        save_set(self.set_value.save_id, set)
    else
        minetest.debug("[Factorymod]Soft Error: Tried to delete a network which isn't saved")
    end
end

---@param pos Position
---@return Node, number
function Network:get_node(pos)
	for key, node in pairs(self.nodes) do
		if(f_util.is_same_pos(node.pos, pos)) then
			return node, key
		end
	end
end

---@param node Node
---@return number
function Network:add_node(node)
    self.min_pos = f_util.get_min_pos(self.min_pos, node.pos)
    self.max_pos = f_util.get_max_pos(self.max_pos, node.pos)
    table.insert(self.nodes, node)
    return table.getn(self.nodes)
end

---@param node Node
---@param key number
function Network:set_node(node, key)
    self.nodes[key] = node
end

---@param pos Position
---@param key number
function Network:delete_node(pos, key)
    local node
    if not key then node, key = self:get_node(pos) end
    table.remove(self.nodes, key)
end

---@param message string
function Network:update_infotext(message)
    for _, node in pairs(self.nodes) do
        local meta = minetest.get_meta(node.pos)
        meta:set_string("infotext",  message)
    end
end

function Network:merge(network2)
    for i, node in pairs(network2.nodes) do
        self:add_node(node)
    end
end

--Has no function in the base class, but can be overridden in child classes
function Network:force_network_recalc()
end


--Start of global methods

---@param save_id string
---@param pos Position
---@param ensure_continuity boolean
---@param n_class Network
function Network.on_node_destruction(save_id, pos, ensure_continuity, n_class)
    ---@type Network
    local set_value = Network.set_values[save_id]
    local network = n_class(pos, save_id)
    if network.loaded then
        if table.getn(f_util.get_adjacent_nodes(pos, set_value.types)) > 1 and ensure_continuity == true then
            network:delete_node(pos)
            while table.getn(network.nodes) > 0 do
                local initial_node = math.random(table.getn(network.nodes))
                local new_network = n_class(nil, save_id)
                new_network, network = recursive_add(new_network, network, network.nodes[initial_node].pos, set_value.types)
                new_network:save()
            end
            network:delete()
        else
            --Reset the bounding box to the whole map so it can be shrunk to the right size in the for loop
            network.min_pos = f_util.map_max_pos
            network.max_pos = f_util.map_min_pos
            for key,node in pairs(network.nodes) do
                if f_util.is_same_pos(node.pos, pos) then
                    table.remove(network.nodes, key)
                else
                    network.min_pos = f_util.get_min_pos(network.min_pos, node.pos)
                    network.max_pos = f_util.get_max_pos(network.max_pos, node.pos)
                end
            end
            if table.getn(network.nodes) > 0 then network:save()
            else network:delete() end
        end
    end
end

---@param pos Position
---@param save_id string
---@return Network[]
--Type is optional filter to reduce search space
function Network.get_adjacent_networks(pos, n_class, save_id)
    local connected_nodes = f_util.get_adjacent_nodes(pos, Network.set_values[save_id].types)
    local networks = {}
    for _, adj_pos in pairs(connected_nodes) do
        ---@type Network
        local n = n_class(adj_pos, save_id)
        if n.loaded then  
            local duplicate = false
            for _, network in pairs(networks) do
                if(n.key == network.key) then duplicate = true end
            end
            if not duplicate then table.insert(networks, n) end
        end
    end
    return networks
end

--Set values is an array of possible networks that the block can connect to
---@param save_ids string[]
---@param n_class Network
---@param node Node
---@return number[] @comment array key of inserted node
function Network.on_node_place(save_ids, n_class, node)
    local inserted_keys = {}
    for _,save_id in pairs(save_ids) do
        f_util.debug(save_ids)
        local set_value = Network.set_values[save_id]
        local connected_networks = Network.get_adjacent_networks(node.pos, n_class, save_id)
        if table.getn(connected_networks) == 0 then
            local n = n_class(nil, save_id)
            inserted_keys[save_id] = n:add_node(node)
            n:save()
        elseif table.getn(connected_networks) == 1 then
            local network = connected_networks[1]
            inserted_keys[save_id] = network:add_node(node)
            network:save()
        else
            inserted_keys[save_id] = merge_networks(connected_networks, node, n_class, save_id)
        end
    end
    return inserted_keys
end

Network.set_values = {}

---@param save_id string
---@param unit_name string| nil
function Network.register_network(save_id, unit_name)
    Network.set_values[save_id] = {save_id = save_id, unit_name = unit_name, types = {}, usage_functions = {}}
end

function Network.register_node(save_id, block_name)
    table.insert(Network.set_values[save_id].types,  block_name)
end