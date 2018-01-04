local storageimages = import "storageimages.jsonnet";
local storageconfig = import "storageconfig.jsonnet";
local configs = import "config.jsonnet";

{
	"version": "1.10",
	"persistentVolumeClaim": {
		"metadata": {
			"name": "sfstore"
		},
		"spec": {
			"Resources": {
				"Requests": {
					"storage": "15Gi"
				}
			},
			"accessModes": [
				"ReadWriteOnce"
			],
			"name": "ssd",
			"StorageClassName": "ssd"
		}
	},
	"podConfig": {
		"hostNetwork": true,
		"DNSPolicy": "ClusterFirstWithHostNet",
		"containers": [{
				"name": "bookie",
				"image": storageimages.sfstorebookie, 
				"ports": [{
					"name": "bookieport",
					"containerPort": 3181
				}],
				"Env": [{
						"name": "BOOKIE_LOG_DIR",
						"value": "/var/log/sfslogs"
					},
					{
						"name" : "sf_zkServers",
						"value" : storageconfig.perEstate.sfstore.zkServer[configs.estate]
					}
				],
				"command": ["/sfs/sfsbuild/bin/k8sstartup.py"],
				"args": ["bookie"],
				"imagePullPolicy": "Always"
			},
			{
				"name": "autorecovery",
				"image": storageimages.sfstorebookie, 
				"Env": [{
						"name": "BOOKIE_LOG_DIR",
						"value": "/var/log/sfslogs"
					},
					{
						"name" : "sf_zkServers",
						"value" : storageconfig.perEstate.sfstore.zkServer[configs.estate] 
					}
				],
				"command": ["/sfs/sfsbuild/bin/k8sstartup.py"],
				"args": ["autorecovery"],
				"imagePullPolicy": "Always"
			},
			{
				"name": "sfms",
				"image": storageimages.sfms,
				"command": ["/bin/bash", "/opt/sfms/bin/sfms"],
				"args": ["-t", "json", "-s", "sfstore", "-i", "180"],
				"imagePullPolicy": "Always"
			}
		]
	}
}
