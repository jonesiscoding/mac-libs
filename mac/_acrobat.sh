#!/bin/bash

# Prevent being sourced more than once
[ "${BASH_SOURCE[0]}" != "$0" ] && [ -n "$sourced_lib_mac_acrobat" ] && return 0

function acrobat::path() {
  local edition aDir

  edition="$1"

  if [ "$edition" == "DC" ] || [ "$edition" == "dc" ] || [ -z "$edition" ]; then
    aDir="/Applications/Adobe Acrobat DC/Adobe Acrobat.app"
    [ -f "$aDir/Contents/Info.plist" ] && echo "$aDir" && return 0
  fi

  if [ "$edition" == "XI" ] || [ "$edition" == "xi" ] || [ -z "$edition" ];then
    aDir="/Applications/Adobe Acrobat XI Pro/Adobe Acrobat Pro.app"
    [ -f "$aDir/Contents/Info.plist" ] && echo "$aDir" && return 0
  fi

  if [ "$edition" == "Reader" ] || [ "$edition" == "reader" ] || [ -z "$edition" ]; then
    aDir="/Applications/Adobe Acrobat Reader DC.app"
    [ -f "$aDir/Contents/Info.plist" ] && echo "$aDir" && return 0
  fi

  return 1
}

function acrobat::getPdfHandler() {
  local pathDuti edition aPath bundleId

  dependency::assert "duti"
  pathDuti=$(dependency::path duti)

  edition="$1"
  aPath=$(acrobat::path "$edition")
  bundleId=$(/usr/bin/mdls -n kMDItemCFBundleIdentifier -r "$aPath")

  "$pathDuti" -x "com.adobe.pdf" | grep ".app" | tail -1
}

function acrobat::setPdfHandler() {
  local pathDuti edition aPath bundleId

  dependency::assert "duti"
  pathDuti=$(dependency::path duti)

  edition="$1"
  aPath=$(acrobat::path "$edition")
  bundleId=$(/usr/bin/mdls -n kMDItemCFBundleIdentifier -r "$aPath")

  if "$pathDuti" -s "$bundleId" "com.adobe.pdf" all > /dev/null 2>&1; then
    return 0
  else
    return 1
  fi
}

function acrobat::version() {
  local edition aPath

  edition="$1"
  aPath=$(acrobat::path "$edition")

  if [ -n "$aPath" ]; then
    _getAdobePlistValue "$aPath" CFBundleShortVersionString
    return 0
  fi

  return 1
}

function acrobat::uninstall() {
  local edition

  edition="$1"

  if [ "$edition" == "DC" ] || [ "$edition" == "dc" ]; then
    if [ -d "/Applications/Adobe Acrobat DC/Adobe Acrobat.app" ]; then
      if "/Applications/Adobe Acrobat DC/Adobe Acrobat.app/contents/Helpers/Acrobat uninstaller.app/contents/Library/LaunchServices/com.adobe.Acrobat.RemoverTool" > "$libsMacAdobeLog" 2>&1; then
        return 0
      else
        return 1
      fi
    else
      return 0
    fi
  elif [ "$edition" == "XI" ] || [ "$edition" == "xi" ]; then
    if [ -d "/Applications/Adobe Acrobat XI Pro/Adobe Acrobat Pro.app" ]; then
      if "/Applications/Adobe Acrobat XI Pro/Adobe Acrobat Pro.app/Contents/Support/Acrobat Uninstaller.app/Contents/Library/LaunchServices/com.adobe.Acrobat.RemoverTool" "/Applications/Adobe Acrobat XI Pro/Adobe Acrobat Pro.app/Contents/Support/Acrobat Uninstaller.app/Contents/MacOS/Acrobat Uninstaller" "/Applications/Adobe Acrobat XI Pro/Adobe Acrobat Pro.app" > "$libsMacAdobeLog" 2>&1; then
        return 0
      else
        return 1
      fi
    else
      return 0
    fi
  else
    return 1
  fi
}


if [ -z "$sourced_lib_mac_acrobat" ]; then
  # shellcheck disable=SC2034
  sourced_lib_mac_acrobat=0

  [ -z "$libsMacAdobeLog" ] && libsMacAdobeLog="/Library/Application\ Support/MDM/Logs/adobe.log"
fi