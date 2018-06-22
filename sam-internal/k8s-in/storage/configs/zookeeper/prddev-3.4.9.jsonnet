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

{
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
    "containers": [
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
        "command": [
          "sh",
          "-c",
          "/opt/zookeeper/bin/zkGenConfig.sh && /opt/zookeeper/bin/zkServer.sh start-foreground"
        ],
        "args": [],
        "readinessProbe": {
          "exec": {
            "command": [
              "/opt/zookeeper/bin/zkOk.sh"
            ]
          },
          "initialDelaySeconds": 15,
          "timeoutSeconds": 5
        },
        "livenessProbe": {
          "exec": {
            "command": [
              "/opt/zookeeper/bin/zkOk.sh"
            ]
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
      },
      {
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
        "imagePullPolicy": "Always"
      }
    ],
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
