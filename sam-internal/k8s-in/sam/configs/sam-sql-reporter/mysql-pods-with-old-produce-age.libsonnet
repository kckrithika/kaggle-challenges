{
      name: "MySql-Pods-With-Old-Produce-Age",
      sql: "select
  NamespacePodPrefix,
  SUM(Count) as Count,
  GROUP_CONCAT(ControlEstate, ' ')
from
(
  select
    NamespacePodPrefix,
    ControlEstate,
    COUNT(*) as Count
  from
  (
    select
      CONCAT(Namespace, ' ', SUBSTRING_INDEX(Name, '-', 1)) as NamespacePodPrefix,
      ControlEstate
    from podDetailView
    where IsSamApp = True and ProduceAgeInMinutes>60.0
  ) as ss
  group by NamespacePodPrefix, ControlEstate
) as ss2
group by NamespacePodPrefix
order by Count desc",
    }
