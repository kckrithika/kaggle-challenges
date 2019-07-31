# Architecture

![mTLS](https://git.soma.salesforce.com/storage/user/9054/files/afd60380-afc4-11e9-89a9-85187c91798c)

* **A**: Beacon (hda sidecar) announces HDA to Zookeeper on startup
    * https://git.soma.salesforce.com/sam/manifests/blob/master/apps/team/hubs/hda/manifest.yaml#L43
* **1**: hda-client sends a grpc request to `heap-dump-analyser.hubs.localhost.mesh.force.com:5443` which routes to the Sherpa sidecar.
* **2**: Sherpa (hda-client sidecar) looks up hubs/heap-dump-analyser on Zookeeper for it’s kingdom.
* **3**: Sherpa (hda-client sidecar) sends the grpc request to Sherpa (hda) on port 7443 using mTLS.
* **4**: Sherpa (hda sidecar) hands the grpc request (and the client certificate) to hda on localhost:7020.