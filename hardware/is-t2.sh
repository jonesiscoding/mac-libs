#!/bin/bash

# /*!
#   Public: Evaluates whether this Mac contains a T2 Security Chip.
#
#   Example:
#     if hardware::isT2; then
#       <code to run if the os uses a T2 Chip>
#     else
#       <code to run if the does not use a T2 Chip>
#     fi
# */
function hardware::isT2() {
  local arch

  arch=$(/usr/bin/arch)
  if [ "$arch" == "i386" ]; then
    if /usr/sbin/system_profiler SPiBridgeDataType | /usr/bin/grep -q 'T2'; then
      return 0
    fi
  fi

  return 1
}