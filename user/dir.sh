#!/bin/bash

function user::dir() {
  local su suDir

  su="$1"
  [[ -n "$su" ]] && suDir=$(/usr/bin/dscl . -read /Users/"$su" NFSHomeDirectory 2> /dev/null | /usr/bin/awk -F ': ' '{print $2}')
  if [[ -z "$suDir" ]]; then
    if [ -d "/Users/$su/Desktop" ]; then
      # While this is not always correct, it is likely to be correct if the desktop directory exists.
      # This is only used as a backup in the case of the above failing.
      suDir="/Users/$su"
    fi
  fi

  echo "$suDir" && return 0
}