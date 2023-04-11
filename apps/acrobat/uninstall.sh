#!/bin/bash

[ -z "$libsMacAdobeLog" ] && libsMacAdobeLog="/Library/Application\ Support/MDM/Logs/adobe.log"

# /*!
#   Public: Runs the uninstaller for the given edition of Adobe Acrobat, if installed.
#
#   Example:
#     if apps::acrobat::uninstall XI; then
#       <success code here>
#     else
#       <failure code here>
#     fi
#
#   $1  The edition of Adobe Acrobat to uninstall: DC, XI, or Reader.
# */
function apps::acrobat::uninstall() {
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