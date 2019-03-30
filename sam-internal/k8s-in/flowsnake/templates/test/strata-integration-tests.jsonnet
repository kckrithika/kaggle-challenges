
# Strata integration testing of Spark-on-Kubernetes
#
# The flow is as follows:
# - Strata build creates docker images, including a "test runner" image based on cliChecker.
# - Strata build script pokes a key-value into a special configmap "ci-test-requests" in the
#   flowsnake-ci-tests namespace
# - Test Agent monitors the configmap; when a new entry appears it creates a test-runner pod using the k+v
#   as name and docker image tag, respectively.
# - Strata build script monitors the runner pod for completion and success, then writes its logs into the
#   Strata build logs.
#
# This file creates some miscellaneous resources needed for this process
#
# Resources created here:
# - Role for perms to get/list pods, logs, sparkapplications, and configmaps + patch the test requests configmap
# - Rolebinding of all users (including anonymous) to the preceding
# - Configmap containing scripts and the runner pod template used by the test agent
#
# Resources created via configuration in ../../flowsnake_direct_clients.jsonnet:
# - flowsnake-ci-tests namespace
# - role for client/sparkdriver to access anything in that NS
# - service account for sparkdriver (reused for the agent so it can schedule pods)
# - rolebinding for preceeding role to preceeding SA, plus flowsnake_test.flowsnake-ci-test user
#
# Other related resources:
# - The spec for the test agent's deployment, in strata-test-agent-deployment.jsonnet
# - a copy of the watchdog test-runner scripts in the flowsnake-ci-tests namespace, produced by
#   logic in ../watchdog/watchdog-spark-operator-scripts.libsonnet
# - the ci-test-requests configmap, created dynamically by the agent when it is missing.


local flowsnake_config = import "flowsnake_config.jsonnet";

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
        },
        {
            kind: "ConfigMap",
            apiVersion: "v1",
            metadata: {
                name: "strata-test-agent-scripts",
                namespace: "flowsnake-ci-tests"
            },
            data: {
                "strata-test-agent.py": importstr "strata-test-agent.py",
                "runner_spec_template.json": std.toString(import "strata-runner-spec.libsonnet"),
            }
        },
    ]
}