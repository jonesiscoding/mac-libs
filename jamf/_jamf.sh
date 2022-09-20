#!/bin/bash

# Prevent being sourced more than once
[ "${BASH_SOURCE[0]}" != "$0" ] && [ -n "$sourced_lib_jamf" ] && return 0

# /*!
#   Public: Trigger the installation of an app that is not currently installed using
#   a self-service policy.
#
#   $1  The path to the application bundle
#   $2  The Policy ID
# */
function jamf::selfService() {
  local policyId
  local appPath

  appPath="$1"
  policyId="$2"
  if [ ! -d "$appPath" ]; then
    output::notify "Installing $appPath"
    if open "jamfselfservice://content?entity=policy&id=$policyId&action=execute"; then
      output::successbg "DONE"
      return 0
    else
      output::errorbg "ERROR"
      return 1
    fi
  fi

  return 0
}

if [ -z "$sourced_lib_jamf" ]; then
  # shellcheck disable=SC2034
  sourced_lib_jamf_update=0
fi