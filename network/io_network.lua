--Network which keeps track of input and output devices.'


local function recalculate(set_values, network)
	local production = 0;
	local usage = 0;
	local demand = 0;
	local pdRatio = 1.0; --Production/Demand
	for _, node in pairs(network[set_values.io_name].production_nodes) do
		production = production+node.production;
	end
	for _, node in pairs(network[set_values.io_name].usage_nodes) do
		demand = demand+node.demand;
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
end

--Add input

--Add output

--Remove input

--Remove output

--Update input/output usage/production
function io_network.update_input(set_values, pos, production, network)
	network = network or node_network.get_network(set_values, pos)
	for _, node in pairs(network[set_values.io_name].production_nodes) do
		if(f_util.is_same_pos(node.pos, pos)) then 
			node.production = production;
		end;
	end
	recalculate(set_values, network);
end

--Returns available usage
function io_network.update_output(set_values, pos, demand, network)
	network = network or node_network.get_network(set_values, pos)
	for _, node in pairs(network[set_values.io_name].usage_nodes) do
		if(f_util.is_same_pos(node.pos, pos)) then
			node.demand = demand;
		end;
	end
	recalculate(set_values, network);
end