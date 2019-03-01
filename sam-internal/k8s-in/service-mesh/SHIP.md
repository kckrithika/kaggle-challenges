## Upgrading Pilot using Ship
This `istio-ship` folder as been initiated with `ship init https://github.com/istio/istio/tree/1.0.2/install/kubernetes/helm/istio`. Refer quip doc on [using Ship](https://salesforce.quip.com/arllAbyoT0jh) for details.

To update the repo, use the following workflow:

1. Run `ship update --headed`. This opens up the browser to visually analyse the `base` changes between the existing and latest istio charts.
1. Update the patches as necessary. Once you reach Step 6 in the browser app above, the overlays are updated.
1. Run `./splitter.sh k8s`. This splits the generated `rendered.yaml` into individual resource files and puts them in `k8s-out/prd/prd-sam`. 
1. `git diff` the files in `k8s-out/prd/prd-sam`
1. This pipeline is still in experimental stage, so do not merge the k8s out files. Run ` rm ../../k8s-out/prd/prd-sam/istio-*; cd ../; ./build.sh prd/prd-sam` to revert the changes to k8s-out.
1. Alternatively, you could also run `./splitter.sh` without any args and check the generated output in `istio-ship-out` directory. 
