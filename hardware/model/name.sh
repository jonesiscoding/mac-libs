#!/bin/bash

# /*!
#   Public: Retrieves the model name of this Mac
#
#   Example:
#     model=$(hardware::model::name)
# */
function hardware::model::name() {
  /usr/sbin/system_profiler SPHardwareDataType model -json | /usr/bin/plutil -extract 'SPHardwareDataType.0.machine_name' raw -
}