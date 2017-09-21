#!/bin/bash

# This should always change at the same time as tnrp/pipeline_manifest.json and use the same sha1
# Follow instructions here for validating the new SMB: https://git.soma.salesforce.com/sam/sam/wiki/Update-SAM-Manifest-Builder#verify-the-new-smb-changes-produce-good-output
# PR Reviewer: Ensure that PR comments include the results of the above check (image_promotion, control_estate, manifest diffs)
HYPERSAM=ops0-artifactrepo1-0-prd.data.sfdc.net/tnrp/sam/hypersam:sam-0001268-104afce3
