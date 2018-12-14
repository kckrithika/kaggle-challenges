local cacheMain = import "cache-main.libsonnet";
local cacheSidecar = import "cache-sidecar.libsonnet";

{
  name: $.functionName,
  count: 5,
  volumes: [
    {
      name: "logvol",
      hostPath: {
        path: "/home/caas/logs",
      },
    },
    {
      name: "secretvol",
      k4aSecret: {
        secretName: "caas-secret",
      },
    },
  ],
  containers: [
    cacheMain.New($.env),
    cacheSidecar.New($.env),
  ],
}
