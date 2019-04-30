# This provides a the ability to customize the shell to your liking on a host by running a one-liner.
# Roughly, the mechanism to to put content in a script in a configmap and execute a one-liner that grabs and runs
# the script to install the content.

local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
if !std.objectHas(flowsnake_images.feature_flags, "aliases") then
"SKIP"
else
{
    apiVersion: "v1",
    kind: "List",
    metadata: {},
    items: [
        // Define a role with access to read the config map
        {
            kind: "Role",
            apiVersion: "rbac.authorization.k8s.io/v1",
            metadata: {
                namespace: "default",
                name: "shell-customize-reader",
            },
            rules: [
                {
                    apiGroups: [""],
                    resources: ["configmaps"],
                    resourceNames: ["shell-customize"],
                    verbs: ["get"],
                },
            ],
        },
        // Put everyone in the role
        {
            kind: "RoleBinding",
            apiVersion: "rbac.authorization.k8s.io/v1",
            metadata: {
                name: "shell-customize-reader-everyone",
                annotations: {
                     "manifestctl.sam.data.sfdc.net/swagger": "disable",
                },
            },
            roleRef: {
                kind: "Role",
                name: "shell-customize-reader",
                apiGroup: "rbac.authorization.k8s.io",
            },
            subjects: [
                {
                    kind: "Group",
                    name: "system:authenticated",
                    apiGroup: "rbac.authorization.k8s.io",
                },
                {
                    kind: "Group",
                    name: "system:unauthenticated",
                    apiGroup: "rbac.authorization.k8s.io",
                },
                {
                    kind: "Group",
                    name: "system:serviceaccounts",
                    apiGroup: "rbac.authorization.k8s.io",
                }
            ]
        },
        {
            kind: "ConfigMap",
            apiVersion: "v1",
            metadata: {
              name: "shell-customize",
              namespace: "default",
            },
            data: {
              "install.sh":
                importstr "customize-shell-user-overrides.sh" + importstr "customize-shell-aliases.sh" + importstr "customize-shell-install.sh",
            },
        },
    ]
}
