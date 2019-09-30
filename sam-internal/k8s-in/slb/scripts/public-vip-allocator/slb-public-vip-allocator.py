from collections import OrderedDict
from io import StringIO
from lxml import etree
import json
import re
import ssl
import sys
import os
import yaml
import urllib.request

DEFAULT_CLUSTER = "sam"
FQDN_SUFFIX = ".slb.sfdc.net"
MAX_OCTET_VALUE = 255
PRD_KINGDOM_NAME = "prd"
PRIVATE_RESERVED_IPS_FIELD_NAME = "privateReservedIps"
PUBLIC_RESERVED_IPS_FIELD_NAME = "publicReservedIps"
SLB_PORTAL_URL = "http://slb-portal-{}.slb.sfdc.net"
SPACES_IN_TAB = "  "

VIPS_YAML_FILE_NAME = "vips.yaml"
VIPS_YAML_LBNAME_FIELD_NAME = "lbname"
VIPS_YAML_CUSTOM_LBNAME_FIELD_NAME = "customlbname"
VIPS_YAML_PUBLIC_FIELD_NAME = "public"
VIPS_YAML_RESERVED_FIELD_NAME = "reserved"

vips_file_path_regex = re.compile(r".*team/([a-zA-Z0-9-_]+)/vips/([a-z][a-z0-9]{2,})/(?:([a-zA-Z0-9-_]+)/)?vips\.yaml")


class VipMetadata:
    def __init__(self, vip, vip_file_path):
        self.vip = vip

        results = vips_file_path_regex.search(vip_file_path)
        team_name = results.group(1)
        self.kingdom = results.group(2)
        self.cluster = results.group(3)
        if self.cluster is None:
            self.cluster = self.kingdom + "-" + DEFAULT_CLUSTER

        customlbname_used = VIPS_YAML_CUSTOM_LBNAME_FIELD_NAME in vip
        final_lbname = vip[VIPS_YAML_CUSTOM_LBNAME_FIELD_NAME] if customlbname_used else vip[VIPS_YAML_LBNAME_FIELD_NAME]

        self.fqdn = final_lbname
        if not customlbname_used:
            self.fqdn += "-" + team_name + "-" + self.kingdom

        self.fqdn += FQDN_SUFFIX


def get_first_three_octets(subnet):
    octets = subnet.split(".")
    return ".".join(octets[:3])


def get_portal_url(kingdom):
    if kingdom == PRD_KINGDOM_NAME:
        return SLB_PORTAL_URL.format("service.sam-system.prd-sam.prd") + ":9112"

    return SLB_PORTAL_URL.format(kingdom)


def get_ip_from_portal(kingdom, fqdn):
    ssl._create_default_https_context = ssl._create_unverified_context

    conn = urllib.request.urlopen(get_portal_url(kingdom))
    byte_response = conn.read()

    str_response = byte_response.decode("utf8")
    conn.close()

    tree = etree.parse(StringIO(str_response), etree.HTMLParser())

    root = tree.getroot()
    results = root.xpath('//tr/td[position() = 2]/a|//tr/td[position() = 3]')

    for index in range(0, len(results)):
        if results[index].text == fqdn:
            return results[index + 1].text

        index += 1

    raise Exception("Could not find the IP of {}".format(fqdn))


def process_all_vips_yamls(root_vip_yaml_path,
                           config_file_path,
                           reserved_ips_file_path,
                           minimum_octet):
    # Read slb-reserved-ips.jsonnet
    with open(reserved_ips_file_path, "r") as reserved_ips_file:
        reserved_ips = json.load(reserved_ips_file)
        public_reserved_ips = reserved_ips[PUBLIC_RESERVED_IPS_FIELD_NAME]
        private_reserved_ips = reserved_ips[PRIVATE_RESERVED_IPS_FIELD_NAME]

    # Read slbconfig.jsonnet
    with open(config_file_path, "r") as slbconfig_file:
        public_subnets = json.load(slbconfig_file)

    process_vip_files(root_vip_yaml_path,
                      public_reserved_ips,
                      private_reserved_ips,
                      public_subnets,
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


def process_vip_files(root_vip_yaml_path, public_reserved_ips, private_reserved_ips, public_subnets, minimum_octet):
    vips_to_delete = []
    vips_to_add = []

    for file_location, _, file_names_in_dir in os.walk(root_vip_yaml_path):
        for file_name in file_names_in_dir:
            full_path = os.path.join(file_location, file_name)
            if file_name == VIPS_YAML_FILE_NAME:
                vips = parse_vips(full_path)
                for vip in vips:
                    # The reserved and public fields are mutually exclusive
                    if VIPS_YAML_PUBLIC_FIELD_NAME in vip:
                        if vip[VIPS_YAML_PUBLIC_FIELD_NAME]:
                            vips_to_add.append(VipMetadata(vip, full_path))
                        else:
                            vips_to_delete.append(VipMetadata(vip, full_path))
                    elif VIPS_YAML_RESERVED_FIELD_NAME in vip:
                        vip_metadata = VipMetadata(vip, full_path)
                        if vip[VIPS_YAML_RESERVED_FIELD_NAME]:
                            ip = get_ip_from_portal(vip_metadata.kingdom, vip_metadata.fqdn)
                            add_private_ip(vip_metadata.cluster, vip_metadata.fqdn, ip, private_reserved_ips)
                        else:
                            delete_ip(vip_metadata.fqdn, vip_metadata.cluster, private_reserved_ips)

    # Delete happens first in order to allow for IP reuse
    for vip_meta_data in vips_to_delete:
        delete_ip(vip_meta_data.fqdn,
                  vip_meta_data.cluster,
                  public_reserved_ips)

    for vip_meta_data in vips_to_add:
        add_public_ip(vip_meta_data.fqdn,
                      vip_meta_data.cluster,
                      public_reserved_ips,
                      public_subnets,
                      minimum_octet)


def parse_vips(vip_file_path):
    with open(vip_file_path, "r") as file:
        yaml_text = file.read().replace("\t", SPACES_IN_TAB)
        try:
            vip_data = yaml.safe_load(yaml_text)
            return vip_data
        except yaml.YAMLError as exc:
            print("Failed to parse {}: {}".format(vip_file_path, exc))
        return []


def delete_ip(fqdn, cluster, public_reserved_ips):
    if cluster not in public_reserved_ips:
        return

    if fqdn in public_reserved_ips[cluster]:
        del public_reserved_ips[cluster][fqdn]
        print("Deleted {} from {}".format(fqdn, cluster))


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


def add_private_ip(cluster, fqdn, ip, private_reserved_ips):
    if cluster in private_reserved_ips:
        if fqdn in private_reserved_ips[cluster]:
            return
    else:
        private_reserved_ips[cluster] = {}

    private_reserved_ips[cluster][fqdn] = ip
    print("Added {} to {} with private IP {}".format(fqdn, cluster, ip))


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
    process_all_vips_yamls(sys.argv[1],
                           sys.argv[2],
                           sys.argv[3],
                           int(sys.argv[4]))
    print("Run successfully")
