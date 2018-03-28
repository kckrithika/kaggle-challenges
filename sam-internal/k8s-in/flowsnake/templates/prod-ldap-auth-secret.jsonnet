local util = import "util_functions.jsonnet";
local kingdom = std.extVar("kingdom");
if util.is_prod(kingdom) then
// we don't support LDAP in prod, but the FleetService crashes without an LDAP secret, so we're temporarily deploying a dummy one until the Fleet Service is fixed
{
    apiVersion: "v1",
    kind: "Secret",
    metadata: {
        name: "flowsnake-ldap",
        namespace: "flowsnake",
    },
    type: "Opaque",
    data: {
        "service-username": std.base64("prod@sfdc"),
        "service-password": std.base64("nopassword"),
    },
} else "SKIP"
