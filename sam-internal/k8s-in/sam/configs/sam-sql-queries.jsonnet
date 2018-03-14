# To run this locally before merge, follow instructions here: https://git.soma.salesforce.com/sam/sam/tree/master/pkg/sam-sql-reporter
{
  queries: [
    {
      name: "Kube-Resource-Kafka-Pipeline-Latencies-ByControlEstate",
      sql: "SELECT min(diff_seconds), avg(diff_seconds), max(diff_seconds), ControlEstate 
FROM ( SELECT (ConsumeTime - ProduceTime) / 1000000000 AS diff_seconds, ControlEstate FROM k8s_resource ) AS ss
GROUP BY ControlEstate",
    },
    {
      name: "Kube-Resource-Kafka-Pipeline-Latencies-ByHour",
      sql: "SELECT Count(*) as Count, avg(diff_seconds), std(diff_seconds), min(diff_seconds), max(diff_seconds), FROM_UNIXTIME(ProduceTime / 1000000000, \"%y-%m-%d %k\") as DayHour
FROM ( SELECT (ConsumeTime - ProduceTime) / 1000000000 AS diff_seconds, ProduceTime FROM k8s_resource ) AS ss
GROUP BY DayHour;",
    },
    {
      name: "Host-Os-Versions-Aggregate",
      sql: "SELECT kernelVersion, COUNT(*) FROM nodeDetailView GROUP BY kernelVersion ORDER BY kernelVersion DESC",
    },
    {
      name: "Host-Os-Versions",
      sql: "SELECT Name, kernelVersion FROM nodeDetailView ORDER BY kernelVersion DESC",
    },
    {

      name: "Hosts-All",
      sql: "SELECT * FROM nodeDetailView",
    },
    {
      name: "Hosts-Not-Ready-Sam",
     sql: "SELECT * FROM nodeDetailView WHERE Ready != 'True' AND NOT Name like '%minionceph%'",
    },
    {
      name: "Hosts-Not-Ready-Ceph",
     sql: "SELECT * FROM nodeDetailView WHERE Ready != 'True' AND Name like '%minionceph%'",
    },
    {
      name: "Hosts-Docker-Version",
      sql: "SELECT ControlEstate, Name, containerRuntimeVersion FROM nodeDetailView ORDER BY containerRuntimeVersion",
    },
    {
      name: "Hosts-Kube-Version",
      sql: "SELECT Name, kubeletVersion, Ready FROM nodeDetailView ORDER BY kubeletVersion",
    },
    {
      name: "Hosts-Kube-Version-Aggregate",
      sql: "SELECT Kingdom, kubeletVersion, COUNT(*) FROM nodeDetailView GROUP BY Kingdom, kubeletVersion ORDER BY kubeletVersion",
    },
    {
      name: "Resource-Types-By-Kingdom",
      sql: "SELECT ControlEstate, ApiKind, Count(*) FROM ( SELECT ControlEstate, ApiKind, IsTombstone FROM k8s_resource where IsTombstone <> 1) AS ss GROUP BY ControlEstate, ApiKind ORDER BY ControlEstate",
    },
    {
      name: "Bad-Customer-Deployments-Production",
      sql: "SELECT * FROM
(
  SELECT
    ControlEstate,
    Namespace, 
    Name,
    JSON_EXTRACT(Payload, '$.metadata.annotations.\"smb.sam.data.sfdc.net/emailTo\"') AS email,
    JSON_EXTRACT(Payload, '$.spec.replicas') AS desiredReplicas,
    JSON_EXTRACT(Payload, '$.status.availableReplicas') AS availableReplicas, 
    JSON_EXTRACT(Payload, '$.status.replicas') AS replicas,
    JSON_EXTRACT(Payload, '$.status.readyReplicas') AS readyReplicas,
    JSON_EXTRACT(Payload, '$.status.updatedReplicas') AS updatedReplicas,
    CONCAT('http://dashboard-',SUBSTR(ControlEstate, 1, 3),'-sam.csc-sam.prd-sam.prd.slb.sfdc.net/#!/deployment/',Namespace,'/',Name,'?namespace=',Namespace) AS Url
  FROM k8s_resource
  WHERE ApiKind = 'Deployment'
) AS ss
WHERE
  ( Namespace != 'sam-watchdog' AND Namespace != 'sam-system' AND Namespace != 'csc-sam') AND
  (availableReplicas != desiredReplicas OR availableReplicas IS NULL) AND
  NOT ControlEstate LIKE 'prd-%' AND
  desiredReplicas != 0",
    },
    {
      name: "Bad-Pods-By-Host-Production",
      sql: "select * from (
select
        NodeName,
        NodeUrl,
        SUM(PendingCount) AS PendingCount,
        SUM(FailedCount) AS FailedCount,
        SUM(SucceededCount) AS SucceededCount,
        SUM(OtherCount) AS OtherCount,
        SUM(RunningCount) AS RunningCount,
        GROUP_CONCAT(CustomerPodWithIssue SEPARATOR '; ') AS CustomerPodWithIssue,
        GROUP_CONCAT(SystemPodWithIssue SEPARATOR '; ') AS SystemPodWithIssue
from (
        select
                NodeName,
                CASE WHEN Phase = 'Pending' THEN 1 ELSE 0 END AS PendingCount,
                CASE WHEN Phase = 'Failed' THEN 1 ELSE 0 END AS FailedCount,
                CASE WHEN Phase = 'Succeeded' THEN 1 ELSE 0 END AS SucceededCount,
                CASE WHEN Phase != 'Running' AND Phase != 'Pending' AND Phase != 'Failed' AND Phase != 'Succeeded' THEN 1 ELSE 0 END AS OtherCount,
                CASE WHEN Phase = 'Running' THEN 1 ELSE 0 END AS RunningCount,
                CASE WHEN Phase != 'Running' AND (Namespace = 'sam-system' OR Namespace = 'sam-watchdog' OR Namespace = 'csc-sam') THEN Name ELSE NULL END AS SystemPodWithIssue,
                CASE WHEN Phase != 'Running' AND (Namespace != 'sam-system' AND Namespace != 'sam-watchdog' AND Namespace != 'csc-sam') THEN Name ELSE NULL END AS CustomerPodWithIssue,
                NodeUrl
        from
                podDetailView
        where
                Kingdom != 'prd'
                AND NodeName is not NULL
                AND NOT (NodeName like '%samminionceph%')
) as ss
group by NodeName, NodeUrl
) as ss2
where (PendingCount+FailedCount+SucceededCount+OtherCount)>0
order by PendingCount+FailedCount+SucceededCount+OtherCount desc",
    },
    {
      name: "Bad-Customer-Pods",
      sql: "select
        Kingdom, Namespace, Name AS PodName, Phase, NodeName, PodUrl, NodeUrl
from
        podDetailView
where
        Kingdom != 'prd'
        and not (NodeName like '%samminionceph%')
        and (Namespace != 'sam-system' AND Namespace != 'sam-watchdog' AND Namespace != 'csc-sam')
        and Phase != 'Running'",
    },
  ],
}
