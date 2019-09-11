import ast
import json
import re
import sys
import os
import yaml

DEFAULT_CLUSTER = "sam"
MAX_OCTET_VALUE = 255
PUBLIC_RESERVED_IPS_FIELD_NAME = "publicReservedIps"
PUBLIC_SUBNET_FIELD_NAME = "publicSubnet"
VIPS_YAML_FILE_NAME = "vips.yaml"
VIPS_YAML_LBNAME_FIELD_NAME = "lbname"
VIPS_YAML_CUSTOM_LBNAME_FIELD_NAME = "customlbname"
VIPS_YAML_PUBLIC_FIELD_NAME = "public"

vips_file_path_regex = re.compile(r".*team/([a-zA-Z0-9-_]+)/vips/([a-z][a-z0-9]{2,})/(?:([a-zA-Z0-9-_]+)/)?vips\.yaml")


def get_first_three_octets(config_file_path, cluster):
    with open(config_file_path, 'r') as jsonnet_file:
        config_text = jsonnet_file.read()

    # Finds public subnet field's text
    public_subnet_regex = re.compile(r"" + PUBLIC_SUBNET_FIELD_NAME + ":[^{]*{[^}]*}", re.M)
    public_subnet_regex_search_results = public_subnet_regex.search(config_text)
    if public_subnet_regex_search_results is None:
        raise Exception('{} was not found'.format(PUBLIC_SUBNET_FIELD_NAME))

    public_subnet_text = public_subnet_regex_search_results.group(0)
    # Finds the cluster's text
    cluster_regex = re.compile(r'"' + cluster + '": "(.*)"')
    cluster_regex_search_results = cluster_regex.search(public_subnet_text)

    subnet = cluster_regex_search_results.group(1)
    # ONLY USE THE FIRST SUBNET GIVEN
    subnet = subnet.split(",")[0]
    octets = subnet.split(".")
    return ".".join(octets[:3])


def update_reserved_ips(reserved_ips_file_path, cluster, new_ip):
    with open(reserved_ips_file_path, 'r') as jsonnet_file:
        reserved_ip_text = jsonnet_file.read()

    # Finds the public reserved IPs field's text
    public_reserved_ips_regex = re.compile(r"(" + PUBLIC_RESERVED_IPS_FIELD_NAME + ":[^{]*{[^}]*)}", re.M)
    public_reserved_ips_search_results = public_reserved_ips_regex.search(reserved_ip_text)
    if public_reserved_ips_search_results is None:
        raise Exception('{} was not found'.format(PUBLIC_RESERVED_IPS_FIELD_NAME))

    public_reserved_ips_text = public_reserved_ips_search_results.group(0)

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
    cluster_reserved_ips = ast.literal_eval('{' + cluster_reserved_ips_text + '}')[cluster]
    if new_ip in cluster_reserved_ips:
        print("{} is already in {}".format(new_ip, cluster))
    else:
        # Adds the new IP into the cluster's text
        new_public_reserved_ip_text = cluster_reserved_ips_regex.sub(r'\1  "' + new_ip + '",\n            ]',
                                                                     public_reserved_ips_text)
        with open(reserved_ips_file_path, 'w') as jsonnet_file:
            # Replace the public reserved IP text with the new one and write it
            jsonnet_file.write(public_reserved_ips_regex.sub(new_public_reserved_ip_text, reserved_ip_text))


def reserve_for_all_vips_yamls(root_path, config_file_path, reserved_ips_file_path, public_vip_allocation_file_path, minimum_octet):
    for root, dirs, files in os.walk(root_path):
        for file_name in files:
            full_path = os.path.join(root, file_name)
            if file_name == VIPS_YAML_FILE_NAME:
                process_vip_file(full_path, config_file_path, reserved_ips_file_path, public_vip_allocation_file_path, minimum_octet)


def process_vip_file(vip_file_path, config_file_path, reserved_ips_file_path, public_vip_allocation_file_path, minimum_octet):
    with open(vip_file_path, 'r') as file:
        try:
            vip_data = yaml.safe_load(file)
            for vip in vip_data:
                public = False if VIPS_YAML_PUBLIC_FIELD_NAME not in vip else vip[VIPS_YAML_PUBLIC_FIELD_NAME]
                if public:
                    results = vips_file_path_regex.search(vip_file_path)
                    team_name = results.group(1)
                    kingdom = results.group(2)
                    cluster = results.group(3)
                    if cluster is None:
                        cluster = kingdom + "-" + DEFAULT_CLUSTER

                    lbname = vip[VIPS_YAML_CUSTOM_LBNAME_FIELD_NAME] if VIPS_YAML_CUSTOM_LBNAME_FIELD_NAME in vip else vip[VIPS_YAML_LBNAME_FIELD_NAME]

                    create_new_public_vip(team_name + "." + lbname, config_file_path,
                                                                cluster, public_vip_allocation_file_path,
                                                                reserved_ips_file_path, minimum_octet)
        except yaml.YAMLError as exc:
            print("Failed to parse {}: {}", vip_file_path, exc)


def create_new_public_vip(public_vip_entry_name, config_file_path,
                          cluster, public_vip_allocation_file_path,
                          reserved_ips_file_path, minimum_octet):
    with open(public_vip_allocation_file_path, "r") as public_vip_file:
        public_vip_data = json.loads(public_vip_file.read())

    if cluster not in public_vip_data:
        public_vip_data[cluster] = {}

    cluster_public_vip_data = public_vip_data[cluster]
    if public_vip_entry_name in cluster_public_vip_data:
        print("{} already has a public IP reserved".format(public_vip_entry_name))
        return

    fourth_octet_values = cluster_public_vip_data.values()

    new_ip_fourth_octet_value = -1
    for i in range(minimum_octet, MAX_OCTET_VALUE + 1):
        if i not in fourth_octet_values:
            new_ip_fourth_octet_value = i
            break

    if new_ip_fourth_octet_value == -1:
        raise Exception('There are no more free public IPs in: {}'.format(cluster))

    public_vip_data[cluster][public_vip_entry_name] = new_ip_fourth_octet_value
    with open(public_vip_allocation_file_path, "w") as public_vip_file:
        json.dump(public_vip_data, public_vip_file, indent=2, sort_keys=True)

    new_ip = get_first_three_octets(config_file_path, cluster) + "." + str(new_ip_fourth_octet_value) + "/32"
    update_reserved_ips(reserved_ips_file_path, cluster, new_ip)
    print("Added {} for {}".format(new_ip, public_vip_entry_name))