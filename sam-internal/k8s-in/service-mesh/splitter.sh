#!/usr/bin/env bash

istio_objects=(
  "CustomResourceDefinition"
  "ServiceAccount"
  "ClusterRole"
  "ClusterRoleBinding"
  "ConfigMap"
  "Service"
  "Deployment"
  "HorizontalPodAutoscaler",
  "MutatingWebhookConfiguration"
  "Gateway"
)

csplit -f tmpistio -ks ./ship-istio/rendered.yaml "/---/+1" "{$(wc -l < ./ship-istio/rendered.yaml)}"

out_dir="./ship-istio-out/"

rm ./ship-istio-out/*

for kind in "${istio_objects[@]}"; do
  obj_files=( $(grep -l "kind: $kind" ./tmpistio* ) )

  # Find 1st 'name' attribute in the file.
  # Use it to form the target file name.
  for file in "${obj_files[@]}"; do
    case "$kind" in
      "ConfigMap")
        obj_name=$(grep -h "name:" "$file" | tail -1 | cut -d":" -f 2 | tr -d '[:space:]')
        ;;
      *)
        obj_name=$(grep -m 1 -h "name:" "$file" | cut -d":" -f 2 | tr -d '[:space:]')
        ;;
    esac

    case "$kind" in
      "CustomResourceDefinition")
        target_file_name="istio-crd-$(echo "$obj_name" | cut -d"." -f 1).yaml"
        ;;
      *)
        target_file_name="$(echo "$obj_name")-$(echo $kind | sed -e 's/\([A-Z]\)/-\1/g' -e 's/^-//' | tr '[:upper:]' '[:lower:]').yaml"
        ;;
    esac

    echo "Moving $obj_name of kind $kind in $file to $out_dir$target_file_name"
    mv "$file" "$out_dir$target_file_name"

  done

done

#rm ./tmpistio*