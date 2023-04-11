#!/bin/bash

# /*!
#   Public: Displays the battery serial number
#
#   Example:
#     serial=$(hardware::battery::serial)
# */
function hardware::battery::serial() {
  /usr/sbin/system_profiler SPPowerDataType battery -json | /usr/bin/plutil -extract 'SPPowerDataType.0.sppower_battery_model_info.sppower_battery_serial_number' raw -
}