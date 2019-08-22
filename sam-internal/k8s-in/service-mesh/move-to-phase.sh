#!/usr/bin/env bash

if [[ $# -eq 0 ]]; then
  echo "No phase specified."
  echo "Please provide a phase between 2 to 3 (both included)."
  exit 1
fi

if [[ $1 < 2 ]] || [[ $1 > 3 ]]; then
  echo "Please provide a phase between 2 to 3 (both included)."
  exit 1
fi

# Create phase directory if it doesn't exist.
mkdir -p ${BASH_SOURCE%/*}/templates/phase$1

for path in ${BASH_SOURCE%/*}/templates/phase1/*; do
  [[ -d "${path}" ]] || continue # skip if not a directory
  dirname="$(basename "${path}")"

  # Copy directory to new phase.
  cp -r ${BASH_SOURCE%/*}/templates/phase1/$dirname ${BASH_SOURCE%/*}/templates/phase$1

  # Rename files with phase suffix. This is required as build.sh checks for duplicate file names.
  for file in ${BASH_SOURCE%/*}/templates/phase$1/$dirname/*; do
    filename=$(basename -- "$file")
    extension="${filename##*.}"
    filename="${filename%.*}"
    mv $file ${BASH_SOURCE%/*}/templates/phase$1/$dirname/$filename-phase$1.$extension
  done
done