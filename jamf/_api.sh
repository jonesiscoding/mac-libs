#!/bin/bash

# Prevent being sourced more than once
[ "${BASH_SOURCE[0]}" != "$0" ] && [ -n "$sourced_lib_jamf_api" ] && return 0

# /*!
#   Internal: Makes a call to the given Jamf API endpoint using the given token.
#
#   $1  The full Jamf API endpoint complete with leading slash
#   $2  The Jamf API token
#   $3  The number of minutes to cache API data; defaults to 15
# */
function _jamfApiGet() {
  local jamfEndpoint jamfServer jamfToken jamfUrl workDir workFile workName result jamfCache

  jamfEndpoint="$1"
  jamfToken="$2"
  jamfServer=$(jamf::api::getServer)
  jamfCache="${3:-15}"

  [ -z "$jamfServer" ] && output::errorln "  ERROR: Could not locate Jamf Pro Server!" && return 1
  [ -z "$jamfEndpoint" ] && output::errorln "  ERROR: No Jamf Endpoint given!" && return 1
  [ -z "$jamfToken" ] && output::errorln "ERROR: Could not generate Jamf API Token!" && return 1

  jamfUrl="${jamfServer}${jamfEndpoint}"

  workFile="$_libsMacMdm_UserWorkDir/JamfAPI$jamfEndpoint"
  workDir=$(/usr/bin/dirname "$workFile")
  workName=$(/usr/bin/basename "$workFile")
  [ ! -d "$workDir" ] && /bin/mkdir -p "$workDir"

  if [ "$jamfCache" -gt "0" ]; then
    cd "$workDir" || return 1
    /usr/bin/find . -type f -name "$workName" -mmin +"$jamfCache" -delete
  else
    rm "$workFile"
  fi

  if [ -f "$workFile" ]; then
    cat "$workFile" && return 0
  else
    result=$(/usr/bin/curl --request GET --header "Authorization: Bearer ${jamfToken}" --silent --write-out "%{http_code}" -z "${workFile}" --header "Content-Type: application/json" --output "${workFile}" --url "${jamfUrl}")
    if [ "$result" -eq "304" ] || [ "$result" -eq "200" ]; then
      cat "$workFile"
      return 0
    else
      return 1
    fi
  fi
}

# /*!
#   Public: Retrieves the URL to the Mac's Jamf Server
# */
function jamf::api::getServer() {
  /usr/bin/defaults read /Library/Preferences/com.jamfsoftware.jamf.plist jss_url
}

# /*!
#   Public: Retrieves the JSON for a Jamf Computer Record via the given ID or computer name.
#
#   $1  A numeric ID or computer name
# */
function jamf::api::computer() {
  local computer in

  in="$1"
  if [[ $in =~ ^-?[0-9]+$ ]]; then
    if computer=$(jamf::api::computer::byId "$in"); then
      echo "$computer" && return 0
    fi
  else
    if computer=$(jamf::api::computer::byName "$in"); then
      echo "$computer" && return 0
    fi
  fi

  return 1
}

# /*!
#   Public: Retrieves the JSON for a Jamf Computer Record via the given ID.
#
#   $1  A numeric ID
# */
function jamf::api::computer::byId() {
  local jamfToken jamfId jamfEndpoint

  jamfId=$1
  jamfToken=$(jamf::api::getToken "$_libsMacMdm_User")
  jamfEndpoint="/api/v1/computers-inventory-detail/$jamfId"

  [ -z "$jamfId" ] && output::errorln "  ERROR: No Jamf System ID given!" && return 1
  [ -z "$jamfToken" ] && output::errorln "ERROR: Could not generate Jamf API Token!" && return 1

  if _jamfApiGet "$jamfEndpoint" "$jamfToken"; then
    return 0
  else
    return 1
  fi
}

# /*!
#   Public: Retrieves the JSON for a Jamf Computer Record via the given computer name.
#
#   $1  A computer name
# */
function jamf::api::computer::byName() {
  local name computers count in

  in="$1"
  if computers=$(jamf::api::computers); then
    count=$(echo "$computers" | jq -r .totalCount)
    for ((i=0;i<=((count-1));i++));
    do
      name=$(echo "$computers" | jq -r .results["$i"].general.name)
      if [ "$name" == "$in" ]; then
        if echo "$computers" | jq -r .results["$i"]; then
          return 0
        else
          return 1
        fi
      fi
    done
  fi

  return 1
}

# /*!
#   Public: Retrieves the last reported IP for a computer
#
#   $1  A numeric ID or computer name
# */
function jamf::api::computer::ip() {
  local computer in ip

  in="$1"

  if computer=$(jamf::api::computer "$in"); then
    if ip=$(echo "$computer" | jq -r .general.lastReportedIp); then
      if [ -n "$ip" ] && [ "$ip" != "null" ]; then
        echo "$ip" && return 0
      fi
    fi
  fi

  return 1
}

