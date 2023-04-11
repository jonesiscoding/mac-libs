#!/bin/bash

# /*!
#   Public: Retrieves the machine model of this Mac
#
#   Example:
#     model=$(hardware::model::machine)
# */
function hardware::model::machine() {
  /usr/sbin/system_profiler SPHardwareDataType model -json | /usr/bin/plutil -extract 'SPHardwareDataType.0.machine_model' raw -
}