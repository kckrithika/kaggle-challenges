#TODO: write a script to generate rbac config file
{
  "prd": {
    "prd-samtest": {
      "master": [
        "shared0-samtestkubeapi1-1-prd.eng.sfdc.net",
        "shared0-samtestkubeapi2-1-prd.eng.sfdc.net",
        "shared0-samtestkubeapi3-1-prd.eng.sfdc.net"
      ],
      "minion": [
        {
          "pool": "samcompute",
          "hosts": [
            "shared0-samtestcompute1-1-prd.eng.sfdc.net",
            "shared0-samtestcompute2-1-prd.eng.sfdc.net",
            "shared0-samtestcompute1-2-prd.eng.sfdc.net"
          ],
          "namespaces": [
            "*"
          ]
        }
      ]
    },
    "prd-samdev": {
      "master": [
        "shared0-samdevkubeapi1-1-prd.eng.sfdc.net",
        "shared0-samdevkubeapi2-1-prd.eng.sfdc.net",
        "shared0-samdevkubeapi3-1-prd.eng.sfdc.net"
      ],
      "minion": [
        {
          "pool": "samcompute",
          "hosts": [
            "shared0-samdevcompute1-1-prd.eng.sfdc.net",
            "shared0-samdevcompute2-1-prd.eng.sfdc.net",
            "shared0-samdevcompute1-2-prd.eng.sfdc.net"
          ],
          "namespaces": [
            "*"
          ]
        }
      ]
    },
    "prd-sam": {
      "master": [
        "shared0-samkubeapi1-1-prd.eng.sfdc.net",
        "shared0-samkubeapi2-1-prd.eng.sfdc.net",
        "shared0-samkubeapi3-1-prd.eng.sfdc.net"
      ],
      "minion": [
        {
          "pool": "samcompute",
          "host": [
            "shared0-samcompute2-1-prd.eng.sfdc.net",
            "shared0-samcompute2-1-prd.eng.sfdc.net"
          ],
          "namespaces": [
            "*"
          ]
        },
        {
          "pool": "prd-sam_report_collector",
          "host": [
            "shared0-samminionreportcollector1-1-prd.eng.sfdc.net",
            "shared0-samminionreportcollector2-1-prd.eng.sfdc.net",
            "shared0-samminionreportcollector3-1-prd.eng.sfdc.net"
          ],
          "namespaces": [
            "csc-health",
            "sam-system",
            "sam-watchdog"
          ]
        },
        {
          "pool": "prd-sam_gater",
          "host": [
            "shared0-samminiongater1-1-prd.eng.sfdc.net",
            "shared0-samminiongater1-2-prd.eng.sfdc.net",
            "shared0-samminiongater1-3-prd.eng.sfdc.net",
            "shared0-samminiongater2-1-prd.eng.sfdc.net",
            "shared0-samminiongater1-2-prd.eng.sfdc.net"
          ],
          "namespaces": [
            "gater",
            "sam-system",
            "sam-watchdog"
          ]
        }
      ]
    }
  }
}
