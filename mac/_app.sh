#!/bin/bash

# /*
#   Module:
#     Contains functions to allow for retrieval of information about installed app bundles.
#
#   Example:
#     source "<path-to-mac-libs>/mac/_app.sh"
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
[ "${BASH_SOURCE[0]}" != "$0" ] && [ -n "$sourced_lib_mac_app" ] && return 0

# /*!
#   Public: Retrieves the name from the given app bundle
#
#   Example:
#     name=$(mac::app::getName /Applications/iTerm.app)
#
#   $1 The absolute path to the application bundle.
# */
function mac::app::getName() {
  _getPlistValue "$1" CFBundleName
}

# /*!
#   Public: Retrieves the bundle ID from the given app bundle
#
#   Example:
#     bundleId=$(mac::app::getBundleId /Applications/iTerm.app)
#
#   $1 The absolute path to the application bundle.
# */
function mac::app::getBundleId() {
  /usr/bin/mdls -n kMDItemCFBundleIdentifier -r "$1"
}

# /*!
#   Public: Retrieves the (short) version from the given app bundle
#
#   Example:
#     version=$(mac::app::getVersion /Applications/iTerm.app)
#
#   $1 The absolute path to the application bundle.
# */
function mac::app::getVersion() {
  _getPlistValue "$1" CFBundleShortVersionString
}

# /*!
#   Public: Sets the given app as the default app for the given extension
#
#   Example:
#     mac::app::setDefaultForExtension "/Applications/Visual Studio Code.app" "js"
#     name=$(mac::app::getName /Applications/iTerm.app)
#
#   Dependency:
#     duti (https://github.com/moretension/duti)
#
#   $1 The Extension
#   $2 The absolute path to the application bundle.
# */
function mac::app::setDefaultForExtension() {
  local app ext uti bundle duti

  ext="$1"
  app="$2"
  uti=$(mac::app::getUti "$ext")
  bundle=$(mac::app::getBundleId "$app")
  duti=$(dependency::path duti)

  if [ -n "$duti" ]; then
    if "$duti" -s "$bundle" "$uti" all > /dev/null 2>&1; then
      return 0
    else
      return 1
    fi
  else
    return 1
  fi
}

# /*!
#   Public: Gets the UTI for the given extension, from a limited number of known UTIs.
#
#   Example:
#     jsUti=$(mac::app::getUti js)
#
#   Dependency:
#     jq (https://stedolan.github.io/jq/)
#
#   $1 The Extension
# */
function mac::app::getUti() {
  local ext uti pathJQ

  ext="$1"

  # Ensure JQ dependency
  dependency::assert "jq"
  pathJQ=$(dependency::path jq)

  # Get the UTI from the array.
  uti=$(echo "$_libsMacApp_Uti" | "$pathJQ" -r ."$ext")
  [ -n "$uti" ] && [ "$uti" != "null" ] && echo "$uti" && return 0

  return 1
}

# /*!
#   Private: Gets the path to the Info.plist from the given application bundle and verifies that it exists.
#
#   Example:
#     plist=$(_getPlist /Applications/iTerm.app)
#
#   $1 The absolute path to the application bundle
# */
function _getPlist() {
  local plist

  plist="$1/Contents/Info.plist"
  [ -f "$plist" ] && echo "$plist" && return 0

  return 1
}

# /*!
#   Public: Retrieves value of the given key from the plist of the given application bundle.
#
#   Example:
#     value=$(_getPlist /Applications/iTerm.app CFBundleName)
#
#   $1 The absolute path to the application bundle
#   $2 The key to retreive
# */
function _getPlistValue() {
  local app key plist value

  app="$1"
  key="$2"
  plist=$(_getPlist "$app")
  if [ -n "$plist" ]; then
    value=$(/usr/bin/defaults read "$plist" "$key" 2> /dev/null)
  fi

  echo "$value"
}

#
# Initialization Code for App Module
#
if [ -z "$sourced_lib_mac_app" ]; then
  # shellcheck disable=SC2034
  sourced_lib_mac_app=0

  # This variable is needed for default app assignments
  read -r -d '' _libsMacApp_Uti << EOM
{
  "pdf": "com.adobe.pdf",
  "ps": "com.adobe.postscript",
  "eps": "com.adobe.encapsulated-postscript",
  "psd": "com.adobe.photoshop-image",
  "ai": "com.adobe.illustrator.ai-image",
  "gif": "com.compuserve.gif",
  "bmp": "com.microsoft.bmp",
  "ico": "com.microsoft.ico",
  "doc": "com.microsoft.word.doc",
  "docx": "com.microsoft.word.doc",
  "xls": "com.microsoft.excel.xls",
  "xlsx": "com.microsoft.excel.xls",
  "ppt": "com.microsoft.powerpoint.ppt",
  "pptx": "com.microsoft.powerpoint.ppt",
  "wav": "com.microsoft.waveform-audio",
  "wave": "com.microsoft.waveform-audio",
  "wmv": "com.microsoft.windows-media-wmv",
  "key": "com.apple.keynote.key",
  "xml": "public.xml",
  "txt": "public.txt",
  "jpg": "public.jpeg",
  "jpeg": "public.jpeg",
  "tiff": "public.tiff",
  "tif": "public.tiff",
  "png": "public.png",
  "js": "com.netscape.javascript.source",
  "jscript": "com.netscape.javascript.source",
  "javascript": "com.netscape.javascript.source",
  "sh": "public.shell-script",
  "command": "public.shell-script",
  "py": "public.python-script",
  "pl": "public.perl-script",
  "pm": "public.perl-script",
  "rb": "public.ruby-script",
  "rbw": "public.ruby-script",
  "php": "public.php-script",
  "php3": "public.php-script",
  "php4": "public.php-script",
  "ph3": "public.php-script",
  "ph4": "public.php-script",
  "phtml": "public.php-script",
  "htm": "public.html",
  "html": "public.html",
  "c": "public.c-source",
  "scpt": "com.apple.applescript.script"
}
EOM
fi

