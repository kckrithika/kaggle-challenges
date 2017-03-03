#!/bin/bash

#exitIfMergeCommitFound checks if there are any 
#merge commits introduced by the current branch 
#which are not present in the origin/master.
#If it finds any merge commits, it calls exit.
exitIfMergeCommitFound() {
  GIT_CURRENT_BRANCH=$(git name-rev --name-only HEAD)
  #Find count of all the merge commits that are 
  #present in the current branch but not in origin/master.
  key="commit"
  git log origin/master..$GIT_CURRENT_BRANCH --merges
  git log origin/master..$GIT_CURRENT_BRANCH --no-merges
  mergeCommits=$(git log origin/master..$GIT_CURRENT_BRANCH --merges --pretty=format:"$key %H %P" | grep -c $key) || true
  #Find count of all non merge commits that are 
  #present in the current branch but not in origin/master.
  nonMergeCommits=$(git log origin/master..$GIT_CURRENT_BRANCH --no-merges --pretty=format:"$key %H %P" | grep -c $key) || true
  echo "PR has ${mergeCommits} merge commits and ${nonMergeCommits} normal commits"
  if [ "$mergeCommits" -ne "0" ]
  then
    echo "Merge commits are not allowed in PRs"
    echo "For help removing them see http://stackoverflow.com/questions/21115596/remove-a-merge-commit-keeping-current-changes"
    exit 1
  fi
}

HYPERSAM=shared0-samcontrol1-1-prd.eng.sfdc.net:5000/hypersam:20170216_175432.6acc29a.dirty.thargrove-ltm1

if [ "$1" == "evaluatePR" ] 
then
  set -x
  echo -e "\nEvaluating PR\n"
  exitIfMergeCommitFound
  echo -e '```\n'
  /opt/sam/sam-manifest-builder --root='./' -validateonly
  exitcode="$?"
  echo -e '\n```\n'
else
  echo "NOTE: If the docker run command gives you an error like 'server gave HTTP response to HTTPS client.' then you most likely are missing the insecure registry setting in Docker.  See https://confluence.internal.salesforce.com/x/NRDa (Set up Docker for Sam)"
  EXTRAARGS=""
  if [ "$1" == "verbose" ]
  then
    EXTRAARGS="-verbose"
  fi
  docker run -it --rm -v ${PWD}:/repo/ ${HYPERSAM} /sam/sam-manifest-builder --root='/repo/' -validateonly $EXTRAARGS
  exitcode="$?"
fi


if [ "0" != "$exitcode" ]
then
  echo -e "\033[30;41mValidations failed.  You must fix these issues before merging!\033[0m"
  exit 1
else
  echo -e "\033[30;42m!!! All validations passed.  Your changes look good !!!\033[0m"
fi
