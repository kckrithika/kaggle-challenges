#!/bin/bash
TAINT=flowsnake-patching
echo "Shutting down. Applying ${TAINT} taints."
sudo kubectl --kubeconfig /etc/kubernetes/kubeconfig taint nodes ${HOSTNAME} ${TAINT}=cordon:NoSchedule
sudo kubectl --kubeconfig /etc/kubernetes/kubeconfig taint nodes ${HOSTNAME} ${TAINT}=drain:NoExecute
GRACEFUL_SECONDS=60
START_TIME=$(date '+%s')
echo "Waiting up to $GRACEFUL_SECONDS seconds for pods to exit gracefully."
while true; do
    PROCESS_COUNT=$(sudo docker ps -q | wc -l)
    if [[ "$PROCESS_COUNT" == "0" ]]; then
        echo "All Docker processes have exited."
        break
    else
        echo "$PROCESS_COUNT Docker processes still running."
        if (( $(date '+%s') - START_TIME >= GRACEFUL_SECONDS )); then
            # Note assumption that every Docker process belongs to Kubernetes!
            echo "Forcibly killing remaining Docker processes:"
            sudo docker ps
            sudo docker kill $(sudo docker ps -q)
            break
        fi
        sleep 5
    fi
done
# Docker processes have exited, but Kubernetes might not be aware yet. Give it time to update
# so we don't leave pods stuck in Terminating state
FORCEFUL_SECONDS=30
START_TIME=$(date '+%s')
echo "Waiting up to $FORCEFUL_SECONDS seconds for Kubernetes to observe that processes have terminated."
while true; do
    POD_COUNT=$(sudo kubectl --kubeconfig /etc/kubernetes/kubeconfig get pods --all-namespaces -o wide | grep ${HOSTNAME} | wc -l)
    if [[ "$POD_COUNT" == "0" ]]; then
        echo "All pods have terminated."
        exit 0
    else
        if (( $(date '+%s') - START_TIME >= FORCEFUL_SECONDS )); then
            PROCESS_COUNT=$(sudo docker ps -q | wc -l)
            if [[ "$PROCESS_COUNT" == "0" ]]; then
                # This should be safe since we confirmed they really are not running.
                echo "All Docker processes have exited. Force deleting remaining $POD_COUNT pods from Kubernetes:"
                sudo kubectl --kubeconfig /etc/kubernetes/kubeconfig get pods --all-namespaces -o wide | grep ${HOSTNAME}
                for NSPOD in $(sudo kubectl --kubeconfig /etc/kubernetes/kubeconfig get pods --all-namespaces --field-selector spec.nodeName=$HOSTNAME -o template --template '{{ range .items }}{{.metadata.namespace}}{{":"}}{{.metadata.name}}{{"\n"}}{{end}}'); do
                    NS=${NSPOD%:*}
                    POD=${NSPOD#*:}
                    sudo kubectl --kubeconfig /etc/kubernetes/kubeconfig  -n ${NS} delete pod ${POD} --grace-period=0 --force
                done;
                exit 0
            else
                echo "Giving up even though some pods have not terminated:"
                sudo kubectl --kubeconfig /etc/kubernetes/kubeconfig get pods --all-namespaces -o wide | grep ${HOSTNAME}
                exit 1
            fi
        else
            echo "Kubernetes still sees $POD_COUNT pods on this node."
            sleep 5
        fi
    fi
done
