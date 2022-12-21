#!/bin/bash

# /*
#   Module:
#     Contains functions to allow for easier manipulation of the file system.  Note that all functions within the
#     user::files namespace utilize the global $libsMacUser for the referenced user.
#
#     This user is populated by sourcing _core.sh and/or _root.sh.  Please see those modules for additional information.
#
#   Example:
#     source "<path-to-os-libs>/os/files.sh"
#
#   Copyright:
#     © 2022/09 AMJones <am@jonesiscoding.com>
#
#   License:
#     For the full copyright and license information, please view the LICENSE
#     file that was distributed with this source code.
# */

#
# User/Files Initialization
#

[ "${BASH_SOURCE[0]}" != "$0" ] && [ -n "$sourced_lib_mac_files" ] && return 0
# shellcheck disable=SC2034
sourced_lib_mac_files=0

# Fallback for the initialization of this variable.
# Developer should have sourced _core.sh and/or _root.sh already.
[ -z "$libsMacUser" ] && libsMacUser="${USER}"


#
# User/Files Functions
#

# /*
#   Internal: Retrieves the group for the given directory or file
#
#   $1 The directory or file to retrieve the group for
# */
_group() {
  local TGROUP
  local REF

  REF=$1

  if [ -f "$REF" ] || [ -d "$REF" ]; then
    TGROUP=$(/usr/bin/stat -f "%Sg" "$REF")
    # shellcheck disable=SC2181
    if [ "$?" -eq "0" ]; then
      echo "$TGROUP"

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
  local TOWNER
  local REF

  REF=$1

  if [ -f "$REF" ] || [ -d "$REF" ]; then
    TOWNER=$(/usr/bin/stat -f "%Su" "$REF")
    # shellcheck disable=SC2181
    if [ "$?" -eq "0" ]; then
      echo "$TOWNER"

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
  local owner group tfile recursive cOwn cGrp res

  tfile="$1"
  owner=$(_owner "/Users/${libsMacUser}")
  group=$(_group "/Users/${libsMacUser}")
  cOwn="/usr/sbin/chown"
  cGrp="/usr/bin/chgrp"

  if [ -d "$tfile" ]; then
    recursive="$2"
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
