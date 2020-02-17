--Network which keeps track of input and output devices.'

---@param n IO_network
---@param pos Position | nil
---@param set_value SetValue
local function construct (n, pos, set_value)
	IO_network._base.init(n, pos, set_value)
	f_util.cdebug(n.loaded)
	if not n.loaded then
		n.production_nodes = {}
		n.usage_nodes = {}
		n.production = 0
		n.demand = 0
		n.usage = 0
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
    f_util.cdebug("From save called in IO network")
	self.production_nodes = network.production_nodes
	self.usage_nodes = network.usage_nodes
	self.production = network.production
	self.demand = network.demand
	self.usage = network.usage
end

function IO_network:to_save()
	local v = self._base.to_save(self)
	minetest.chat_send_all("In io")
    f_util.cdebug(v)
    f_util.cdebug("To save called in IO network")
	v.production_nodes = self.production_nodes
	v.usage_nodes = self.usage_nodes
	v.production = self.production
	v.demand = self.demand
	v.usage = self.usage
    f_util.cdebug(v)
	return v
end

function IO_network:update_infotext()
	self._base.update_infotext(self, "Production: " .. self.production .. " Demand: " .. self.demand .. " Usage: " .. self.usage)
end

---@param pos Position
---@param production number
function IO_network:update_input(pos, production)
	local node, node_key = self:get_node(pos)
	local diff = production - (node.production or 0)
	node.production = production
	self:set_node(node, node_key)
	self.production = self.production + diff
	--Call a function which checks if we need to update usage nodes
	self:update_infotext()
end

---@param pos Position
---@param demand number
function IO_network:update_output(pos, demand)
	local node, node_key = self:get_node(pos)
	local diff = demand - (node.demand or 0)
	node.demand = demand
	self:set_node(node, node_key)
	self.demand = self.demand + diff
	--Call a function which checks if we need to update usage nodes
	self:update_infotext()
end

function IO_network:check_burntime(pos, time)
	minetest.chat_send_all("Burn time called")
	local node, node_key = self:get_node(pos)
	if not node.burn_time or time >= node.burn_time then -- There is no burn time left, turn off the boiler
		minetest.chat_send_all("Burn time is up!")
		node.burn_time = 0
		self:update_input(pos, 0)
		--Call same recalc function
	end	
end

---@param set_value SetValue
---@param network Network
local function update_usage(set_value, network)
	if network[set_value.io_name] then
		local io_values = network[set_value.io_name]
		local old_pd = io_values.pdRatio
		io_values.pdRatio = io_values.production / io_values.demand
		network[set_value.io_name] = io_values
		node_network.save_network(set_value, network)
		if old_pd >= 1 and io_values.pdRatio >= 1  then -- We dont need to update usage nodes. There is no change
		else -- We will need to update usgae nodes
			for node_key, node_name in pairs(network[set_value.io_name].usage_nodes) do
				local node = network.nodes[node_key]
				if set_value.usage_functions and set_value.usage_functions[node_name] then
					set_value.usage_functions[node_name](node.pos, io_values.pdRatio, network)
				end
			end
		end
	end
end

---@param set_value SetValue
---@param node Node
---@param io_type string
function io_network.on_node_place(set_value, node, io_type)
	local key = node_network.on_node_place({set_value}, node)[set_value.save_id]
	local network = node_network.get_network(set_value, node.pos)
	setup_network(set_value.io_name, network)
	local node_name = minetest.get_node(node.pos)
	if io_type == "use" then
		network[set_value.io_name].usage_nodes[key] = node_name.name
	elseif io_type == "prod" then
		network[set_value.io_name].production_nodes[key] = node_name.name
	end
	node_network.save_network(set_value, network)
end

local timer = 0
---@param elapsed number
--[[function io_network.tick_networks(elapsed)
	timer = timer + elapsed;
	if timer >= 1 then
		for _, set_name in pairs(f_constants.network_updates) do
			local set_value = f_constants.networks[set_name]
			for key, network in pairs(node_network.get_set(set_value)) do
				if network[set_value.io_name] then
					if network[set_value.io_name].production_nodes then
						for node_key, node_name in pairs(network[set_value.io_name].production_nodes) do
							local node = network.nodes[node_key]
							if set_value.production_functions and set_value.production_functions[node_name] then
								local production = set_value.production_functions[node_name](node.pos, timer)
								local diff = production - (node.production or 0)
								node.production = production
								network = node_network.set_node(set_value, node, key, network)
								network[set_value.io_name].production = network[set_value.io_name].production + diff
							end
						end
					end
					if network[set_value.io_name].usage_nodes then
						for node_key, node_name in pairs(network[set_value.io_name].usage_nodes) do
							local node = network.nodes[node_key]
							if set_value.usage_functions and set_value.usage_functions[node_name] then
								local demand = set_value.usage_functions[node_name](node.pos, timer)
								local diff = demand - (node.demand or 0)
								node.demand = demand
								network = node_network.set_node(set_value, node, key, network)
								network[set_value.io_name].demand = network[set_value.io_name].demand + diff
							end
						end
					end
					update_infotext(set_value, network)
					node_network.save_network(set_value,network)
				end
			end
		end
		timer = 0
	end
end]--]]