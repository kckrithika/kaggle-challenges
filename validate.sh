#!/bin/bash
set -e

#exitIfMergeCommitFound checks if there are any 
#merge commits introduced by the current branch 
#which are not present in the origin/master.
#If it finds any merge commits, it calls exit.
exitIfMergeCommitFound() {
  GIT_CURRENT_BRANCH=$(git name-rev --name-only HEAD)
  #Find count of all the merge commits that are 
  #present in the current branch but not in origin/master.
  mergeCommits=`git log origin/master..$GIT_CURRENT_BRANCH --merges --pretty=format:'%H %P%n' | wc -l | tr -d '[[:space:]]' `
  #Find count of all non merge commits that are 
  #present in the current branch but not in origin/master.
  nonMergeCommits=`git log origin/master..$GIT_CURRENT_BRANCH --no-merges --pretty=format:'%H %P%n' | wc -l | tr -d '[[:space:]]' `
  echo "PR has ${mergeCommits} merge commits and ${nonMergeCommits} normal commits"
  if [ $mergeCommits -ne "0" ]
  then
    echo "Merge commits are not allowed in PRs"
    exit 1
  fi
}

HYPERSAM=shared0-samcontrol1-1-prd.eng.sfdc.net:5000/hypersam:20170216_175432.6acc29a.dirty.thargrove-ltm1

if [ "$1" == "evaluatePR" ] 
then
  set -x
  echo -e "\nEvaluating PR\n"
  git remote -v || true
  git branch
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
