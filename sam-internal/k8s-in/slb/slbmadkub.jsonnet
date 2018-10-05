{
    dirSuffix:: "",
    certDirs:: [],  // list of certificate mountpoints to create
    local configs = import "config.jsonnet",
    local samimages = (import "sam/samimages.jsonnet") + { templateFilename:: std.thisFile },
    local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: $.dirSuffix },
    local slbimages = (import "slbimages.jsonnet") + { dirSuffix:: $.dirSuffix },
    local slbflights = (import "slbflights.jsonnet") + { dirSuffix:: $.dirSuffix },
    // Eventually I'd like there to be a /cert1 for server, /cert2 for nginx client, and /cert3 for slb-internal
    // A parameter should pass an array of which cert classes it needs and based on that compute the volumes, volumeMounts, annotations, and maddog parameters

    local madkubContainerArgsNew = [
        "/sam/madkub-client",
        "--madkub-endpoint=https://$(MADKUBSERVER_SERVICE_HOST):32007",
        "--maddog-endpoint=" + configs.maddogEndpoint + "",
        "--maddog-server-ca=/maddog-certs/ca/security-ca.pem",
        "--madkub-server-ca=/maddog-certs/ca/cacerts.pem",
     ] + madkubSlbCertFolders + [
        "--token-folder=/tokens/",
        "--requested-cert-type=client",
        "--ca-folder=/maddog-certs/ca",
    ],

    local certDirLookup = {
        cert1: {  // server certificate
            mount: {
                mountPath: "/cert1",
                name: "cert1",
            },
            volume: {
                emptyDir: {
                    medium: "Memory",
                },
                name: "cert1",
            },
            annotation: {
                name: "cert1",
                "cert-type": "server",
                kingdom: if slbflights.roleBasedSecrets then configs.kingdom else "prd",
                role: slbconfigs.samrole,
                san: [
                    "*.sam-system." + configs.estate + "." + configs.kingdom + ".slb.sfdc.net",
                    "*.slb.sfdc.net",
                    "*.soma.salesforce.com",
                    "*.data.sfdc.net",
                    "*.kms.slb.sfdc.net",
                    "*.moe." + configs.estate + "." + configs.kingdom + ".slb.sfdc.net",
                ] + if configs.estate == "prd-sam" then [
                    "*.retail-rsui." + configs.estate + "." + configs.kingdom + ".slb.sfdc.net",
                ] else [],
            },
        },
        cert2: {  // client certificate
            mount: {
                mountPath: "/cert2",
                name: "cert2",
            },
            volume: {
                emptyDir: {
                    medium: "Memory",
                },
                name: "cert2",
            },
            annotation: {
                name: "cert2",
                "cert-type": "client",
                kingdom: if slbflights.roleBasedSecrets then configs.kingdom else "prd",
                role: slbconfigs.samrole,
            },
        },
        cert3: {  // slb internal certificate for SS
            mount: {
                mountPath: "/cert3",
                name: "cert3",
            },
            volume: {
                emptyDir: {
                    medium: "Memory",
                },
                name: "cert3",
            },
            annotation: {
                name: "cert3",
                "cert-type": "client",
                kingdom: configs.kingdom,
                role: "slb.internal",
            },
        },
    },

    local madkubSlbCertFolders = [
      '--cert-folders=%s:/%s/' % [dir, dir]
        for dir in $.certDirs
    ],

    madkubSlbCertVolumeMounts():: [
        certDirLookup[dir].mount
                for dir in $.certDirs
    ],
    madkubSlbCertVolumes():: [
        certDirLookup[dir].volume
                for dir in $.certDirs
    ],

    madkubSlbCertsAnnotation():: {
        certreqs: [
                certDirLookup[dir].annotation
                        for dir in $.certDirs
        ],
    },

    local madkubSlbMadkubVolumeMounts = [
        {
            mountPath: "/maddog-certs/",
            name: "maddog-certs",
        },
        {
            mountPath: "/tokens",
            name: "tokens",
        },
    ],

    madkubSlbMadkubVolumes():: [
        {
            emptyDir: {
                medium: "Memory",
            },
            name: "tokens",
        },
    ],

    madkubInitContainer: {
        image: "" + samimages.madkub + "",
        args: madkubContainerArgsNew,
        name: "madkub-init",
        imagePullPolicy: "IfNotPresent",
        volumeMounts: $.madkubSlbCertVolumeMounts() + madkubSlbMadkubVolumeMounts,
        env: [
            {
                name: "MADKUB_NODENAME",
                valueFrom:
                    {
                        fieldRef: { fieldPath: "spec.nodeName", apiVersion: "v1" },
                    },
            },
            {
                name: "MADKUB_NAME",
                valueFrom:
                    {
                        fieldRef: { fieldPath: "metadata.name", apiVersion: "v1" },
                    },
            },
            {
                name: "MADKUB_NAMESPACE",
                valueFrom:
                    {
                        fieldRef: { fieldPath: "metadata.namespace", apiVersion: "v1" },
                    },
            },
        ],
    },

    madkubRefreshContainer: $.madkubInitContainer {
        args+: [
            "--refresher",
            "--run-init-for-refresher-mode",
        ],
        name: "madkub-refresher",
        resources: {},
    },

    # image_functions needs to know the filename of the template we are processing
    # Each template must set this at time of importing this file, for example:
    #
    # "local someteamimages = (import "someteamimages.jsonnet")  + { templateFilename:: std.thisFile };"
    #
    # Then we pass this again into image_functions at time of import.
    templateFilename:: error "templateFilename must be passed at time of import",
    local imageFunc = (import "image_functions.libsonnet") + { templateFilename:: $.templateFilename },
}
