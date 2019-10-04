from io import StringIO
from lxml import etree
import ssl
import urllib.request

DEFAULT_CLUSTER = "sam"

PRD_KINGDOM_NAME = "prd"

SLB_PORTAL_URL = "http://slb-portal-{}.slb.sfdc.net"
SLB_PORTAL_PRD_PORT = "9112"

portal_info_cache = {}


class PortalEntry:
    def __init__(self, lbname, fqdn, ip):
        self.lbname = lbname
        self.fqdn = fqdn
        self.ip = ip


def __get_portal_url(kingdom, cluster):
    if kingdom == PRD_KINGDOM_NAME:
        namespace_with_cluster_name = "service.sam-system.{}.prd".format(cluster)
        return SLB_PORTAL_URL.format(namespace_with_cluster_name) + ":" + SLB_PORTAL_PRD_PORT

    return SLB_PORTAL_URL.format(kingdom)


def __get_portal_info(url):
    if url in portal_info_cache:
        return portal_info_cache[url]

    print("Connecting to {}".format(url))

    ssl._create_default_https_context = ssl._create_unverified_context
    conn = urllib.request.urlopen(url)
    byte_response = conn.read()

    str_response = byte_response.decode("utf8")
    conn.close()

    tree = etree.parse(StringIO(str_response), etree.HTMLParser())

    root = tree.getroot()
    results = root.xpath("//table[@id='serviceTable']/tr/td[position() = 1]|//table[@id='serviceTable']/tr/td[position() = 2]/a|//table[@id='serviceTable']/tr/td[position() = 3]")

    portal_entries = []
    index = 0
    while index < len(results):
        portal_entries.append(PortalEntry(results[index].text, results[index + 1].text, results[index + 2].text))
        index += 3

    portal_info_cache[url] = portal_entries

    return portal_entries


def get_portal_entry_from_portal(kingdom, cluster, evaluator, value):
    portal_entries = __get_portal_info(__get_portal_url(kingdom, cluster))
    for portal_entry in portal_entries:
        if value == evaluator(portal_entry):
            return portal_entry

    return None

