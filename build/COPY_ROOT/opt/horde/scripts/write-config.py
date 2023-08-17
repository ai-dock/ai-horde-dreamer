import os
from ruamel.yaml import YAML

BRIDGEDATA_PREFIX = "BRIDGE_"
BRIDGEDATA_TEMPLATE_PATH = None
BRIDGEDATA_PATH = '/opt/AI-Horde-Worker/bridgeData.yaml'

bridge_vars = None
bridge_data_template = None
bridge_data = None

# If there is already a config we shoudld not reset it
def set_bridgedata_template_path():
    global BRIDGEDATA_TEMPLATE_PATH
    
    if os.path.exists(BRIDGEDATA_PATH):
        BRIDGEDATA_TEMPLATE_PATH = BRIDGEDATA_PATH
    else:
        BRIDGEDATA_TEMPLATE_PATH = "/opt/AI-Horde-Worker/bridgeData_template.yaml"

def set_bridge_vars():
    global bridge_vars
    
    transformed = {}
    
    for k,v in os.environ.items():
        if k.upper().startswith(BRIDGEDATA_PREFIX):
            newKey = k.split("_",1)[1].lower()
            transformed[newKey] = v
    
    bridge_vars = transformed

def set_bridge_data_template():
    global bridge_data_template
    
    with open(BRIDGEDATA_TEMPLATE_PATH, 'r') as file:
        yaml = YAML(typ='safe')
        bridge_data_template = yaml.load(file)

def set_bridge_data():
    global bridge_data, bridge_data_template, bridge_vars
    
    bd = {}

    for k, v in bridge_data_template.items():
        if not k in bridge_vars:
            bd[k] = v
        else:
            bd[k] = get_as_type(bridge_vars[k], type(v))
            
    bridge_data = bd

def get_as_type(value, type):
    match type.__name__:
        case "bool":
            return get_as_bool(value)
        case "int":
            return get_as_int(value)
        case "str":
            return get_as_str(value)
        case "list":
            return get_as_list(value)

def get_as_bool(value):
    truthy = ['1','yes','true']
    return value.lower() in truthy

def get_as_int(value):
    return int(value)

def get_as_str(value):
    return str(value)

def get_as_list(value):
        cleaned_list = []
        initial_list = (value.strip('\w,[]')
                        .replace("'", "")
                        .replace('"', "")
                        .split(","))
                        
        for item in initial_list:
            cleaned_list.append(item.strip())
        return cleaned_list
        
def write_bridge_data():
    global bridge_data
    
    with open(BRIDGEDATA_PATH, 'w') as file:
        yaml = YAML()
        yaml.default_flow_style = False
        yaml.indent(mapping=2, sequence=4, offset=2)
        yaml.dump(bridge_data, file)

set_bridgedata_template_path()
set_bridge_vars()
set_bridge_data_template()
set_bridge_data()
write_bridge_data()
