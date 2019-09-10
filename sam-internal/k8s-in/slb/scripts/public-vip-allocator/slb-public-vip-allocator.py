import ast
import json
import re
import sys

MAX_OCTET_VALUE = 255
PUBLIC_RESERVED_IPS_FIELD_NAME = "publicReservedIps"
PUBLIC_SUBNET_FIELD_NAME = "publicSubnet"


def get_first_three_octets(config_file_path, cluster):
    with open(config_file_path, 'r') as jsonnet_file:
        config_text = jsonnet_file.read()

    # Finds the public reserved IPs field's text
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

def get_next_fourth_octet(public_vip_file_path, minimum_octet, cluster):
    with open(public_vip_file_path) as public_vip_file:
        public_vip_data = json.loads(public_vip_file.read())

    fourth_octet_values = public_vip_data[cluster].values()

    for i in range(minimum_octet, MAX_OCTET_VALUE + 1):
        if i not in fourth_octet_values:
            return i

    raise Exception('There are no more free public IPs in: {}'.format(cluster))


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
        print("Cluster was not found, adding it")
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

