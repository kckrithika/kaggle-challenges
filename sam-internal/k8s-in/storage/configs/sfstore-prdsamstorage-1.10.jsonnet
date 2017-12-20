local storageimages = import "storageimages.jsonnet";

{
	"version": "1.10",
	"persistentVolumeClaim": {
		"metadata": {
			"name": "sfstore"
		},
		"spec": {
			"Resources": {
				"Requests": {
					"storage": "750Gi"
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
						"value": "/sfs/sfslogs"
					},
					{
						"name" : "sf_zkServers",
						"value" : "sayonara1a-mnds2-1-prd.eng.sfdc.net:2181,sayonara1a-mnds2-2-prd.eng.sfdc.net:2181,sayonara1a-mnds2-3-prd.eng.sfdc.net:2181"
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
						"value": "/sfs/sfslogs"
					},
					{
						"name" : "sf_zkServers",
						"value" : "sayonara1a-mnds2-1-prd.eng.sfdc.net:2181,sayonara1a-mnds2-2-prd.eng.sfdc.net:2181,sayonara1a-mnds2-3-prd.eng.sfdc.net:2181"
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
				"args": ["-t", "ajna", "-s", "sfstore", "-i", "60"],
				"imagePullPolicy": "Always"
			}
		]
	}
}
