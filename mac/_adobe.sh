#!/bin/bash

# /*
#   Module:
#     Contains functions to allow for retrieval of information about installed Adobe products, as well as
#     the removal of Adobe products.
#
#   Example:
#     source "<path-to-mac-libs>/mac/_adobe.sh"
#
#     See functions for additional examples
#
#   Copyright:
#     © 2022/09 AMJones <am@jonesiscoding.com>
#   License:
#     For the full copyright and license information, please view the LICENSE
#     file that was distributed with this source code.
# */

# Prevent being sourced more than once
[ "${BASH_SOURCE[0]}" != "$0" ] && [ -n "$sourced_lib_mac_adobe" ] && return 0

# /*!
#   Private: Retrieves the ADB ARG file for the given product name and version.
#
#   Example:
#     adbArg=$(_getAdbArgFile photoshop 23.5)
#
#   $1 Adobe Product Name
#   $2 Adobe Product Version
# */
function _getAdbArgFile() {
  local files file productVersion name version

  cd "/Library/Application Support/Adobe/Uninstall" || return 1

  name="$1"
  version="$2"
  files=$(/usr/bin/grep -l "$name")

  while IFS= read -r file; do
    if [ -n "$file" ]; then
      productVersion=$(_getDataFromAdbArg "$file" "productVersion")
      if [ "$productVersion" == "$version" ]; then
        echo "$file" && exit 0
      fi
    fi
  done <<< "$files"

  exit 1
}

# /*!
#   Private: Retrieves a specific piece of data from the given ADB ARG file.
#
#   Example:
#     platform=$(_getDataFromAdbArg "$filePath" "productPlatform")
#
#   $1 Absolute Path to ADB ARG file
#   $2 The key name to retrieve
# */
function _getDataFromAdbArg() {
  local aaFile key

  aaFile="$1"
  key="$2"

  # shellcheck disable=SC2002
  /bin/cat "$aaFile" | /usr/bin/grep "$key" | /usr/bin/cut -d'=' -f2
}

# /*!
#   Private: Retrieves a value from the app bundle's Info.plist.
#
#   Example:
#     version=$(_getAdobePlistValue "$appBundlePath" CFBundleShortVersionString)
#
#   $1 Absolute path to the Adobe .app Bundle
#   $2 The key to retrieve
# */
function _getAdobePlistValue() {
  local app key plist value

  app="$1"
  key="$2"
  plist="$app/Contents/Info.plist"
  if [ -n "$plist" ]; then
    value=$(/usr/bin/defaults read "$plist" "$key" 2> /dev/null)
  fi

  echo "$value"
}

# /*!
#   Public: Retrieves the path to the given Adobe product name and year.
#
#   Example:
#     psPath=$(adobe::path Photoshop 2022)
#     dimPath=$(adobe::path Dimension)
#
#   $1 The name of the Adobe app to find.
#   $2 The optional year of the adobe app.  Some apps don't use years.
# */
function adobe::path() {
  local name year aDir

  name="$1"
  year="$2"

  if [ -n "$year" ]; then
    aDir="/Applications/Adobe $name $year/Adobe $name $year.app"
    [ -f "$aDir/Contents/Info.plist" ] && echo "$aDir" && return 0

    aDir="/Applications/Adobe $name $year/Adobe $name.app"
    [ -f "$aDir/Contents/Info.plist" ] && echo "$aDir" && return 0

    aDir="/Applications/Adobe $name CC $year/Adobe $name CC $year.app"
    [ -f "$aDir/Contents/Info.plist" ] && echo "$aDir" && return 0

    aDir="/Applications/Adobe $name CC $year/Adobe $name.app"
    [ -f "$aDir/Contents/Info.plist" ] && echo "$aDir" && return 0
  fi

  aDir="/Applications/Adobe $name/Adobe $name.app"
  [ -f "$aDir/Contents/Info.plist" ] && echo "$aDir" && return 0

  aDir="/Applications/Adobe $name CC/Adobe $name.app"
  [ -f "$aDir/Contents/Info.plist" ] && echo "$aDir" && return 0

  return 1
}

# /*!
#   Public: Retrieves the platform for the given adobe app name and year.
#
#   Example:
#     platform=$(adobe::platform Photoshop 2022)
#     platform=$(adobe::platform Dimension)
#
#   $1 The name of the Adobe app
#   $2 The optional year of the adobe app.  Some apps don't use years.
# */
function adobe::platform() {
  local name year version adbarg platform

  name="$1"
  year="$2"

  version=$(adobe::path "$name" "$year")
  [ -z "$version" ] && return 1

  adbarg=$(_getAdbArgFile "$name" "$version")
  [ -z "$version" ] && return 1

  platform=$(_getDataFromAdbArg "$adbarg" "productPlatform")
  [ -z "$platform" ] && return 1

  echo "$platform" && return 0
}

