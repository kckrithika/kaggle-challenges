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
    }