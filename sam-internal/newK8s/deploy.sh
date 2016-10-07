#/bin/bash -xe

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
    *)
        echo "Invalid estate $1, use 'prd-sam' or 'prd-samtemp'.  exiting ..."
        exit 1
esac

echo Context is ${KCONTEXT}, using kubectl ${KUBECTLBIN}

${KUBECTLBIN} --context=${KCONTEXT} --namespace=${NAMESPACE} delete ds -all 

${KUBECTLBIN} --context=${KCONTEXT} --namespace=${NAMESPACE} apply -f generated/$KCONTEXT/appConfigs/yaml

# TODO: Add some basic validations
