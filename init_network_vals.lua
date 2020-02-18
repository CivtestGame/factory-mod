f_constants.networks = {
    electricity = {save_id = "wire", unit_name = "Watt", 
        types = {f_constants.wire.name, f_constants.turbine.name, f_constants.usage.name},
        production_functions = {}, usage_functions = {}},
    pipe = {save_id = "pipe", unit_name = "Steam", 
        types = {f_constants.boiler.name, f_constants.pipe.name, f_constants.turbine.name},
        production_functions = {}, usage_functions = {}}
}
f_constants.networks.electricity.production_functions[f_constants.turbine.name] = turbine.get_production
f_constants.networks.electricity.usage_functions[f_constants.usage.name] = usage.update
f_constants.networks.pipe.usage_functions[f_constants.turbine.name] = turbine.update
f_constants.network_updates = {"electricity"}