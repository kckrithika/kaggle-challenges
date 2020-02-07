local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local samfeatureflags = import "sam-feature-flags.jsonnet";
local utils = import "util_functions.jsonnet";
local portconfigs = import "portconfig.jsonnet";

if configs.estate == "prd-sam" then {
    kind: "Deployment",
    spec: {
        replicas: 2,
        template: {
            spec: {
                containers: [
                    {
                        name: "sloop-redirect",
                        image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/thargrove/redirect:latest",
                        command: [
                            "/redirect",
                            "--port=" + portconfigs.sloop.sloop,
                            "--message=Moved to http://sfdc.co/sloop-prd-sam",
                        ],
                        ports: [
                            {
                                containerPort: portconfigs.sloop.sloop,
                            },
                        ],
                    },
                ],
                nodeSelector: {
                              } +
                              if !utils.is_production(configs.kingdom) then {
                                  master: "true",
                              } else {
                                  pool: configs.estate,
                              },
            },
            metadata: {
                labels: {
                    name: "sloop-redirect",
                } + configs.ownerLabel.sam,
                namespace: "sam-system",
            },
        },
        selector: {
            matchLabels: {
                name: "sloop-redirect",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "sloop-redirect",
        } + configs.ownerLabel.sam,
        name: "sloop-redirect",
        namespace: "sam-system",
    },
} else "SKIP"
