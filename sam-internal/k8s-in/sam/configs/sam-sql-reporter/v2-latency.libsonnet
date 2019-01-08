{
      name: "V2-Latency",
      sql: "select
              samApp.controlEstate,
              samApp.name,
              samApp.namespace,
              samAppCreationTimestamp,
              bundle.bundleCreationTimestamp,
               TIMEDIFF(STR_TO_DATE(bundle.bundleCreationTimestamp,'%Y-%m-%dT%H:%i:%s'),STR_TO_DATE(samAppCreationTimestamp,'%Y-%m-%dT%H:%i:%s')) as samAppControllerLatency,
              deployment.deploymentCreationTimestamp,
              TIMEDIFF(STR_TO_DATE(deployment.deploymentCreationTimestamp,'%Y-%m-%dT%H:%i:%s'),STR_TO_DATE(bundle.bundleCreationTimestamp,'%Y-%m-%dT%H:%i:%s')) as bundleControllerLatency,
              samAppNumResourceLinks,
              bundle.bundleState
            from
              (
              select
                controlEstate,
                name,
                namespace,
                json_length(Payload->'$.status.resourceLinks') as samAppNumResourceLinks,
                Payload->>'$.metadata.creationTimestamp' as samAppCreationTimestamp,
                Payload->>'$.status' as samappStatus
              from k8s_resource
              where ApiKind = 'SamApp'
              and Payload->>'$.metadata.labels.deployed_by' is not null
              ) samApp,
              (
              select
                controlEstate,
                name,
                namespace,
                Payload->>'$.status.state' as bundleState,
                Payload->>'$.status' as bundleStatus,
                Payload->>'$.metadata.creationTimestamp' as bundleCreationTimestamp
              from k8s_resource
              where ApiKind = 'Bundle'
              ) bundle,
              (
              select
                controlEstate,
                name,
                namespace,
                Payload->>'$.status.state' as bundleState,
                Payload->>'$.status' as bundleStatus,
                Payload->>'$.metadata.creationTimestamp' as deploymentCreationTimestamp
              from k8s_resource
              where ApiKind = 'Deployment'
              ) deployment

            where
              samApp.controlEstate = bundle.controlEstate
              and deployment.controlEstate = bundle.ControlEstate
              and samApp.name = bundle.name
              and bundle.name=deployment.name
              and samApp.namespace = bundle.namespace
              and bundle.namespace = deployment.namespace
            having
              samAppControllerLatency BETWEEN 0 and 360000
              and bundleControllerLatency BETWEEN 0 and 360000",
    }