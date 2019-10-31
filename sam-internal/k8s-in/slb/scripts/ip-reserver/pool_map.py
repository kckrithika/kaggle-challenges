import os
import yaml

POOL_MAP_YAML_CONTROL_ESTATE_FIELD_NAME = "controlEstate"
POOL_MAP_YAML_SUPER_POD_FIELD_NAME = "superPod"

POOL_MAP_YAML_NAME = "pool.yaml"


class PoolMap:
    def __init__(self, root_pools_path):
        self.root_pools_path = root_pools_path
        self.pool_map_cache = {}

    # Returns kingdom, cluster, superPod
    def get_info_from_pool_name(self, pool_name):
        pool_name_data = pool_name.split("/")
        kingdom = pool_name_data[0]
        pool_data = self.__get_yaml_from_file(os.path.join(self.root_pools_path,
                                                           kingdom,
                                                           pool_name_data[1],
                                                           POOL_MAP_YAML_NAME))
        super_pod = pool_data[POOL_MAP_YAML_SUPER_POD_FIELD_NAME] if POOL_MAP_YAML_SUPER_POD_FIELD_NAME in pool_data \
            else None
        return kingdom, pool_data[POOL_MAP_YAML_CONTROL_ESTATE_FIELD_NAME].split("/")[1], super_pod

    def __get_yaml_from_file(self, file_path):
        if file_path in self.pool_map_cache:
            return self.pool_map_cache[file_path]

        with open(file_path, "r") as file:
            yaml_data = yaml.safe_load(file.read())
            self.pool_map_cache[file_path] = yaml_data
            return yaml_data
