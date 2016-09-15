This repo contains live manifests for SAM deployments.  See SAM documentation here: https://git.soma.salesforce.com/sam/sam/wiki

To validate changes, run this:

```sh
$ ./validate.sh 
NOTE: If the next command gives you an error like 'server gave HTTP response to HTTPS client.' then you most likely are missing the insecure registry setting in docker.  See https://git.soma.salesforce.com/sam/sam/wiki/Set-Up-Docker-For-SAM
+ docker run -it --rm -v /Users/thargrove/manifests-th:/repo/ shared0-samcontrol1-1-prd.eng.sfdc.net:5000/sam-tools:thargrove-20160915_105447-fb609d7 /sam/sam-manifest-builder --root=/repo/ -validateonly
### Loading files from disk
  Ignoring file: apps/README.md
  Found pool-map: apps/team/CSC_Health/pool-map.yaml (team/CSC_Health)
  Found app: apps/team/CSC_Health/reportcollector/manifest.yaml (team/CSC_Health/reportcollector)
  Found app: apps/team/CSC_Health/reportcollector-perf/manifest.yaml (team/CSC_Health/reportcollector-perf)
  ...
  Found app: apps/user/ssandke/srs-demo1/manifest.yaml (user/ssandke/srs-demo1)
  Found app: apps/user/thargrove/TestApp/manifest.yaml (user/thargrove/TestApp)
  Found pool-map: apps/user/thargrove/pool-map.yaml (user/thargrove)
  Found pool: sam-internal/pools/prd/prd-sam/pool.yaml (prd/prd-sam)
  Found pool: sam-internal/pools/prd/prd-samtemp/pool.yaml (prd/prd-samtemp)
### Validating Yaml Contents
### Successfully validated 11 app manifests
### All Validations Passed
### Successful run.  Good files: 20, Bad Files: 0, Ignored Files: 1
```

When you are ready to submit your change, do "git add" then "git commit" and use the GitHub web UI to create a PR. Please include the validation output in the PR body.  To get it to format correctly, add a line before and after the text with three back-ticks.

If you want a review from the SAM team paste the PR URL to #onboarding in sfsam.slack.com, but otherwise you can just merge it.

