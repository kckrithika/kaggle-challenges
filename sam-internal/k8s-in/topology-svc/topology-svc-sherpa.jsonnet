local configs = import "config.jsonnet";
local utils = import "util_functions.jsonnet";
local topologysvcimages = (import 'topology-svc-images.jsonnet') + { templateFilename:: std.thisFile };

{
    ## Service mesh volumes
    sherpa_volume_mounts():: [
      {
        mountPath: "/client-certs",
        name: "tls-client-cert",
      },
      {
        mountPath: "/server-certs",
        name: "tls-server-cert",
      },
    ],

    ### Service mesh container definition
    service_discovery_container(name):: {
        name: name + "-sherpa",
        image: topologysvcimages.sherpa,
        args+: [] +
            if configs.estate == "gsf-core-devmvp-sam2-sam" then ["--switchboard=switchboard.service-mesh.svc:15001"]
            else if configs.estate == "gsf-core-devmvp-sam2-samtest" then ["--switchboard=switchboard-test.service-mesh.svc.sam.core.test.us-central1.gcp.sfdc.net:15001"]
            else [],
        env: [
            {
                name: "SFDC_ENVIRONMENT",
                value: "mesh",
            },
        ],
        resources: {
            requests: {
                memory: "1Gi",
                cpu: "1",
            },
            limits: {
                memory: "1Gi",
                cpu: "1",
            },
        },
        ports: [
            {
                name: "http1-tls-in",
                containerPort: 7442,
            },
            {
                name: "sherpa-adm",
                containerPort: 15373,
            },
        ],
        livenessProbe: {
          exec: {
            command: [
                './bin/is-alive',
            ],
          },
          initialDelaySeconds: 20,
          periodSeconds: 5,
        },
        readinessProbe: {
          exec: {
            command: [
                './bin/is-ready',
            ],
          },
          initialDelaySeconds: 15,
          periodSeconds: 5,
        },
        volumeMounts: $.sherpa_volume_mounts(),
    },
}