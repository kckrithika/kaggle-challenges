{
            name: "SamControl",
            instructions: "The following SAM control stack components dont have even 1 healhty pod",
            alertThreshold: "20m",
            alertFrequency: "336h",
            watchdogFrequency: "5m",
            alertProfile: "sam",
            alertAction: "businesshours_pagerduty",
            sql: "SELECT * FROM
                  (
                    SELECT
                      ControlEstate,
                      Namespace,
                      Name,
                      JSON_EXTRACT(Payload, '$.metadata.labels.\"sam.data.sfdc.net/owner\"') AS ownerlabel,
                      JSON_EXTRACT(Payload, '$.spec.replicas') AS desiredReplicas,
                      JSON_EXTRACT(Payload, '$.status.availableReplicas') AS availableReplicas,
                      JSON_EXTRACT(Payload, '$.status.updatedReplicas') AS updatedReplicas,
                      (JSON_EXTRACT(Payload, '$.spec.replicas') - JSON_EXTRACT(Payload, '$.status.availableReplicas')) AS kpodsDown,
                      COALESCE(JSON_EXTRACT(Payload, '$.status.availableReplicas') /nullif(JSON_EXTRACT(Payload, '$.spec.replicas'), 0), 0) AS availability,
                      CONCAT('http://dashboard-',SUBSTR(ControlEstate, 1, 3),'-sam.csc-sam.prd-sam.prd.slb.sfdc.net/#!/deployment/',Namespace,'/',Name,'?namespace=',Namespace) AS Url
                      FROM k8s_resource
                      WHERE ApiKind = 'Deployment'
                  ) AS ss
                  WHERE
                     Namespace = 'sam-system' AND ownerlabel = 'sam' AND
                     (availableReplicas < 1 OR availableReplicas IS NULL) AND
                     ControlEstate NOT LIKE '%sdc%' AND
                     ControlEstate NOT LIKE '%storage%' AND
                     ControlEstate NOT LIKE '%sdn%' AND
                     ControlEstate NOT LIKE '%slb%' AND
                     ControlEstate != 'prd-samtest' AND
                     ControlEstate != 'prd-samdev' AND
                     desiredReplicas != 0",
    }

