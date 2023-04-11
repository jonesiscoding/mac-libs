#!/bin/bash

if [[ $(type -t "user::files::chown") != function ]]; then
  # shellcheck source=../dir.sh disable=SC2164
  source "$( cd "$(/usr/bin/dirname "${BASH_SOURCE[0]}")" ; /bin/pwd -P )/chown.sh"
fi

# /*
#   Public: Verifies that the parent directory exists, then touches (or creates) the given file path, changing
#   ownership to the user referenced by $libsMacUser.
#
#   Example:
#     if user::files::touch $filePath; then
#       <code for positive result>
#     else
#       <code for negative result>
#     fi
#
#   $1 The file path to create
# */
function user::files::touch() {
  local parentDirectory
  local theFile
  theFile="$1"

  if [ ! -f "$theFile" ]; then
    parentDirectory=$(/usr/bin/dirname "$theFile")
    if [ ! -d "$parentDirectory" ]; then
      if ! /bin/mkdir -p "$parentDirectory"; then
        echo "ERROR: Cannot create directory '$parentDirectory'."
        return 1
      fi
    fi

    if ! /usr/bin/touch "$theFile"; then
      echo "ERROR: Could not create file '$theFile'."
      return 1
    fi

    if ! user::files::chown "$theFile"; then
      return 1
    fi
  fi

  return 0
}