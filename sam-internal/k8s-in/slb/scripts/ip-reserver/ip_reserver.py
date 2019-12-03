import portal_query

from collections import OrderedDict
import copy
import json

MAX_OCTET_VALUE = 255

PRIVATE_RESERVED_IPS_FIELD_NAME = "privateReservedIps"
PUBLIC_RESERVED_IPS_FIELD_NAME = "publicReservedIps"


class IpReserver:
    def __init__(self, reserved_ips_file_path, subnets_file_path, minimum_octet):
        # Read slb-reserved-ips
        with open(reserved_ips_file_path, "r") as reserved_ips_file:
            self.reserved_ips_file_path = reserved_ips_file_path
            self.reserved_ips = json.load(reserved_ips_file)
            self.public_reserved_ips = self.reserved_ips[PUBLIC_RESERVED_IPS_FIELD_NAME]
            self.private_reserved_ips = self.reserved_ips[PRIVATE_RESERVED_IPS_FIELD_NAME]
            self.minimum_octet = minimum_octet

            self.original_public_reserved_ips = copy.deepcopy(self.public_reserved_ips)
            self.original_private_reserved_ips = copy.deepcopy(self.private_reserved_ips)

    # Read slbpublicsubnets
        with open(subnets_file_path, "r") as subnet_file:
            self.public_subnets = json.load(subnet_file)

    def save_reserved_ips(self):
        # Sorts each kingdom's data by fourth octet value
        for kingdom, data in self.public_reserved_ips.items():
            self.public_reserved_ips[kingdom] = OrderedDict(sorted(data.items(), key=lambda item: item[1]))

        public_reserved_ips = OrderedDict(sorted(self.public_reserved_ips.items()))
        self.reserved_ips[PUBLIC_RESERVED_IPS_FIELD_NAME] = public_reserved_ips

        # Sorts each kingdom's data by fourth octet value
        for kingdom, data in self.private_reserved_ips.items():
            self.private_reserved_ips[kingdom] = OrderedDict(sorted(data.items(), key=lambda item: item[1]))

        private_reserved_ips = OrderedDict(sorted(self.private_reserved_ips.items()))
        self.reserved_ips[PRIVATE_RESERVED_IPS_FIELD_NAME] = private_reserved_ips

        with open(self.reserved_ips_file_path, "w") as reserved_ips_file:
            json.dump(self.reserved_ips, reserved_ips_file, indent=2)

    def delete_ip(self, fqdn, cluster, public):
        ips = self.public_reserved_ips if public else self.private_reserved_ips
        if cluster not in ips:
            return

        if fqdn in ips[cluster]:
            ip = ips[cluster][fqdn]
            del ips[cluster][fqdn]
            print("Deleted {}'s reserved IP of {} from {}".format(fqdn, ip, cluster))

    def get_next_public_ip(self, cluster):
        existing_ips = self.public_reserved_ips[cluster].values()

        subnets = self.public_subnets[cluster].split(",")
        for subnet in subnets:
            first_three_octets = get_first_three_octets(subnet)
            for i in range(self.minimum_octet, MAX_OCTET_VALUE + 1):
                new_ip = first_three_octets + "." + str(i)
                if new_ip not in existing_ips:
                    return new_ip

        raise Exception("There are no more free public IPs in: {}".format(cluster))

    def add_private_ip(self, kingdom, cluster, fqdn):
        if cluster in self.private_reserved_ips:
            if fqdn in self.private_reserved_ips[cluster]:
                return
        else:
            self.private_reserved_ips[cluster] = {}

        matching_portal_entry = portal_query.get_portal_entry_from_portal(kingdom, cluster, lambda entry: entry.fqdn, fqdn)
        if matching_portal_entry is None:
            raise Exception("Could not find IP for {}".format(fqdn))

        self.private_reserved_ips[cluster][fqdn] = matching_portal_entry.ip
        print("Added {} to {} with private IP {}".format(fqdn, cluster, matching_portal_entry.ip))

    def add_public_ip(self, fqdn, cluster):
        if cluster not in self.public_subnets:
            raise Exception("No public subnet was found for {}".format(cluster))

        if cluster in self.public_reserved_ips:
            if fqdn in self.public_reserved_ips[cluster]:
                return
        else:
            self.public_reserved_ips[cluster] = {}

        new_ip = self.get_next_public_ip(cluster)
        self.public_reserved_ips[cluster][fqdn] = new_ip
        print("Reserved {} for {} in {}".format(new_ip, fqdn, cluster))

    def get_modified_kingdom_estates(self):
        modified_kingdom_estates = set()
        
        # Checks if everything in original is in new
        for estate, reserved_ips in self.original_public_reserved_ips.items():
            if estate not in self.public_reserved_ips or reserved_ips != self.public_reserved_ips[estate]:
                kingdom = estate.split("-")[0]
                modified_kingdom_estates.add(kingdom + "/" + estate)

        # Checks if new estates were added, equality of existing estates is done above
        for estate, reserved_ips in self.public_reserved_ips.items():
            if estate not in self.original_public_reserved_ips:
                kingdom = estate.split("-")[0]
                modified_kingdom_estates.add(kingdom + "/" + estate)

        # Checks if everything in original is in new
        for estate, reserved_ips in self.original_private_reserved_ips.items():
            if estate not in self.private_reserved_ips or reserved_ips != self.private_reserved_ips[estate]:
                kingdom = estate.split("-")[0]
                modified_kingdom_estates.add(kingdom + "/" + estate)

        # Checks if new estates were added, equality of existing estates is done above
        for estate, reserved_ips in self.private_reserved_ips.items():
            if estate not in self.original_private_reserved_ips:
                kingdom = estate.split("-")[0]
                modified_kingdom_estates.add(kingdom + "/" + estate)
        
        return modified_kingdom_estates


def get_first_three_octets(subnet):
    octets = subnet.split(".")
    return ".".join(octets[:3])
