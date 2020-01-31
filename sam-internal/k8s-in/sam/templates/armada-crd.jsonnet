local configs = import "config.jsonnet";
local utils = import "util_functions.jsonnet";

if configs.estate == "prd-sam" then {
   apiVersion: "apiextensions.k8s.io/v1beta1",
   kind: "CustomResourceDefinition",
    metadata: {
      name: "armadaapplications.armadacrd.salesforce.com",
      annotations: {
        "manifestctl.sam.data.sfdc.net/swagger": "disable",
      },
      labels: {} + configs.ownerLabel.sam + configs.pcnEnableLabel,
    },
    spec: {
        group: "armadacrd.salesforce.com",
        names: {
          kind: "ArmadaApplication",
          listKind: "ArmadaApplicationList",
          plural: "armadaapplications",
          singular: "armadaapplication",
        },
        scope: "Namespaced",
        validation: {
          openAPIV3Schema: {
            description: "ArmadaApp describes a Armada Application",
            properties: {
              apiVersion: {
                description: "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources",
                type: "string",
              },
              kind: {
                description: "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds",
                type: "string",
              },
              metadata: {
                type: "object",
              },
              spec: {
                description: "http://releases.k8s.io/HEAD/docs/devel/api-conventions.md#spec-and-status",
                properties: {
                  appType: {
                    type: "string",
                  },
                  env: {
                    items: {
                      description: "EnvVar defines an environment variable",
                      properties: {
                        name: {
                          type: "string",
                        },
                        value: {
                          type: "string",
                        },
                      },
                      required: [
                        "name",
                        "value",
                      ],
                      type: "object",
                    },
                    type: "array",
                  },
                  name: {
                    type: "string",
                  },
                  org: {
                    type: "string",
                  },
                  replicas: {
                    minimum: 1,
                    type: "integer",
                  },
                  repoName: {
                    type: "string",
                  },
                  resourceLimits: {
                    properties: {
                      cpuLimit: {
                        type: "string",
                      },
                      cpuRequest: {
                        type: "string",
                      },
                      memoryLimit: {
                        type: "string",
                      },
                      memoryRequest: {
                        type: "string",
                      },
                    },
                    required: [
                      "cpuLimit",
                      "cpuRequest",
                      "memoryLimit",
                      "memoryRequest",
                    ],
                    type: "object",
                  },
                  teamEmail: {
                    type: "string",
                  },
                  teamName: {
                    type: "string",
                  },
                  teamSlackChannel: {
                    type: "string",
                  },
                },
                required: [
                  "appType",
                  "name",
                  "org",
                  "repoName",
                  "resourceLimits",
                  "teamEmail",
                  "teamName",
                  "teamSlackChannel",
                ],
                type: "object",
              },
              status: {
                description: "ArmadaAppStatus is the status of a ArmadaApp resource",
                properties: {
                  ciURL: {
                    type: "string",
                  },
                  conditions: {
                    type: "object",
                  },
                  dockerImage: {
                    type: "string",
                  },
                  githubRepo: {
                    type: "string",
                  },
                  gusTicketID: {
                    type: "string",
                  },
                  spinnakerPipelineURL: {
                    type: "string",
                  },
                },
                required: [
                  "ciURL",
                  "conditions",
                  "dockerImage",
                  "githubRepo",
                  "gusTicketID",
                  "spinnakerPipelineURL",
                ],
                type: "object",
              },
            },
            required: [
              "spec",
            ],
            type: "object",
          },
        },
        version: "v1alpha1",
        versions: [
          {
            name: "v1alpha1",
            served: true,
            storage: true,
          },
        ],
      },
      status: {
        acceptedNames: {
          kind: "",
          plural: "",
        },
        conditions: [

        ],
        storedVersions: [

        ],
      },
} else "SKIP"
