#!/bin/bash

# Prevent being sourced more than once
[ "${BASH_SOURCE[0]}" != "$0" ] && [ -n "$sourced_lib_mac_files" ] && return 0

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

function mac::files::user::chown() {
  local OWNER
  local GROUP
  local TFILE

  TFILE="$1"
  OWNER=$(_owner "/Users/${libsMacUser}")
  GROUP=$(_group "/Users/${libsMacUser}")

  if ! /usr/sbin/chown "$OWNER" "$TFILE"; then
    echo "ERROR: Could not set ownership for '$TFILE'"
    return 1
  fi

  if ! /usr/bin/chgrp "$GROUP" "$TFILE"; then
    echo "ERROR: Could not set ownership for '$TFILE'"
    return 1
  fi

  return 0
}

function mac::files::user::mkdir() {
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

  if ! mac::files::user::chown "$DIR"; then
    return 1
  fi

  return 0
}

function mac::files::user::touch() {
  local PARENT
  local TFILE
  TFILE="$1"

  if [ ! -f "$TFILE" ]; then
    PARENT=$(/usr/bin/dirname "$TFILE")
    if [ ! -d "$PARENT" ]; then
      if ! /bin/mkdir -p "$PARENT"; then
        echo "ERROR: Cannot create directory '$PARENT'."
        return 1
      fi
    fi

    if ! /usr/bin/touch "$TFILE"; then
      echo "ERROR: Could not create file '$TFILE'."
      return 1
    fi

    if ! mac::files::user::chown "$TFILE"; then
      return 1
    fi
  fi

  return 0
}

if [ -z "$sourced_lib_mac_files" ]; then
  # shellcheck disable=SC2034
  sourced_lib_mac_files=0
fi