{
    dirSuffix:: "",
    local configs = import "config.jsonnet",
    local samimages = (import "sam/samimages.jsonnet") + { templateFilename:: std.thisFile },
    local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: $.dirSuffix },
    local slbimages = (import "slbimages.jsonnet") + { dirSuffix:: $.dirSuffix },
    // Eventually I'd like there to be a /cert1 for server, /cert2 for nginx client, and /cert3 for slb-internal
    // A parameter should pass an array of which cert classes it needs and based on that compute the volumes, volumeMounts, annotations, and maddog parameters

    madkubRefactor20180913: (if slbimages.phaseNum <= 1 then true else false),  // For backward compatibility
    local reverseVolumeMounts = ! $.madkubRefactor20180913,

    local madkubContainerArgsOld = [
        "/sam/madkub-client",
        "--madkub-endpoint",
        "https://$(MADKUBSERVER_SERVICE_HOST):32007",
        "--maddog-endpoint",
        "" + configs.maddogEndpoint + "",
        "--maddog-server-ca",
        "/maddog-certs/ca/security-ca.pem",
        "--madkub-server-ca",
        "/maddog-certs/ca/cacerts.pem",
        "--cert-folders",
        "cert1:/cert1/",
        "--cert-folders",
        "cert2:/cert2/",
        "--token-folder",
        "/tokens/",
        "--requested-cert-type",
        "client",
        "--ca-folder",
        "/maddog-certs/ca",
    ],

    local madkubContainerArgsNew = [
        "/sam/madkub-client",
        "--madkub-endpoint=https://$(MADKUBSERVER_SERVICE_HOST):32007",
        "--maddog-endpoint=" + configs.maddogEndpoint + "",
        "--maddog-server-ca=/maddog-certs/ca/security-ca.pem",
        "--madkub-server-ca=/maddog-certs/ca/cacerts.pem",
        "--cert-folders=cert1:/cert1/",
        "--cert-folders=cert2:/cert2/",
        "--token-folder=/tokens/",
        "--requested-cert-type=client",
        "--ca-folder=/maddog-certs/ca",
    ],

    madkubSlbNginxVolumeMounts():: [
        {
            mountPath: "/cert1",
            name: "cert1",
        },
        {
            mountPath: "/cert2",
            name: "cert2",
        },
    ],
    madkubSlbNginxVolumes():: [
        {
            emptyDir: {
                medium: "Memory",
            },
            name: "cert1",
        },
        {
            emptyDir: {
                medium: "Memory",
            },
            name: "cert2",
        },
    ],

    madkubSlbMadkubVolumeMountsCompat(reverse=false):: (
        if reverse then [
            $.madkubSlbMadkubVolumeMounts[1],
            $.madkubSlbMadkubVolumeMounts[0],
        ] else $.madkubSlbMadkubVolumeMounts
    ),

    madkubSlbMadkubVolumeMounts: [
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
        args: madkubContainerArgsOld,
        name: "madkub-init",
        imagePullPolicy: "IfNotPresent",
        volumeMounts: $.madkubSlbNginxVolumeMounts() + $.madkubSlbMadkubVolumeMountsCompat(false),
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
        volumeMounts: $.madkubSlbNginxVolumeMounts() + $.madkubSlbMadkubVolumeMountsCompat(reverseVolumeMounts),
    },

    madkubCertsAnnotation():: {
        certreqs: [
            {
                name: "cert1",
                "cert-type": "server",
                kingdom: "prd",
                role: slbconfigs.samrole,
                san: [
                    "*.sam-system." + configs.estate + "." + configs.kingdom + ".slb.sfdc.net",
                    "*.slb.sfdc.net",
                    "*.soma.salesforce.com",
                    "*.data.sfdc.net",
                    "*.kms.slb.sfdc.net",
                    "*.moe." + configs.estate + "." + configs.kingdom + ".slb.sfdc.net",
                ],
            },
            {
                name: "cert2",
                "cert-type": "client",
                kingdom: "prd",
                role: slbconfigs.samrole,
            },
        ],

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