# /*!
#   Public: Retrieves the SAP code for the given adobe app name and year.
#
#   Example:
#     sap=$(adobe::sap Photoshop 2022)
#     sap=$(adobe::sap Dimension)
#
#   $1 The name of the Adobe app
#   $2 The optional year of the adobe app.  Some apps don't use years.
# */
function adobe::sap() {
  local name year version adbarg sap

  name="$1"
  year="$2"

  version=$(adobe::path "$name" "$year")
  [ -z "$version" ] && return 1

  adbarg=$(_getAdbArgFile "$name" "$version")
  [ -z "$version" ] && return 1

  sap=$(_getDataFromAdbArg "$adbarg" "sapCode")
  [ -z "$sap" ] && return 1

  echo "$sap" && return 0
}

# /*!
#   Public: Uninstalls the Adobe app for the given name and year, optionally removing user preferences.
#
#   Example:
#     if adobe::uninstall Photoshop 2022 "true"; then
#       <success code here>
#     else
#       <failure code here>
#     fi
#
#   $1 The name of the Adobe app to uninstall.
#   $2 The optional year of the adobe app to uninstall.  Some apps don't use years.
#   $3 To remove user preferences, set this to "true"
# */
function adobe::uninstall() {
  local name year version adbarg sap platform prefs baseVersion

  name="$1"
  year="$2"
  prefs="${3:-false}"

  # Normalize Variable
  [ "$prefs" == "TRUE" ] && prefs="true"
  [ "$prefs" == "FALSE" ] && prefs="false"

  # Get Version from App
  version=$(adobe::version "$name" "$year")
  [ -z "$version" ] && return 1

  # Get Adbarg File
  adbarg=$(_getAdbArgFile "$name" "$version")
  [ -z "$version" ] && return 1

  # Get SapCode
  sap=$(_getDataFromAdbArg "$adbarg" "sapCode")
  [ -z "$sap" ] && return 1

  # Get Base Version
  baseVersion=$(_getDataFromAdbArg "$adbarg" "productVersion")
  [ -z "$baseVersion" ] && baseVersion="$version"

  # Get Platform
  platform=$(_getDataFromAdbArg "$adbarg" "productPlatform")
  [ -z "$productPlatform" ] && platform="osx10-64"

  # Perform the Uninstallation
  if /Library/Application\ Support/Adobe/Adobe\ Desktop\ Common/HDBox/Setup --uninstall=1 --sapCode="$sap" --baseVersion="$baseVersion" --deleteUserPreferences=false --platform="platform" > "$libsMacAdobeLog" 2>&1; then
    return 0
  else
    return 1
  fi
}

# /*!
#   Public: Retrieves the version for the given adobe app name and year.
#
#   Example:
#     version=$(adobe::version Photoshop 2022)
#     version=$(adobe::version Dimension)
#
#   $1 The name of the Adobe app.
#   $2 The optional year of the adobe app. Some apps don't use years.
# */
function adobe::version() {
  local name year aPath

  name="$1"
  year="$2"

  aPath=$(adobe::path "$name" "$year")
  if [ -n "$aPath" ]; then
    _getAdobePlistValue "$aPath" CFBundleShortVersionString
  fi
}

# /*!
#   Public: Retrieves the base version for the given adobe app name and year.
#
#   Example:
#     baseVersion=$(adobe::versionBase Photoshop 2022)
#     baseVersion=$(adobe::versionBase Dimension)
#
#   $1 The name of the Adobe app.
#   $2 The optional year of the adobe app.  Some apps don't use years.
# */
function adobe::versionBase() {
  local name year version adbarg baseVersion

  name="$1"
  year="$2"

  version=$(adobe::version "$name" "$year")
  [ -z "$version" ] && return 1

  adbarg=$(_getAdbArgFile "$name" "$version")
  [ -z "$version" ] && return 1

  baseVersion=$(_getDataFromAdbArg "$adbarg" "productVersion")
  [ -z "$baseVersion" ] && return 1

  echo "$baseVersion" && return 0
}

# /*!
#   Public: Retrieves the major version for the given adobe app name and year.
#
#   Example:
#     major=$(adobe::versionMajor Photoshop 2022)
#     major=$(adobe::versionMajor Dimension)
#
#   $1 The name of the Adobe app.
#   $2 The optional year of the adobe app. Some apps don't use years.
# */
function adobe::versionMajor() {
  local name year version

  name="$1"
  year="$2"

  version=$(adobe::version "$name" "$year")
  [ -z "$version" ] && return 1

  echo "$version" | /usr/bin/cut -d'.' -f1
}

# /*!
#   Public: Retrieves the minor version for the given adobe app name and year.
#
#   Example:
#     minor=$(adobe::versionMinor Photoshop 2022)
#     minor=$(adobe::versionMinor Dimension)
#
#   $1 The name of the Adobe app.
#   $2 The optional year of the adobe app. Some apps don't use years.
# */
function adobe::versionMinor() {
  local name year version

  name="$1"
  year="$2"

  version=$(adobe::version "$name" "$year")
  [ -z "$version" ] && return 1

  echo "$version" | /usr/bin/cut -d'.' -f2
}

#
# Initialization Code for Adobe Module
#
if [ -z "$sourced_lib_mac_adobe" ]; then
  # shellcheck disable=SC2034
  sourced_lib_mac_adobe=0

  [ -z "$libsMacAdobe_Log" ] && libsMacAdobeLog="/Library/Application\ Support/MDM/Logs/adobe.log"
fi


