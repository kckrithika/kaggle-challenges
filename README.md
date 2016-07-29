This repo contains live manifests for SAM deployments.  See SAM documentation here: https://git.soma.salesforce.com/sam/sam/wiki

To validate changes, run this:

```sh
$ ./validate.sh 
Reading /repo/kingdom-map.yaml
---
[G] Manifest /repo/demoestate/manifest.yaml - good
[G] Manifest /repo/thargrove-test/manifest.yaml - good
[G] Manifest /repo/antorcol-test/manifest.yaml - good
[G] Manifest /repo/caas-test/manifest.yaml - good
[G] Manifest /repo/mayank-test/manifest.yaml - good
[G] Manifest /repo/demoestate/manifest.yaml - good
[G] Manifest /repo/cbatra-test/manifest.yaml - good
---
Successfully validated /repo/. Good=7, Errors=0, Ignored=0
```

### Note about 'apps' and 'sam-internal' folders
These two folders are for a work in progress to change our manifest layout.
For now customers can ignore these.  When we are ready to do the switch we will migrate all existing apps.
If you are curious about this upcoming change, see [this document](https://docs.google.com/document/d/1I0Z8zjJD3TVZvzmQSWiNEgATtuapxzp0cquc6-PXweE/edit#)
