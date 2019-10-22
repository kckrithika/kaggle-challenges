{
      name: "SlaDepl",
      instructions: "The following deployments are reported as bad customer deployments in Production. Debug Instructions: https://git.soma.salesforce.com/sam/sam/wiki/Debug-Failed-Deployment",
      alertThreshold: "10m",
      alertFrequency: "336h",
      watchdogFrequency: "10m",
      alertProfile: "sam",
      alertAction: "businesshours_pagerduty",
      sql: "SELECT * FROM
                        (
                          SELECT
                            ControlEstate,
                            Namespace,
                            Name,
                            JSON_EXTRACT(Payload, '$.metadata.annotations.\"smb.sam.data.sfdc.net/emailTo\"') AS email,
                            CASE WHEN JSON_EXTRACT(Payload, '$.metadata.labels.sam_app') is NULL then False
                                 ELSE True END AS IsSamApp,
                            JSON_EXTRACT(Payload, '$.spec.replicas') AS desiredReplicas,
                            JSON_EXTRACT(Payload, '$.status.availableReplicas') AS availableReplicas,
                            JSON_EXTRACT(Payload, '$.status.updatedReplicas') AS updatedReplicas,
                            (JSON_EXTRACT(Payload, '$.spec.replicas') - JSON_EXTRACT(Payload, '$.status.availableReplicas')) AS kpodsDown,
                            COALESCE(JSON_EXTRACT(Payload, '$.status.availableReplicas') /nullif(JSON_EXTRACT(Payload, '$.spec.replicas'), 0), 0) AS availability,
                            0.6 as minAvailability,
                            CONCAT('http://dashboard-',SUBSTR(ControlEstate, 1, 3),'-sam.csc-sam.prd-sam.prd.slb.sfdc.net/#!/deployment/',Namespace,'/',Name,'?namespace=',Namespace) AS Url
                            FROM k8s_resource
                            WHERE ApiKind = 'Deployment'
                        ) AS ss
                        WHERE
                           isSamApp AND
                           ( Namespace != 'sam-watchdog' AND Namespace != 'sam-system' AND Namespace != 'csc-sam' AND Namespace NOT LIKE '%slb%' AND Namespace NOT LIKE '%user%' 
                            AND Namespace NOT LIKE '%cloudatlas%'  # Follow up work item W-5415695
                           ) AND
                           (availableReplicas != desiredReplicas OR availableReplicas IS NULL) AND
                           (availability IS NULL OR availability < 0.6) AND
                           (kpodsDown IS NULL OR kpodsDown >1) AND
                           NOT ControlEstate LIKE 'prd-%' AND
                           ControlEstate != 'unknown' AND
                           desiredReplicas > 1"

                           # add snooze conditions with expiration timestamp
                           # as in https://gus.lightning.force.com/lightning/r/ADM_Work__c/a07B0000006UbTRIA0/view
                             + "
                             AND NOT
                             (controlestate like 'par-sam' AND namespace like 'casp' AND now() < STR_TO_DATE('2019-03-21', '%Y-%m-%d'))
                             AND NOT
                             (controlestate like 'cdg-sam' AND namespace like 'mc-eventing' AND now() < STR_TO_DATE('2019-03-21', '%Y-%m-%d'))
                             AND NOT
                             (controlestate like 'frf-sam' AND namespace like 'casp' AND now() < STR_TO_DATE('2019-03-21', '%Y-%m-%d'))",

    }
