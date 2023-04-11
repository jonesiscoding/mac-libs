#!/bin/bash

# /*!
#   Public: Retrieves the physical memory of this Mac
#
#   Example:
#     model=$(hardware::memory)
# */
function hardware::memory() {
  /usr/sbin/system_profiler SPHardwareDataType model -json | /usr/bin/plutil -extract 'SPHardwareDataType.0.physical_memory' raw -
}