f_constants.boiler = {name = minetest.get_current_modname()..":boiler", max_steam = 500, max_steam_push = 10, steam_produced_per_second = 5}

local function get_formspec(burn_pct)
    local formspec = {
        "size[8,6]",
        "list[context;fuel;3,0;1,1;]",
        "image[4,0;1,1;default_furnace_fire_bg.png^[lowpart:",
        (burn_pct),":default_furnace_fire_fg.png]",
        "list[current_player;main;0,2;8,4;]",
        "listring[]",
    }
    return table.concat(formspec, "")
end

local function boiler_node_timer(pos, elapsed)
	--
	-- Initialize metadata
	--
	local time_elapsed = elapsed
	local meta = minetest.get_meta(pos)
	local fuel_time = meta:get_float("fuel_time") or 0
	local fuel_totaltime = meta:get_float("fuel_totaltime") or 0

	local inv = meta:get_inventory()

	local fuel

	local update = true

	while elapsed > 0 and update do
		update = false

		local el = math.min(elapsed, fuel_totaltime - fuel_time)

		-- Check if we have enough fuel to burn
		if fuel_time < fuel_totaltime then
			-- The furnace is currently active and has enough fuel
			fuel_time = fuel_time + el
			-- If there is a cookable item then check if it is ready yet
			--Produce steam here
			f_steam.add_steam(pos,el*f_constants.boiler.steam_produced_per_second)
		else
			-- boiler ran out of fuel
			-- We need to get new fuel
			local afterfuel
			fuel, afterfuel = minetest.get_craft_result({method = "fuel", width = 1, items = inv:get_list("fuel")})

            if fuel.time == 0 then
				-- No valid fuel in fuel list
				fuel_totaltime = 0
			else
				-- Take fuel from fuel list
				inv:set_stack("fuel", 1, afterfuel.items[1])
				-- Put replacements in dst list or drop them on the furnace.
				local replacements = fuel.replacements
				if replacements[1] then
					local leftover = inv:add_item("dst", replacements[1])
					if not leftover:is_empty() then
						local above = vector.new(pos.x, pos.y + 1, pos.z)
						local drop_pos = minetest.find_node_near(above, 1, {"air"}) or above
						minetest.item_drop(replacements[1], nil, drop_pos)
					end
				end
				update = true
				fuel_totaltime = fuel.time + (fuel_totaltime - fuel_time)
			end
			fuel_time = 0
		end

		elapsed = elapsed - el
	end

	if fuel and fuel_totaltime > fuel.time then
		fuel_totaltime = fuel.time
	end
	
	local connected_pipes = f_util.find_neighbor_pipes(pos)
	local steam_per_pipe = f_constants.boiler.max_steam_push*time_elapsed / table.getn(connected_pipes)
	local transffered = 0

	for i, pipe_pos in pairs(connected_pipes) do
		local to_transfer = math.min(resource_network.get_capacity_left(f_constants.networks.pipe, pipe_pos), steam_per_pipe)
		local extracted = f_steam.extract_steam(pos, to_transfer)
		resource_network.add(f_constants.networks.pipe, pipe_pos, extracted)
		transffered = transffered + extracted
	end

    local result = false

    if fuel_totaltime ~= 0 then
		-- make sure timer restarts automatically
		result = true
        local pct_fuel_left = 100 - math.floor(fuel_time / fuel_totaltime * 100)
        meta:set_string("formspec", get_formspec(pct_fuel_left))
	else
        minetest.get_node_timer(pos):stop()
        meta:set_string("formspec", get_formspec(0))
	end

	meta:set_float("fuel_totaltime", fuel_totaltime)
    meta:set_float("fuel_time", fuel_time)

	return result
end

function boiler.update_infotext(meta)
	meta:set_string("infotext",  "Contains " .. meta:get_float("steam_units") .. " units of steam")
end

function boiler.get_reg_values()   
    return f_constants.boiler.name, {
        description = "Boiler",
        tiles = {"^[colorize:#a83232"},
        on_timer = boiler_node_timer,
        groups = {choppy = 2, oddly_breakable_by_hand = 2, wood = 1},
        on_construct = function(pos)
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
            inv:set_size('fuel', 1)
            meta:set_string("formspec", get_formspec(0))
        end,
        on_metadata_inventory_move = function(pos)
            minetest.get_node_timer(pos):start(1.0)
        end,
        on_metadata_inventory_put = function(pos)
            -- start timer function, it will sort out whether furnace can burn or not.
            minetest.get_node_timer(pos):start(1.0)
        end,
    }
end

