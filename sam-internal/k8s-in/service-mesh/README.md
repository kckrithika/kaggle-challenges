# Mesh Control Plane
## Istio Pilot Update, Upgrade & Deployment 
The [templates](./templates) directory contains the Istio k8s resources auto-generated from the [Istio helm charts](https://github.com/istio/istio/tree/master/install/kubernetes/helm/istio) using [Replicated Ship](https://github.com/replicatedhq/ship) and [Internal Istio Upgrade Tool](https://git.soma.salesforce.com/servicemesh/istio-upgrade). 

The [istio-ship](./istio-ship) directory contains Ship's workspace to convert Istio helm charts to [yaml with embedded jsonnet variables](./istio-ship/rendered.yaml). The Istio Upgrade tool converts this single yaml which contains multiple Istio resources to separate jsonnet templates and populates them in [templates](./templates) directory.

[`./build.sh`](../build.sh) converts the auto-generated jsonnet templates to yaml with SAM config values populated in place of the jsonnet variables.

**Notes:**
1. Files that end with **.TEMPLATE** suffix are not processed by the build script.
1. Some files in the templates directory are added manually like the `Policy` object till we find a better place for it.

### Update/Upgrade and Deployment Steps (Skip steps as required based on the action)
1. If updating Istio images, update the new image as required in [istio-images.jsonnet](./istio-images.jsonnet). Note: Phased deployment not decided yet for istio, only phase 0 active.
1. If updating the estates Istio runs on, update the [istio-pilot-estates.json](./istio-pilot-estates.json).
1. If updating overlays, ensure [Ship is installed](https://github.com/replicatedhq/ship#installation), navigate to [istio-ship](./istio-ship) directory and run `ship update --headed`.
1. If updating overlays, complete all the steps in Ship's visual UI. Jsonnet variables in overlays can be represented as `"mcpIstioConfig.<name>"` or `"%(<name>)s" % mcpIstioConfig`. Where, `<name>` is the variable name defined in [`istio-config.jsonnet`](./istio-config.jsonnet).
1. Run [`./generate-istio-templates.sh`](./generate-istio-templates.sh) script. This will auto-generate jsonnet templates in [templates](./templates) directory based on the [rendered.yaml](./istio-ship/rendered.yaml).
1. Run [`./build.sh`](../build.sh) script in [k8s-in directory](../). This will generate the k8s yamls in [k8s-out directory](../../k8s-out) as per the estates.
1. If you would like to verify the generated k8s resource files, apply them directly to your local k8s cluster or to prd-samtest only. Ensure you are in the intended kubectl context.
1. Create PR for review.
1. Once the PR is authorized, the SAM TNRP pipeline should take care of the deployment. Use the links mentioned in [SAM Auto Deployer](https://git.soma.salesforce.com/sam/sam/wiki/Debugging-SAM-Auto-Deployer) to check the deployment progress and errors.
1. Verify Istio deployments and Istio test apps are running fine based on the steps mentioned below.

### Verification
Istio test apps are deployed in `prd-sam` in `service-mesh` namespace. Please ensure the apps are running as expected after any modifications. Once metrics support is added, we will add alerts for the same.
```
$ kubectl config use-context prd-sam
Switched to context "prd-sam".

$ kubectl -n mesh-control-plane get pods -o wide
NAME                                     READY     STATUS    RESTARTS   AGE       IP               NODE
istio-ingressgateway-584b455c6b-q27cw    2/2       Running   0          1d        10.251.130.103   shared0-samminiongater1-1-prd.eng.sfdc.net
istio-mesh-webhook-58db4957fb-cv8bj      2/2       Running   2          3d        10.251.161.41    shared0-samkubeapi1-1-prd.eng.sfdc.net
istio-mesh-webhook-58db4957fb-qksm8      2/2       Running   0          3d        10.251.163.174   shared0-samkubeapi2-1-prd.eng.sfdc.net
istio-mesh-webhook-58db4957fb-tdw4n      2/2       Running   0          3d        10.251.161.202   shared0-samkubeapi3-1-prd.eng.sfdc.net
istio-pilot-7b6946ff78-6447v             2/2       Running   0          18h       10.251.131.38    shared0-samminiongater2-4-prd.eng.sfdc.net
istio-sidecar-injector-f59875c8c-7kpm6   2/2       Running   0          1h        10.251.161.195   shared0-samkubeapi3-1-prd.eng.sfdc.net
istio-sidecar-injector-f59875c8c-st84v   2/2       Running   0          1h        10.251.163.165   shared0-samkubeapi2-1-prd.eng.sfdc.net

$ kubectl -n service-mesh get pods | grep istio
istio-fake-casam-5db6587dc6-92tx8                       4/4       Running                        0          4d
istio-fake-casam-na35-86f5bff859-9nrkw                  4/4       Running                        0          4d
istio-geoip-77dc849555-ksb4n                            5/5       Running                        1          4d
istio-ordering-54945d5b49-br2p7                         4/4       Running                        0          3d
istio-ordering-mixed-istio-to-sherpa-7d6fd45bbb-d6khw   4/4       Running                        0          4d
istio-ordering-mixed-sherpa-to-istio-67fcb69f57-2g5tg   2/3       Running                        4          4d
istio-shipping-7bd9467875-6n9rz                         4/4       Running                        0          4d
istio-shipping-mixed-istio-to-sherpa-6ddb77b4d9-4jl6k   4/4       Running                        1          4d
istio-shipping-mixed-sherpa-to-istio-64f799c4dd-qt9bl   5/5       Running                        0          4d
```

The app definitions can be found in the [service-mesh team manifests](https://git.soma.salesforce.com/sam/manifests/tree/master/apps/team/service-mesh).