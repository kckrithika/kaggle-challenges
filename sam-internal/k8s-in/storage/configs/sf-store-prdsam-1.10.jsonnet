{
	"version": "1.10",
	"persistentVolumeClaim": {
		"metadata": {
			"name": "sfstore"
		},
		"spec": {
			"Resources": {
				"Requests": {
					"storage": "440Gi"
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
				"image": "ops0-artifactrepo2-0-prd.data.sfdc.net/docker-all/tnrp/storagecloud/bookie:base-0000031-8791cfb6",
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
				"image": "ops0-artifactrepo2-0-prd.data.sfdc.net/docker-all/tnrp/storagecloud/bookie:base-0000031-8791cfb6",
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
				"image": "ops0-artifactrepo2-0-prd.data.sfdc.net/docker-all/tnrp/storagecloud/sfms:latest-0000047-f46de00d",
				"command": ["/bin/bash", "/opt/sfms/bin/sfms"],
				"args": ["-t", "ajna", "-s", "sfstore", "-i", "60"],
				"imagePullPolicy": "Always"
			}
		]
	}
}