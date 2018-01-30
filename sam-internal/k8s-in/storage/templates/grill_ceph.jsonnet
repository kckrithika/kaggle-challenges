local configs = import "config.jsonnet";
local storageutils = import "storageutils.jsonnet";
local storageimages = import "storageimages.jsonnet";

if configs.estate == "prd-sam_storage" || configs.estate == "prd-sam" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "grill_ceph",
            team: "legostore",
            cloud: "storage",
        },
        name: "grill_ceph-deployment",
        namespace: "sam-system",
    },
    spec: {
        replicas: 1,
        minReadySeconds: 30,
        template: {
            metadata: {
                labels: {
                    name: "grill-ceph",
                    team: "legostore",
                    cloud: "storage",
                },
            },
            spec: {
                containers: [
                    {
                        name: "grill_ceph",
                        image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/small/ceph-test:ceph-v1",
                        ports: [
                            {
                                containerPort: 9098,
                            },
                        ],
                        livenessProbe: {
                            httpGet: {
                                path: "/",
                                port: 9098,
                            },
                        },
                    },
                    {
                        // Pump prometheus metrics to argus.
                        name: "sfms",
                        image: storageimages.sfms,
                        command: [
                            "/opt/sfms/bin/sfms",
                        ],
                        args: [
                            "-j",
                            "prometheus",
                        ],
                        env: storageutils.sfms_environment_vars("grill_ceph"),

                    },
                ],
                },
            },
        },
    } else "SKIP"
