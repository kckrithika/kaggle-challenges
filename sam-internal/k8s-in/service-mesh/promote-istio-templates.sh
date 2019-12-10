#!/usr/bin/env bash

if [[ $# != 2 ]]; then
  echo "Proper phases not specified"
  echo "Please provide a 'from' phase and a 'to' phase"
  echo ""
  echo "Example:"
  echo "./promote-istio-templates.sh 1 2"
  echo "Promotes istio templates from phase 1 to phase 2"
  echo ""
  echo "Valid phases are between 1 to 5 (both included)"
  exit 1
fi

if [[ $1 < 1 ]] || [[ $1 > 5 ]] || [[ $2 < 1 ]] || [[ $2 > 5 ]]; then
  echo "Invalid phases specified"
  echo "Valid phases are between 1 to 5 (both included)"
  exit 1
fi

if (( $1 >= $2)); then
  echo "Invalid phases specified"
  echo "The 'from' phase has to be less than the 'to' phase"
  exit 1
fi

# Format phase1 jsonnets before copying.
${BASH_SOURCE%/*}/format-istio-jsonnets.sh

# Create phase directory if it doesn't exist.
mkdir -p ${BASH_SOURCE%/*}/templates/istio/phase$2

# Clear contents of the new phase directory.
rm -rf ${BASH_SOURCE%/*}/templates/istio/phase$2/*

for path in ${BASH_SOURCE%/*}/templates/istio/phase$1/*; do
  [[ -d "${path}" ]] || continue # skip if not a directory

  dirname="$(basename "${path}")"

  # Skip istio-ingressgateway & casam if not PRD.
  if [[ $2 > 2 ]] && ([[ $dirname == "istio-ingressgateway-autogenerated" ]] || [[ $dirname == "casam" ]]); then
    continue
  fi

  # Copy directory to new phase.
  cp -r ${BASH_SOURCE%/*}/templates/istio/phase$1/$dirname ${BASH_SOURCE%/*}/templates/istio/phase$2

  # Rename files with phase suffix. This is required as build.sh checks for duplicate file names.
  for file in ${BASH_SOURCE%/*}/templates/istio/phase$2/$dirname/*; do
    # Template phase string to replace.
    currentPhase="if (istioPhases.phaseNum == $1) then"
    nextPhase="if (istioPhases.phaseNum == $2) then"

    # Replace the phase string.
    sed -i'.bak' -e "s/$currentPhase/$nextPhase/g" "$file"
    if [[ $? -eq 0 ]]; then
      rm "$file.bak"
    fi

    # Replace phase name in file name if it exists.
    newFilename=${file/phase$1/phase$2}

    # If copying from phase 1, add suffix.
    if (( $1 == 1)); then
      # Add suffix for the phase file to avoid "Duplicate field" error in multifile-temp stage when running build.sh.
      filename=$(basename -- "$file")
      extension="${filename##*.}"
      filename="${filename%.*}"
      newFilename=${BASH_SOURCE%/*}/templates/istio/phase$2/$dirname/$filename-phase$2.$extension
    fi
    mv $file $newFilename
  done
done