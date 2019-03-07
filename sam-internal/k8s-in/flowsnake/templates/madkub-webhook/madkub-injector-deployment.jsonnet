local madkub_common = import "madkub_common.jsonnet";
local kingdom = std.extVar("kingdom");
local certs_and_kubeconfig = import "certs_and_kubeconfig.jsonnet";
local cert_name = "madkubinjector";
local flowsnake_config = import "flowsnake_config.jsonnet";
local flowsnake_images = import "flowsnake_images.jsonnet";

if flowsnake_config.madkub_enabled then
{
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        name: "madkub-injector",
        namespace: "flowsnake",
    },
    spec: {
        replicas: 2,
        selector: {
            matchLabels: {
                app: "madkub-injector"
            }
        },
        template: {
            metadata: {
                labels: {
                    app: "madkub-injector"
                },
                annotations: {
                    "madkub.sam.sfdc.net/allcerts": std.toString({"certreqs": [{
                        "cert-type": "server",
                        "kingdom": kingdom,
                        "name": cert_name,
                        "role": "flowsnake.madkub-injector",
                        "san": ["madkub-injector.flowsnake", "madkub-injector.flowsnake.svc", "madkub-injector.flowsnake.svc.cluster.local"]
                    }]})
                }
            },
            spec: {
                serviceAccountName: "madkub-injector-serviceaccount",
                containers: [
                    {
                        name: "injector",
                        image: flowsnake_images.madkub_injector,
                        imagePullPolicy: "Always",
                        ports: [{
                            containerPort: 8443
                        }],
                        livenessProbe: {
                            httpGet: {
                                path: "/healthz",
                                port: 8443,
                                scheme: "HTTPS",
                            },
                            initialDelaySeconds: 5,
                            periodSeconds: 5,
                        },
                        volumeMounts: [
                          {
                              name: "spec",
                              mountPath: "/etc/madkub-container-spec",
                              readOnly: true
                          },
                          {
                              name: "volumes",
                              mountPath: "/etc/madkub-required-volumes",
                              readOnly: true
                          },
                        ] +
                        madkub_common.cert_mounts(cert_name),
                        args: [
                            "-madkubVolumesFile",
                            "/etc/madkub-required-volumes/volumes.jaysawn",
                            "-madkubContainerSpecFile",
                            "/etc/madkub-container-spec/spec.jaysawn",
                            "-kingdom",
                            kingdom,
                            "-v",
                            "2",
                            "-alsologtostderr",
                        ]
                    },
                    madkub_common.refresher_container(cert_name),
                ],
                initContainers: [ madkub_common.init_container(cert_name) ],
                volumes: [
                    {
                        name: "spec",
                        configMap: {
                            name: "madkub-container-spec"
                        }
                    },
                    {
                        name: "volumes",
                        configMap: {
                            name: "madkub-required-volumes"
                        }
                    },
                ] +
                madkub_common.cert_volumes(cert_name) +
                (if !flowsnake_config.is_minikube then
                    certs_and_kubeconfig.kubeconfig_volume
                else []),
            }
        }
    }
} else "SKIP"
