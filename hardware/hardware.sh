#!/bin/bash

# /*
#   Module:
#     Contains functions to ease the retrieval of hardware information on this Mac.
#
#   Example:
#     source "<path-to-os-libs>/os/hardware.sh"
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
[ "${BASH_SOURCE[0]}" != "$0" ] && [ -n "$sourced_lib_mac_hardware" ] && return 0

# /*!
#   Public: Evaluates whether this Mac is using Apple Silicon.  The value is then cached to prevent additional overhead
#   in using the function repeatedly.
#
#   Example:
#     if hardware::isAppleSilicon; then
#       <code to run if the os uses an M1, M2, etc.>
#     else
#       <code to run if the os uses an Intel (or other) chip
#     fi
# */
function hardware::isAppleSilicon() {
  if [ -z "$_libsMacHardware_Arch" ]; then
    _libsMacHardware_Arch=$(/usr/bin/arch)
  fi

  if [ "$_libsMacHardware_Arch" == "arm64" ]; then
    return 0
  else
    return 1
  fi
}

# /*!
#   Public: Evaluates whether this device is a MacBook
#
#   Example:
#     if hardware::isMacBook; then
#       <code to run if a MacBook>
#     else
#       <code to run if not a MacBook>
#     fi
# */
function hardware::isMacBook() {
  hardware::model | /usr/bin/grep -q "MacBook"
}

# /*!
#   Public: Evaluates whether this Mac contains a T2 Security Chip.  The value is then cached to prevent additional
#   overhead in using the function repeatedly.
#
#   Example:
#     if hardware::isT2; then
#       <code to run if the os uses a T2 Chip>
#     else
#       <code to run if the does not use a T2 Chip>
#     fi
# */
function hardware::isT2() {
  if [ -z "$_libsMacHardware_T2" ]; then
    _libsMacHardware_T2="false"
    if ! hardware::isAppleSilicon; then
      if /usr/sbin/system_profiler SPiBridgeDataType | /usr/bin/grep -q 'T2'; then
        _libsMacHardware_T2="true"
      fi
    fi
  fi

  # True Result
  $_libsMacHardware_T2 && return 0

  # False Result
  return 1
}

# /*!
#   Public: Retrieves the model name of this Mac
#
#   Example:
#     model=$(hardware::model)
# */
function hardware::model() {
  if [ -z "$_libsMacHardware_Model" ]; then
    _libsMacHardware_Model=$(/usr/sbin/system_profiler SPHardwareDataType | /usr/bin/grep "Model Name" | /usr/bin/rev | /usr/bin/cut -d':' -f1 | /usr/bin/rev | /usr/bin/sed -e 's/^[[:space:]]*//')
  fi

  echo "$_libsMacHardware_Model"
}

#
# Initialization Code
#
if [ -z "$sourced_lib_mac_hardware" ]; then
  # shellcheck disable=SC2034
  sourced_lib_mac_hardware=0

  # Internal Variables
  _libsMacHardware_Arch=""
  _libsMacHardware_T2=""
  _libsMacHardware_Model=""
fi
