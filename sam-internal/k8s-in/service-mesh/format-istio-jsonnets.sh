#!/usr/bin/env bash

${BASH_SOURCE%/*}/../jsonnet/jsonnet fmt -i ${BASH_SOURCE%/*}/*.*sonnet

# Jsonnets in sub-directories are not formatted by default.
# Will send this as PR to SAM, adding this script temporarily.
${BASH_SOURCE%/*}/../jsonnet/jsonnet fmt -i ${BASH_SOURCE%/*}/templates/*/*/*.*sonnet
