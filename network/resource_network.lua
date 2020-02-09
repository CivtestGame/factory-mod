function resource_network.get_capacity(set_values, network)
    return set_values.resource.max_per_node*table.getn(network.nodes)
end

function resource_network.get_capacity_left(set_values, pos, network) -- Network is optional but preffered. Saves lookups
	if network == nil then network = node_network.get_network(set_values, pos) end
	return resource_network.get_capacity(set_values, network) - resource_network.get(set_values, pos, network)
end

function resource_network.extract(set_values, pos, max_resource, network, network_key) -- Network is optional but preffered. Saves lookups
	if not network then network, network_key = node_network.get_network(set_values, pos) end
	local extracted_units = math.min(resource_network.get(set_values, pos, network), max_resource)
    local amount = resource_network.get(set_values, pos, network) - extracted_units
    resource_network.set(set_values, amount, pos, network)
	resource_network.update_infotext(set_values, network)
	node_network.save_network(set_values, network, network_key)
	return extracted_units
end

function resource_network.add(set_values, pos, amount, network, network_key) -- Network is optional but preffered. Saves lookups
	if not network then network, network_key = node_network.get_network(set_values, pos) end
	local max_resource = resource_network.get_capacity(set_values, network)
	local resource_to_add = math.min(amount, max_resource - resource_network.get(set_values, pos, network))
	local amount = resource_network.get(set_values, pos, network) + resource_to_add
    resource_network.set(set_values, amount, pos, network)
	resource_network.update_infotext(set_values, network)
	node_network.save_network(set_values, network, network_key)
	return resource_to_add
end

function resource_network.set(set_values, value, pos, network)
    network = network or node_network.get_network(set_values, pos)
    network[set_values.resource.name] = value
end

function resource_network.get(set_values, pos, network)
	network = network or node_network.get_network(set_values, pos)
	return network[set_values.resource.name] or 0
end

function resource_network.update_infotext(set_values, network)
	node_network.update_infotext(network, "Contains " .. resource_network.get(set_values, nil, network) .. " units of " .. set_values.resource.name)
end