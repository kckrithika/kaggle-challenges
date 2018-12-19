## Service Mesh - Istio Pilot Deployment
The [templates](./templates) contains the K8s resources derived from [Istio minimal install](https://istio.io/docs/setup/kubernetes/minimal-install/). 
There are certain modifications to the yaml. When upgrading manually make sure you compare the yaml you are upgrading. We need to build a tool to automate this.  

Till ServiceAccount support is functional, istio-pilot is expected to run on the pool that has `cluster-admin` privilege, i.e., kubeapi nodes.

Files that end with **.TEMPLATE** suffix are not processed by the build script.

## Deployment Steps
1. Update the new image as required in [istio-images.jsonnet](./istio-images.jsonnet). Note: Phased deployment not decided yet for istio, only phase 0 active.
1. Update the [istio-pilot-estates.json](./istio-pilot-estates.json) if there is a change to estates.
1. Run `./build.sh` in [k8s-in directory](../build.sh). This will generate the k8s yamls in [k8s-out directory](../../k8s-out) as per the estates.
1. If you would like to verify the generated k8s resource files, apply them directly to your local k8s cluster or to prd-samtest only. Ensure you are in the intended kubectl context.
1. Create PR for review.
1. Once the PR is authorized, the SAM TNRP pipeline should take care of the deployment. Use the links mentioned in [SAM Auto Deployer](https://git.soma.salesforce.com/sam/sam/wiki/Debugging-SAM-Auto-Deployer) to check the deployment progress and errors.

# Verification
Shipping-Ordering Istio apps are deployed in both prd-sam and prd-samtest in `mesh-control-plane` namespace for verification purposes. Please ensure the apps are running as expected after any modifications. Once metrics support is added, we will add alerts for the same.
```
$ kubectl -n mesh-control-plane get deployments
NAME                 DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
ordering-istio       1         1         1            0           19h
shipping-istio       1         1         1            0           19h
```

The app definitions can be found in the [mesh-control-plane](https://git.soma.salesforce.com/sam/manifests/tree/master/apps/team/mesh-control-plane) team manifests.