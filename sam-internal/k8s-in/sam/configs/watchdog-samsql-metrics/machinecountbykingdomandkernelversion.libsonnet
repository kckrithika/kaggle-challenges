{
     watchdogFrequency: "15m",
     name: "MachineCountByKingdomAndKernelVersion",
     sql: "select UPPER(kingdom) as Kingdom, 'NONE' as SuperPod, ControlEstate as Estate, 'sql.machineCountByKingdomAndKernelVersion' as Metric, COUNT(*) as Value, CONCAT('KernelVersion=',KernelVersion) as Tags from nodeDetailView group by ControlEstate, kingdom, kernelVersion",
   }

