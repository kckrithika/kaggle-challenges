local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";
local samfeatureflags = import "sam-feature-flags.jsonnet";

if samfeatureflags.maddogforsamapps then configs.deploymentBase("sam") {
    metadata+: {
        name: "madkubserver",
        namespace: "sam-system",
    }
    + (if utils.is_pcn(configs.kingdom) then { labels: {} + configs.pcnEnableLabel } else {}),
    spec+: {
        replicas: if utils.is_pcn(configs.kingdom) then 1 else 3,
        minReadySeconds: 45,
        revisionHistoryLimit: 2,
        template: {
            metadata: {
                labels: {
                    service: "madkubserver",
                } + configs.ownerLabel.sam,
            },
            spec: {
                hostNetwork: if !utils.is_running_flannel(configs.kingdom) then false else true,
                nodeSelector: {
                } + (if utils.is_pcn(configs.kingdom) then {} else { master: "true" }),
                containers: [
                    {
                        args: [
                            "/sam/madkub-server",
                            "--listen",
                            "0.0.0.0:32007",
                            "-d",
                            "--maddog-endpoint",
                            if utils.is_pcn(configs.kingdom) then configs.maddogGCPEndpoint else configs.maddogEndpoint,
                            "--kubeconfig",
                            if utils.is_pcn(configs.kingdom) then "$(KUBECONFIG)" else "/kubeconfig",
                            "--client-cert",
                            if utils.is_pcn(configs.kingdom) then "/etc/gcp_certs/tls.crt" else "/etc/pki_service/root/madkubtokenserver/certificates/madkubtokenserver.pem",
                            "--client-key",
                            if utils.is_pcn(configs.kingdom) then "/etc/gcp_certs/tls.key" else "/etc/pki_service/root/madkubtokenserver/keys/madkubtokenserver-key.pem",
                            "--maddog-server-ca",
                            "/etc/pki_service/ca/security-ca.pem",
                            "--cert-folder",
                            "/certs/",
                            "--token-folder",
                            "/tokens/",
                            "--service-hostname",
                            "$(MADKUBSERVER_SERVICE_HOST)",
                            "--funnel-endpoint",
                            if utils.is_pcn(configs.kingdom) then "" else "http://" + configs.funnelVIP,
                            "--kingdom",
                            configs.kingdom,
                            "--estate",
                            configs.estate,

                        ] + if configs.kingdom == "prd" then
                            [
                                "--retry-max-elapsed-time",
                                "20s",
                            ] else [],
                        image: if utils.is_pcn(configs.kingdom) then samimages.static.madkubPCN else samimages.madkub,
                        name: "madkubserver",
                        ports: [
                            {
                                containerPort: 3000,
                            },
                        ],
                        volumeMounts: configs.filter_empty([
                            {
                                mountPath: "/kubeconfig",
                                name: "kubeconfig",
                            },
                        ]) + (if !utils.is_pcn(configs.kingdom) then [{ mountPath: "/data/certs", name: "kubeconfig-certs" }, { mountPath: "/certs", name: "datacerts" }] else [])
                           + [{ mountPath: "/tokens", name: "tokens" }, { mountPath: "/etc/pki_service/", name: "pki" }]
                           + (if utils.is_pcn(configs.kingdom) then [{ mountPath: "/etc/gcp_certs/", name: "tls" }] else []),
                        livenessProbe: {
                            httpGet: {
                                path: "/healthz",
                                port: 32007,
                                scheme: "HTTPS",
                            },
                            initialDelaySeconds: 30,
                            periodSeconds: 10,
                        },
                    } + configs.containerInPCN + configs.ipAddressResourceRequest,
                    {
                        name: "madkub-refresher",
                        args: [
                                  "/sam/madkub-client",
                                  "--madkub-endpoint",
                                  "",
                                  "--maddog-endpoint",
                                  if utils.is_pcn(configs.kingdom) then configs.maddogGCPEndpoint else configs.maddogEndpoint,
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
                                  if utils.is_pcn(configs.kingdom) then "" else "http://" + configs.funnelVIP,
                                  "--kingdom",
                                  configs.kingdom,
                                  "--ca-folder",
                                  "/maddog-certs/ca",
                              ] +
                              (if configs.estate == "prd-samtest" then [
                                  "--run-init-for-refresher-mode",
                                  "false",
                              ] else []) +
                              (if samimages.madkub == "1.0.0-0000035-9241ed31" then [
                                  "--cert-folder",
                                  "/certs/",
                                  "--requested-cert-type",
                                  "server",
                              ] else [
                                  "--cert-folders",
                                  "madkubInternalCert:/certs/",
                              ]),
                        image: if utils.is_pcn(configs.kingdom) then samimages.static.madkubPCN else samimages.madkub,
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
                ]) + (if !utils.is_pcn(configs.kingdom) then [{ name: "kubeconfig-certs", hostPath: { path: "/data/certs" } }] else [])
                   + [{ name: "pki", hostPath: { path: "/etc/pki_service" } }]
                   + [{ name: "datacerts", emptyDir: { medium: "Memory" } }]
                   + [{ name: "tokens", emptyDir: { medium: "Memory" } }]
                   + (if utils.is_pcn(configs.kingdom) then [{ name: "tls", secret: { secretName: "madkubserver-cert" } }] else []),
            } + configs.serviceAccount,
        },
    },
} else "SKIP"
