{
   local secretsimages = import "secretsimages.libsonnet",
   caimanWdSecondReplicaEnabled(canary=false): (secretsimages.k4aCaimanWatchdog_build(canary) >= 195),
   podManagementPolicyEnabled(canary=false): (secretsimages.sswatchdog_build(canary) >= 180),
}
