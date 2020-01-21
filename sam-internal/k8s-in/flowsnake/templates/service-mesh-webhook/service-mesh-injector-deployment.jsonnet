local madkub_common = import "madkub_common.jsonnet";
local kingdom = std.extVar("kingdom");
local certs_and_kubeconfig = import "certs_and_kubeconfig.jsonnet";
local cert_name = "madkubinjector";
local flowsnake_config = import "flowsnake_config.jsonnet";
local flowsnake_images = import "flowsnake_images.jsonnet";

if flowsnake_config.service_mesh_enabled then
{
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        name: "service-mesh-injector",
        namespace: "flowsnake",
    },
    spec: {
        replicas: 2,
        selector: {
            matchLabels: {
                app: "service-mesh-injector"
            }
        },
        template: {
            metadata: {
                labels: {
                    app: "service-mesh-injector"
                },
                annotations: {
                    "madkub.sam.sfdc.net/allcerts": std.toString({"certreqs": [{
                        "cert-type": "server",
                        "kingdom": kingdom,
                        "name": cert_name,
                        "role": "flowsnake.service-mesh-injector",
                        "san": ["service-mesh-injector.flowsnake", "service-mesh-injector.flowsnake.svc", "service-mesh-injector.flowsnake.svc.cluster.local"]
                    }]}),
                    "annotation_to_force_restart": "1"
                }
            },
            spec: {
                serviceAccountName: "service-mesh-injector-serviceaccount",
                containers: [
                    {
                        name: "injector",
                        image: flowsnake_images.service_mesh_injector,
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
                              mountPath: "/etc/service-mesh-container-spec",
                              readOnly: true
                          },
                        ] +
                        madkub_common.cert_mounts(cert_name),
                        args: [
                            "-serviceMeshContainerSpecFile",
                            "/etc/service-mesh-container-spec/spec.jaysawn",
                            "-kingdom",
                            kingdom,
                            "-v",
                            "2",
                            "-alsologtostderr",
                        ]
                    }
                    + (if std.objectHas(flowsnake_images.feature_flags, "webhook_readiness_probes") then {
                        readinessProbe:
                            {
                                httpGet: {
                                    path: "/healthz",
                                    port: 8443,
                                    scheme: "HTTPS",
                                },
                                initialDelaySeconds: 5,
                                periodSeconds: 5,
                            }
                        } else {}),
                    madkub_common.refresher_container(cert_name),
                ],
                initContainers: [ madkub_common.init_container(cert_name) ],
                volumes: [
                    {
                        name: "spec",
                        configMap: {
                            name: "service-mesh-container-spec"
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
