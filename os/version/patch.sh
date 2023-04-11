#!/bin/bash

function os::version::patch() {
  local patch

  patch=$(/usr/bin/sw_vers -productVersion | /usr/bin/cut -d "." -f3)
  if [ -z "$patch" ]; then
    echo "0"
  else
    echo "$patch"
  fi

  return 0
}