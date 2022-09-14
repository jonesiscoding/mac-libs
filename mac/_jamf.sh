#!/bin/bash

# Prevent being sourced more than once
[ "${BASH_SOURCE[0]}" != "$0" ] && [ -n "$sourced_lib_mac_jamf" ] && return 0

# shellcheck source=../io/_output.sh
source "$libsMacSourcePath/io/_output.sh"

function jamf::getServer() {
  /usr/bin/defaults read /Library/Preferences/com.jamfsoftware.jamf.plist jss_url
}

function jamf::getApiToken() {
  local jamfServer jamfAcct jamfPass jamfToken major

  jamfServer=$(jamf::getServer)
  jamfAcct="$_libsMacJamf_Acct"

  # security add-generic-password -a "updater" -s "MDM API" -w "<password>" -T /usr/bin/security /Library/Keychains/System.keychain
  jamfPass=$(/usr/bin/security find-generic-password -w -a "$jamfAcct" -s "MDM API" /Library/Keychains/System.keychain 2> /dev/null)
  jamfToken=""

  if [ -n "$jamfPass" ]; then
    major=$(/usr/bin/sw_vers -productVersion | /usr/bin/cut -d '.' -f 1)
    if [ "$major" -lt "12" ]; then
      jamfToken=$(curl -X POST -u "$jamfAcct:$jamfPass" -s "${jamfServer}api/v1/auth/token" | /usr/bin/python -c 'import sys, json; print json.load(sys.stdin)["token"]')
    else
      jamfToken=$(curl -X POST -u "$jamfAcct:$jamfPass" -s "${jamfServer}api/v1/auth/token" | /usr/bin/plutil -extract token raw -)
    fi
  fi

  echo "$jamfToken"
}

function jamf::checkApiToken() {
  local jamfServer jamfToken jamfId

  jamfId=$1
  jamfServer=$(jamf::getServer)
  jamfToken=$(jamf::getApiToken)

  [ -z "$jamfServer" ] && output::errorln "  ERROR: Could not locate Jamf Pro Server!" && return 1
  [ -z "$jamfId" ] && output::errorln "  ERROR: No Jamf System ID given!" && return 1
  [ -z "$jamfToken" ] && output::errorln "ERROR: Could not generate Jamf API Token!" && return 1

  result=$(curl --header "Authorization: Bearer ${jamfToken}" --write-out "%{http_code}" --silent --output /dev/null --request GET --url "${jamfServer}api/v1/auth")


  if [ "$result" -eq "200" ] ; then
    return 0
  else
    if jamf::getApiToken; then
      return 0
    else
      return 1
    fi
  fi
}

function jamf::downloadUpdates() {
    local jamfServer jamfUrl jamfToken jamfId jamfJson

    jamfId=$1
    jamfServer=$(jamf::getServer)
    jamfToken=$(jamf::getApiToken)

    [ -z "$jamfServer" ] && output::errorln "  ERROR: Could not locate Jamf Pro Server!" && return 1
    [ -z "$jamfId" ] && output::errorln "  ERROR: No Jamf System ID given!" && return 1
    [ -z "$jamfToken" ] && output::errorln "ERROR: Could not generate Jamf API Token!" && return 1

  	jamfUrl="${jamfServer}api/v1/macos-managed-software-updates/send-updates"
		jamfJson='{ "deviceIds": ["'${jamfId}'"], "skipVersionVerification": false, "applyMajorUpdate": false, "updateAction": "DOWNLOAD_ONLY" }'
    result=$(/usr/bin/curl --header "Authorization: Bearer ${jamfToken}" --header "Content-Type: application/json" --write-out "%{http_code}" --silent --output /dev/null --request POST --url "${jamfUrl}" --data "${jamfJson}")

    if [ "$result" -eq "200" ] || [ "$result" -eq "201" ]; then
      return 0
    else
      return 1
    fi
}

