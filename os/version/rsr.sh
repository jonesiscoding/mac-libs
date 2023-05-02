#!/bin/bash

function os::version::rsr() {
  local rsr

  if rsr=$(/usr/bin/sw_vers -productVersionExtra 2>/dev/null); then
    echo "$rsr"
  else
    echo ""
  fi

  return 0
}