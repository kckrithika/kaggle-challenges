local madkub_common = import "madkub_common.jsonnet";
local flowsnake_config = import "flowsnake_config.jsonnet";
local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local certs_and_kubeconfig = import "certs_and_kubeconfig.jsonnet";
local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");

# Copied from madkub_common
local containerspec(cert_names, user=0) = {
    local certs = madkub_common.make_cert_config(cert_names),
    name: "<replaced>",
    args: [
        "/sam/madkub-client",
        "--madkub-endpoint",
        flowsnake_config.madkub_endpoint,
        "--maddog-endpoint",
        flowsnake_config.maddog_endpoint,
        "--maddog-server-ca",
        if flowsnake_config.is_minikube then "/maddog-onebox/ca/security-ca.pem" else "/etc/pki_service/ca/security-ca.pem",
        "--madkub-server-ca",
        if flowsnake_config.is_minikube then "/maddog-onebox/ca/ca.pem" else "/etc/pki_service/ca/cacerts.pem",
        "--token-folder",
        "/tokens",
        "--kingdom",
        kingdom,
        "--superpod",
        "None",
        "--estate",
        estate,
    ] + std.flattenArrays([['--cert-folders', '%s:%s' % [cert.name, cert.dir]] for cert in certs]) +
    [
       "--ca-folder",
       if flowsnake_config.is_minikube then "/maddog-onebox/ca" else "/etc/pki_service/ca",
    ] +
    (if !flowsnake_config.is_minikube then [
        "--funnel-endpoint",
        flowsnake_config.funnel_endpoint,
    ] else [
        "--log-level",
        "7",
    ]),
    image: flowsnake_images.madkub,
    resources: {
        requests: {
            cpu: "1m",
            memory: "1Mi"
        },
        limits: {
            cpu: "1.0",
            memory: "1Gi"
        },
    },
    volumeMounts: madkub_common.cert_mounts(certs)
        + [{
            mountPath: "/tokens",
            name: "tokens",
        }]
    + (if !flowsnake_config.is_minikube then
        certs_and_kubeconfig.platform_cert_volumeMounts
    else [
        {
            mountPath: "/maddog-onebox",
            name: "maddog-onebox-certs",
        },
    ]),
    env: [
        {
        name: "MADKUB_NODENAME",
            valueFrom: {
                fieldRef: {
                    apiVersion: "v1",
                    fieldPath: "spec.nodeName",
                },
            },
        },
        {
        name: "MADKUB_NAME",
            valueFrom: {
                fieldRef: {
                    apiVersion: "v1",
                    fieldPath: "metadata.name",
                },
            },
        },
        {
        name: "MADKUB_NAMESPACE",
            valueFrom: {
                fieldRef: {
                    apiVersion: "v1",
                    fieldPath: "metadata.namespace",
                },
            },
        },
    ],
} + (if user == null || user == 0 then {} else {
    securityContext: {
        runAsNonRoot: true,
        runAsUser: user,
    },
});

if flowsnake_config.madkub_enabled then
{
    apiVersion: "v1",
    kind: "ConfigMap",
    metadata: {
        name: "madkub-container-spec",
        namespace: "flowsnake",
    },
    data: {
        "spec.jaysawn": std.toString(containerspec([
                                                    {
                                                        name: "usercerts",
                                                        dir: "/certs",
                                                        type: "client",
                                                        volume: "datacerts",
                                                    }]
                                                    + (if std.objectHas(flowsnake_images.feature_flags, "madkub_injector_server_cert") then
                                                        [{
                                                            name: "servercerts",
                                                            dir: "/servercerts",
                                                            type: "server",
                                                            volume: "servercerts",
                                                        }] else [])
                                                    , 7447))
    }
} else "SKIP"
