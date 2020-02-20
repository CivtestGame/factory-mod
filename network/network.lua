---@param save_id string
---@return Network_save[]
local function get_set(save_id)
    return minetest.deserialize(factory_mod_storage:get_string(save_id .. "_network")) or {}
end

---@param save_id string
---@param set Network_save[]
local function save_set(save_id, set)
    factory_mod_storage:set_string(save_id .. "_network", minetest.serialize(set))
end

--Recursive function to hopefully generate a new network in cases of network splits
---@param network Network
---@param old_network Network
---@param pos Position
---@param types string[]
local function recursive_add(network, old_network, pos, types)
    minetest.chat_send_all("Recursively adding " .. f_util.dump(pos))
    for key, node in pairs(old_network.nodes) do
        if f_util.is_same_pos(node.pos, pos) then
            network:add_node(node)
            table.remove(old_network.nodes, key) -- We dont use delete node here since we won't use the old network for anything
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
    local key = new_network:add_node(extra_node)
    for _, network in pairs(networks) do
        new_network:merge(network)
        network:delete()
    end
    new_network:update_infotext()
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
        n:save()
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
        self.key = table.getn(set)+1
        table.insert(set, self:to_save())
    end
    minetest.chat_send_all("Saving this key " .. self.key .. " for this save_id " .. self.set_value.save_id)
    f_util.cdebug(self.nodes)
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
    minetest.chat_send_all("Deleting key ".. tostring(self.key))
    if self.key then
        local set = get_set(self.set_value.save_id)
        table.remove(set, self.key)
        save_set(self.set_value.save_id, set)
    else
        minetest.debug("[Factorymod]Soft Error: Tried to delete a network which isn't saved")
    end
    self = nil
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
---@return Node | nil
function Network:delete_node(pos)
    --Reset the bounding box to the whole map so it can be shrunk to the right size in the for loop
    self.min_pos = f_util.map_max_pos
    self.max_pos = f_util.map_min_pos
    local rnode --return values
    for key,node in pairs(self.nodes) do
        if f_util.is_same_pos(node.pos, pos) then
            rnode = node
            table.remove(self.nodes, key)
        else
            self.min_pos = f_util.get_min_pos(self.min_pos, node.pos)
            self.max_pos = f_util.get_max_pos(self.max_pos, node.pos)
        end
    end
    if table.getn(self.nodes) > 0 then
        self:save()
        return rnode
    else self:delete() end
end

---@param message string
function Network:set_infotext(message, pos)
    minetest.chat_send_all("Pos:" .. f_util.dump(pos) .. "Setting this message ".. message)
    if pos then
        local meta = minetest.get_meta(pos)
        meta:set_string("infotext",  message)
    else
        for _, node in pairs(self.nodes) do
            minetest.chat_send_all("Looped to node " .. f_util.dump(node))
            local meta = minetest.get_meta(node.pos)
            meta:set_string("infotext",  message)
        end
    end
end

function Network:update_infotext()
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
    minetest.chat_send_all("Calling constructor")
    local network = n_class(pos, save_id)
    minetest.chat_send_all("Constructor called. Key is" .. tostring(network.key) .. " loaded is " ..tostring(network.loaded))
    local connected_nodes = f_util.get_adjacent_nodes(pos, set_value.types)
    minetest.chat_send_all("1")
    if network.loaded then
        if table.getn(connected_nodes) > 1 and ensure_continuity == true then
            minetest.chat_send_all("2")
            local node, key = network:get_node(pos)
            minetest.chat_send_all("3")
            table.remove(network.nodes, key) -- We dont use delete node here since we won't use the old network for anything
            minetest.chat_send_all("4")
            while table.getn(network.nodes) > 0 do
                minetest.chat_send_all("5")
                local initial_node = math.random(table.getn(network.nodes))
                local new_network = n_class(nil, save_id)
                minetest.chat_send_all("6")
                new_network, network = recursive_add(new_network, network, network.nodes[initial_node].pos, set_value.types)
                minetest.chat_send_all("Done recursively adding.")
                new_network:force_network_recalc()
                minetest.chat_send_all("7")
                new_network:save()
                minetest.chat_send_all("8")
            end
            minetest.chat_send_all("9")
            network:delete()
            minetest.chat_send_all("After deleting old network")
        else
            network:delete_node(pos)
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
---@param save_id string
---@param n_class Network
---@param node Node
---@return number[] @comment array key of inserted node
function Network.on_node_place(save_id, node, n_class)
    local inserted_key
    local connected_networks = Network.get_adjacent_networks(node.pos, n_class, save_id)
    if table.getn(connected_networks) == 0 then
        local n = n_class(nil, save_id)
        inserted_key = n:add_node(node)
        n:save()
    elseif table.getn(connected_networks) == 1 then
        local network = connected_networks[1]
        inserted_key = network:add_node(node)
        network:save()
    else
        inserted_key = merge_networks(connected_networks, node, n_class, save_id)
    end
    return inserted_key
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