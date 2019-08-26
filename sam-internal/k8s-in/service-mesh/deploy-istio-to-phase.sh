#!/usr/bin/env bash

if [[ $# -eq 0 ]]; then
  echo "No phase specified."
  echo "Please provide a phase between 2 to 5 (both included)."
  exit 1
fi

if [[ $1 < 2 ]] || [[ $1 > 5 ]]; then
  echo "Please provide a phase between 2 to 5 (both included)."
  exit 1
fi

# Format phase1 jsonnets before copying.
${BASH_SOURCE%/*}/format-istio-jsonnets.sh

# Create phase directory if it doesn't exist.
mkdir -p ${BASH_SOURCE%/*}/templates/phase$1

# Clear contents of the new phase directory.
rm -rf ${BASH_SOURCE%/*}/templates/phase$1/*

for path in ${BASH_SOURCE%/*}/templates/phase1/*; do
  [[ -d "${path}" ]] || continue # skip if not a directory
  dirname="$(basename "${path}")"

  # Copy directory to new phase.
  cp -r ${BASH_SOURCE%/*}/templates/phase1/$dirname ${BASH_SOURCE%/*}/templates/phase$1

  # Rename files with phase suffix. This is required as build.sh checks for duplicate file names.
  for file in ${BASH_SOURCE%/*}/templates/phase$1/$dirname/*; do
    # Replace phase1 with the intended phase.
    sed -i'.bak' -e "s/is_phase1/is_phase$1/g" "$file"
    if [[ $? -eq 0 ]]; then
      rm "$file.bak"
    fi

    # Add suffix for the phase file to avoid "Duplicate field" error in multifile-temp stage when running build.sh.
    filename=$(basename -- "$file")
    extension="${filename##*.}"
    filename="${filename%.*}"
    mv $file ${BASH_SOURCE%/*}/templates/phase$1/$dirname/$filename-phase$1.$extension
  done
done