## Service Mesh - Istio Pilot Deployment
The [teamplates](templates) contains the K8s resources derived from [Istio minimal install](https://istio.io/docs/setup/kubernetes/minimal-install/). There are certain modifications to the yaml.
1. The sidecar injection config is currently not present.
1. The ServiceAccount, ClusterRole and ClusterRoleBinding are not used. istio-pilot is expected to run on the pool that has `cluster-admin` privilege till SAM supports ServiceAccount.

Files that end with **.TEMPLATE** suffix are not processed by the build script.
