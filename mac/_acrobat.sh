#!/bin/bash

# /*
#   Module:
#     Contains functions that work with Adobe Acrobat DC, Reader, and XI
#
#   Example:
#     source "<path-to-mac-libs>/mac/_acrobat.sh"
#     <various code>
#     <see function examples>
#
#   Copyright:
#     © 2022/09 AMJones <am@jonesiscoding.com>
#   License:
#     For the full copyright and license information, please view the LICENSE
#     file that was distributed with this source code.
# */

# Prevent being sourced more than once
[ "${BASH_SOURCE[0]}" != "$0" ] && [ -n "$sourced_lib_mac_acrobat" ] && return 0

# /*!
#   Public: Displays the path to the given edition of Adobe Acrobat, if installed.
#
#   Example:
#     acrobatPath=$(acrobat::path DC)
#
#   $1  The edition of Adobe Acrobat to retrieve the path for: DC, XI, or Reader.
# */
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

# /*!
#   Public: Displays the path to the current handler of PDF files for the OS.
#
#   Example:
#     pdfHandler=$(acrobat::getPdfHandler)
#
#   Dependency:
#     duti (https://github.com/moretension/duti)
# */
function acrobat::getPdfHandler() {
  local pathDuti

  dependency::assert "duti"
  pathDuti=$(dependency::path duti)

  "$pathDuti" -x "com.adobe.pdf" | grep ".app" | tail -1
}

# /*!
#   Public: Sets the PDF handler for the OS to the given edition of Adobe
#   Acrobat, if installed.
#
#   Example:
#     acrobat::setPdfHandler DC
#
#   Dependency:
#     duti (https://github.com/moretension/duti)
#
#   $1    The edition of Adobe Acrobat to use for PDF files, if installed.
# */
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

# /*!
#   Public: Displays the installed version of the given edition of Adobe Acrobat.
#
#   Example:
#     acrobatVersion=$(acrobat::version DC)
#
#   $1  The edition of Adobe Acrobat to retrieve the version for: DC, XI, or Reader.
# */
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

# /*!
#   Public: Runs the uninstaller for the given edition of Adobe Acrobat, if installed.
#
#   Example:
#     if acrobat::uninstall XI; then
#       <success code here>
#     else
#       <failure code here>
#     fi
#
#   $1  The edition of Adobe Acrobat to uninstall: DC, XI, or Reader.
# */
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

#
# Initialization Code
#
if [ -z "$sourced_lib_mac_acrobat" ]; then
  # shellcheck disable=SC2034
  sourced_lib_mac_acrobat=0

  [ -z "$libsMacAdobeLog" ] && libsMacAdobeLog="/Library/Application\ Support/MDM/Logs/adobe.log"
fi