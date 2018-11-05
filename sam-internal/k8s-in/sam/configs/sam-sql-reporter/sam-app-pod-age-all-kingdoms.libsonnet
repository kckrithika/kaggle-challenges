{
      name: "Sam-App-Pod-Age-All-Kingdoms",
      sql: "select
  PodAgeDays,
  SUM(CASE WHEN ControlEstate = 'prd-sam' then Count else 0 END) as 'PrdSam',
  SUM(CASE WHEN ControlEstate = 'prd-samdev' then Count else 0 END) as 'PrdSamDev',
  SUM(CASE WHEN ControlEstate = 'prd-samtest' then Count else 0 END) as 'PrdSamTest',
  SUM(CASE WHEN ControlEstate = 'frf-sam' then Count else 0 END) as 'FrfSam',
  SUM(CASE WHEN ControlEstate = 'phx-sam' then Count else 0 END) as 'PhxSam',
  SUM(CASE WHEN ControlEstate = 'par-sam' then Count else 0 END) as 'ParSam',
  SUM(CASE WHEN ControlEstate = 'ord-sam' then Count else 0 END) as 'OrdSam',
  SUM(CASE WHEN ControlEstate = 'iad-sam' then Count else 0 END) as 'IadSam',
  SUM(CASE WHEN ControlEstate = 'hnd-sam' then Count else 0 END) as 'HndSam',
  SUM(CASE WHEN ControlEstate = 'dfw-sam' then Count else 0 END) as 'DfwSam',
  SUM(CASE WHEN ControlEstate = 'ukb-sam' then Count else 0 END) as 'UkbSam',
  SUM(CASE WHEN ControlEstate = 'cdu-sam' then Count else 0 END) as 'CduSam',
  SUM(CASE WHEN ControlEstate = 'syd-sam' then Count else 0 END) as 'SydSam',
  SUM(CASE WHEN ControlEstate = 'yhu-sam' then Count else 0 END) as 'YhuSam',
  SUM(CASE WHEN ControlEstate = 'yul-sam' then Count else 0 END) as 'YulSam',
  SUM(CASE WHEN ControlEstate = 'chx-sam' then Count else 0 END) as 'ChxSam',
  SUM(CASE WHEN ControlEstate = 'wax-sam' then Count else 0 END) as 'WaxSam'
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