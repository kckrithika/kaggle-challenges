#/bin/bash -xe

# This is a placeholder script when we dont want to use this feature.
# Never add commands to this file.  When you want to use this feature, add a new script side-by-side, and tweak ops-adhoc-configmap.jsonnet in templates
# This is a very dangerous feature.  NEVER use this without explicit approval from the active Ops and one lead.
echo NOP adhoc script

# Keep this running so we dont create a crash loop backoff
while true; do sleep 10000; done
