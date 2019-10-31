import re

DEFAULT_CLUSTER = "sam"
DEFAULT_IP_TYPE = "private_nonreserved"

FQDN_SUFFIX = ".slb.sfdc.net"

VIPS_YAML_LBNAME_FIELD_NAME = "lbname"
VIPS_YAML_CUSTOM_LBNAME_FIELD_NAME = "customlbname"
VIPS_YAML_IP_TYPE_FIELD_NAME = "iptype"

vips_file_path_regex = re.compile(r".*team/([a-zA-Z0-9-_]+)/vips/([a-z][a-z0-9]{2,})/(([a-zA-Z0-9-_]+)/)?vips\.yaml")


class VipMetadata:
    def __init__(self, kingdom, cluster, fqdn, ip_type):
        self.kingdom = kingdom
        self.cluster = cluster
        self.fqdn = fqdn
        self.ip_type = ip_type


def get_vip_metadata_from_vip_yaml(vip, vip_file_path):
    results = vips_file_path_regex.search(vip_file_path)
    team_name = results.group(1)
    kingdom = results.group(2)
    cluster = results.group(4)

    if cluster is None:
        cluster = kingdom + "-" + DEFAULT_CLUSTER

    ip_type = vip[VIPS_YAML_IP_TYPE_FIELD_NAME] if VIPS_YAML_IP_TYPE_FIELD_NAME in vip else DEFAULT_IP_TYPE

    return VipMetadata(kingdom, cluster, get_fqdn(vip, kingdom, team_name), ip_type)


def get_fqdn(vip, kingdom, team_name):
    is_customlbname_used = VIPS_YAML_CUSTOM_LBNAME_FIELD_NAME in vip
    final_lbname = vip[VIPS_YAML_CUSTOM_LBNAME_FIELD_NAME] if is_customlbname_used else vip[VIPS_YAML_LBNAME_FIELD_NAME]

    fqdn = final_lbname
    if not is_customlbname_used:
        fqdn += "-" + team_name + "-" + kingdom

    fqdn += FQDN_SUFFIX
    return fqdn
