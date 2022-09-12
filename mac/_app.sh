#!/bin/bash

# Prevent being sourced more than once
[ "${BASH_SOURCE[0]}" != "$0" ] && [ -n "$sourced_lib_mac_app" ] && return 0

function mac::app::getName() {
  _getPlistValue "$1" CFBundleName
}

function mac::app::getBundleId() {
  /usr/bin/mdls -n kMDItemCFBundleIdentifier -r "$1"
}

function mac::app::getVersion() {
  _getPlistValue "$1" CFBundleShortVersionString
}

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

function _getPlist() {
  local plist

  plist="$1/Contents/Info.plist"
  [ -f "$plist" ] && echo "$plist" && return 0

  return 1
}

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

