#!/bin/bash

# Prevent being sourced more than once
[ "${BASH_SOURCE[0]}" != "$0" ] && [ -n "$sourced_lib_output" ] && return 0

output::msgln() {
  $_libsMacOutput_Notifying && output::defaultbg "SEE BELOW"
  echo -e "${_libsMacOutput_Magenta}${1}${_libsMacOutput_EndColor}"
}

output::qln() {
  $_libsMacOutput_Notifying && output::defaultbg "SEE BELOW"
  echo -e "${_libsMacOutput_Yellow}${1}${_libsMacOutput_EndColor}"
}

output::infoln() {
  $_libsMacOutput_Notifying && output::defaultbg "SEE BELOW"
  echo -e "${_libsMacOutput_Blue}${1}${_libsMacOutput_EndColor}"
}

output::successln() {
  $_libsMacOutput_Notifying && output::successbg "SUCCESS"
  echo -e "${_libsMacOutput_Green}${1}${_libsMacOutput_EndColor}"
}

output::errorln() {
  $_libsMacOutput_Notifying && output::errorbg "ERROR"
  echo -e "${_libsMacOutput_Red}${1}${_libsMacOutput_EndColor}"
}

function output::hr() {
  echo -e "$_libsMacOutput_Line"
}

function output::blankln() {
  echo -e ""
}

output::notify() {
  local padding="............................................................................"
  _libsMacOutput_Notifying=true
  printf "${_libsMacOutput_Blue}%s${_libsMacOutput_EndColor}%s " "$1" "${padding:${#1}}"
}

output::successbg() {
  local BADGE
  BADGE=${1:-SUCCESS}
  $_libsMacOutput_Notifying && echo -e "[${_libsMacOutput_Green}$BADGE${_libsMacOutput_EndColor}]"
  _libsMacOutput_Notifying=false

  return 0
}

output::defaultbg() {
  local BADGE
  BADGE=${1:-DONE}
  $_libsMacOutput_Notifying && echo -e "[$BADGE]"
  _libsMacOutput_Notifying=false

  return 0
}

output::errorbg() {
  local BADGE
  BADGE=${1:-ERROR}
  $_libsMacOutput_Notifying && echo -e "[${_libsMacOutput_Red}$BADGE${_libsMacOutput_EndColor}]"
  _libsMacOutput_Notifying=false

  return 0
}

if [ -z "$sourced_lib_mac_output" ]; then
  # shellcheck disable=SC2034
  sourced_lib_output=0
  if [ -n "$TERM" ] && [ "$TERM" != "dumb" ]; then
    _libsMacOutput_Yellow=$(/usr/bin/tput setaf 3) #"\033[1;33m"
    _libsMacOutput_Magenta=$(/usr/bin/tput setaf 5) #"\033[1;35m"
    _libsMacOutput_Green=$(/usr/bin/tput setaf 2) #"\033[1;32m"
    _libsMacOutput_Blue=$(/usr/bin/tput setaf 4) #"\033[1;36m"
    _libsMacOutput_Red=$(/usr/bin/tput setaf 1) #"\033[1;31m"
    _libsMacOutput_EndColor=$(/usr/bin/tput sgr0) #"\033[0m"
  else
    _libsMacOutput_Yellow=""
    _libsMacOutput_Magenta=""
    _libsMacOutput_Green=""
    _libsMacOutput_Blue=""
    _libsMacOutput_Red=""
    _libsMacOutput_EndColor=""
  fi
  _libsMacOutput_Notifying=false
  _libsMacOutput_Line="----------------------------------------------------------------------------"
fi
