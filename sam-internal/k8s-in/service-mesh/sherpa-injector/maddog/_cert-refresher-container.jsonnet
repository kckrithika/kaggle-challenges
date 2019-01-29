// This file contains a definition of a MadKub Refresher Container

local configs = import "config.jsonnet";
local samimages = (import "sam/samimages.jsonnet") + { templateFilename:: std.thisFile };

{
    # Returns a container that periodically refreshes maddog certs
    madkubRefresherContainer:: {
            image: "" + samimages.madkub + "",
            args: [
              "/sam/madkub-client",
              "--madkub-endpoint=https://$(MADKUBSERVER_SERVICE_HOST):32007",
              "--maddog-endpoint=" + configs.maddogEndpoint + "",
              "--maddog-server-ca=/maddog-certs/ca/security-ca.pem",
              "--madkub-server-ca=/maddog-certs/ca/cacerts.pem",
              "--cert-folders=cert1:/cert1/",
              "--cert-folders=cert2:/cert2/",
              "--token-folder=/tokens/",
              //"--requested-cert-type=server",
              "--ca-folder=/maddog-certs/ca",
              "--refresher",
              "--run-init-for-refresher-mode",
            ],
            name: "madkub-refresher",
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

}