#!/bin/bash

# This script pushes local commits to the remote, then calls into deployerbot asking it to do a
# build of the changes (build.sh) and publish a PR with the results.

set -o errexit
set -o nounset
set -o pipefail

: "${SLACK_CHANNEL:="#infrasec-secrets"}"
: "${DEPLOYERBOT_BUDDYPR_ENDPOINT:=https://deployerbot-secrets.moe.prd-sam.prd.slb.sfdc.net/buddyPR}"

SLACK_CHANNEL="$SLACK_CHANNEL" DEPLOYERBOT_BUDDYPR_ENDPOINT="$DEPLOYERBOT_BUDDYPR_ENDPOINT" "$(dirname "${0}")/../slb/qb.sh" "$@"