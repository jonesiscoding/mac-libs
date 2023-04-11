#!/bin/bash

# /*!
#   Public: Evaluates whether this Mac is using Apple Silicon.
#
#   Example:
#     if hardware::isAppleSilicon; then
#       <code to run if the os uses an M1, M2, etc.>
#     else
#       <code to run if the os uses an Intel (or other) chip
#     fi
# */
function hardware::isAppleSilicon() {
  local arch

  arch=$(/usr/bin/arch)
  if [ "$arch" == "arm64" ]; then
    return 0
  else
    return 1
  fi
}