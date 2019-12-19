{
    name: "Hosts-Up-Per-Estate",
    note: "",
    multisql: [

    # ===

    {
    name: "Number of hosts up or down per estate",
    note: "",
    sql: "select
  controlEstate,
  pool,
  sum(down) as downCount,
  sum(up) as upCount,
  count(*) as count,
  group_concat(downHosts, '', '') as downHosts,
  (0.0+sum(up))/(0.0+count(*)) as percentHostsUp
from
(
  select 
    controlEstate,
    name,
    pool,
    case when ((KubeletReady is null) or (KubeletReady != 'True') or (ProduceAgeInMin > 60)) then 1 else 0 end as down,
    case when ((KubeletReady is null) or (KubeletReady != 'True') or (ProduceAgeInMin > 60)) then 0 else 1 end as up,
    case when ((KubeletReady is null) or (KubeletReady != 'True') or (ProduceAgeInMin > 60)) then name else null end as downHosts
  from (
    select
      controlEstate,
      name,
      Payload->>'$.metadata.labels.\"pool\"' as pool,
      floor((time_to_sec(timediff(utc_timestamp(),from_unixtime((ProduceTime / 1000000000.0)))) / 60.0)) as ProduceAgeInMin,
      json_unquote(json_extract(Payload, concat('$.status.conditions[',substring(json_search(Payload->>'$.status.conditions', 'one', 'KubeletReady'), 4,1),'].status'))) as KubeletReady,
      Payload->>'$.status.conditions[*].message' as Messages,
      isTombstone
    from k8s_resource 
    where ApiKind = 'node' and isTombstone = 0
  ) as ss
) as ss2
group by controlEstate, pool
order by percentHostsUp desc",
    },
    ],
}