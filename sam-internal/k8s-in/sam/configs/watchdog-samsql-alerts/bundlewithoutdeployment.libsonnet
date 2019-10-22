{
    name: "BundleWithoutDeployment",
    instructions: "This alert is for Bundle CRDs that do not have a corresponding deployment",
    alertThreshold: "20m",
    alertFrequency: "336h",
    watchdogFrequency: "5m",
    alertProfile: "sam",
    alertAction: "businesshours_pagerduty",
    sql: "
        SELECT
            bundle.controlEstate,
            bundle.namespace,
            bundle.name,
            bundleCreationTimestamp,
            bundle.bundleDeploymentName,
            bundleKind,
            bundleState,
            overallStatus,
            bundle.UID
        FROM
            (
                SELECT
                    controlEstate,
                    name,
                    namespace,
                    Payload->>'$.status.state' as bundleState,
                    Payload->>'$.status' as overallStatus,
                    Payload->>'$.metadata.creationTimestamp' as bundleCreationTimestamp,
                    Payload->>'$.spec.K8sResourceList[*].kind' as bundleKind,
                    Payload->>'$.spec.K8sResourceList[*].metadata.name' as bundleDeploymentName,
                    Payload->>'$.metadata.uid' as UID
                FROM k8s_resource
                WHERE ApiKind = 'Bundle'
                AND Payload->>'$.spec.K8sResourceList[*].kind' like '%Deployment%'
                AND controlEstate NOT LIKE 'prd-sam%'
            ) bundle
            
        LEFT JOIN
            
            (
                SELECT
                    controlEstate,
                    name,
                    namespace,
                    Payload->>'$.metadata.ownerReferences[0].uid' as ownerRef
                FROM k8s_resource
                WHERE ApiKind = 'Deployment'
                AND namespace NOT LIKE '%sam-system%'
            ) deployment
            
        ON bundle.controlEstate = deployment.controlEstate
        AND bundle.namespace = deployment.namespace
        AND bundle.UID = deployment.ownerRef
            
        WHERE deployment.ownerRef IS NULL AND deployment.name IS NULL AND deployment.namespace IS NULL
              "
              # add snooze conditions with expiration time
              + "
              AND NOT
              (bundle.controlEstate like 'frf-sam' AND now() < STR_TO_DATE('2019-01-21', '%Y-%m-%d'))"
}