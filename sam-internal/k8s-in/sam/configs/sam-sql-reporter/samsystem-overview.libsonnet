{
      name: "SamSystem-Overview",
      sql: "select
  controlEstate,
  sum(Running) as Running,
  sum(NotRunning) as NotRunning,
  sum(Running) / (sum(Running)+sum(NotRunning)) as PctHealthy,
  group_concat(FailingSam, '') as FailingSam,
  group_concat(FailingOther, '') as FailingOther
from
(
select
  controlEstate,
  (CASE WHEN Phase <> 'Running' and Name not like '%slb%' and Name not like '%sdn%' then name else null end) as FailingSam,
  (CASE WHEN Phase <> 'Running' and (Name like '%slb%' or Name like '%sdn%') then name else null end) as FailingOther,
  (CASE WHEN Phase = 'Running' then 1 else 0 end) as Running,
  (CASE WHEN Phase <> 'Running' then 1 else 0 end) as NotRunning
from podDetailView
where namespace = 'sam-system'
) as ss
group by controlEstate
order by NotRunning desc",
    }
