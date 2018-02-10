local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local portconfigs = import "portconfig.jsonnet";
local samimages = (import "../sam/samimages.jsonnet") + { templateFilename:: std.thisFile };

if configs.estate == "prd-sdc" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "slb-cert",
        },
        name: "slb-cert",
         namespace: "sam-system",
    },
    spec: {
        replicas: 1,
        template: {
            metadata: {
                labels: {
                    name: "slb-cert",
                },
                namespace: "sam-system",
            },
            spec: {
                containers: [
                    {
                      name: "madkub-refresher",
                      args: [
                        "/sam/madkub-client",
                        "--madkub-endpoint",
                        "",
                        "--maddog-endpoint",
                        "https://all.pkicontroller.pki.blank." + configs.kingdom + ".prod.non-estates.sfdcsd.net:8443",
                        "--maddog-server-ca",
                        "/maddog-certs/ca/security-ca.pem",
                        "--madkub-server-ca",
                        "/maddog-certs/ca/cacerts.pem",
                        "--token-folder",
                        "/tokens/",
                        "--refresher",
                        "--refresher-token-grace-period",
                        "30s",

                        "--funnel-endpoint",
                        "http://" + configs.funnelVIP,
                        "--kingdom",
                        configs.kingdom,
                      ] +
                      if samimages.per_phase[samimages.phase].madkub == "1.0.0-0000035-9241ed31" then [
                        "--cert-folder",
                        "/certs/",
                        "--requested-cert-type",
                        "server",
                        ] else [
                        "--cert-folders",
                        "madkubInternalCert:/certs/",
                        ],
                      image: samimages.madkub,
                      resources: {
                      },
                      volumeMounts: configs.filter_empty([
                        {
                          mountPath: "/certs",
                          name: "datacerts",
                        },
                        {
                          mountPath: "/tokens",
                          name: "tokens",
                        },
                        {
                          mountPath: "/maddog-certs/",
                          name: "pki",
                        },
                      ]),
                      env: [
                        {
                          name: "MADKUB_NODENAME",
                          valueFrom: {
                            fieldRef: {
                              fieldPath: "spec.nodeName",
                            },
                          },
                        },
                        {
                          name: "MADKUB_NAME",
                          valueFrom: {
                            fieldRef: {
                              fieldPath: "metadata.name",
                            },
                          },
                        },
                        {
                          name: "MADKUB_NAMESPACE",
                          valueFrom: {
                            fieldRef: {
                              fieldPath: "metadata.namespace",
                            },
                          },
                        },
                      ],
                    },
                ],
               restartPolicy: "Always",
               volumes: configs.filter_empty([
                 {
                   name: "kubeconfig",
                   hostPath: {
                     path: "/etc/kubernetes/kubeconfig",
                   },
                 },
                 {
                   name: "kubeconfig-certs",
                   hostPath: {
                     path: "/data/certs",
                   },
                 },
                 {
                   name: "pki",
                   hostPath: {
                     path: "/etc/pki_service",
                   },
                 },
                 {
                   name: "datacerts",
                   emptyDir: {
                     medium: "Memory",
                   },
                 },
                 {
                   name: "tokens",
                   emptyDir: {
                     medium: "Memory",
                   },
                 },
               ]),
            },
        },
    },
} else "SKIP"
