#!/bin/bash

# /*!
#   Public: Evaluates whether the battery is fully charged
#
#   Example:
#     if hardware::battery::isFullyCharged; then
#       <positive code here>
#     else
#       <negative code here>
#     fi
# */
function hardware::battery::isFullyCharged() {
  local output
  output=$(/usr/sbin/system_profiler SPPowerDataType battery -json | /usr/bin/plutil -extract 'SPPowerDataType.0.sppower_battery_charge_info.sppower_battery_fully_charged' raw -)
  if [ -z "$output" ] || [ "$output" == "FALSE" ]; then
    return 1
  fi
}