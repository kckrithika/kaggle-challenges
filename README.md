This repo contains live manifests for SAM deployments.  See SAM documentation here: https://git.soma.salesforce.com/sam/sam/wiki

### Before submitting a pull request

Please make your changes on a fork of this repo.  Remember to sync changes from master, then run validate.sh before submitting a pull request.  Pay attention to the last line of output.

```sh
$ ./validate.sh 
NOTE: If the next command gives you an error like 'server gave HTTP response to HTTPS client.' then you most likely are missing the insecure registry setting in docker.  See https://git.soma.salesforce.com/sam/sam/wiki/Set-Up-Docker-For-SAM
+ docker run -it --rm -v /Users/thargrove/manifests-th:/repo/ shared0-samcontrol1-1-prd.eng.sfdc.net:5000/sam-tools:thargrove-20160915_105447-fb609d7 /sam/sam-manifest-builder --root=/repo/ -validateonly
### Loading files from disk
  Ignoring file: apps/README.md
  Found pool-map: apps/team/CSC_Health/pool-map.yaml (team/CSC_Health)
  ...
  Found pool: sam-internal/pools/prd/prd-samtemp/pool.yaml (prd/prd-samtemp)
### Validating Yaml Contents
### Successfully validated 11 app manifests
### All Validations Passed
### Successful run.  Good files: 20, Bad Files: 0, Ignored Files: 1

!!! All validations passed.  You are good to commit !!!
```

To start a pull request commit your changes, push to your fork, then use the GitHub UI to create a pull request. Please include the validation output in the PR body.  To get it to format correctly, add a line before and after the text with three back-ticks.

If you want a review from the SAM team paste the PR URL to #onboarding in sfsam.slack.com, but otherwise you can just merge it.  If you dont have permissions you can request them from sam@salesforce.com.  Please let us know what team you are with and what you will be trying out on SAM.
