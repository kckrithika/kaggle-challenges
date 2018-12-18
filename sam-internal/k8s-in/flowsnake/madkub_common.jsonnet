local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local flowsnakeconfig = import "flowsnake_config.jsonnet";
local certs_and_kubeconfig = import "certs_and_kubeconfig.jsonnet";
local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");

local default_cert_folder_map = { datacerts: "/certs" };

# Generate Volume Mounts for all MadDog certificates
# cert_name_folder_map associates named certs with their directory on disk.
# default: "datacerts" cert is mounted at /certs
#
# The volumeMounts do NOT include the PKI host-cert directories because, even though (for now, at least)
# the MadKub init/refresh side-cars need to mount those, the primary MadKub-cert-using container does not
# need to mount them.
local cert_mounts(cert_name_folder_map=default_cert_folder_map) = [{
    mountPath: '%s' % cert_name_folder_map[cert_name],
    name: cert_name,
} for cert_name in std.objectFields(cert_name_folder_map)];

# Generate Volumes for all MadDog certificates
# cert_name_folder_map associates named certs with their directory on disk.
# default: "datacerts" cert and tokens in Memory volume
#
# The volumes include the PKI host-cert directories because (for now, at least)
# the MadKub init/refresh side-cars need to mount those.
local cert_volumes(cert_name_folder_map=default_cert_folder_map) = [{
    name: cert_name,
    emptyDir: {
        medium: "Memory",
    },
} for cert_name in std.objectFields(cert_name_folder_map) + ["tokens"]] +
    certs_and_kubeconfig.platform_cert_volume;


# Generate Volume Mount for MadDog token
local tokens_mount = {
    mountPath: "/tokens",
    name: "tokens",
};

### Refresh container for Madkub - Reloads tokens at regular intervals, required for cert rotation
# cert_name_folder_map: names of certs to initialize and their associated directory locations.
# Note: cert_name_folder_map may be a simple cert_name string, in which case it is assumed that the certs are
# stored in /certs. This is equivalent to providing the argument { [cert_name]: "/certs" }
#
### cert_name_folder_map associates named certs with their directory on disk.
local refresher_container(cert_name_folder_map) = {
    certs:: if std.type(cert_name_folder_map) == "string" then
        { [cert_name_folder_map]: "/certs" }
        else cert_name_folder_map,
    name: "sam-madkub-integration-refresher",
    args: [
        "/sam/madkub-client",
        "--madkub-endpoint",
        flowsnakeconfig.madkub_endpoint,
        "--maddog-endpoint",
        flowsnakeconfig.maddog_endpoint,
        "--maddog-server-ca",
        if flowsnakeconfig.is_minikube then "/maddog-onebox/ca/security-ca.pem" else "/etc/pki_service/ca/security-ca.pem",
        "--madkub-server-ca",
        if flowsnakeconfig.is_minikube then "/maddog-onebox/ca/ca.pem" else "/etc/pki_service/ca/cacerts.pem",
        "--token-folder",
        "/tokens",
        "--kingdom",
        kingdom,
        "--superpod",
        "None",
        "--estate",
        estate,
        "--refresher",
        "--run-init-for-refresher-mode",
        "--cert-folders",
    ] + ['%s:%s' % [name, $.certs[name]] for name in std.objectFields($.certs)] +
    (if !flowsnakeconfig.is_minikube then [
        "--funnel-endpoint",
        flowsnakeconfig.funnel_endpoint,
    ] else [
        "--log-level",
        "7",
    ]),
    image: flowsnake_images.madkub,
    resources: {
    },
    volumeMounts: cert_mounts($.certs)
      + [tokens_mount]
      +
    (if !flowsnakeconfig.is_minikube then
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
};

### Init container for madkub - initializes connection to Madkub and loads initial certs.  Required for madkub integration
# cert_name_folder_map: names of certs to initialize and their associated directory locations.
# Note: cert_name_folder_map may be a simple cert_name string, in which case it is assumed that the certs are
# stored in /certs. This is equivalent to providing the argument { [cert_name]: "/certs" }
#
local init_container(cert_name_folder_map) = {
    certs:: if std.type(cert_name_folder_map) == "string" then
        { [cert_name_folder_map]: "/certs" }
        else cert_name_folder_map,
    name: "sam-madkub-integration-init",
    args: [
        "/sam/madkub-client",
        "--madkub-endpoint",
        flowsnakeconfig.madkub_endpoint,
        "--maddog-endpoint",
        flowsnakeconfig.maddog_endpoint,
        "--maddog-server-ca",
        if flowsnakeconfig.is_minikube then "/maddog-onebox/ca/security-ca.pem" else "/etc/pki_service/ca/security-ca.pem",
        "--madkub-server-ca",
        if flowsnakeconfig.is_minikube then "/maddog-onebox/ca/ca.pem" else "/etc/pki_service/ca/cacerts.pem",
        "--token-folder",
        "/tokens",
        "--kingdom",
        kingdom,
        "--superpod",
        "None",
        "--estate",
        estate,
        "--cert-folders",
    ] + ['%s:%s' % [name, $.certs[name]] for name in std.objectFields($.certs)] +
    (if !flowsnakeconfig.is_minikube then [
        "--funnel-endpoint",
        flowsnakeconfig.funnel_endpoint,
    ] else [
        "--log-level",
        "7",
    ]),
    image: flowsnake_images.madkub,
    resources: {
    },
    volumeMounts: cert_mounts($.certs)
        + [tokens_mount]
    + (if !flowsnakeconfig.is_minikube then
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
};

## Expose common bits for external use / consumption
{
    cert_mounts:: cert_mounts,
    cert_volumes:: cert_volumes,

    refresher_container:: refresher_container,
    init_container:: init_container,
}
