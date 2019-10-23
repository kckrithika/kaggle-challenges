{
   local secretsimages = import "secretsimages.libsonnet",
   caimanWdSecondReplicaEnabled(canary=false): (secretsimages.k4aCaimanWdPhaseNum(canary) <= 2),
}
