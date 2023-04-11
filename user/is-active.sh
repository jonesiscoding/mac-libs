#!/bin/bash

if [[ $(type -t "user::console") != function ]]; then
  # shellcheck source=./console.sh disable=SC2164
  source "$( cd "$(/usr/bin/dirname "${BASH_SOURCE[0]}")" ; /bin/pwd -P )/console.sh"
fi

function user::isActive() {
  local idle consoleUser

  consoleUser=$(user::console)
  if [ "$libsMacUser" == "$consoleUser" ]; then
    # Get MacOSX idletime. Originally found at: http://bit.ly/yVhc5H
    idle=$(/usr/sbin/ioreg -c IOHIDSystem | /usr/bin/awk '/HIDIdleTime/ {print int($NF/1000000000); exit}' | /usr/bin/xargs)
    if [ "${idle}" -gt 0 ]; then
      # shellcheck disable=SC2219
      let MM=idle/60
      if [ "$MM" -lt "6" ]; then
        return 0
      fi
    fi
  fi

  return 1
}