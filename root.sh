#!/bin/bash

# Prevent being sourced more than once
[ "${BASH_SOURCE[0]}" != "$0" ] && [ -n "$sourced_lib_root" ] && return 0

function core::isJamf() {
  local cName firstCharFirstArg

  if [ "$_libsMacCore_IsJamf" == ":::_:::" ]; then
    _libsMacCore_IsJamf=1
    cName=$(/usr/sbin/scutil --get ComputerName)
    firstCharFirstArg=$(/usr/bin/printf '%s' "$1" | /usr/bin/cut -c 1)

    if [ "$firstCharFirstArg" == "/" ] && [ "$2" == "$cName" ]; then
      _libsMacCore_IsJamf=0
    fi
  fi

  return $_libsMacCore_IsJamf
}

#
# Library Initialization
#
if [ -z "$sourced_lib_root" ]; then
  # shellcheck disable=SC2034
  sourced_lib_root=0

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

  # The user referenced in all user functions
  if [ -z "$libsMacUser" ] || [ "$libsMacUser" == "$USER" ]; then
    # Set User Based on Jamf or Console User
    if core::isJamf "$@"; then
      libsMacUser="$3"
    else
      libsMacUser=$(echo "show State:/Users/ConsoleUser" | /usr/sbin/scutil | /usr/bin/awk '/Name :/ && ! /loginwindow/ { print $3 }')
    fi
  fi

  #
  # Internal Variables
  #

  _libsMacCore_IsJamf=":::_:::"

  #
  # Internal Function Dependencies
  #

  # shellcheck source=./_dependencies.sh
  source "$libsMacSourcePath/_dependencies.sh"
fi
