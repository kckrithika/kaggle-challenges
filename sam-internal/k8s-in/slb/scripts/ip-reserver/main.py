import ip_reserver
import pool_map
import vip

import os
import sys
import yaml


IP_TYPE_PRIVATE_NON_RESERVED = vip.DEFAULT_IP_TYPE
IP_TYPE_PRIVATE_RESERVED = "private_reserved"
IP_TYPE_PUBLIC_RESERVED = "public_reserved"
IP_TYPE_PUBLIC_ACTIVE = "public_active"

MANIFEST_YAML_ANNOTATIONS_FIELD_NAME = "annotations"
MANIFEST_YAML_FILE_NAME = "manifest.yaml"
MANIFEST_YAML_LOAD_BALANCERS_FIELD_NAME = "loadbalancers"
MANIFEST_YAML_SLB_ANNOTATION_PREFIX = "slb.sfdc.net/"
MANIFEST_YAML_SYSTEM_FIELD_NAME = "system"

POOL_MAP_FILE_NAME = "pool-map.yaml"
PRIVATE_IP_PREFIX = "10."

SPACES_IN_TAB = "  "

VIPS_YAML_FILE_NAME = "vips.yaml"


def get_sam_app_fqdn(kingdom, cluster, team_name, super_pod, lbname):
    namespace = team_name
    if super_pod is not None:
        namespace += "-" + super_pod
    return "{}.{}.{}.{}{}".format(lbname, namespace, cluster, kingdom, vip.FQDN_SUFFIX)


def get_load_balancers_from_manifest_yaml(path):
    manifest = parse_yaml(path)
    if MANIFEST_YAML_SYSTEM_FIELD_NAME not in manifest:
        return []

    manifest = manifest[MANIFEST_YAML_SYSTEM_FIELD_NAME]

    if MANIFEST_YAML_LOAD_BALANCERS_FIELD_NAME not in manifest:
        return []

    return manifest[MANIFEST_YAML_LOAD_BALANCERS_FIELD_NAME]


def get_vip_metadatas(path):
    vips = parse_yaml(path)
    vip_metadatas = []
    for vip_dict in vips:
        vip_metadatas.append(vip.get_vip_metadata_from_vip_yaml(vip_dict, path))
    return vip_metadatas


def process_vip_metadata(vip_metadata, public_vips_to_add, public_vips_to_delete, ip_handler):
    if vip_metadata.ip_type == IP_TYPE_PUBLIC_ACTIVE or vip_metadata.ip_type == IP_TYPE_PUBLIC_RESERVED:
        ip_handler.delete_ip(vip_metadata.fqdn, vip_metadata.cluster, public=False)
        public_vips_to_add.append(vip_metadata)
    else:
        public_vips_to_delete.append(vip_metadata)
        if vip_metadata.ip_type == IP_TYPE_PRIVATE_RESERVED:
            ip_handler.add_private_ip(vip_metadata.kingdom, vip_metadata.cluster, vip_metadata.fqdn)
        elif vip_metadata.ip_type == IP_TYPE_PRIVATE_NON_RESERVED:
            ip_handler.delete_ip(vip_metadata.fqdn, vip_metadata.cluster, public=False)
        else:
            raise Exception("{} has an invalid ip type".format(vip_metadata.fqdn))


def get_ip_type(loadbalancer):
    ip_type = vip.DEFAULT_IP_TYPE
    if MANIFEST_YAML_ANNOTATIONS_FIELD_NAME in loadbalancer:
        annotations = loadbalancer[MANIFEST_YAML_ANNOTATIONS_FIELD_NAME]
        ip_type_annotation_name = MANIFEST_YAML_SLB_ANNOTATION_PREFIX + vip.VIPS_YAML_IP_TYPE_FIELD_NAME
        if ip_type_annotation_name in annotations:
            ip_type = annotations[ip_type_annotation_name]

    return ip_type


def process_sam_apps(pool_map_path, team_folder_path, pools, public_vips_to_add, public_vips_to_delete, ip_handler):
    pool_yaml = parse_yaml(pool_map_path)
    apps = pool_yaml['apps']
    if apps is None:
        return

    for app, app_data in apps.items():
        if app_data is None:
            continue

        load_balancers = get_load_balancers_from_manifest_yaml(os.path.join(team_folder_path, app, MANIFEST_YAML_FILE_NAME))

        for pool in app_data:
            kingdom, cluster, super_pod = pools.get_info_from_pool_name(pool) if type(pool) is str \
                else pools.get_info_from_pool_name(pool['name'])

            for lb in load_balancers:
                team_name = team_folder_path.split("/")[-1].lower().replace("_", "-")
                fqdn = get_sam_app_fqdn(kingdom, cluster, team_name, super_pod, lb[vip.VIPS_YAML_LBNAME_FIELD_NAME])
                ip_type = get_ip_type(lb)
                vip_metadata = vip.VipMetadata(kingdom, cluster, fqdn, ip_type)
                process_vip_metadata(vip_metadata, public_vips_to_add, public_vips_to_delete, ip_handler)


def process_services(root_vip_yaml_path, ip_handler, pools_path):
    public_vips_to_delete = []
    public_vips_to_add = []

    pools = pool_map.PoolMap(pools_path)

    for team_folder_name in os.listdir(root_vip_yaml_path):
        team_folder_path = os.path.join(root_vip_yaml_path, team_folder_name)
        if os.path.isfile(team_folder_path):
            continue

        for file_location, _, file_names_in_dir in os.walk(team_folder_path):
            for file_name in file_names_in_dir:
                full_path = os.path.join(file_location, file_name)
                if file_name == POOL_MAP_FILE_NAME:
                    process_sam_apps(full_path, team_folder_path, pools, public_vips_to_add, public_vips_to_delete, ip_handler)
                    continue

                if file_name != VIPS_YAML_FILE_NAME:
                    continue

                vip_metadatas = get_vip_metadatas(full_path)

                for vip_metadata in vip_metadatas:
                    process_vip_metadata(vip_metadata, public_vips_to_add, public_vips_to_delete, ip_handler)

    # Delete happens first in order to allow for IP reuse
    for vip_metadata in public_vips_to_delete:
        ip_handler.delete_ip(vip_metadata.fqdn, vip_metadata.cluster, public=True)

    for vip_metadata in public_vips_to_add:
        ip_handler.add_public_ip(vip_metadata.fqdn, vip_metadata.cluster)


def parse_yaml(yaml_file_path):
    with open(yaml_file_path, "r") as file:
        yaml_text = file.read().replace("\t", SPACES_IN_TAB)
        try:
            return yaml.safe_load(yaml_text)
        except yaml.YAMLError as exc:
            print("Failed to parse {}: {}".format(yaml_file_path, exc))
        return []


if __name__ == "__main__":
    root_vip_yaml_path = sys.argv[1]
    config_file_path = sys.argv[2]
    reserved_ips_file_path = sys.argv[3]
    pools_path = sys.argv[4]
    minimum_octet = int(sys.argv[5])

    ip_handler = ip_reserver.IpReserver(reserved_ips_file_path, config_file_path, minimum_octet)

    process_services(root_vip_yaml_path, ip_handler, pools_path)

    modified_kingdom_estates = ip_handler.get_modified_kingdom_estates()

    # Used for the build script
    if len(modified_kingdom_estates) == 0:
        print("No IP reservation changes found")
    else:
        print(",".join(modified_kingdom_estates))

    ip_handler.save_reserved_ips()
