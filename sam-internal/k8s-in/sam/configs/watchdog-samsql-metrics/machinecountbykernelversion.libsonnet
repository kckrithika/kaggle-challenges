{
     watchdogFrequency: "15m",
     name: "MachineCountByKernelVersion",
     sql: "select 'GLOBAL' as Kingdom, 'NONE' as SuperPod, 'global' as Estate, 'sql.machineCountByKernelVersion' as Metric, COUNT(*) as Value, CONCAT('KernelVersion=',KernelVersion) as Tags from nodeDetailView group by kernelVersion",
   }

