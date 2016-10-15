#!/bin/bash -xe

# Temporary script to redeploy all our DaemonSets and deployments to prd-sam and prd-samtemp
# Either put kubectl in your path, or set KUBECTLBIN to point to it.  For example, you can add this to .bash_profile:
#
# export KUBECTLBIN='/Users/thargrove/sam/src/k8s.io/kubernetes/cluster/kubectl.sh'

KUBECTLBIN=${KUBECTLBIN:-kubectl}
NAMESPACE=sam-system

case "$1" in
    prd-sam)
        KCONTEXT=prd-sam
        ;;
    prd-samtemp)
        KCONTEXT=prd-samtemp
        ;;
    prd-samdev)
        KCONTEXT=prd-samdev
        ;;
    *)
        echo "Invalid estate $1, use 'prd-sam', 'prd-samtemp' or 'prd-samdev'.  exiting ..."
        exit 1
esac

echo Context is ${KCONTEXT}, using kubectl ${KUBECTLBIN}

# NOTE: 
# Issue: https://github.com/kubernetes/kubernetes/issues/33245
# DaemonSet deletion gets stuck sometimes. The reason is not clear but the above issue gives more details.
# To avoid getting stuck, we first delete the DaemonSet with --cascade=false, which leaves the pod around,
# and only deletes the DaemonSets. Then we go, and cleanup all DaemonSet pods. The DaemonSet creation will
# bring up new pods with new configuration as desired.
# Delete all the DaemonSets in NAMESPACE
for aDaemonSet in `${KUBECTLBIN} --context=${KCONTEXT} --namespace=${NAMESPACE} get ds -o jsonpath='{$.items[*].metadata.name}'`; do
  ${KUBECTLBIN} --context=${KCONTEXT} --namespace=${NAMESPACE} delete ds $aDaemonSet --cascade=false
done

#Delete all the Pods for DaemonSets
for aPods in `${KUBECTLBIN} --context=${KCONTEXT} --namespace=${NAMESPACE} get pods -ldaemonset=true -o jsonpath='{$.items[*].metadata.name}'`; do
  ${KUBECTLBIN} --context=${KCONTEXT} --namespace=${NAMESPACE} delete pod $aPods
done

#Update all Deployments and DaemonSets
${KUBECTLBIN} --context=${KCONTEXT} --namespace=${NAMESPACE} apply -f generated/$KCONTEXT/appConfigs/json

# TODO: Add some basic validations
