{
  "apiVersion": "networking.istio.io/v1alpha3",
  "kind": "VirtualService",
  "metadata": {
    "annotations": {
      "manifestctl.sam.data.sfdc.net/swagger": "disable",
    },
    "labels": {
      "app": "app"
    },
    "name": "na7-mist61app-prd-ingress",
    "namespace": "core-on-sam-sp2"
  },
  "spec": {
    "gateways": [
      "core-on-sam-sp2/ingressgateway"
    ],
    "hosts": [
      "*"
    ],
    "http": [
      {
        "fault": {
          "abort": {
            "httpStatus": 200,
            "percent": 100
          }
        },
        "match": [
          {
            "uri": {
              "exact": "/casam_ready_blue"
            }
          }
        ],
        "retries": {
          "attempts": 5
        },
        "route": [
          {
            "destination": {
              "host": "na7-mist61app-prd"
            }
          }
        ]
      },
      {
        "fault": {
          "abort": {
            "httpStatus": 500,
            "percent": 100
          }
        },
        "match": [
          {
            "uri": {
              "exact": "/casam_ready_green"
            }
          }
        ],
        "retries": {
          "attempts": 5
        },
        "route": [
          {
            "destination": {
              "host": "na7-mist61app-prd"
            }
          }
        ]
      },
      {
        "retries": {
          "attempts": 5
        },
        "route": [
          {
            "destination": {
              "host": "na7-mist61app-prd"
            }
          }
        ]
      }
    ]
  }
}
