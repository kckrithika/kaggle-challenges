{
      name: "Sam-App-Pod-Age-Prd",
      sql: "select
  PodAgeDays,
  SUM(CASE WHEN ControlEstate = 'prd-sam' then Count else 0 END) as 'PrdSam',
  SUM(CASE WHEN ControlEstate = 'prd-samdev' then Count else 0 END) as 'PrdSamDev',
  SUM(CASE WHEN ControlEstate = 'prd-samtest' then Count else 0 END) as 'PrdSamTest'
from
(
  select
    ControlEstate,
    PodAgeDays,
    COUNT(*) as Count
  from
  (
    select
      ControlEstate,
      LEAST(FLOOR(PodAgeInMinutes/60.0/24.0),10) as PodAgeDays
    from podDetailView
    where IsSamApp = True and ProduceAgeInMinutes<60
  ) as ss
  where PodAgeDays IS NOT NULL
  group by ControlEstate, PodAgeDays
) as ss2
group by PodAgeDays",
    }