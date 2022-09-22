#!/bin/bash

# /*
#   Module:
#     Contains functions to ease the retrieval of power information on this Mac.
#
#   Example:
#     source "<path-to-mac-libs>/mac/_power.sh"
#
#     See functions for additional examples
#
#   Copyright:
#     © 2022/09 AMJones <am@jonesiscoding.com>
#
#   License:
#     For the full copyright and license information, please view the LICENSE
#     file that was distributed with this source code.
# */


# Prevent being sourced more than once
[ "${BASH_SOURCE[0]}" != "$0" ] && [ -n "$sourced_lib_mac_power" ] && return 0

# /*!
#   Public: Evaluates whether the Mac is currently plugged in to AC power. Note that this does not necessarily indicate
#   a MacBook with a power adapter; Mac Desktops will also return a positive result.
#
#   Example:
#     if mac::power::isPlugged in; then
#       <code to run if the mac is on AC power>
#     else
#       <code to run if not plugged in>
#     fi
#
#   Dependency:
#     jq (https://stedolan.github.io/jq/)
# */
function mac::power::isPluggedIn() {
  local jqPath

  # Ensure JQ dependency
  dependency::assert "jq"
  jqPath=$(dependency::path jq)
  if /usr/sbin/system_profiler SPPowerDataType battery -json | "$jqPath" -r '.SPPowerDataType[]."AC Power"."Current Power Source"' | grep -q "TRUE"; then
    return 0
  else
    return 1
  fi
}

# /*!
#   Public: Evaluates whether the display has a NoDisplaySleep or PreventUserIdleDisplaySleep assertion.
#
#   Example:
#     if mac::power::isDisplayNoSleep; then
#       <code to run if display sleep is prevented>
#     else
#       <code to run if not>
#     fi
# */
function mac::power::isDisplayNoSleep() {
  local asserts
  asserts=$(/usr/bin/pmset -g assertions | /usr/bin/awk '/NoDisplaySleepAssertion | PreventUserIdleDisplaySleep/ && match($0,/\(.+\)/) && ! /coreaudiod/ {gsub(/^\ +/,"",$0); print};')

  if [ -n "$asserts" ]; then
    return 0
  else
    return 1
  fi
}

#
# Initialize Module
#
if [ -z "$sourced_lib_mac_power" ]; then
  # shellcheck disable=SC2034
  sourced_lib_mac_power=0
fi
