#!/bin/bash

# Prevent being sourced more than once
[ "${BASH_SOURCE[0]}" != "$0" ] && [ -n "$sourced_lib_mac_hardware" ] && return 0

function mac::hardware::isAppleSilicon() {
  if [ -z "$_libsMacHardware_Arch" ]; then
    _libsMacHardware_Arch=$(/usr/bin/arch)
  fi

  if [ "$_libsMacHardware_Arch" == "arm64" ]; then
    return 0
  else
    return 1
  fi
}

function mac::hardware::isT2() {
  if [ "$_libsMacHardware_Arch" != "arm64" ]; then
    if /usr/sbin/system_profiler SPiBridgeDataType | /usr/bin/grep -q 'T2'; then
      return 0
    fi
  fi

  return 1
}

if [ -z "$sourced_lib_mac_hardware" ]; then
  # shellcheck disable=SC2034
  sourced_lib_mac_hardware=0
  _libsMacHardware_Arch=""
fi
