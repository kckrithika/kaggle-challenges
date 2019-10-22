{
        name: "SlaNode",
        instructions: "The following minion pools have multiple nodes down in Production requiring immediate attention according to our SLA. Debug Instructions: https://git.soma.salesforce.com/sam/sam/wiki/Repair-Failed-SAM-Host",
        alertThreshold: "20m",
        alertFrequency: "336h",
        watchdogFrequency: "5m",
        alertProfile: "sam",
        alertAction: "pagerduty",
        sql: "SELECT
  minionpool,
  TotalCount,
  NotReadyCount,
  NotReadyPerc,
  activePools.appCount as SamAppCount
FROM
(
  SELECT
    minionpool,
    TotalCount ,
    NotReadyCount,
    (NotReadyCount/TotalCount) as 'NotReadyPerc'
  FROM
  (
    SELECT
      COUNT(*) as TotalCount,
      SUM(CASE WHEN READY = 'True' THEN 0 ELSE 1 END) as NotReadyCount,
      minionpool
    FROM
      nodeDetailView nd
    WHERE
      KINGDOM != 'PRD' AND KINGDOM != 'UNK' AND KINGDOM != 'GSF'
      GROUP BY minionpool
    ) ss
  ) ss2
inner join
(
  select SUBSTRING_INDEX(Payload->>'$.spec.controlMap.pool', '/', -1) as pool, count(*) as appCount
  from k8s_resource
  where apikind = 'samapp'
  group by pool
) as activePools
on ss2.minionpool = activePools.pool
WHERE
  ((TotalCount >= 10 AND NotReadyPerc >0.25) OR (TotalCount < 10 AND NotReadyCount >2))
  AND NOT (minionpool like '___-sam')
-- AND NOT
-- (minionpool like 'par-sam_warden' AND now() < STR_TO_DATE('2019-03-21', '%Y-%m-%d')) #as in https://gus.lightning.force.com/lightning/r/ADM_Work__c/a07B0000006UbTRIA0/view
-- AND NOT
-- (minionpool like 'phx-sam_mgmt_hub' AND now() < STR_TO_DATE('2019-01-22', '%Y-%m-%d'))
-- AND NOT
-- (minionpool like 'ph2-sam_gater' AND NotReadyPerc < 0.5 AND now() < STR_TO_DATE('2019-01-30', '%Y-%m-%d'))
",
        }

