import portal_query
from collections import OrderedDict
import json
import re
import sys
import os
import yaml

DEFAULT_CLUSTER = "sam"
FQDN_SUFFIX = ".slb.sfdc.net"

MANIFEST_YAML_FILE_NAME = "manifest.yaml"
MANIFEST_YAML_KINGDOMS_FIELD_NAME = "kingdoms"
MANIFEST_YAML_LOAD_BALANCERS_FIELD_NAME = "loadbalancers"
MANIFEST_YAML_SYSTEM_FIELD_NAME = "system"

MAX_OCTET_VALUE = 255
PRIVATE_RESERVED_IPS_FIELD_NAME = "privateReservedIps"
PUBLIC_RESERVED_IPS_FIELD_NAME = "publicReservedIps"


SPACES_IN_TAB = "  "

VIPS_YAML_FILE_NAME = "vips.yaml"
VIPS_YAML_LBNAME_FIELD_NAME = "lbname"
VIPS_YAML_CUSTOM_LBNAME_FIELD_NAME = "customlbname"
VIPS_YAML_PUBLIC_FIELD_NAME = "public"
VIPS_YAML_RESERVED_FIELD_NAME = "reserved"

vips_file_path_regex = re.compile(r".*team/([a-zA-Z0-9-_]+)/vips/([a-z][a-z0-9]{2,})/(?:([a-zA-Z0-9-_]+)/)?vips\.yaml")


class VipMetadata:
    def __init__(self, kingdom, cluster, fqdn, reserved, public):
        self.kingdom = kingdom
        self.cluster = cluster
        self.fqdn = fqdn
        self.reserved = reserved
        self.public = public


def get_vip_metadata_from_vip_yaml(vip, vip_file_path):
    results = vips_file_path_regex.search(vip_file_path)
    team_name = results.group(1)
    kingdom = results.group(2)
    cluster = results.group(3)
    if cluster is None:
        cluster = kingdom + "-" + DEFAULT_CLUSTER

    reserved = vip[VIPS_YAML_RESERVED_FIELD_NAME] if VIPS_YAML_RESERVED_FIELD_NAME in vip else None
    public = vip[VIPS_YAML_PUBLIC_FIELD_NAME] if VIPS_YAML_PUBLIC_FIELD_NAME in vip else None

    return VipMetadata(kingdom, cluster, get_fqdn(vip, kingdom, team_name), reserved, public)


def get_fqdn(vip, kingdom, team_name):
    customlbname_used = VIPS_YAML_CUSTOM_LBNAME_FIELD_NAME in vip
    final_lbname = vip[VIPS_YAML_CUSTOM_LBNAME_FIELD_NAME] if customlbname_used else vip[VIPS_YAML_LBNAME_FIELD_NAME]

    fqdn = final_lbname
    if not customlbname_used:
        fqdn += "-" + team_name + "-" + kingdom

    fqdn += FQDN_SUFFIX
    return fqdn


def get_fqdn_from_portal(kingdom, lbname):
    portal_entry = portal_query.get_portal_entry_from_portal(kingdom, lambda entry: entry.lbname, lbname)
    if portal_entry is not None:
        return portal_entry.fqdn

    raise Exception("Could not find fqdn for {}".format(lbname))


def get_first_three_octets(subnet):
    octets = subnet.split(".")
    return ".".join(octets[:3])


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


def get_vip_metadatas(file_name, path):
    if file_name == MANIFEST_YAML_FILE_NAME:
        manifest = parse_yaml(path)
        if MANIFEST_YAML_SYSTEM_FIELD_NAME not in manifest:
            return []

        manifest = manifest[MANIFEST_YAML_SYSTEM_FIELD_NAME]

        if MANIFEST_YAML_LOAD_BALANCERS_FIELD_NAME not in manifest:
            return []

        load_balancers = manifest[MANIFEST_YAML_LOAD_BALANCERS_FIELD_NAME]
        vip_metadatas = []
        for lb in load_balancers:
            if MANIFEST_YAML_KINGDOMS_FIELD_NAME not in lb:
                continue

            reserved = lb[VIPS_YAML_RESERVED_FIELD_NAME] if VIPS_YAML_RESERVED_FIELD_NAME in lb else None
            public = lb[VIPS_YAML_PUBLIC_FIELD_NAME] if VIPS_YAML_PUBLIC_FIELD_NAME in lb else None

            for kingdom in lb[MANIFEST_YAML_KINGDOMS_FIELD_NAME]:
                cluster = kingdom + "-" + DEFAULT_CLUSTER

                # This is the case where the user has provided a cluster such as prd-sam, prd-samtwo etc
                if "-" in kingdom:
                    cluster = kingdom
                    kingdom = kingdom.split("-")[0]

                lbname = lb[VIPS_YAML_LBNAME_FIELD_NAME]
                vip_metadatas.append(VipMetadata(kingdom, cluster, get_fqdn_from_portal(kingdom, lbname), reserved, public))
        return vip_metadatas

    elif file_name == VIPS_YAML_FILE_NAME:
        vips = parse_yaml(path)
        vip_metadatas = []
        for vip in vips:
            vip_metadatas.append(get_vip_metadata_from_vip_yaml(vip, path))
        return vip_metadatas
    else:
        return []


def process_vip_files(root_vip_yaml_path, public_reserved_ips, private_reserved_ips, public_subnets, minimum_octet):
    public_vips_to_delete = []
    public_vips_to_add = []

    for file_location, _, file_names_in_dir in os.walk(root_vip_yaml_path):
        for file_name in file_names_in_dir:
            full_path = os.path.join(file_location, file_name)
            vip_metadatas = get_vip_metadatas(file_name, full_path)

            for vip_metadata in vip_metadatas:
                if vip_metadata.reserved is None:
                    continue

                # Ignores the public field when reserved is false in case the public field is set improperly
                # The script will delete the reserved IP wherever it is
                if not vip_metadata.reserved:
                    public_vips_to_delete.append(vip_metadata)
                    delete_ip(vip_metadata.fqdn, vip_metadata.cluster, private_reserved_ips)
                elif vip_metadata.public is None or not vip_metadata.public:
                    public_vips_to_delete.append(vip_metadata)
                    add_private_ip(vip_metadata.kingdom, vip_metadata.cluster, vip_metadata.fqdn, private_reserved_ips)
                else:
                    delete_ip(vip_metadata.fqdn, vip_metadata.cluster, private_reserved_ips)
                    public_vips_to_add.append(vip_metadata)

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
            vip_data = yaml.safe_load(yaml_text)
            return vip_data
        except yaml.YAMLError as exc:
            print("Failed to parse {}: {}".format(yaml_file_path, exc))
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


def add_private_ip(kingdom, cluster, fqdn, private_reserved_ips):
    if cluster in private_reserved_ips:
        if fqdn in private_reserved_ips[cluster]:
            return
    else:
        private_reserved_ips[cluster] = {}

    matching_portal_entry = portal_query.get_portal_entry_from_portal(kingdom, lambda entry: entry.fqdn, fqdn)
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
    process_all_vips_yamls(sys.argv[1],
                           sys.argv[2],
                           sys.argv[3],
                           int(sys.argv[4]))
    print("Run successfully")
