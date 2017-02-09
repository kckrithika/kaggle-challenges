#!/bin/bash

HYPERSAM=shared0-samcontrol1-1-prd.eng.sfdc.net:5000/hypersam:20170208_174602.32c93f4.dirty.prahladjos-ltm

if [ "$1" == "evaluatePR" ] 
then
  echo -e "\nEvaluating PR\n"
  echo -e '```\n'
  /opt/sam/sam-manifest-builder --root='./' -validateonly
  exitcode="$?"
  echo -e '\n```\n'
else
  echo "NOTE: If the docker run command gives you an error like 'server gave HTTP response to HTTPS client.' then you most likely are missing the insecure registry setting in Docker.  See https://confluence.internal.salesforce.com/x/NRDa (Set up Docker for Sam)"
  if [ "$1" == "verbose" ]
  then
    docker run -it --rm -v ${PWD}:/repo/ ${HYPERSAM} /sam/sam-manifest-builder --root='/repo/' -validateonly -verbose
  else
    docker run -it --rm -v ${PWD}:/repo/ ${HYPERSAM} /sam/sam-manifest-builder --root='/repo/' -validateonly
  fi
  exitcode="$?"
fi


if [ "0" != "$exitcode" ]
then
  echo -e "\033[30;41mValidations failed.  You must fix these issues before merging!\033[0m"
  exit 1
else
  echo -e "\033[30;42m!!! All validations passed.  Your changes look good !!!\033[0m"
fi
