local configs = import "config.jsonnet";
local samimages = (import "sam/samimages.jsonnet") + { templateFilename:: std.thisFile };

{
    permsetterInitContainer():: {
        image: "" + samimages.permissionInitContainer + "",
        args: [
        "chmod -R 775 /vols/maddog-certs && chown -R 7447:7447 /vols/maddog-certs && chmod -R 775 /vols/data-volume && chown -R 7447:7447 /vols/data-volume",
        ],
        name: "permissionsetterinitcontainer",
        imagePullPolicy: "Always",
        command: [
          '/bin/sh',
          '-c',
        ],
        securityContext: {
          runAsNonRoot: false,
          runAsUser: 0,
        },
        volumeMounts: [
        {
            mountPath: "/vols/maddog-certs",
            name: "maddog-certs",
        },
        {
            mountPath: "/vols/data-volume",
            name: "data-volume",
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
