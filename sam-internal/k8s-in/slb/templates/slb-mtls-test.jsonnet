local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = import "slbimages.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local samimages = import "sam/samimages.jsonnet";

if configs.kingdom == "prd" && configs.estate == "prd-sam" then {
     apiVersion: "extensions/v1beta1",
     kind: "Deployment",
     metadata: {
      name: "slb-mtls-test",
      namespace: "sam-system",
      labels: {
        name: "slb-mtls-test",
      },
     },
     spec: {
      replicas: 1,
      template: {
       metadata: {
        labels: {
          name: "slb-mtls-test",
        },
        namespace: "sam-system",
        annotations: {
         "madkub.sam.sfdc.net/allcerts": "{
            \"certreqs\":[
                {
                    \"name\": \"cert1\",
                    \"cert-type\":\"server\",
                    \"kingdom\":\"prd\",
                    \"role\": \"sam_compute\",
                    \"san\":[
                        \"*.sam-system." + configs.estate + ".prd.slb.sfdc.net\"
                    ]
                },
                {
                    \"name\": \"cert2\",
                    \"cert-type\":\"client\",
                    \"kingdom\":\"prd\",
                    \"role\": \"sam_compute\"
                }
            ]
         }",
        },
        creationTimestamp: null,
       },
       spec: {
        containers: [
         {
          args: [
           "/sam/madkub-client",
           "--madkub-endpoint",
           "https://$(MADKUBSERVER_SERVICE_HOST):32007",
           "--maddog-endpoint",
           "https://all.pkicontroller.pki.blank.prd.prod.non-estates.sfdcsd.net:8443",
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
           "--refresher",
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
            mountPath: "/cert1",
            name: "cert1",
           },
           {
            mountPath: "/cert2",
            name: "cert2",
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
        ],
        hostNetwork: true,
        nodeSelector: {
            pool: configs.estate,
        },
        restartPolicy: "Always",
        volumes: configs.filter_empty([
         slbconfigs.logs_volume,
         {
           name: "var-target-config-volume",
           hostPath: {
               path: slbconfigs.slbDockerDir + "/nginx/config",
            },
         },
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
         {
          emptyDir: {
           medium: "Memory",
          },
          name: "tokens",
         },
         {
          hostPath: {
           path: "/etc/pki_service",
          },
          name: "maddog-certs",
         },
         configs.sfdchosts_volume,
        ]),
       },
     },
   },
} else "SKIP"
