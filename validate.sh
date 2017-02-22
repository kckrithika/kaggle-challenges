#!/bin/bash

HYPERSAM=shared0-samcontrol1-1-prd.eng.sfdc.net:5000/hypersam:20170216_175432.6acc29a.dirty.thargrove-ltm1

if [ "$1" == "evaluatePR" ] 
then
  echo -e "\nEvaluating PR\n"
  git remote -v || true
  git branch
  commitCount=`git log origin.. --pretty=format:'%H %P' |wc -l`
  if [ $commitCount -gt 1 ]
  then
    echo "Only 1 commit is allowed per PR"
    #This is for testing othewise we would exit here.
  fi

  if [ $commitCount -eq 1 ]
  then
    commitHashes=`git log origin.. --pretty=format:'%H %P'`
    echo "AdditionalCommits "$commitHashes
    head=`git rev-parse origin/master`
    while IFS=' ' read -ra hashes
    do
      for commit in ${hashes[@]}
      do
        if [ "$commit" == "$head" ]
        then
          found="true"
          break
        fi
      done
    done <<< "$commitHashes"
    if [ "$found" != "true" ]
    then
      echo "Commit in the PR must have upstream HEAD as its parent"
      #This is for testing othewise we would exit here.
    fi
  fi
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
