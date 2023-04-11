#!/bin/bash

# /*!
#   Public: Evaluates whether the display has a NoDisplaySleep or PreventUserIdleDisplaySleep assertion.
#
#   Example:
#     if hardware::power::isDisplayNoSleep; then
#       <code to run if display sleep is prevented>
#     else
#       <code to run if not>
#     fi
# */
function hardware::power::isDisplayNoSleep() {
  local asserts
  asserts=$(/usr/bin/pmset -g assertions | /usr/bin/awk '/NoDisplaySleepAssertion | PreventUserIdleDisplaySleep/ && match($0,/\(.+\)/) && ! /coreaudiod/ {gsub(/^\ +/,"",$0); print};')

  if [ -n "$asserts" ]; then
    return 0
  else
    return 1
  fi
}