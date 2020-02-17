---@param save_id string
---@return Network_save[]
local function get_set(save_id)
    return minetest.deserialize(factory_mod_storage:get_string(save_id .. "_network")) or {}
end

---@param save_id string
---@param set Network_save[]
local function save_set(save_id, set)
    minetest.chat_send_all("Saving this")
    f_util.cdebug(set)
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
            table.remove(old_network.nodes, i)
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
---@param set_value SetValue
---@return number, Network
local function merge_networks(networks, extra_node, n_class, set_value)
    local set = get_set(set_value.save_id)
    local new_network = n_class(nil, set_value)
    for _, network in pairs(networks) do
        for i, node in pairs(network.nodes) do
            new_network:add_node(node)
        end
        network:delete(set)
    end
    local key = new_network:add_node(extra_node)
    new_network:save(set)
    return key
end


---@param n Network
---@param pos Position | nil
---@param set_value SetValue
local function construct(n, pos, set_value)
    f_util.cdebug(pos)
    n.set_value = set_value
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
    f_util.cdebug("From save called in network")
    self.nodes = network.nodes
    self.min_pos = network.min_pos
    self.max_pos = network.max_pos
end

---@param set Network_save[] | nil
function Network:save(set)
    set = set or get_set(self.set_value.save_id)
    if self.key then
        local save_value = self:to_save()
        minetest.chat_send_all("Saving this")
        f_util.cdebug(save_value)
        set[self.key] = save_value
    else
        table.insert(set, self:to_save())
    end
    save_set(self.set_value.save_id, set)
end

---@return Network_save
function Network:to_save()
    f_util.cdebug("To save called in network")
    f_util.cdebug(self)
    local v = {}
    v.nodes = self.nodes
    v.min_pos = self.min_pos
    v.max_pos = self.max_pos
    f_util.cdebug(v)
    return v
end

---@param set Network_save[] | nil
function Network:delete(set)
    if self.key then
        set = set or get_set(self.save_id)
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
function Network:delete_node(pos)
    local node, key = self.get_node(pos)
    table.remove(self.nodes, key)
end

---@param message string
function Network:update_infotext(message)
    for _, node in pairs(self.nodes) do
        local meta = minetest.get_meta(node.pos)
        meta:set_string("infotext",  message)
    end
end

--Start of global methods

---@param pos Position
---@param set_value SetValue
---@return Network[]
--Type is optional filter to reduce search space
function Network.get_adjacent_networks(pos, n_class, set_value)
    local connected_nodes = f_util.get_adjacent_nodes(pos, set_value.types)
    local networks = {}
    for _, pos in pairs(connected_nodes) do
        ---@type Network
        local n = n_class(pos, set_value)
        if n.loaded then
            table.insert(networks, n)
        end
    end
    return networks
end

---@param pos Position
---@param set_value SetValue
---@param ensure_continuity boolean
function Network.on_node_destruction(pos, ensure_continuity, n_class, set_value)
    ---@type Network
    local network = n_class(pos, set_value)
    if network.loaded then
        if table.getn(f_util.get_adjacent_nodes(pos, set_value.types)) > 1 and ensure_continuity == true then
            local set = get_set(set_value.save_id)
            network:delete_node(pos)
            while table.getn(network.nodes) > 0 do
                local initial_node = math.random(table.getn(network.nodes))
                local new_network = n_class(nil, set_value)
                new_network, network = recursive_add(new_network, network, network.nodes[initial_node].pos, set_value.types)
                new_network:save()
            end
            network:delete(set)
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

--Set values is an array of possible networks that the block can connect to
---@param set_values SetValue[]
---@param n_class Network
---@param node Node
---@return number[] @comment array key of inserted node
function Network.on_node_place(set_values, n_class, node)
    local inserted_keys = {}
    for _,set_value in pairs(set_values) do
        f_util.debug(set_value)
        local connected_networks = Network.get_adjacent_networks(node.pos, n_class, set_value)
        if table.getn(connected_networks) == 0 then
            local n = n_class(nil, set_value)
            minetest.chat_send_all("We are where we expected")
            f_util.cdebug(n)
            inserted_keys[set_value.save_id] = n:add_node(node)
            minetest.chat_send_all("after node add")
            f_util.cdebug(n)
            n:save()
        elseif table.getn(connected_networks) == 1 then
            local network = connected_networks[1]
            inserted_keys[set_value.save_id] = network:add_node(node)
            network:save()
        else
            inserted_keys[set_value.save_id] = merge_networks(connected_networks, node, n_class, set_value)
        end
    end
    return inserted_keys
end
