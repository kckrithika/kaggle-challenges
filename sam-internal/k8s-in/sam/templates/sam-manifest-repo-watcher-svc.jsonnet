local configs = import "config.jsonnet";
if configs.estate == "prd-samdev" then {
    kind: "Service",
    apiVersion: "v1",
    metadata: {
        name: "sam-manifest-repo-watcher",
        namespace: "sam-system",
        labels: {
            app: "sam-manifest-repo-watcher",
        },
    },
    spec: {
              ports: [
                  {
                      name: "mrw-port",
                      port: 80,
                      protocol: "TCP",
                      targetPort: 8099,
                  },
              ],
              selector: {
                  name: "sam-manifest-repo-watcher",
              },
          }
          # The 2 test beds dont have SLB, so we need to add nodePorts
          # This is a little ugly, but here is what is going on.  In jsonnet
          # ObjA + ObjB is not a simle merge, it is more like ObjA is the base class
          # and ObjB is derived.  Here we add a second spec object, but the field
          # ports is computed from the base ports but with a tweak.
          + if (configs.estate != "prd-sam") then {
              ports: [super.ports[0] { nodePort: 32865 }],
              type: "NodePort",
          } else {},
} else "SKIP"
