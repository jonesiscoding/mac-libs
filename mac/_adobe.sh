#!/bin/bash

# Prevent being sourced more than once
[ "${BASH_SOURCE[0]}" != "$0" ] && [ -n "$sourced_lib_mac_adobe" ] && return 0

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

function _getDataFromAdbArg() {
  local aaFile key

  aaFile="$1"
  key="$2"

  # shellcheck disable=SC2002
  /bin/cat "$aaFile" | /usr/bin/grep "$key" | /usr/bin/cut -d'=' -f2
}

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

function adobe::version() {
  local name year aPath

  name="$1"
  year="$2"

  aPath=$(adobe::path "$name" "$year")
  if [ -n "$aPath" ]; then
    _getAdobePlistValue "$aPath" CFBundleShortVersionString
  fi
}

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

function adobe::versionMajor() {
  local name year version

  name="$1"
  year="$2"

  version=$(adobe::version "$name" "$year")
  [ -z "$version" ] && return 1

  echo "$version" | /usr/bin/cut -d'.' -f1
}

function adobe::versionMinor() {
  local name year version

  name="$1"
  year="$2"

  version=$(adobe::version "$name" "$year")
  [ -z "$version" ] && return 1

  echo "$version" | /usr/bin/cut -d'.' -f2
}

if [ -z "$sourced_lib_mac_adobe" ]; then
  # shellcheck disable=SC2034
  sourced_lib_mac_adobe=0

  [ -z "$libsMacAdobe_Log" ] && libsMacAdobeLog="/Library/Application\ Support/MDM/Logs/adobe.log"
fi


