#!/bin/bash

# This should always change at the same time as tnrp/pipeline_manifest.json and use the same sha1

# Changing hypersam can impact apps in every kingdom at the same time, so extreme care must be taken when updating the image+rpm to make sure the output is the same as before.
# Follow instructions here for validating the new SMB: https://git.soma.salesforce.com/sam/sam/wiki/Update-SAM-Manifest-Builder#verify-the-new-smb-changes-produce-good-output
# PR Reviewer: Ensure that PR comments include the results of the above check (image_promotion, control_estate, manifest diffs)
HYPERSAM=ops0-artifactrepo1-0-prd.data.sfdc.net/dva/sam/hypersam:2812-38944eb3a2b2445a5e9f6a76d927cad3eaacfc17
