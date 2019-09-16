from collections import OrderedDict
import ast
import json
import re
import sys
import os
import yaml

DEFAULT_CLUSTER = "sam"
FQDN_SUFFIX = ".slb.sfdc.net"
MAX_OCTET_VALUE = 255
PUBLIC_RESERVED_IPS_FIELD_NAME = "publicReservedIps"
PUBLIC_SUBNET_FIELD_NAME = "publicSubnet"
TAB_TO_SPACE = "  "
VIPS_YAML_FILE_NAME = "vips.yaml"
VIPS_YAML_LBNAME_FIELD_NAME = "lbname"
VIPS_YAML_CUSTOM_LBNAME_FIELD_NAME = "customlbname"
VIPS_YAML_PUBLIC_FIELD_NAME = "public"

public_reserved_ips_regex = re.compile(r"(" + PUBLIC_RESERVED_IPS_FIELD_NAME + ":[^{]*{[^}]*)}", re.M)
vips_file_path_regex = re.compile(r".*team/([a-zA-Z0-9-_]+)/vips/([a-z][a-z0-9]{2,})/(?:([a-zA-Z0-9-_]+)/)?vips\.yaml")


class VipMetadata:
    def __init__(self, vip, vip_file_path):
        self.vip = vip

        results = vips_file_path_regex.search(vip_file_path)
        team_name = results.group(1)
        kingdom = results.group(2)
        self.cluster = results.group(3)
        if self.cluster is None:
            self.cluster = kingdom + "-" + DEFAULT_CLUSTER

        lbname = vip[VIPS_YAML_CUSTOM_LBNAME_FIELD_NAME] if VIPS_YAML_CUSTOM_LBNAME_FIELD_NAME in vip \
            else vip[VIPS_YAML_LBNAME_FIELD_NAME]

        self.public_vip_entry_name = team_name + "." + lbname
        self.fqdn = lbname + FQDN_SUFFIX


def get_first_three_octets(public_subnet_text, cluster):
    # Finds the cluster's text
    cluster_regex = re.compile(r'"' + cluster + '": "(.*)"')
    cluster_regex_search_results = cluster_regex.search(public_subnet_text)

    subnet = cluster_regex_search_results.group(1)
    # ONLY USE THE FIRST SUBNET GIVEN
    subnet = subnet.split(",")[0]
    octets = subnet.split(".")
    return ".".join(octets[:3])


def update_reserved_ips(public_reserved_ips_text, cluster, new_ip, fqdn):
    # Finds the cluster's text
    cluster_reserved_ips_regex = re.compile(r'("' + cluster + '": \[[^\]]+)\]')
    cluster_reserved_ips_search_results = cluster_reserved_ips_regex.search(public_reserved_ips_text)

    # The cluster was not found
    if cluster_reserved_ips_search_results is None:
        print("Cluster {} was not found, adding it to {}".format(cluster, PUBLIC_RESERVED_IPS_FIELD_NAME))
        # The text for a new cluster with no IPs
        cluster_reserved_ips_text = '"' + cluster + '": [\n            ],'
        # Add this new cluster into the public reserved IP field's text
        public_reserved_ips_text = public_reserved_ips_regex.sub(r'\1    ' + cluster_reserved_ips_text + '\n        }',
                                                                 public_reserved_ips_text)
    else:
        # Take the found result
        cluster_reserved_ips_text = cluster_reserved_ips_search_results.group(0)

    # Convert the cluster's array from text form to array form
    cluster_reserved_ips = ast.literal_eval("{" + cluster_reserved_ips_text + "}")[cluster]
    if new_ip in cluster_reserved_ips:
        print("{} is already in {}".format(new_ip, cluster))
    else:
        # Adds the new IP into the cluster's text
        public_reserved_ips_text = cluster_reserved_ips_regex.sub(r'\1  "' + new_ip + '",  # '+ fqdn + '\n            ]',
                                                                  public_reserved_ips_text)
    return public_reserved_ips_text


def reserve_for_all_vips_yamls(root_path,
                               config_file_path,
                               reserved_ips_file_path,
                               public_vip_allocation_file_path,
                               minimum_octet):
    # Read slb-public-vip-allocation.json
    with open(public_vip_allocation_file_path, "r") as public_vip_file:
        public_vip_data = json.loads(public_vip_file.read())

    # Read slb-reserved-ips.jsonnet
    with open(reserved_ips_file_path, "r") as jsonnet_file:
        reserved_ip_text = jsonnet_file.read()

    # Finds the public reserved IPs field's text
    public_reserved_ips_search_results = public_reserved_ips_regex.search(reserved_ip_text)
    if public_reserved_ips_search_results is None:
        raise Exception('{} was not found'.format(PUBLIC_RESERVED_IPS_FIELD_NAME))

    public_reserved_ips_text = public_reserved_ips_search_results.group(0)

    # Read slbconfig.jsonnet
    with open(config_file_path, "r") as jsonnet_file:
        config_text = jsonnet_file.read()

    # Finds public subnet field's text
    public_subnet_regex = re.compile(r"" + PUBLIC_SUBNET_FIELD_NAME + ":[^{]*{[^}]*}", re.M)
    public_subnet_regex_search_results = public_subnet_regex.search(config_text)
    if public_subnet_regex_search_results is None:
        raise Exception('{} was not found'.format(PUBLIC_SUBNET_FIELD_NAME))

    public_reserved_ips_text = process_vip_files(root_path,
                                                 public_vip_data,
                                                 public_subnet_regex_search_results.group(0),
                                                 public_reserved_ips_text,
                                                 minimum_octet)

    for kingdom, data in public_vip_data.items():
        public_vip_data[kingdom] = OrderedDict(sorted(data.items(), key=lambda item: item[1]))

    with open(public_vip_allocation_file_path, "w") as public_vip_file:
        json.dump(public_vip_data, public_vip_file, indent=2)

    with open(reserved_ips_file_path, "w") as jsonnet_file:
        # Replace the public reserved IP text with the new one and write it
        jsonnet_file.write(public_reserved_ips_regex.sub(public_reserved_ips_text, reserved_ip_text))


