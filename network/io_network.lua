--Network which keeps track of input and output devices.'

---@param n IO_network
---@param pos Position | nil
---@param save_id string
local function construct (n, pos, save_id)
	IO_network._base.init(n, pos, save_id)
	if not n.loaded then
		minetest.chat_send_all("Network not loaded")
		n.production_nodes = {}
		n.usage_nodes = {}
		n.production = 0
		n.demand = 0
		n.usage = 0
		n.pdRatio = 0
	end
end

---@class IO_network : Network
---@field public _base Network
---@field public production_nodes number[]
---@field public usage_nodes number[]
---@field public production number
---@field public demand number
---@field public usage number
IO_network = class(Network,construct)

---@param network IO_network_save
function IO_network:from_save(network)
	self._base.from_save(self, network)
	self.production_nodes = network.production_nodes
	self.usage_nodes = network.usage_nodes
	self.production = network.production
	self.demand = network.demand
	self.usage = network.usage
	self.pdRatio = network.pdRatio
end

function IO_network:to_save()
	local v = self._base.to_save(self)
	v.production_nodes = self.production_nodes
	v.usage_nodes = self.usage_nodes
	v.production = self.production
	v.demand = self.demand
	v.usage = self.usage
	v.pdRatio = self.pdRatio
	return v
end

function IO_network:update_infotext()
	self._base.update_infotext(self, "Production: " .. self.production .. " Demand: " .. self.demand .. " Usage: " .. self.usage)
end

function IO_network:calc_pdratio()
	if not self.demand or not self.production or self.demand == 0 then
		self.pdRatio = 0
	else
		self.pdRatio = self.production / self.demand
	end
end

---@param pos Position
---@param key number
function IO_network:add_to_production_nodes(pos, key)
	local node_name = minetest.get_node(pos).name
	self.production_nodes[key] = node_name
end

---@param pos Position
---@param key number
function IO_network:add_to_usage_nodes(pos, key)
	local node_name = minetest.get_node(pos).name
	self.usage_nodes[key] = node_name
end

---@param pos Position
---@param production number
function IO_network:update_production(pos, production)
	local node, node_key = self:get_node(pos)
	local diff = production - (node.production or 0)
	node.production = production
	self:set_node(node, node_key)
	self.production = self.production + diff
	self:add_to_production_nodes(node.pos, node_key)
	self:update_usage_nodes()
	self:update_infotext()
end

---@param pos Position
---@param demand number
function IO_network:update_demand(pos, demand)
	local node, node_key = self:get_node(pos)
	local diff = demand - (node.demand or 0)
	node.demand = demand
	self:set_node(node, node_key)
	self.demand = self.demand + diff
	self:add_to_usage_nodes(node.pos, node_key)
	self:update_usage_nodes(pos)
	self:update_infotext()
end

---@param pos Position
---@param usage number
function IO_network:update_usage(pos, usage)
	local node, node_key = self:get_node(pos)
	local diff = usage - (node.usage or 0)
	node.usage = usage
	self:set_node(node, node_key)
	self.usage = self.usage + diff
	self:add_to_usage_nodes(node.pos, node_key)
	self:update_infotext()
end

function IO_network:check_burntime(pos, time)
	self:load(pos)
	minetest.chat_send_all("Checking burn time")
	local node, node_key = self:get_node(pos)
	if not node.burn_end or os.time() >= node.burn_end then -- There is no burn time left, turn off the boiler
		minetest.chat_send_all("Burn time is up!")
		node.burn_end = nil
		self:set_node(node, node_key)
		self:update_production(pos, 0)
		self:save()
		--Call same recalc function
	end	
end

---@param exclude_pos Position
function IO_network:update_usage_nodes(exclude_pos)
	local old_pd = self.pdRatio or 0
	self:calc_pdratio()
	if old_pd >= 1 and self.pdRatio >= 1  then -- We dont need to update usage nodes. There is no change
	else -- We will need to update usgae nodes
		for node_key, node_name in pairs(self.usage_nodes) do
			local node = self.nodes[node_key]
			if not exclude_pos or not f_util.is_same_pos(exclude_pos, node.pos) then
				local usage = (node.demand or 0) * self.pdRatio
				self:update_usage(node.pos, usage)
				if self.set_value.usage_functions and self.set_value.usage_functions[node_name] then
					self.set_value.usage_functions[node_name](node, self, usage)
				end
			end
		end
	end
end

---@param network IO_network
function IO_network:merge(network)
	self._base.merge(self, network)
	minetest.chat_send_all("Io network merge called")
	for key, node in pairs(self.nodes) do
		if node.production then self:add_to_production_nodes(node.pos,key) end
		if node.demand then self:add_to_usage_nodes(node.pos,key) end
		if node.usage then self:add_to_usage_nodes(node.pos,key) end
	end
	self:force_network_recalc()
	self:update_usage_nodes()
end

function IO_network:force_network_recalc()
	self.demand = 0
	self.usage = 0
	self.production = 0
	for node_key, node_name in pairs(self.usage_nodes) do
		local node = self.nodes[node_key]
		self.demand = self.demand + (node.demand or 0)
		self.usage = self.usage + (node.usage or 0)
	end
	for node_key, node_name in pairs(self.production_nodes) do
		local node = self.nodes[node_key]
		self.production = self.production + (node.production or 0)
	end
end

---@param save_id string
---@param node Node
---@param io_type string
---@param initial_value number
function IO_network.on_node_place(save_id, node, io_type, initial_value)
	local set_value = Network.set_values[save_id]
	local key = Network.on_node_place({save_id}, IO_network, node)[save_id]
	local network = IO_network(node.pos, save_id)
	if io_type == "use" then
		network:update_demand(node.pos, initial_value)
	elseif io_type == "prod" then
		network:update_production(node.pos, initial_value)
	end
	network:update_infotext()
	network:save()
end

---@param save_id string
---@param node Node
---@param io_type string
function IO_network.on_node_destruction(save_id, node, io_type, ensure_continuity)
	local set_value = Network.set_values[save_id]
	local network = IO_network(node.pos, save_id)
	if io_type == "use" then
		network:update_demand(node.pos, 0)
		network:update_usage(node.pos, 0)
	elseif io_type == "prod" then
		network:update_production(node.pos, 0)
	end
	network:save()
	Network.on_node_destruction(node.pos, ensure_continuity, IO_network, save_id)
end

---@param save_id string
---@param block_name string
---@param usage_function function
function IO_network.register_usage_node(save_id, block_name, usage_function)
	Network.register_node(save_id, block_name)
	Network.set_values[save_id].usage_functions[block_name] = usage_function
end

---@param save_id string
---@param block_name string
function IO_network.register_production_node(save_id, block_name)
	Network.register_node(save_id, block_name)
end