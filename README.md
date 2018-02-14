This repo contains live manifests for SAM deployments.  

Please read the [Confluence docs on deploying](https://confluence.internal.salesforce.com/display/SAM/Onboarding+To+SAM), which provides the most up to date overviews of the deploy process. There you also find links to details for the file formats and validation commands that are necessary for a successful deployment. Below we provide the short version. Above all else, make sure you validate bfore starting a pull!!

### Before submitting a pull request

Please make your changes on a fork of this repo.  Remember to sync changes from master, then run validate.sh before submitting a pull request.  Pay attention to the last line of output.

```sh
$ ./validate.sh 
NOTE: If the docker run command returns a 'BAD_CREDENTIAL' error, you need to run 'docker login ops0-artifactrepo1-0-prd.data.sfdc.net' (one-time). See https://confluence.internal.salesforce.com/x/NRDa (Set up Docker for Sam)
sam-manifest-builder build version: 20180131_005446.43e3d41.dirty.9b0f360a10ec
### Successful run.  Good files: 1589, Bad Files: 0, Ignored Files: 285
```

To start a pull request: commit your changes, push to your fork, then use the GitHub UI to create a pull request. Please include the validation output in the PR body. To get it to format correctly, add a line before and after the text with three back-ticks.

After creating a PR, the TNRP bot will post a URL as a comment. A person other than the one who created the PR needs to click it. That will kick off a TNRP pipeline. If it passes, the changes will be merged. For more info see [this doc](https://confluence.internal.salesforce.com/x/uafy).
