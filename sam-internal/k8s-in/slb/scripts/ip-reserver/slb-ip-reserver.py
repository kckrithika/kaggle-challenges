import pool_map
import portal_query
import vip

from collections import OrderedDict
import json
import sys
import os
import yaml


IP_TYPE_PRIVATE_NON_RESERVED = vip.DEFAULT_IP_TYPE
IP_TYPE_PRIVATE_RESERVED = "private_reserved"
IP_TYPE_PUBLIC_RESERVED = "public_reserved"
IP_TYPE_PUBLIC_ACTIVE = "public_active"

KINGDOMS = ["frf", "phx", "iad", "ord", "dfw", "hnd", "xrd", "cdg", "fra", "ia2", "ph2", "par", "ukb", "lo2", "lo3", "ia4", "prd-sam", "prd-samtwo"]

MANIFEST_YAML_ANNOTATIONS_FIELD_NAME = "annotations"
MANIFEST_YAML_FILE_NAME = "manifest.yaml"
MANIFEST_YAML_LOAD_BALANCERS_FIELD_NAME = "loadbalancers"
MANIFEST_YAML_SLB_ANNOTATION_PREFIX = "slb.sfdc.net/"
MANIFEST_YAML_SYSTEM_FIELD_NAME = "system"

MAX_OCTET_VALUE = 255

POOL_MAP_FILE_NAME = "pool-map.yaml"
PRIVATE_IP_PREFIX = "10."
PRIVATE_RESERVED_IPS_FIELD_NAME = "privateReservedIps"
PUBLIC_RESERVED_IPS_FIELD_NAME = "publicReservedIps"

SPACES_IN_TAB = "  "

VIPS_YAML_FILE_NAME = "vips.yaml"


def get_fqdn_from_portal(kingdom, cluster, lbname):
    portal_entry = portal_query.get_portal_entry_from_portal(kingdom, cluster, lambda entry: entry.lbname, lbname)
    if portal_entry is not None:
        return portal_entry.fqdn

    return None


def get_first_three_octets(subnet):
    octets = subnet.split(".")
    return ".".join(octets[:3])


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


def process_vip_metadata(vip_metadata, public_vips_to_add, public_vips_to_delete, private_reserved_ips):
    if vip_metadata.ip_type == IP_TYPE_PUBLIC_ACTIVE or vip_metadata.ip_type == IP_TYPE_PUBLIC_RESERVED:
        delete_ip(vip_metadata.fqdn, vip_metadata.cluster, private_reserved_ips)
        public_vips_to_add.append(vip_metadata)
    else:
        public_vips_to_delete.append(vip_metadata)
        if vip_metadata.ip_type == IP_TYPE_PRIVATE_RESERVED:
            add_private_ip(vip_metadata.kingdom, vip_metadata.cluster, vip_metadata.fqdn, private_reserved_ips)
        elif vip_metadata.ip_type == IP_TYPE_PRIVATE_NON_RESERVED:
            delete_ip(vip_metadata.fqdn, vip_metadata.cluster, private_reserved_ips)
        else:
            raise Exception("{} has an invalid ip type".format(vip_metadata.fqdn))


def process_sam_apps(pool_map_path, team_folder_path, pools, public_vips_to_add, public_vips_to_delete, private_reserved_ips):
    pool_yaml = parse_yaml(pool_map_path)
    apps = pool_yaml['apps']
    if apps is None:
        return

    for app, app_data in apps.items():
        if app_data is None:
            continue

        manifest_yaml_path = os.path.join(team_folder_path, app, MANIFEST_YAML_FILE_NAME)

        load_balancers = get_load_balancers_from_manifest_yaml(manifest_yaml_path)

        for pool in app_data:
            kingdom, cluster = pools.get_kingdom_cluster_from_pool_name(pool) if type(pool) is str else pools.get_kingdom_cluster_from_pool_name(pool['name'])

            for lb in load_balancers:
                ip_type = vip.DEFAULT_IP_TYPE
                if MANIFEST_YAML_ANNOTATIONS_FIELD_NAME in lb:
                    annotations = lb[MANIFEST_YAML_ANNOTATIONS_FIELD_NAME]
                    ip_type_annotation_name = MANIFEST_YAML_SLB_ANNOTATION_PREFIX + vip.VIPS_YAML_IP_TYPE_FIELD_NAME
                    if ip_type_annotation_name in annotations:
                        ip_type = annotations[ip_type_annotation_name]
                vip_metadata = vip.VipMetadata(kingdom, cluster, get_fqdn_from_portal(kingdom, cluster, lb[vip.VIPS_YAML_LBNAME_FIELD_NAME]), ip_type)
                process_vip_metadata(vip_metadata, public_vips_to_add, public_vips_to_delete, private_reserved_ips)


