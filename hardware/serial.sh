#!/bin/bash

# /*!
#   Public: Retrieves the serial number of this Mac
#
#   Example:
#     model=$(hardware::serial)
# */
function hardware::serial() {
  /usr/sbin/system_profiler SPHardwareDataType model -json | /usr/bin/plutil -extract 'SPHardwareDataType.0.serial_number' raw -
}