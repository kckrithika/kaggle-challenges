import ast
import json
import re
import sys

MAX_OCTET_VALUE = 255
PUBLIC_RESERVED_IPS_FIELD_NAME = "publicReservedIps"


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

    public_reserved_ips_regex = re.compile(r"(" + PUBLIC_RESERVED_IPS_FIELD_NAME + ":[^{]*{[^}]*)}", re.M)
    public_reserved_ips_search_results = public_reserved_ips_regex.search(reserved_ip_text)
    if public_reserved_ips_search_results is None:
        raise Exception('{} was not found'.format(PUBLIC_RESERVED_IPS_FIELD_NAME))

    public_reserved_ips_text = public_reserved_ips_search_results.group(0)
    cluster_reserved_ips_regex = re.compile(r'("' + cluster + '": \[[^\]]+)\]')
    cluster_reserved_ips_search_results = cluster_reserved_ips_regex.search(public_reserved_ips_text)

    if cluster_reserved_ips_search_results is None:
        print("Cluster was not found, adding it")
        cluster_reserved_ips_text = '"' + cluster + '": [\n            ],'
        public_reserved_ips_text = public_reserved_ips_regex.sub(r'\1    ' + cluster_reserved_ips_text + '\n        }',
                                                                 public_reserved_ips_text)
    else:
        cluster_reserved_ips_text = cluster_reserved_ips_search_results.group(0)

    cluster_reserved_ips = ast.literal_eval('{' + cluster_reserved_ips_text + '}')[cluster]
    if new_ip in cluster_reserved_ips:
        print("{} is already in {}".format(new_ip, cluster))
    else:
        new_public_reserved_ip_text = cluster_reserved_ips_regex.sub(r'\1  "' + new_ip + '",\n            ]',
                                                                     public_reserved_ips_text)
        with open(reserved_ips_file_path, 'w') as jsonnet_file:
            jsonnet_file.write(public_reserved_ips_regex.sub(new_public_reserved_ip_text, reserved_ip_text))
