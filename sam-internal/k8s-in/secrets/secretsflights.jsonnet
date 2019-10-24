{
   local secretsimages = import "secretsimages.libsonnet",
   caimanWdSecondReplicaEnabled(canary=false): (secretsimages.k4aCaimanWatchdog_build(canary) >= 195),
}
