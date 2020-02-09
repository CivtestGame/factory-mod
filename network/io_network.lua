--Network which keeps track of input and output devices.'

local function recalculate(set_values, network)
	local production = 0;
	local usage = 0;
	local demand = 0;
	local pdRatio = 1.0; --Production/Demand
	for _, node in pairs(network.nodes) do
		production = production + (node.production or 0)
		demand = demand + (node.demand or 0)
	end
	if(demand > production) then
		pdRatio = production/demand;
		usage = production;
		for _, node in pairs(network[set_values.io_name].usage_nodes) do
			node.usage = node.demand * pdRatio;
		end
	else
		usage = demand;
		for _, node in pairs(network[set_values.io_name.usage_nodes]) do
			node.usage = node.demand
		end
	end
	network[set_values.io_name].production = production;
	network[set_values.io_name].demand = demand;
	network[set_values.io_name].usage = usage;
	network[set_values.io_name].pdRatio = pdRatio;
	minetest.debug(f_util.dump(network))
end

---@param io_name string
---@param network Network
---@return Network
local function setup_network(io_name, network)
	if not network[io_name] then
		network[io_name] = { production = 0, demand = 0, usage = 0}
	end
	return network
end

local function update_infotext(set_values, network)
	node_network.update_infotext(network, "Production: " .. network[set_values.io_name].production .. " Demand: " .. network[set_values.io_name].demand .. " Usage: " .. network[set_values.io_name].usage)
end

--Update input/output usage/production
---@param set_values SetValue
---@param pos Position
---@param production number
---@param network Network | nil
function io_network.update_input(set_values, pos, production, network)
	network = network or node_network.get_network(set_values, pos)
	local node, key = node_network.get_node(set_values, pos, network)
	local diff = production - (node.production or 0)
	node.production = production
	network = node_network.set_node(set_values, node, key, network)
	network = setup_network(set_values.io_name, network) -- Avoids trying to do math on nil values
	network[set_values.io_name].production = network[set_values.io_name].production + diff
	update_infotext(set_values, network)
	node_network.save_network(set_values,network)
end

--Returns available usage
function io_network.update_output(set_values, pos, demand, network)
	network = network or node_network.get_network(set_values, pos)
	local node, key = node_network.get_node(set_values, pos, network)
	local diff = demand - (node.demand or 0)
	node.demand = demand
	network = node_network.set_node(set_values, node, key, network)
	network = setup_network(set_values.io_name, network) -- Avoids trying to do math on nil values
	network[set_values.io_name].demand = network[set_values.io_name].demand + diff
	update_infotext(set_values, network)
	node_network.save_network(set_values,network)
end
