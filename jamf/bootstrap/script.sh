#!/bin/bash

function jamf::isJamfRun() {
  local cName firstCharFirstArg
  cName=$(/usr/sbin/scutil --get ComputerName)
  firstCharFirstArg=$(/usr/bin/printf '%s' "$1" | /usr/bin/cut -c 1)
  if [ "$firstCharFirstArg" == "/" ] && [ "$2" == "$cName" ]; then
    return 0
  else
    return 1
  fi
}

if jamf::isJamfScript "$@"; then
  # shellcheck disable=SC2034
  jamfMountPoint="$1"
  # shellcheck disable=SC2034
  jamfHostName="$2"
  # shellcheck disable=SC2034
  jamfUser="$3"
  # shellcheck disable=SC2034
  libsMacUser="$jamfUser"
  # Remove Jamf Arguments
  shift 3
  # Blank first Output Line for Prettier Jamf Logs
  echo ""
fi