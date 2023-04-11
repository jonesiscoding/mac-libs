#!/bin/bash

function user::idle() {
  local S MM M H IDLE
  if user::isConsole; then
    # Get MacOSX idletime. Shamelessly stolen from http://bit.ly/yVhc5H
    IDLE=$(/usr/sbin/ioreg -c IOHIDSystem | /usr/bin/awk '/HIDIdleTime/ {print int($NF/1000000000); exit}' | /usr/bin/xargs)

    if [ "${IDLE}" -gt 0 ]; then
      # shellcheck disable=SC2219
      let S=${IDLE}%60
      MM=$((IDLE/60)) #Total number of minutes
      # shellcheck disable=SC2219
      let M=${MM}%60
      # shellcheck disable=SC2219
      let H=${MM}/60
      [ "$H" -gt "0" ] && printf "%02d%s" "$H" "h"
      [ "$M" -gt "0" ] && printf "%02d%s" "$M" "m"
      /usr/bin/printf "%02d%s" "$S" "s"
    fi

    return 0
  fi

  return 1
}