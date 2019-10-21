{
                name: "SqlSamAppWithoutBundle",
                instructions: "The following alert is for SamApp CRDs that dont have corresponding Bundle CRDs",
                alertThreshold: "20m",
                alertFrequency: "336h",
                watchdogFrequency: "5m",
                alertProfile: "sam",
                alertAction: "businesshours_pagerduty",
                sql: "SELECT
                        samApp.controlEstate,
                        samApp.name,
                        samApp.namespace,
                        samAppCreationTimestamp,
                        bundleCreationTimestamp,
                        samAppNumResourceLinks,
                        bundleState,
                        bundleStatus
                      FROM
                      (
                          SELECT
                            controlEstate,
                            name,
                            namespace,
                            json_length(Payload->'$.status.resourceLinks') as samAppNumResourceLinks,
                            Payload->>'$.metadata.creationTimestamp' as samAppCreationTimestamp
                          FROM
                            k8s_resource
                          WHERE
                            ApiKind = 'SamApp'
                            AND Payload->>'$.metadata.labels.deployed_by' IS NULL
                            AND controlEstate NOT LIKE 'prd-sam%'
                      ) samApp
                      LEFT JOIN
                      (
                          SELECT
                            controlEstate,
                            name,
                            namespace,
                            Payload->>'$.status.state' as bundleState,
                            Payload->>'$.status' as bundleStatus,
                            Payload->>'$.metadata.creationTimestamp' as bundleCreationTimestamp
                          FROM k8s_resource
                          WHERE ApiKind = 'Bundle'
                      ) bundle
                      ON samApp.controlEstate = bundle.controlEstate and samApp.name = bundle.name and samApp.namespace = bundle.namespace
                      WHERE bundle.controlEstate is NULL AND bundle.name is NUll AND bundle.namespace is NULL",
        }

