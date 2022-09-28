#!/bin/bash

# Prevent being sourced more than once
[ "${BASH_SOURCE[0]}" != "$0" ] && [ -n "$sourced_lib_mac_defaults" ] && return 0

# shellcheck source=./files.sh
source "$libsMacSourcePath/user/files.sh"

function defaults::toBoolean() {
  local inValue trueValue

  inValue="$1"
  trueValue=("ON" "on" "TRUE" "true" "1" "YES" "yes")

  for i in "${trueValue[@]}"; do
    [ "$inValue" == "$i" ] && echo "1" && return 0
  done

  echo "0" && return 0
}

function user::defaults::has() {
  local KEY
  local PLIST

  KEY="${2}"
  PLIST="/Users/${libsMacUser}/Library/Preferences/${1}.plist"

  [ -z "$KEY" ] && return 1
  [ -z "${1}" ] && return 1

  if /usr/bin/defaults read "${PLIST}" "${KEY}" 2>&1 | /usr/bin/grep -q "does not exist"; then
    return 1
  else
    return 0
  fi
}

function user::defaults::read() {
  local KEY
  local VALUE
  local PLIST

  KEY="${2}"
  PLIST="/Users/${libsMacUser}/Library/Preferences/${1}.plist"

  if [ -n "$KEY" ]; then
    VALUE=$(/usr/bin/defaults read "${PLIST}" "$KEY")
  else
    VALUE=$(/usr/bin/defaults read "${PLIST}")
  fi

  # shellcheck disable=SC2181
  if [ $? -eq 0 ]; then
    echo "$VALUE" && return 0
  else
    return 1
  fi
}

function user::defaults::readArray() {
  user::defaults::read "$1" "$2" 2> /dev/null | /usr/bin/grep -wv -e '(' -e ')' | /usr/bin/rev | /usr/bin/cut -d',' -f2 | /usr/bin/cut -d' ' -f1 | /usr/bin/rev
}

function user::defaults::write() {
  local DOMAIN
  local KEY
  local VALUE
  local PLIST

  DOMAIN="${1}"
  KEY="${2}"
  VALUE="${3}"

  if [ -z "$KEY" ]; then
    return 1
  fi

  if [ -z "$VALUE" ]; then
    return 1
  fi

  PLIST="/Users/${libsMacUser}/Library/Preferences/${DOMAIN}.plist"

  /usr/bin/defaults "write" "$PLIST" "$KEY" "$VALUE" || return 1
  mac::files::user::chown "$PLIST" || return 1

  return 0
}

if [ -z "$sourced_lib_mac_defaults" ]; then
  # shellcheck disable=SC2034
  sourced_lib_mac_defaults=0
fi
