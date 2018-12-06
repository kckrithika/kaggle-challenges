local flowsnake_config = import "flowsnake_config.jsonnet";
local flowsnake_hostlist = import "flowsnake_hosts.jsonnet";

if flowsnake_config.kubernetes_hosts_are_admin then (
{
    kind: "ClusterRoleBinding",
    apiVersion: "rbac.authorization.k8s.io/v1",    
    metadata: {
        name: "hosts-are-admin",
        annotations: {
            "manifestctl.sam.data.sfdc.net/swagger": "disable",
        },
    },
    roleRef: {
        kind: "ClusterRole",
        name: "cluster-admin",
        apiGroup: "rbac.authorization.k8s.io",
    },
    subjects: [
        {
            kind: "User",
            name: host.hostname
        }
        for host in flowsnake_hostlist.hosts
    ],
}) else "SKIP"