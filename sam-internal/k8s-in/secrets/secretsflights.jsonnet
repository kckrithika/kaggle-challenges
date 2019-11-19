{
   local secretsimages = import "secretsimages.libsonnet",
   caimanWdSecondReplicaEnabled(canary=false): (secretsimages.k4aCaimanWatchdog_build(canary) >= 195),
   ssWdSecondReplicaEnabled(canary=false): (secretsimages.sswatchdog_build(canary) >= 163),
   podManagementPolicyEnabled(canary=false): 
}
