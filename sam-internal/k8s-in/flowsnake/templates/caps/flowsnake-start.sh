#!/bin/bash
TAINT=flowsnake-patching
echo "Starting up. Removing any prior ${TAINT} taints."
# kubectl taint removal has no built-in way return success if the taint was not present.
# But we want to be sure to fail if anything else goes wrong to prevent patching
# causing a rolling outage. So we can't || true and have to instead verify the
# taint is present.
# Verifying is a pain, because the taints are stored in a list and not addressable
# by id with a simple go template. Just presume our name is sufficiently unique.
if sudo kubectl --kubeconfig /etc/kubernetes/kubeconfig get node $HOSTNAME -o json | grep $TAINT >/dev/null; then
    echo "Removing $TAINT taint."
    sudo kubectl --kubeconfig /etc/kubernetes/kubeconfig taint nodes ${HOSTNAME} ${TAINT}-
else
    echo "No $TAINT taint to remove."
fi
