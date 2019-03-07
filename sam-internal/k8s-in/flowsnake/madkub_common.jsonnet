local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local flowsnake_config = import "flowsnake_config.jsonnet";
local certs_and_kubeconfig = import "certs_and_kubeconfig.jsonnet";
local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");

# Helper function used to process the cert_names argument used by multiple functions in this file.
#
# A Cert Name refers to the name assigned to a cert in a MadDog PKI certreqs annoation. It is the name used
# to refer to the cert by the MadDog components. It is distinct from the role in the certreqs, which we sometimes
# call appname, that shows in the OU field of the issued cert, and it is distinct from the directory in which the
# cert is stored, as well as from the name of the volume used to access that directory in Kubernetes.
#
# This function takes cert name(s) as input and generates a map containing the other fields.
# cert_names may be:
# 1) a single String, containing a cert_name
# 2) an array of Strings, containing one or more cert_names
# 3) an array of Objects, each containing a name field with a cert_name, and optionally fields dir, volume, and type
#
# The output of this function is an array of Objects, containing fields:
#   name (from input)
#   dir, where on disk the certs will be stored
#   volume, the name of the Kubernetes volume cnotaining the storage location
#   type, the type of the certificate (e.g. client or server)
#   cert_path, key_path, ca_path: full paths to these artifacts, beginning with dir
# All values not provided are computed / set to default
#
local make_cert_config(cert_names) =
    if std.type(cert_names) == "string" then
        make_cert_config([cert_names])
    else
        assert std.assertEqual(std.type(cert_names), "array");
        [
            # Upgrade c from simple string to object with a name field
            local c_obj = if std.type(c) == "string"
                then { name: c }
                else
                    assert std.assertEqual(std.type(c), "object");  //if not providing simple strings, must provide objects
                    assert std.objectHas(c, "name");  //must provide cert_name for each entry
                    c;
            local cert_name = c_obj.name;
            {
                name: cert_name,
                dir: if std.objectHas(c_obj, "dir")
                    then
                        # Strip trailing slash of provided directory for easier appending later on
                        std.substr(c_obj.dir, 0, std.length(c_obj.dir) - if std.endsWith(c_obj.dir, "/") then 1 else 0)
                    else
                         // Use /<cert_name> as default directory when multiple certs are present, else /certs
                         if std.length(cert_names) == 1 then "/certs" else "/" + c_obj.name,
                volume: if std.objectHas(c_obj, "volume")
                    then c_obj.volume
                    else
                        // Use <cert_name> as default volume name when multiple certs are present, else datacerts
                        if std.length(cert_names) == 1 then "datacerts" else c_obj.name,
                // Client certs by default
                type: if std.objectHas(c_obj, "type") then c_obj.type else "client",
                cert_path: std.join("/", [self.dir, self.type, "certificates", self.type + ".pem"]),
                key_path: std.join("/", [self.dir, self.type, "keys", self.type + "-key.pem"]),
                ca_path: std.join("/", [self.dir, "ca.pem"]),
            }
        for c in cert_names
];

# Find a cert object from the array by its name
local cert_by_name(certs, name) =
    local filtered = std.filter(function(c) c.name == name, certs);
    assert std.length(filtered) == 1;
    filtered[0];


### Functions for generating Volumes and VolumeMounts

# Generate Volume Mounts for all MadDog certificates
#
# The volumeMounts do NOT include the PKI host-cert directories because, even though (for now, at least)
# the MadKub init/refresh side-cars need to mount those, the primary MadKub-cert-using container does not
# need to mount them.
#
# cert_names parameter: see make_cert_config() comments for documentation
local cert_mounts(cert_names) =
    [
        {
            mountPath: c_obj.dir,
            name: c_obj.volume,
        }
    for c_obj in make_cert_config(cert_names)
];


# Generate Volumes for all MadDog certificates, including the tokens volume.
#
# The volumes also include the PKI host-cert directories because (for now, at least)
# the MadKub init/refresh side-cars need to mount those.
#
# cert_names parameter: see make_cert_config() comments for documentation
#
local cert_volumes(cert_names) =
    [
        {
            emptyDir: {
                medium: "Memory",
            },
            name: c_obj.volume,
        }
    for c_obj in make_cert_config(cert_names) + [{ volume: "tokens" }]
    ]
    + certs_and_kubeconfig.platform_cert_volume;


# Generate Volume Mount for MadDog token
local tokens_mount = {
    mountPath: "/tokens",
    name: "tokens",
};


### Functions for generating MadDog side-car contains

# Refresh container for Madkub - Reloads tokens at regular intervals, required for cert rotation
#
# cert_names parameter: see make_cert_config() comments for documentation
#
local refresher_container(cert_names) = {
    local certs = make_cert_config(cert_names),
    name: "sam-madkub-integration-refresher",
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
        "--refresher",
        "--run-init-for-refresher-mode",
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
    },
    volumeMounts: cert_mounts(certs)
      + [tokens_mount]
      +
    (if !flowsnake_config.is_minikube then
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

# Init container for madkub - initializes connection to Madkub and loads initial certs.  Required for madkub integration
#
# cert_names parameter: see make_cert_config() comments for documentation
#
local init_container(cert_names) = {
    local certs = make_cert_config(cert_names),
    name: "sam-madkub-integration-init",
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
    },
    volumeMounts: cert_mounts(certs)
        + [tokens_mount]
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
};

### Expose functions for use in other templates
{
    make_cert_config:: make_cert_config,
    cert_by_name:: cert_by_name,

    cert_mounts:: cert_mounts,
    cert_volumes:: cert_volumes,

    refresher_container:: refresher_container,
    init_container:: init_container,
}
