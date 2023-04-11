#!/bin/bash

if [[ $(type -t "user::dir") != function ]]; then
  # shellcheck source=../dir.sh disable=SC2164
  source "$( cd "$(/usr/bin/dirname "${BASH_SOURCE[0]}")" ; /bin/pwd -P )/../dir.sh"
fi

# /*
#   Internal: Retrieves the group for the given directory or file
#
#   $1 The directory or file to retrieve the group for
# */
_group() {
  local tGroup
  local refFile

  refFile=$1

  if [ -f "$refFile" ] || [ -d "$refFile" ]; then
    tGroup=$(/usr/bin/stat -f "%Sg" "$refFile")
    # shellcheck disable=SC2181
    if [ "$?" -eq "0" ]; then
      echo "$tGroup"

      return 0
    fi
  fi

  return 1
}

# /*
#   Internal: Retrieves the owner for the given directory or file
#
#   $1 The directory or file to retrieve the owner for
# */
_owner() {
  local tOwner
  local refFile

  refFile=$1

  if [ -f "$refFile" ] || [ -d "$refFile" ]; then
    tOwner=$(/usr/bin/stat -f "%Su" "$refFile")
    # shellcheck disable=SC2181
    if [ "$?" -eq "0" ]; then
      echo "$tOwner"

      return 0
    fi
  fi

  return 1
}

# /*
#   Public: Sets the ownership of the given file or directory to the script user.  The script user is defined
#   in _core.sh or _root.sh. Please see these scripts for details.
#
#   Example:
#     if user::files::chown $dirPath; then
#       <code for positive result>
#     else
#       <code for negative result>
#     fi
#
#   $1 The path to change the ownership of.
#   $2 Set to 1 to make the ownership change recursive.
# */
function user::files::chown() {
  local owner group tfile recursive cOwn cGrp userDir

  tfile="$1"
  userDir=$(user::dir "$libsMacUser")
  owner=$(_owner "$userDir")
  group=$(_group "$userDir")
  cOwn="/usr/sbin/chown"
  cGrp="/usr/bin/chgrp"

  if [ -d "$tfile" ]; then
    recursive="${2:-0}"
    if [ "$recursive" -eq "1" ]; then
      cOwn="${cOwn} -R"
      cGrp="${cGrp} -R"
    fi
  fi

  if ! $cOwn "$owner" "$tfile"; then
    return 1
  fi

  if ! $cGrp "$group" "$tfile"; then
    return 1
  fi

  return 0
}