#!/usr/bin/bash

# This test actually does not involve Spark applications at all, but it is part of verifying the Flowsnake v2 offering.
# This test performs a minimal interaction with the Kubernetes API to verify connectivity, authentication, and
# authorization.

KUBECONFIG="$1"

# Success of this command demonstrates successful connection via impersonation proxy and mapping to
# user account flowsnake_test.flowsnake-watchdog (which in turn is bound to flowsnake-client-flowsnake-watchdog-Role)
# (Success does not depend on whether there exist any sparkapplication resources in the namespace)
kubectl -n flowsnake-watchdog get sparkapplications