# /*!
#   Public: Retrieves the last known VPN IP address for a computer, using the Extension Attribute name
#   configured in your managed preferences.
#
#   $1  A numeric ID or computer name
# */
function jamf::api::computer::vpn() {
  local computer in vpn

  in="$1"
  if computer=$(jamf::api::computer "$in"); then
    if vpn=$(echo "$computer" | jq -r --arg VPNEA "${_libsMacMdm_EaVpn}" '.general.extensionAttributes | map(select(.name == "$VPNEA"))' | jq -r '.[].values[0]' ); then
      if [ -n "$vpn" ] && [ "$vpn" != "None" ] && [ "$vpn" != "null" ]; then
        echo "$vpn" && return 0
      fi
    fi
  fi

  return 1
}

# /*!
#   Public: Retrieves the JSON for all the computers listed in your Jamf instance
# */
function jamf::api::computers() {
  local jamfEndpoint jamfToken

  jamfToken=$(jamf::api::getToken "$_libsMacMdm_User")
  jamfEndpoint="/api/v1/computers-inventory"

  [ -z "$jamfToken" ] && output::errorln "ERROR: Could not generate Jamf API Token!" && return 1

  if _jamfApiGet "$jamfEndpoint" "$jamfToken"; then
    return 0
  else
    return 1
  fi
}

# /*!
#   Public: Retrieves a token for the Jamf API using the given user and a password retrieved from
#   the user's keychain.
#
#   $1  The username
# */
function jamf::api::getToken() {
  local jamfServer jamfAcct jamfPass jamfToken major

  jamfAcct="$1"
  jamfServer=$(jamf::api::getServer)
  jamfPass=$(/usr/bin/security find-generic-password -w -a "$jamfAcct" -s "MDM API" 2> /dev/null)
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
#
#   $1  The username
# */
function jamf::api::checkToken() {
  local jamfUser jamfServer jamfToken result

  jamfUser=$1
  jamfServer=$(jamf::api::getServer)
  jamfToken=$(jamf::api::getToken "$jamfUser")

  [ -z "$jamfServer" ] && output::errorln "  ERROR: Could not locate Jamf Pro Server!" && return 1
  [ -z "$jamfUser" ] && output::errorln "  ERROR: No Jamf System User given!" && return 1
  [ -z "$jamfToken" ] && output::errorln "ERROR: Could not generate Jamf API Token!" && return 1

  result=$(curl --header "Authorization: Bearer ${jamfToken}" --write-out "%{http_code}" --silent --output /dev/null --request GET --url "${jamfServer}api/v1/auth")

  if [ "$result" -eq "200" ] ; then
    return 0
  else
    if jamf::api::getToken "$jamfUser"; then
      return 0
    else
      return 1
    fi
  fi
}

if [ -z "$sourced_lib_jamf_api" ]; then
  # shellcheck disable=SC2034
  sourced_lib_jamf_api=0

  # Global Variables
  [ -z "$libsMacBundlePrefix" ] && libsMacBundlePrefix="org.organization"

  # Internal Variables
  _libsMacMdm_Domain="$libsMacBundlePrefix.softwareupdate"
  _libsMacMdm_User="$USER"
  _libsMacMdm_UserWorkDir="/Users/$_libsMacMdm_User/Library/Application Support/MDM"

  # Internal Variables set from Managed Preferences
  _libsMacMdm_Plist="/Library/Managed Preferences/${_libsMacMdm_Domain}.plist"

  # Managed Preferences
  if [ -f "$_libsMacMdm_Plist" ]; then
    _libsMacMdm_Override=$(/usr/bin/defaults read "$_libsMacMdm_Plist" allowOverride 2>/dev/null || echo "0")
    _libsMacMdm_WorkDir=$(/usr/bin/defaults read "$_libsMacMdm_Plist" workPath 2>/dev/null || echo "/Library/Application\ Support/MDM")
    _libsMacMdm_EaVpn=$(/usr/bin/defaults read "$_libsMacMdm_Plist" vpnExtensionAttribute 2>/dev/null || echo "Last VPN IP Address")
  else
    echo "ERROR: Managed preferences ${_libsMacMdm_Domain} are not available.  Please contact an IS staff member."
    exit 1
  fi

  # Handle Overrides via User Preferences or Variables
  if [ "$_libsMacMdm_Override" -eq "1" ]; then
    _libsMacMdm_LocalPlist="/Users/$_libsMacMdm_User/Library/Preferences/${_libsMacMdm_Domain}.plist"
    if [ -f "$_libsMacMdm_LocalPlist" ]; then
      _libsMacMdm_WorkDir=$(/usr/bin/defaults read "$_libsMacMdm_Plist" workPath 2>/dev/null || echo "/Library/Application\ Support/MDM")
      _libsMacMdm_EaVpn=$(/usr/bin/defaults read "$_libsMacMdm_Plist" vpnExtensionAttribute 2>/dev/null || echo "Last VPN IP Address")
    fi

    [ -n "$libsMacMdmWorkDir" ] && _libsMacMdm_WorkDir="$libsMacMdmWorkDir"
    [ -n "$libsMacMdmEaVpn" ] && _libsMacMdm_EaVpn="$libsMacMdmEaVpn"
  fi
fi