#!/bin/bash

if [[ $(type -t "user::files::chown") != function ]]; then
  # shellcheck source=../dir.sh disable=SC2164
  source "$( cd "$(/usr/bin/dirname "${BASH_SOURCE[0]}")" ; /bin/pwd -P )/chown.sh"
fi

# /*
#   Public: Makes the given directory and sets ownership to the user referenced by $libsMacUser. This variable
#   is defined in _core.sh or _root.sh.  Please see these scripts for details.
#
#   Example:
#     if user::files::chown $dirPath; then
#       <code for positive result>
#     else
#       <code for negative result>
#     fi
#
#   $1 The directory path to create
# */
function user::files::mkdir() {
  local DIR
  DIR="$1"

  if [ ! -d "$DIR" ]; then
    if [ -f "$DIR" ]; then
      echo "ERROR: The file '$DIR' exists but is not a directory."
      return 1
    fi

    if ! /bin/mkdir -p "$DIR"; then
      echo "ERROR: Cannot create directory '$DIR'."
      return 1
    fi
  fi

  if ! user::files::chown "$DIR"; then
    return 1
  fi

  return 0
}



