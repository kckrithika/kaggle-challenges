// This file contains a definition of an Init Container that inits MadDog certificates

local configs = import "config.jsonnet";
local samimages = (import "sam/samimages.jsonnet") + { templateFilename:: std.thisFile };

{
    # Returns a container that inits MadDog certificates
    madkubInitContainer:: {
            image: "" + samimages.madkub + "",
            args: [
              "/sam/madkub-client",
              "--madkub-endpoint=https://10.254.208.254:32007",  // Check madkubserver-service.jsonnet for why IP
              "--maddog-endpoint=" + configs.maddogEndpoint + "",
              "--maddog-server-ca=/maddog-certs/ca/security-ca.pem",
              "--madkub-server-ca=/maddog-certs/ca/cacerts.pem",
              '--cert-folders=cert1:/cert1/', // Server certs
              '--cert-folders=cert2:/cert2/', // Client certs
              "--token-folder=/tokens/",
              "--ca-folder=/maddog-certs/ca",
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
}