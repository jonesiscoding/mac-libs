#!/bin/bash

# Prevent being sourced more than once
[ "${BASH_SOURCE[0]}" != "$0" ] && [ -n "$sourced_lib_core" ] && return 0

if [ -z "$sourced_lib_core" ]; then
  # shellcheck disable=SC2034
  sourced_lib_core=0

  #
  # Global Variables
  #

  # Source Path for Mac-Libs Library
  if [ -z "$libsMacSourcePath" ]; then
    # shellcheck disable=SC2164,SC2034
    libsMacSourcePath="$( cd "$(/usr/bin/dirname "${BASH_SOURCE[0]}")" ; /bin/pwd -P )"
  fi

  # Paths to search for dependencies if the dependency isn't in the path
  if [ ${#libsMacBinPaths[@]} -eq 0 ]; then
    libsMacBinPaths=("/usr/local/sbin" "/usr/local/bin" "/opt/homebrew/sbin" "/opt/homebrew/bin")
  fi

  # The user referenced in all user functions (Note: This sets differently if sourcing "root.sh")
  if [ -z "$libsMacUser" ]; then
    libsMacUser="${USER}"
  fi

  #
  # Internal Variables
  #

  # All previously located executables
  _libsMacCore_Bin=()

  #
  # Internal Function Dependencies
  #

  # shellcheck source=./_shared.sh
  source "_shared.sh"
fi