function jamf::installUpdates() {
    local jamfServer jamfUrl jamfToken jamfId jamfJson

    jamfId=$1
    jamfServer=$(jamf::getServer)
    jamfToken=$(jamf::getApiToken)

    [ -z "$jamfServer" ] && output::errorln "  ERROR: Could not locate Jamf Pro Server!" && return 1
    [ -z "$jamfId" ] && output::errorln "  ERROR: No Jamf System ID given!" && return 1
    [ -z "$jamfToken" ] && output::errorln "ERROR: Could not generate Jamf API Token!" && return 1

  	jamfUrl="${jamfServer}api/v1/macos-managed-software-updates/send-updates"
		jamfJson='{ "deviceIds": ["'${jamfId}'"], "skipVersionVerification": false, "applyMajorUpdate": false, "updateAction": "DOWNLOAD_AND_INSTALL", "forceRestart": true }'
    result=$(/usr/bin/curl --header "Authorization: Bearer ${jamfToken}" --header "Content-Type: application/json" --write-out "%{http_code}" --silent --output /dev/null --request POST --url "${jamfUrl}" --data "${jamfJson}")

    if [ "$result" -eq "200" ] || [ "$result" -eq "201" ]; then
      return 0
    else
      return 1
    fi
}

function jamf::ask() {
  local heading title question buttonYes buttonNo icon

  title="$1"
  heading="$2"
  question="$3"
  buttonYes="${4:-Yes}"
  buttonNo="${5:-No}"
  icon="${6:-/Applications/Self Service.app/Contents/Resources/AppIcon.icns}"

  if [ ! -f "$_libsMacJamf_Helper" ]; then
    # Show error message in logs
    output::errorln "ERROR: Jamf Helper Not Found!"
  fi

  if "$_libsMacJamf_Helper" -windowType hud -lockHUD -title "$title" -heading "$heading" -description "$question" -icon "$icon" -button1 "$buttonYes" -button2 "$buttonNo" -defaultButton "0" -cancelButton "2"; then
    return 0
  else
    return $?
  fi
}

function jamf::assert() {
  local heading title message icon

  title="$1"
  heading="$2"
  message="$3"
  icon="${4:-/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertStopIcon.icns}"
  [ ! -f "$icon" ] && icon="$_libsMacJamf_IconDefault"

  if [ ! -f "$_libsMacJamf_Helper" ]; then
    # Show error message in logs
    echo "ERROR: Jamf Helper Not Found"
    return 1
  fi

  "$_libsMacJamf_Helper" -windowType hud -lockHUD -title "$title" -heading "$heading" -description "$message" -icon "$icon" &
}

function jamf::countdown() {
  local heading title message icon timeout

  title="$1"
  heading="$2"
  message="$3"
  icon="${4:-/Applications/Self Service.app/Contents/Resources/AppIcon.icns}"
  timeout="${5:-300}"
  [ ! -f "$icon" ] && icon="$_libsMacJamf_IconDefault"

  if [ ! -f "$_libsMacJamf_Helper" ]; then
    # Show error message in logs
    echo "ERROR: Jamf Helper Not Found"
    return 1
  fi

  "$_libsMacJamf_Helper" -windowType hud -lockHUD -title "$title" -heading "$heading" -description "$message" -icon "$icon" -timeout "$timeout" -countdown &
}

function jamf::notify() {
  local heading title message icon

  title="$1"
  heading="$2"
  message="$3"
  icon="${4:-/Applications/Self Service.app/Contents/Resources/AppIcon.icns}"
  [ ! -f "$icon" ] && icon="$_libsMacJamf_IconDefault"

  if [ ! -f "$_libsMacJamf_Helper" ]; then
    # Show error message in logs
    echo "ERROR: Jamf Helper Not Found"
    return 1
  fi

  "$_libsMacJamf_Helper" -windowType hud -title "$title" -heading "$heading" -description "$message" -icon "$icon" &
}

function jamf::alert() {
  local msg

  msg="$1"

  # Show error message in logs
  if [ ! -f "$_libsMacJamf_Bin" ]; then
    echo "ERROR: Jamf Helper Not Found - Could Not Show Alert"
  fi

  "$_libsMacJamf_Bin" displayMessage -message "$msg" &

  return 0
}

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

if [ -z "$sourced_lib_mac_jamf" ]; then
  # shellcheck disable=SC2034
  sourced_lib_mac_jamf=0

  # Paths to Binaries
  _libsMacJamf_Helper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
  _libsMacJamf_Bin="/usr/local/bin/jamf"

  # Paths to Icons
  # shellcheck disable=SC2034
  _libsMacJamf_IconAlert="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertStopIcon.icns"
  _libsMacJamf_IconDefault="/Applications/Self Service.app/Contents/Resources/AppIcon.icns"

  # Jamf API Account Username
  if [ -n "$libsMacUpdatesPlist" ] && [ -f "$libsMacUpdatesPlist" ]; then
    _libsMacJamf_Acct=$(/usr/bin/defaults read "$libsMacUpdatesPlist" "jamfUser" 2>/dev/null)
  fi
fi

