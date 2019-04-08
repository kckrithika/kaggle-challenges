// This file contains a definition of an Init Container that fixes certificate file permissions

local configs = import "config.jsonnet";
local samimages = (import "sam/samimages.jsonnet") + { templateFilename:: std.thisFile };

{
    # Returns a container that changes certificate files permissions
    # so that they can be opened by consumers that mounted them in
    permissionSetterInitContainer:: {
        command: [
            "bash",
            "-c",
            "set -ex\nchmod 775 -R /cert1 && chown -R 7447:7447 /cert1\nchmod 775 -R /cert2 && chown -R 7447:7447 /cert2\n",
        ],
        image: samimages.permissionInitContainer,
        imagePullPolicy: "IfNotPresent",
        name: "permissionsetterinitcontainer",
        securityContext: {
            runAsNonRoot: false,
            runAsUser: 0,
        },
        volumeMounts: [
          {
            # Server certs
            mountPath: "/cert1",
            name: "cert1",
          },
          {
            # Client certs
            mountPath: "/cert2",
            name: "cert2",
          },
        ],

    },

}