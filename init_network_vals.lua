f_constants.networks = {
    electricity = {save_id = "wire", io_name = "Electricity", types = {f_constants.wire.name, f_constants.turbine.name}, production_functions = {}},
    pipe = {save_id = "pipe", resource = {name = "steam", max_per_node = 10}, types = {f_constants.pipe.name, f_constants.turbine.name}}
}
f_constants.networks.electricity.production_functions[f_constants.turbine.name] = turbine.get_production
f_constants.network_updates = {"electricity"}