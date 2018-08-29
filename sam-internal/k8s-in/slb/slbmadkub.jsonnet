{
    dirSuffix:: "",
    local configs = import "config.jsonnet",
    local samimages = (import "sam/samimages.jsonnet") + { templateFilename:: std.thisFile },
    local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: $.dirSuffix },

    madkubInitContainer():: {
        image: "" + samimages.madkub + "",
        args: [
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
        name: "madkub-init",
        imagePullPolicy: "IfNotPresent",
        volumeMounts: [
            {
                mountPath: "/cert1",
                name: "cert1",
            },
            {
                mountPath: "/cert2",
                name: "cert2",
            },
            {
                mountPath: "/maddog-certs/",
                name: "maddog-certs",
            },
            {
                mountPath: "/tokens",
                name: "tokens",
            },
        ],
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
