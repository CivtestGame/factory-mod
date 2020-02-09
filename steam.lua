function f_steam.get_capacity_left(pos, network) -- Network is optional but preffered. Saves lookups
	local node = minetest.get_node(pos)
	if node.name == f_constants.boiler.name then
		local meta = minetest.get_meta(pos)
		local steam_units = meta:get_float("steam_units") or 0
		return f_constants.boiler.max_steam - steam_units
	elseif node.name == f_constants.pipe.name then
		if network == nil then network = node_network.get_network(f_constants.pipe.set_values, pos) end
		return pipe.get_max_steam(network) - f_steam.get_steam(pos, network)
	else minetest.debug("Get capacity called with invalid name(" .. node.name .. ")!")
	end
end

function f_steam.extract_steam(pos, max_steam, network, network_key) -- Network is optional but preffered. Saves lookups
	local node = minetest.get_node(pos)
	if node.name == f_constants.boiler.name then
		local meta = minetest.get_meta(pos)
		local steam_units = meta:get_float("steam_units") or 0
		local extracted_units = math.min(steam_units, max_steam) -- If we have less steam than we're trying to extract, only transfer as much as we have
		steam_units = steam_units - extracted_units
		boiler.update_infotext(meta)
		meta:set_float("steam_units", steam_units)
		return extracted_units
	elseif node.name == f_constants.pipe.name then
		--[[if not network then network, network_key = node_network.get_network(f_constants.pipe.set_values, pos) end
		local extracted_units = math.min(f_steam.get_steam(pos, network), max_steam)
		minetest.debug("extract" .. extracted_units)
		network.steam_units = f_steam.get_steam(pos, network) - extracted_units
		pipe.update_infotext(network)
		node_network.save_network(f_constants.pipe.set_values, network, network_key)
		return extracted_units]]--
		resource_network.extract(f_constants.pipe.set_values, pos, max_steam, network, network_key)
	else minetest.debug("Extract steam called with invalid name(" .. node.name .. ")!")
	end
end

function f_steam.add_steam(pos, amount, network, network_key) -- Network is optional but preffered. Saves lookups
	local node = minetest.get_node(pos)
	if node.name == f_constants.boiler.name then
		local meta = minetest.get_meta(pos)
		local steam_units = meta:get_float("steam_units") or 0
		local steam_to_add = math.min(amount, f_constants.boiler.max_steam-steam_units)
		steam_units = steam_units + steam_to_add
		boiler.update_infotext(meta)
		meta:set_float("steam_units", steam_units)
		return steam_to_add
	elseif node.name == f_constants.pipe.name then
		if not network then network, network_key = node_network.get_network(f_constants.pipe.set_values, pos) end
		local max_steam = pipe.get_max_steam(network)
		local steam_to_add = math.min(amount, max_steam - f_steam.get_steam(pos, network))
		network.steam_units = f_steam.get_steam(pos, network) + steam_to_add
		pipe.update_infotext(network)
		node_network.save_network(f_constants.pipe.set_values, network, network_key)
		return steam_to_add
	else minetest.debug("Add steam called with invalid name(" .. node.name .. ")!")
	end
end

function f_steam.transfer_steam(from, to, max_amount)
	local to_transfer = math.min(f_steam.get_capacity_left(to), max_amount)
    local extracted = f_steam.extract_steam(from, to_transfer)
    f_steam.add_steam(to, extracted)
    return extracted
end

function f_steam.get_steam(pos, network)
	local node = minetest.get_node(pos)
	if node.name == f_constants.boiler.name then
		local meta = minetest.get_meta(pos)
		return meta:get_float("steam_units") or 0
	elseif node.name == f_constants.pipe.name then
		network = network or node_network.get_network(f_constants.pipe.set_values, pos)
		return network.steam_units or 0
	else minetest.debug("Get steam called with invalid node name(" .. node.name .. ")!")
	end
end