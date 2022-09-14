#!/bin/bash

# Prevent being sourced more than once
[ "${BASH_SOURCE[0]}" != "$0" ] && [ -n "$sourced_lib_mac_power" ] && return 0

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

function mac::power::isDisplayNoSleep() {
  local asserts
  asserts=$(/usr/bin/pmset -g assertions | /usr/bin/awk '/NoDisplaySleepAssertion | PreventUserIdleDisplaySleep/ && match($0,/\(.+\)/) && ! /coreaudiod/ {gsub(/^\ +/,"",$0); print};')

  if [ -n "$asserts" ]; then
    return 0
  else
    return 1
  fi
}

# Initialize library variables
if [ -z "$sourced_lib_mac_power" ]; then
  # shellcheck disable=SC2034
  sourced_lib_mac_power=0
fi
