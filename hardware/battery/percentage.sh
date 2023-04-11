#!/bin/bash

# /*!
#   Public: Gets the current battery charge as a percentage.
#
#   Example:
#     percentage=$(hardware::battery::percentage)
# */
function hardware::battery::percentage() {
  /usr/sbin/system_profiler SPPowerDataType battery -json | /usr/bin/plutil -extract 'SPPowerDataType.0.sppower_battery_charge_info.sppower_battery_state_of_charge' raw -
}