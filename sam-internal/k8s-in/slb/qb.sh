#!/bin/bash

# This script pushes local commits to the remote, then calls into deployerbot asking it to do a
# build of the changes (build.sh) and publish a PR with the results.

set -o errexit
set -o nounset
set -o pipefail

: "${DEPLOYERBOT_BUDDYPR_ENDPOINT:=http://deployerbot.slb.prd-sam.prd.slb.sfdc.net/buddyPR}"
: "${SLACK_CHANNEL:="#slb-private"}"

# build_buddypr_yaml_request creates a yaml doc containing a buddyPR request payload.
# Argument $1: forkOrg -- the name of the forked manifests repo org.
# Argument $2: branchName -- the name of the branch containing desired changes.
# Argument $3: slackChannelToNotify -- the name of the slack channel which will be notified of the newly-published PR.
# Argument $4: prTitle -- the title to use for the generated PR. Can be empty, in which case a default title is used.
function build_buddypr_yaml_request() {
    fileName=$(mktemp)
    cat <<EOF > "${fileName}"
forkOrg: $1
branchName: $2
slackChannelToNotify: '$3'
prTitle: '$4'
EOF
    echo "${fileName}"
}

# get_fork_org attempts to get the name of the org for this fork of the sam/manifests repo.
# It assumes that the name follows a pattern like:
#    git@git.soma.salesforce.com:mgrass/manifests.git
function get_fork_org() {
    git remote get-url origin | cut -d: -f2 | cut -d/ -f1
}

# get_current_branch_name attempts to determine the name of the current branch.
function get_current_branch_name() {
    git rev-parse --abbrev-ref=strict --symbolic HEAD
}

# get_last_commit_subject gets the "title line"/commit subject of the most recent commit in the local branch.
function get_last_commit_subject() {
    git log -1 --pretty=format:%s
}

# push_local_changes pushes current changes to the origin remote.
function push_local_changes() {
    git push -f origin HEAD > /dev/null 2>&1
}

function send_request_to_deployerbot() {
    slackChannel="$1"
    prTitle="$2"
    forkOrg=$(get_fork_org)
    branchName=$(get_current_branch_name)
    yamlRequestFile=$(build_buddypr_yaml_request "${forkOrg}" "${branchName}" "${slackChannel}" "${prTitle}")

    curl -X POST -H "Content-Type: application/yaml" --data-binary "@${yamlRequestFile}" "${DEPLOYERBOT_BUDDYPR_ENDPOINT}"
}

function main() {
    prTitle=
    slackChannel="${SLACK_CHANNEL}"

    # Parse command-line parameters.
    while [[ $# -gt 0 ]]; do
        key="$1"

        case $key in
            -t|--prTitle)
            prTitle="$2"
            shift # past argument
            shift # past value
            ;;

            -s|--slackChannel)
            slackChannel="$2"
            shift # past argument
            shift # past value
            ;;

            *)    # unknown option
            echo "Unknown option $key"
            exit 1
            ;;
        esac
    done

    if [[ -z "$prTitle" ]]; then
        prTitle=$(get_last_commit_subject)
    fi

    push_local_changes
    send_request_to_deployerbot "${slackChannel}" "${prTitle}"
}

main "$@"