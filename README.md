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
