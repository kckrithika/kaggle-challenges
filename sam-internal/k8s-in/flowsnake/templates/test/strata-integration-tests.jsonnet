

local flowsnake_config = import "flowsnake_config.jsonnet";

## Resources created via flowsnake_direct_clients:
# - ns
# - role for spark driver
# - SA  for driver (must be same name as integration tests)
# - rolebinding for SA

## Resources that must be created here:
# - role for anonymous perms
# - rolebinding for anonymous to configmap ci-test-requests
# - runner configmap w/ script
# - runner deployment (podcount: 1) w/ pod def that runs script
# - copy of the cliChecker's scripts configmap


# limit to CI target fleet
if !flowsnake_config.ci_resources_enabled then
"SKIP"
else
{
    apiVersion: "v1",
    kind: "List",
    metadata: {},
    items: [
        # Role granting permissions for use by Strata pipelines
        {
            kind: "Role",
            apiVersion: "rbac.authorization.k8s.io/v1",
            metadata: { 
                name: "strata-test-submitter-role",
                namespace: "flowsnake-ci-tests",  # must match NS in flowsnake_direct_clients.jsonnet
                annotations: {
                    "manifestctl.sam.data.sfdc.net/swagger": "disable",
                },
            },
            rules: [
                {
                    apiGroups: [""],
                    verbs: ["get", "list", "patch"],
                    resources: [
                        "configmaps"
                    ],
                    resourceNames: [
                        "ci-test-requests"
                    ]

                },
                {
                    apiGroups: [""],
                    verbs: ["get", "list", "watch"],
                    resources: [
                        "pods",
                        "pods/status",
                        "pods/log"
                    ]
                },
                {
                    apiGroups: ["sparkoperator.k8s.io"],
                    verbs: ["get", "list"],
                    resources: ["sparkapplications"],
                },
            ],
        },
        {
            kind: "RoleBinding",
            apiVersion: "rbac.authorization.k8s.io/v1",
            metadata: {
                name: "strata-test-submitter-rolebinding",
                namespace: "flowsnake-ci-tests",
                annotations: {
                    "manifestctl.sam.data.sfdc.net/swagger": "disable",
                },
            },
            roleRef: {
                kind: "Role",
                name: "strata-test-submitter-role",
                apiGroup: "rbac.authorization.k8s.io",
            },
            subjects: [
                # According to docs, this is the formulation that means "everybody"
                {
                    kind: "Group",
                    name: "system:authenticated",
                    apiGroup: "rbac.authorization.k8s.io"
                },
                {
                    kind: "Group",
                    name: "system:unauthenticated",
                    apiGroup: "rbac.authorization.k8s.io"
                }
            ]
        }
    ]
}