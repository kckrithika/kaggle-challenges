#!/bin/bash -xe

# Temporary script to redeploy all our daemon sets and deployments to prd-sam and prd-samtemp
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

#Delete all the daemon sets in NAMESPACE
for aDaemonSet in `${KUBECTLBIN} --context=${KCONTEXT} --namespace=${NAMESPACE} get ds -o jsonpath='{$.items[*].metadata.name}'`; do
  ${KUBECTLBIN} --context=${KCONTEXT} --namespace=${NAMESPACE} delete ds $aDaemonSet --cascade=false
done

#Delete all the pods for daemon sets
for aPods in `${KUBECTLBIN} --context=${KCONTEXT} --namespace=${NAMESPACE} get pods -lapp=slam-agent -o jsonpath='{$.items[*].metadata.name}'`; do
  ${KUBECTLBIN} --context=${KCONTEXT} --namespace=${NAMESPACE} delete pod $aPods
done

for aPods in `${KUBECTLBIN} --context=${KCONTEXT} --namespace=${NAMESPACE} get pods -lapp=debug-portal -o jsonpath='{$.items[*].metadata.name}'`; do
  ${KUBECTLBIN} --context=${KCONTEXT} --namespace=${NAMESPACE} delete pod $aPods
done

#Update all deployments and daemon sets
${KUBECTLBIN} --context=${KCONTEXT} --namespace=${NAMESPACE} apply -f generated/$KCONTEXT/appConfigs/json

# TODO: Add some basic validations
