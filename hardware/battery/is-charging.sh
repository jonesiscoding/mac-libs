#!/bin/bash

# /*!
#   Public: Evaluates whether the battery is charging.  Note that a negative response does NOT mean that the MacBook is
#           unplugged, only that it isn't presently charging.
#
#   Example:
#     if hardware::battery::isCharging; then
#       <positive code here>
#     else
#       <negative code here>
#     fi
#
# */
function hardware::battery::isCharging() {
  local output
  output=$(/usr/sbin/system_profiler SPPowerDataType battery -json | /usr/bin/plutil -extract 'SPPowerDataType.0.sppower_battery_charge_info.sppower_battery_is_charging' raw -)
  if [ -z "$output" ] || [ "$output" == "FALSE" ]; then
    return 1
  fi

  return 0
}