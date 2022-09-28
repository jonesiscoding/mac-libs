#!/bin/bash

# /*
#   Module:
#     Contains functions to allow easy retrieval of battery information
#
#   Example:
#     source "<path-to-os-libs>/os/battery.sh"
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
[ "${BASH_SOURCE[0]}" != "$0" ] && [ -n "$sourced_lib_mac_battery" ] && return 0

# /*!
#   Public: Gets the current battery charge as a percentage.
#
#   Example:
#     percentage=$(hardware::battery::percentage)
#
#   Dependency:
#     jq (https://stedolan.github.io/jq/)
# */
function hardware::battery::percentage() {
  /usr/sbin/system_profiler SPPowerDataType battery -json | "$_libsMacBattery_JQ" '.SPPowerDataType[0].sppower_battery_charge_info.sppower_battery_state_of_charge'
}

# /*!
#   Public: Evaluates whether the battery is fully charged
#
#   Example:
#     if hardware::battery::isFullyCharged; then
#       <positive code here>
#     else
#       <negative code here>
#     fi
#
#   Dependency:
#     jq (https://stedolan.github.io/jq/)
# */
function hardware::battery::isFullyCharged() {
  /usr/sbin/system_profiler SPPowerDataType battery -json | "$_libsMacBattery_JQ" '.SPPowerDataType[0].sppower_battery_charge_info.sppower_battery_fully_charged'
}

# /*!
#   Public: Evaluates whether the battery is charging
#
#   Example:
#     if hardware::battery::isCharging; then
#       <positive code here>
#     else
#       <negative code here>
#     fi
#
#   Dependency:
#     jq (https://stedolan.github.io/jq/)
# */
function hardware::battery::isCharging() {
  /usr/sbin/system_profiler SPPowerDataType battery -json | "$_libsMacBattery_JQ" '.SPPowerDataType[0].sppower_battery_charge_info.sppower_battery_is_charging'
}

# /*!
#   Public: Displays the number of battery cycles
#
#   Example:
#     cycles=$(hardware::battery::cycles)
#
#   Dependency:
#     jq (https://stedolan.github.io/jq/)
# */
function hardware::battery::cycles() {
  /usr/sbin/system_profiler SPPowerDataType battery -json | "$_libsMacBattery_JQ" '.SPPowerDataType[0].sppower_battery_health_info.sppower_battery_cycle_count'
}

# /*!
#   Public: Displays the battery serial number
#
#   Example:
#     serial=$(hardware::battery::getSerialNumber)
#
#   Dependency:
#     jq (https://stedolan.github.io/jq/)
# */
function hardware::battery::getSerialNumber() {
  /usr/sbin/system_profiler SPPowerDataType battery -json | "$_libsMacBattery_JQ" '.SPPowerDataType[0].sppower_battery_model_info.sppower_battery_serial_number'
}

#
# Initialize Module
#
if [ -z "$sourced_lib_mac_battery" ]; then
  # shellcheck disable=SC2034
  sourced_lib_mac_battery=0

  # Ensure JQ dependency
  dependency::assert "jq"
  _libsMacBattery_JQ=$(dependency::path jq)
fi




