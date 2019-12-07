local configs = import "config.jsonnet";

// This zero-replica deployment exists solely to ensure that the k4ainitcontainer image is correctly promoted to production.
if configs.estate == "phx-sam" then configs.deploymentBase("secrets") {

      metadata: {
          labels: {
              name: "dummy-image-promotion",
          } + configs.ownerLabel.secrets,
          name: "dummy-image-promotion",
          namespace: "sam-system",
      },
      spec+: {
        replicas: 0,
        template: {
            metadata: {
                labels: {
                    name: "dummy-image-promotion",
                } + configs.ownerLabel.secrets,
                namespace: "sam-system",
            },
            spec: {
                containers: [
                    {
                        name: "image-promotion",
                        image: imageFunc.do_override_based_on_tag({}, "sam", "hypersam", "2857-49f61d7400b7330433a29b09783ca3e7c827d973"),
                    },
                ],
            },
        },
      },

    # image_functions needs to know the filename of the template we are processing
    # Each template must set this at time of importing this file, for example:
    #
    # "local someteamimages = (import "someteamimages.jsonnet")  + { templateFilename:: std.thisFile };"
    #
    # Then we pass this again into image_functions at time of import.
    templateFilename:: std.thisFile,
    local imageFunc = (import "image_functions.libsonnet") + { templateFilename:: $.templateFilename },
} else
    "SKIP"
