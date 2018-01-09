local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local utils = import "util_functions.jsonnet";
{
    sdn_watchdog_emailsender: "sdn-alerts@salesforce.com",
    sdn_watchdog_emailrec: (if kingdom == "chx" || kingdom == "wax" || estate == "prd-samdev" || estate == "prd-samtest" || estate == "prd-sam_storage" || estate == "prd-sdc" || estate == "prd-data-flowsnake_test" then "sdn@salesforce.com" else "sdn-alerts@salesforce.com"),

    # SDN MoM VIP Endpoints
    momVIP: "https://ops0-momapi1-0-" + kingdom + ".data.sfdc.net/api/v1/network/device?key=host-bgp-routes",

    # Charon/Nyx Endpoints
    charonEndpoint: "https://sds2-polcore2-2-" + kingdom + ".eng.sfdc.net:9443/minions",

    # SDN K8S Secret File path
    bgpPasswordFile: (
        if utils.is_flowsnake_cluster(estate) then
            "/data/secrets/flowsnakebgppassword"
        else
            "/data/secrets/sambgppassword"
    ),
}
