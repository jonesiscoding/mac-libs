#!/bin/bash

# Prevent being sourced more than once
[ "${BASH_SOURCE[0]}" != "$0" ] && [ -n "$sourced_lib_jamf_updates" ] && return 0

# shellcheck source=../output/output.sh
source "$libsMacSourcePath/output/output.sh"

# /*!
#   Public: Retrieves the URL to the Mac's Jamf Server
# */
function jamf::updates::server() {
  /usr/bin/defaults read /Library/Preferences/com.jamfsoftware.jamf.plist jss_url
}

# /*!
#   Public: Retrieves this computer's ID in Jamf
# */
function jamf::updates::id() {
  echo "$_libsMacJamf_SystemId"
}

# /*!
#   Public: Evaluates whether this system is configured to send updates via Jamf
# */
# shellcheck disable=SC2034
function jamf::updates::isConfigured() {
  local jamfPass bsToken

  [ -z "$(jamf::updates::server)" ] && updateBlock="No Jamf Pro Server Found" && return 1
  [ -z "$(jamf::updates::id)" ] && updateBlock="No Jamf Pro System ID configured." && return 1
  [ -z "$_libsMacJamf_UpdateUser" ] && updateBlock="No Jamf Pro API User configured." && return 1

  # Check on Password
  jamfPass=$(/usr/bin/security find-generic-password -w -a "$_libsMacJamf_UpdateUser" -s "MDM API" /Library/Keychains/System.keychain 2> /dev/null)
  [ -z "$jamfPass" ] && updateBlock="No Password Saved in System Keychain for Jamf Pro API User" && return 1

  # Bootstrap Token
  bsToken=$(/usr/bin/sudo /usr/bin/profiles status -type bootstraptoken 2>&1)
  if echo "$bsToken" | /usr/bin/grep -q "Error:" || echo "$bsToken" | /usr/bin/grep -q "NO" || ! echo "$bsToken" | /usr/bin/grep -q "YES"; then
    updateBlock="No Bootstrap Token Escrowed in Jamf" && return 1
  fi

  return 0
}


# /*!
#   Public: Retrieves a token for the Jamf API using the update user, and a password retrieved from
#   the system keychain.
# */
function jamf::updates::token::get() {
  local jamfServer jamfAcct jamfPass jamfToken major

  jamfServer=$(jamf::updates::server)
  jamfAcct="$_libsMacJamf_UpdateUser"
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

# /*!
#   Public: Verifies that the API token is valid
# */
function jamf::updates::token::check() {
  local jamfServer jamfToken jamfId

  jamfId=$1
  jamfServer=$(jamf::updates::server)
  jamfToken=$(jamf::updates::token::get)

  [ -z "$jamfServer" ] && output::errorln "  ERROR: Could not locate Jamf Pro Server!" && return 1
  [ -z "$jamfId" ] && output::errorln "  ERROR: No Jamf System ID given!" && return 1
  [ -z "$jamfToken" ] && output::errorln "ERROR: Could not generate Jamf API Token!" && return 1

  result=$(curl --header "Authorization: Bearer ${jamfToken}" --write-out "%{http_code}" --silent --output /dev/null --request GET --url "${jamfServer}api/v1/auth")


  if [ "$result" -eq "200" ] ; then
    return 0
  else
    if jamf::updates::token::get; then
      return 0
    else
      return 1
    fi
  fi
}

# /*!
#   Public: Uses the Jamf Pro API to download updates to the given computer.
#
#   $1  A numeric ID
# */
function jamf::updates::download() {
    local jamfServer jamfUrl jamfToken jamfId jamfJson

    jamfId=$1
    jamfServer=$(jamf::updates::server)
    jamfToken=$(jamf::updates::token::get)

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

# /*!
#   Public: Uses the Jamf Pro API to install updates to the given computer.
#
#   $1  A numeric ID
# */
function jamf::updates::install() {
    local jamfServer jamfUrl jamfToken jamfId jamfJson

    jamfId=$1
    jamfServer=$(jamf::updates::server)
    jamfToken=$(jamf::updates::token::get)

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

if [ -z "$sourced_lib_jamf_updates" ]; then
  # shellcheck disable=SC2034
  sourced_lib_jamf_updates=0

  # Global Variables
  [ -z "$libsMacBundlePrefix" ] && libsMacBundlePrefix="org.organization"

  # Internal Variables
  _libsMacMdm_Domain="$libsMacBundlePrefix.softwareupdate"
  _libsMacMdm_Plist="/Library/Managed Preferences/${_libsMacMdm_Domain}.plist"

  if [ -n "$_libsMacMdm_Plist" ] && [ -f "$_libsMacMdm_Plist" ]; then
    # Are Overrides Allowed?
    _libsMacMdm_Override=$(/usr/bin/defaults read "$_libsMacMdm_Plist" allowOverride 2>/dev/null || echo "0")
    # Jamf API Account Username
    _libsMacJamf_UpdateUser=$(/usr/bin/defaults read "$_libsMacMdm_Plist" "jamfUser" 2>/dev/null)
    # Jamf API System ID
    _libsMacJamf_SystemId=$(/usr/bin/defaults read "$_libsMacMdm_Plist" "jamfId" 2>/dev/null)
    # Work Directory
    _libsMacMdm_WorkDir=$(/usr/bin/defaults read "$_libsMacMdm_Plist" workPath 2>/dev/null || echo "/Library/Application\ Support/MDM")
  else
    echo "ERROR: Managed preferences ${_libsMacMdm_Domain} are not available.  Please contact an IS staff member."
    exit 1
  fi

  # Allow Overrides
  if [ "$_libsMacMdm_Override" -eq "1" ]; then
    [ -n "$libsMacMdmWorkDir" ] && _libsMacMdm_WorkDir="$libsMacMdmWorkDir"
  fi
fi

