{
      name: "MySQL Pods by Produce Age",
      note: "This shows the count of pods by produce age bucket.  Ideally most of our pods should have a produce age less than 15 minutes.  Large number of pods above this indicates an issue.  <a href='https://git.soma.salesforce.com/sam/sam/wiki/Debugging-Visibility-Pipeline'>Debug Instructions</a>",
      sql: "select
  SUM(lt5m),
  SUM(lt10m),
  SUM(lt15m),
  SUM(lt20m),
  SUM(lt25m),
  SUM(lt30m),
  SUM(lt40m),
  SUM(lt50m),
  SUM(lt60m),
  SUM(lt120m),
  SUM(ltMax)
from (
select
  CASE WHEN ProduceAgeInMinutes<5 THEN 1 ELSE 0 END as lt5m,
  CASE WHEN ProduceAgeInMinutes<10 THEN 1 ELSE 0 END as lt10m,
  CASE WHEN ProduceAgeInMinutes<15 THEN 1 ELSE 0 END as lt15m,
  CASE WHEN ProduceAgeInMinutes<20 THEN 1 ELSE 0 END as lt20m,
  CASE WHEN ProduceAgeInMinutes<25 THEN 1 ELSE 0 END as lt25m,
  CASE WHEN ProduceAgeInMinutes<30 THEN 1 ELSE 0 END as lt30m,
  CASE WHEN ProduceAgeInMinutes<40 THEN 1 ELSE 0 END as lt40m,
  CASE WHEN ProduceAgeInMinutes<50 THEN 1 ELSE 0 END as lt50m,
  CASE WHEN ProduceAgeInMinutes<60 THEN 1 ELSE 0 END as lt60m,
  CASE WHEN ProduceAgeInMinutes<120 THEN 1 ELSE 0 END as lt120m,
  1 as ltMax
from
  podDetailView
) as ss",
    }