def process_vip_files(root_path, public_vip_data, public_subnet_text, public_reserved_ips_text, minimum_octet):
    vips_to_delete = []
    vips_to_add = []
    for root, dirs, files in os.walk(root_path):
        for file_name in files:
            full_path = os.path.join(root, file_name)
            if file_name == VIPS_YAML_FILE_NAME:
                vips = parse_vips(full_path)
                for vip in vips:
                    if VIPS_YAML_PUBLIC_FIELD_NAME in vip and vip[VIPS_YAML_PUBLIC_FIELD_NAME]:
                        vips_to_add.append(VipMetadata(vip, full_path))
                    else:
                        vips_to_delete.append(VipMetadata(vip, full_path))

    for vip_meta_data in vips_to_delete:
        public_reserved_ips_text = delete_public_vip(public_vip_data,
                                                     vip_meta_data.public_vip_entry_name,
                                                     vip_meta_data.cluster,
                                                     public_reserved_ips_text,
                                                     public_subnet_text)

    for vip_meta_data in vips_to_add:
        public_reserved_ips_text = create_new_public_vip(vip_meta_data.public_vip_entry_name,
                                                         public_subnet_text,
                                                         vip_meta_data.cluster,
                                                         public_vip_data,
                                                         public_reserved_ips_text,
                                                         minimum_octet,
                                                         vip_meta_data.fqdn)

    return public_reserved_ips_text


def parse_vips(vip_file_path):
    with open(vip_file_path, "r") as file:
        yaml_text = file.read().replace("\t", TAB_TO_SPACE)
        try:
            vip_data = yaml.safe_load(yaml_text)
            return vip_data
        except yaml.YAMLError as exc:
            print("Failed to parse {}: {}", vip_file_path, exc)

        return []


def delete_public_vip(public_vip_data, public_vip_entry_name, cluster, public_reserved_ips_text, public_subnet_text):
    if cluster not in public_vip_data:
        return public_reserved_ips_text

    if public_vip_entry_name in public_vip_data[cluster]:
        fourth_octet = public_vip_data[cluster][public_vip_entry_name]
        del public_vip_data[cluster][public_vip_entry_name]

        ip = get_first_three_octets(public_subnet_text, cluster) + "." + str(fourth_octet) + "/32"
        ip_regex = re.compile(r' *"' + ip + '",(\s*#.*)?\n')
        public_reserved_ips_text = ip_regex.sub("", public_reserved_ips_text)
        print("Deleted {}'s public IP".format(public_vip_entry_name))

    return public_reserved_ips_text


def create_new_public_vip(public_vip_entry_name, public_subnet_text,
                          cluster, public_vip_data,
                          public_reserved_ips_text, minimum_octet, fqdn):
    if cluster not in public_vip_data:
        public_vip_data[cluster] = {}

    cluster_public_vip_data = public_vip_data[cluster]
    if public_vip_entry_name in cluster_public_vip_data:
        print("{} already has a public IP reserved".format(public_vip_entry_name))
        return public_reserved_ips_text

    fourth_octet_values = cluster_public_vip_data.values()

    new_ip_fourth_octet_value = -1
    for i in range(minimum_octet, MAX_OCTET_VALUE + 1):
        if i not in fourth_octet_values:
            new_ip_fourth_octet_value = i
            break

    if new_ip_fourth_octet_value == -1:
        raise Exception("There are no more free public IPs in: {}".format(cluster))

    public_vip_data[cluster][public_vip_entry_name] = new_ip_fourth_octet_value

    new_ip = get_first_three_octets(public_subnet_text, cluster) + "." + str(new_ip_fourth_octet_value) + "/32"
    print("Adding {} for {}".format(new_ip, public_vip_entry_name))

    return update_reserved_ips(public_reserved_ips_text, cluster, new_ip, fqdn)


if __name__ == "__main__":
    reserve_for_all_vips_yamls(sys.argv[1],
                               sys.argv[2],
                               sys.argv[3],
                               sys.argv[4],
                               int(sys.argv[5]))
    print("Run successfully")
