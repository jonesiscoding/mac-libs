#!/bin/bash

# /*!
#   Public: Displays the number of battery cycles
#
#   Example:
#     cycles=$(hardware::battery::cycles)
# */
function hardware::battery::cycles() {
  /usr/sbin/system_profiler SPPowerDataType battery -json | /usr/bin/plutil -extract 'SPPowerDataType.0.sppower_battery_health_info.sppower_battery_cycle_count' raw -
}