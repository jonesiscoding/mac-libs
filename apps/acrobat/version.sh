#!/bin/bash

if [[ $(type -t "apps::acrobat::path") != function ]]; then
  # shellcheck source=./path.sh disable=SC2164
  source "$( cd "$(/usr/bin/dirname "${BASH_SOURCE[0]}")" ; /bin/pwd -P )/path.sh"
fi

# /*!
#   Public: Displays the installed version of the given edition of Adobe Acrobat.
#
#   Example:
#     acrobatVersion=$(apps::acrobat::version DC)
#
#   $1  The edition of Adobe Acrobat to retrieve the version for: DC, XI, or Reader.
# */
function apps::acrobat::version() {
  local edition aPath plist value

  edition="$1"
  aPath=$(apps::acrobat::path "$edition")

  if [ -n "$aPath" ]; then
    plist="$aPath/Contents/Info.plist"
    if [ -f "$plist" ]; then
      if value=$(/usr/bin/defaults read "$plist" CFBundleShortVersionString 2> /dev/null); then
        echo "$value"
        return 0
      fi
    fi
  fi

  return 1
}

