import os
import yaml

POOL_MAP_YAML_CONTROL_ESTATE_FIELD_NAME = "controlEstate"
POOL_MAP_YAML_NAME = "pool.yaml"


class PoolMap:
    def __init__(self, root_pools_path):
        self.root_pools_path = root_pools_path
        self.pool_map_cache = {}

    def get_kingdom_cluster_from_pool_name(self, pool_name):
        pool_name_data = pool_name.split("/")
        kingdom = pool_name_data[0]
        return kingdom, self.__get_cluster_from_file(os.path.join(self.root_pools_path,
                                                                  kingdom,
                                                                  pool_name_data[1], POOL_MAP_YAML_NAME))

    def __get_cluster_from_file(self, file_path):
        if file_path in self.pool_map_cache:
            return self.pool_map_cache[file_path]

        with open(file_path, "r") as file:
            yaml_data = yaml.safe_load(file.read())
            cluster = yaml_data[POOL_MAP_YAML_CONTROL_ESTATE_FIELD_NAME].split("/")[1]
            self.pool_map_cache[file_path] = cluster
            return cluster