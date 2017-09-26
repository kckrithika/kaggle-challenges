# WARNING

This folder is for configuation internal to SAM services.  Changes to this folder can break production if you are not careful.

Any changes need to be either initiated by the Ops on duty, or approved by the Ops.

1. k8s-in/sam, k8s-out: Follow instructions on https://git.soma.salesforce.com/sam/sam/wiki/Deploy-SAM
1. hypersam.sh: Follow instruction on https://git.soma.salesforce.com/sam/sam/wiki/Update-SAM-Manifest-Builder
1. pools: remember to run k8s-in/build.sh after updating pools
