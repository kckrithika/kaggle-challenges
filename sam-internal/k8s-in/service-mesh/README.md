## Service Mesh - Istio Pilot Deployment
The [templates](./templates) contains the K8s resources derived from [Istio minimal install](https://istio.io/docs/setup/kubernetes/minimal-install/). There are certain modifications to the yaml.
1. The sidecar injection config is currently not present.
1. The ServiceAccount, ClusterRole and ClusterRoleBinding are not used. istio-pilot is expected to run on the pool that has `cluster-admin` privilege till SAM supports ServiceAccount.

Files that end with **.TEMPLATE** suffix are not processed by the build script.

## Deployment Steps
1. Update the new image if required in [istio-images.jsonnet](./istio-images.jsonnet). Note: Currently we don't have a deployment flow defined nor images in SFCI, so the images are hard-coded in the deployment jsonnet files.
1. Update the [istio-pilot-estates.json](./istio-pilot-estates.json) if there is a change to estates.
1. Run `./build.sh` in [k8s-in directory](../build.sh). This will generate the k8s yamls in [k8s-out directory](../../k8s-out) as per the estates.
1. If you would like to verify the generated k8s resource files, apply them directly to your local k8s cluster or to prd-samtest only. Ensure you are in the intended kubectl context.
1. Create PR for review.
1. Once the PR is authorized, the SAM TNRP pipeline should take care of the deployment. Use the links mentioned in [SAM Auto Deployer](https://git.soma.salesforce.com/sam/sam/wiki/Debugging-SAM-Auto-Deployer) to check the deployment progress and errors.

