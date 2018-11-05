{
      name: "SAM Node Status Aggregate",
      sql: "select * from (
select * from (
select ControlEstate,
SUM(ReadyCount) as Ready,
SUM(NotReadyCount) as NotReady,
SUM(NotReadyCount)+SUM(ReadyCount) as Total,
SUM(ReadyCount)/(SUM(NotReadyCount)+SUM(ReadyCount)) as ReadyPct,
GROUP_CONCAT(NotReadyName) as NotReadyHosts
from
(
select 'TOTAL' as ControlEstate,
NULL as NotReadyName,
case when Ready = 'True' then 1 else 0 end as ReadyCount,
case when Ready = 'True' then 0 else 1 end as NotReadyCount
from nodeDetailView
where 
	(Name not like '%slb%')
	and (Name not like '%ceph%')
	and (Name not like '%sdc%')
	and (Name not like '%flowsnake%')

) as ss
group by ControlEstate
) as ss2

union

select * from (
select ControlEstate,
SUM(ReadyCount) as Ready,
SUM(NotReadyCount) as NotReady,
SUM(NotReadyCount)+SUM(ReadyCount) as Total,
SUM(ReadyCount)/(SUM(NotReadyCount)+SUM(ReadyCount)) as ReadyPct,
GROUP_CONCAT(NotReadyName) as NotReadyHosts
from
(
select ControlEstate,
case when Ready = 'True' then NULL else Name end as NotReadyName,
case when Ready = 'True' then 1 else 0 end as ReadyCount,
case when Ready = 'True' then 0 else 1 end as NotReadyCount
from nodeDetailView
where 
	(Name not like '%slb%')
	and (Name not like '%ceph%')
	and (Name not like '%sdc%')
	and (Name not like '%flowsnake%')

) as ss3
group by ControlEstate
) as ss4
) as ss5
order by ReadyPct",
    }