#!/bin/bash

# /*!
#   Public: Evaluates whether the Mac is currently plugged in to AC power. Note that this does not necessarily indicate
#   a MacBook with a power adapter; Mac Desktops will also return a positive result.
#
#   Example:
#     if hardware::power::isPlugged in; then
#       <code to run if the os is on AC power>
#     else
#       <code to run if not plugged in>
#     fi
# */
function hardware::power::isPluggedIn() {
  # bashsupport disable=GrazieInspection
  local output
  output=$(/usr/sbin/system_profiler SPPowerDataType battery -json | /usr/bin/plutil -extract 'SPPowerDataType.1.AC Power.Current Power Source' raw -)
  if [ -z "$output" ] || [ "$output" == "FALSE" ]; then
    return 1
  fi

  return 0
}