#!/bin/bash

# /*!
#   Public: Displays the path to the given edition of Adobe Acrobat, if installed.
#
#   Example:
#     acrobatPath=$(apps::acrobat::path DC)
#
#   $1  The edition of Adobe Acrobat to retrieve the path for: DC, XI, or Reader.
# */
function apps::acrobat::path() {
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
    aDir="/Applications/Adobe Acrobat Reader.app"
    if [ ! -f "$aDir/Contents/Info.plist" ]; then
      aDir="/Applications/Adobe Acrobat Reader DC.app"
    fi

    [ -f "$aDir/Contents/Info.plist" ] && echo "$aDir" && return 0
  fi

  return 1
}