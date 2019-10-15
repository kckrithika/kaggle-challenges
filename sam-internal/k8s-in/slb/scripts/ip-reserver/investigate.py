import json
import os
import portal_query
import yaml





# Read slb-reserved-ips.jsonnet
with open("/Users/hammondpang/Code/go/src/git.soma.salesforce.com/sam/manifests/sam-internal/k8s-in/slb/slbreservedips.json", "r") as reserved_ips_file:
    reserved_ips = json.load(reserved_ips_file)
    public_reserved_ips = reserved_ips["publicReservedIps"]
    private_reserved_ips = reserved_ips["privateReservedIps"]


portal_entries = portal_query.get_all_portal_entries("prd", "prd-samtwo")
for portal_entry in portal_entries:
    print(portal_entry.fqdn)
    if portal_entry.fqdn in public_reserved_ips["prd-samtwo"]:
        print("{} public".format(portal_entry.fqdn))
    elif portal_entry.fqdn in private_reserved_ips:
        print("{} private".format(portal_entry.fqdn))




def get_state(public_ips, private_ips, fqdn, cluster):
    if cluster in public_ips and fqdn in public_ips[cluster]:
        return "public"
    elif cluster in private_ips and fqdn in private_ips[cluster]:
        return "private_reserved"
    else:
        return "private"


def get_fqdn_from_portal(kingdom, cluster, lbname):
    portal_entry = portal_query.get_portal_entry_from_portal(kingdom, cluster, lambda entry: entry.lbname, lbname)
    if portal_entry is not None:
        return portal_entry.fqdn

    return ""


def parse_yaml(yaml_file_path):
    with open(yaml_file_path, "r") as file:
        yaml_text = file.read().replace("\t", "  ")
        try:
            vip_data = yaml.safe_load(yaml_text)
            return vip_data
        except yaml.YAMLError as exc:
            print("Failed to parse {}: {}".format(yaml_file_path, exc))
        return []


for file_location, _, file_names_in_dir in os.walk("/Users/hammondpang/Code/go/src/git.soma.salesforce.com/sam/manifests/apps/team"):
    for file_name in file_names_in_dir:
        full_path = os.path.join(file_location, file_name)
        if full_path.endswith("pool-map.yaml"):
            apps = parse_yaml(full_path)['apps']
            if apps is not None:
                for app, map in apps.items():
                    kingdoms = []
                    if map is None:
                        continue

                    for name in map:
                        if type(name) is str:
                            if "prd-samtwo" in name:
                                kingdoms.append("prd-samtwo")
                            else:
                                kingdoms.append(name.split("/")[0])
                            continue
                        for k, v in name.items():
                            if k == "name":
                                if "prd-samtwo" in v:
                                    kingdoms.append("prd-samtwo")
                                else:
                                    kingdoms.append(v.split("/")[0])

                    manifest_path = os.path.join(file_location, app, "manifest.yaml")
                    system = parse_yaml(manifest_path)['system']
                    if "loadbalancers" not in system:
                        continue

                    loadbalancers = system['loadbalancers']
                    for loadbalancer in loadbalancers:
                        last_state = ""
                        for kingdom in kingdoms:
                            try:
                                cluster = kingdom + "-sam"
                                if "-" in kingdom:
                                    cluster = kingdom
                                    kingdom = kingdom.split("-")[0]

                                fqdn = get_fqdn_from_portal(kingdom, cluster, loadbalancer['lbname'])
                                if fqdn == "":
                                    continue

                                if kingdom == "prd-samtwo":
                                    print(fqdn)

                                state = get_state(public_reserved_ips, private_reserved_ips, fqdn, cluster)
                               # print("state: {}, fqdn: {}".format(state, fqdn))
                                if last_state != state and last_state != "":
                                    print("app: {} last state: {} state: {} kingdom: {} lb: {}".format(app, last_state, state, kingdom, loadbalancer['lbname']))
                                last_state = state
                            except:
                                abc = 1
                                #print("error for {} {}".format(kingdom, loadbalancer['lbname']))


