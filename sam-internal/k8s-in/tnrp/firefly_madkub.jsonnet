local configs = import "config.jsonnet";
local samimages = (import "sam/samimages.jsonnet") + { templateFilename:: std.thisFile };

{
    madkubInitContainer():: {
        image: "" + samimages.madkub + "",
        args: [
        "/sam/madkub-client",
        "--madkub-endpoint",
        "https://10.254.208.254:32007",
        "--maddog-endpoint",
        "" + configs.maddogEndpoint + "",
        "--maddog-server-ca",
        "/maddog-certs/ca/security-ca.pem",
        "--madkub-server-ca",
        "/maddog-certs/ca/cacerts.pem",
        "--cert-folders",
        "certs:/certs/",
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
              mountPath: "/certs",
              name: "certs",
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

    madkubRefreshContainer():: {
        args: [
                "/sam/madkub-client",
                "--madkub-endpoint",
                "https://10.254.208.254:32007",
                "--maddog-endpoint",
                configs.maddogEndpoint,
                "--maddog-server-ca",
                "/maddog-certs/ca/security-ca.pem",
                "--madkub-server-ca",
                "/maddog-certs/ca/cacerts.pem",
                "--cert-folders",
                "certs:/certs/",
                "--token-folder",
                "/tokens/",
                "--requested-cert-type",
                "client",
                "--refresher",
                "--run-init-for-refresher-mode",
                "--ca-folder",
                "/maddog-certs/ca",
            ],
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
          image: samimages.madkub,
          name: "madkub-refresher",
          resources: {},
          volumeMounts: [
              {
                  mountPath: "/certs",
                  name: "certs",
              },
              {
                  mountPath: "/tokens",
                  name: "tokens",
              },
              {
                  mountPath: "/maddog-certs/",
                  name: "maddog-certs",
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
