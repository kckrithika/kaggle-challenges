{
      name: "SamSystem-Failed-Pods-Sam",
      sql: "select ControlEstate, Name, NodeName, Phase, Message, PodUrl from podDetailView where namespace = 'sam-system' and Phase <> 'Running' and Name not like '%slb%' and Name not like '%sdn%' order by ControlEstate, Name",
    }
