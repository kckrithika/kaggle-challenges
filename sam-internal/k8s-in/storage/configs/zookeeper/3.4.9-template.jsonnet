local storageimages = (import "storageimages.jsonnet") + { templateFilename:: std.thisFile };
local storageconfig = import "storageconfig.jsonnet";
local storageutils = import "storageutils.jsonnet";
local configs = import "config.jsonnet";

local initContainers = [
  storageimages.log_init_container(
    storageimages.loginit,
    "zk",
    7447,
    7447,
    "sfdc"
  ),
];

// Public functions
{
  probe(isActualConfig) :: (
    if isActualConfig then [
      "/opt/zookeeper/bin/zkOk.sh"
    ] else [
      "sh",
      "-c",
      "exit 0"
    ]
  ),

  command(isActualConfig) :: (
    if isActualConfig then [
      "sh",
      "-c",
      "/opt/zookeeper/bin/zkGenConfig.sh && /opt/zookeeper/bin/zkServer.sh start-foreground",
    ] else [
      "sh",
      "-c",
      "sleep 60000"
    ]
  ),

  sfms_podspec(isActualConfig) :: (
    if isActualConfig then {
      "name": "sfms",
      "image": storageimages.sfms,
      "command": [
        "/bin/bash",
        "/opt/sfms/bin/sfms"
      ],
      "args": [
        "-j",
        "zookeeper"
      ],
      env: storageutils.sfms_environment_vars("zookeeper"),
      "imagePullPolicy": "Always"
    } else {}
  ),

  createConfig(isActualConfig):: {
    "version": "3.4.9",
    "persistentVolumeClaim": {
      "metadata": {
        "name": "zookeeper"
      },
      "spec": {
        "resources": {
          "requests": {
            "storage": "2Gi"
          }
        },
        "accessModes": [
          "ReadWriteOnce"
        ],
        "storageClassName": "ssd"
      }
    },
    "podConfig": {
      "securityContext": {
        "fsGroup": 7447
      },
      "containers": configs.filter_empty([
        {
          "name": "zookeeper",
          "imagePullPolicy": "Always",
          "image": storageimages.zookeeper,
          "ports": [
            {
              "name": "client",
              "containerPort": 2181
            },
            {
              "name": "server",
              "containerPort": 2888
            },
            {
              "name": "leader-election",
              "containerPort": 3888
            }
          ],
          "env": [
            {
              "name": "ZK_LOG_DIR",
              "value": "/var/log/zk"
            },
            {
              "name": "ZK_POD_NAME",
              "valueFrom": {
                "fieldRef": {
                  "fieldPath": "metadata.name"
                }
              }
            }
          ],
          "command": $.command(isActualConfig),
          "args": [],
          "readinessProbe": {
            "exec": {
              "command": $.probe(isActualConfig),
            },
            "initialDelaySeconds": 15,
            "timeoutSeconds": 5
          },
          "livenessProbe": {
            "exec": {
              "command": $.probe(isActualConfig),
            },
            "initialDelaySeconds": 15,
            "timeoutSeconds": 5
          },
          "volumeMounts": [
            {
              "name": "zookeeper",
              "mountPath": "/opt/zookeeper/var"
            },
            {
              "name": "container-log-vol",
              "mountPath": "/var/log"
            },
            {
              "name": "host-log-vol",
              "mountPath": "/var/log-mounted"
            }
          ]
        }, $.sfms_podspec(isActualConfig),
      ]),
      "initContainers": initContainers,
      "volumes": [
        {
          "name": "container-log-vol",
          "emptyDir": {}
        },
        {
          "name": "host-log-vol",
          "hostPath": {
            "path": "/var/log"
          }
        }
      ]
    }
  }
}