def process_services(root_vip_yaml_path, public_reserved_ips, private_reserved_ips, public_subnets, pools_path, minimum_octet):
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
                    process_sam_apps(full_path, team_folder_path, pools, public_vips_to_add, public_vips_to_delete, private_reserved_ips)
                    continue

                if file_name != VIPS_YAML_FILE_NAME:
                    continue

                vip_metadatas = get_vip_metadatas(full_path)

                for vip_metadata in vip_metadatas:
                    process_vip_metadata(vip_metadata, public_vips_to_add, public_vips_to_delete, private_reserved_ips)

    # Delete happens first in order to allow for IP reuse
    for vip_metadata in public_vips_to_delete:
        delete_ip(vip_metadata.fqdn,
                  vip_metadata.cluster,
                  public_reserved_ips)

    for vip_metadata in public_vips_to_add:
        add_public_ip(vip_metadata.fqdn,
                      vip_metadata.cluster,
                      public_reserved_ips,
                      public_subnets,
                      minimum_octet)


def parse_yaml(yaml_file_path):
    with open(yaml_file_path, "r") as file:
        yaml_text = file.read().replace("\t", SPACES_IN_TAB)
        try:
            return yaml.safe_load(yaml_text)
        except yaml.YAMLError as exc:
            print("Failed to parse {}: {}".format(yaml_file_path, exc))
        return []


def delete_ip(fqdn, cluster, public_reserved_ips):
    if cluster not in public_reserved_ips:
        return

    if fqdn in public_reserved_ips[cluster]:
        ip = public_reserved_ips[cluster][fqdn]
        del public_reserved_ips[cluster][fqdn]
        print("Deleted {}'s reserved IP of {} from {}".format(fqdn, ip, cluster))


def get_next_public_ip(cluster, public_reserved_ips, public_subnets, minimum_octet):
    existing_ips = public_reserved_ips[cluster].values()

    subnets = public_subnets[cluster].split(",")
    for subnet in subnets:
        first_three_octets = get_first_three_octets(subnet)
        for i in range(minimum_octet, MAX_OCTET_VALUE + 1):
            new_ip = first_three_octets + "." + str(i)
            if new_ip not in existing_ips:
                return new_ip

    raise Exception("There are no more free public IPs in: {}".format(cluster))


def add_private_ip(kingdom, cluster, fqdn, private_reserved_ips):
    if cluster in private_reserved_ips:
        if fqdn in private_reserved_ips[cluster]:
            return
    else:
        private_reserved_ips[cluster] = {}

    matching_portal_entry = portal_query.get_portal_entry_from_portal(kingdom, cluster, lambda entry: entry.fqdn, fqdn)
    if matching_portal_entry is None:
        raise Exception("Could not find IP for {}".format(fqdn))

    private_reserved_ips[cluster][fqdn] = matching_portal_entry.ip
    print("Added {} to {} with private IP {}".format(fqdn, cluster, matching_portal_entry.ip))


def add_public_ip(fqdn,
                  cluster,
                  public_reserved_ips,
                  public_subnets,
                  minimum_octet):
    if cluster not in public_subnets:
        raise Exception("No public subnet was found for {}".format(cluster))

    if cluster in public_reserved_ips:
        if fqdn in public_reserved_ips[cluster]:
            return
    else:
        public_reserved_ips[cluster] = {}

    new_ip = get_next_public_ip(cluster, public_reserved_ips, public_subnets, minimum_octet)
    public_reserved_ips[cluster][fqdn] = new_ip
    print("Added {} to {} with public IP {}".format(fqdn, cluster, new_ip))


if __name__ == "__main__":
    root_vip_yaml_path = sys.argv[1]
    config_file_path = sys.argv[2]
    reserved_ips_file_path = sys.argv[3]
    pools_path = sys.argv[4]
    minimum_octet = int(sys.argv[5])

    # Read slb-reserved-ips.jsonnet
    with open(reserved_ips_file_path, "r") as reserved_ips_file:
        reserved_ips = json.load(reserved_ips_file)
        public_reserved_ips = reserved_ips[PUBLIC_RESERVED_IPS_FIELD_NAME]
        private_reserved_ips = reserved_ips[PRIVATE_RESERVED_IPS_FIELD_NAME]

    # Read slbconfig.jsonnet
    with open(config_file_path, "r") as slbconfig_file:
        public_subnets = json.load(slbconfig_file)

    process_services(root_vip_yaml_path,
                     public_reserved_ips,
                     private_reserved_ips,
                     public_subnets,
                     pools_path,
                     minimum_octet)

    # Sorts each kingdom's data by fourth octet value
    for kingdom, data in public_reserved_ips.items():
        public_reserved_ips[kingdom] = OrderedDict(sorted(data.items(), key=lambda item: item[1]))

    public_reserved_ips = OrderedDict(sorted(public_reserved_ips.items()))
    reserved_ips[PUBLIC_RESERVED_IPS_FIELD_NAME] = public_reserved_ips

    # Sorts each kingdom's data by fourth octet value
    for kingdom, data in private_reserved_ips.items():
        private_reserved_ips[kingdom] = OrderedDict(sorted(data.items(), key=lambda item: item[1]))

    private_reserved_ips = OrderedDict(sorted(private_reserved_ips.items()))
    reserved_ips[PRIVATE_RESERVED_IPS_FIELD_NAME] = private_reserved_ips

    with open(reserved_ips_file_path, "w") as reserved_ips_file:
        json.dump(reserved_ips, reserved_ips_file, indent=2)

    print("Run successfully")
