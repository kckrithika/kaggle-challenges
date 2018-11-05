{
      name: "SamSystem-Failed-Pods-NonSam",
      sql: "select ControlEstate, Name, NodeName, Phase, Message, PodUrl from podDetailView where namespace = 'sam-system' and Phase <> 'Running' and (Name like '%slb%' or Name like '%sdn%') order by ControlEstate, Name",
    }
