#!/bin/bash

# /*!
#   Public: Retrieves the model name of this Mac
#
#   Example:
#     model=$(hardware::model::isMacBook)
# */
function hardware::isMacBook() {
  if /usr/sbin/system_profiler SPHardwareDataType model -json | /usr/bin/plutil -extract 'SPHardwareDataType.0.machine_name' raw - | grep -q "MacBook"; then
    return 0
  else
    return 1
  fi
}