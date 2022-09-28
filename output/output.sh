#!/bin/bash

# /*
#   Module:
#     Contains functions to allow for easy colored output in any bash script.
#
#   Example:
#     source "<path-to-os-libs>/output/output.sh"
#     <various code>
#     output::notify "Summoning the Rabbit"
#     if ! <rabbit summoning code>; then
#       # NOTE: Using output::errorln "Additional error text" will output the badge with "ERROR" then
#       # the additional text on the next line indented.
#       output::errorbg "ERROR" && exit 1
#     else
#       output::successbg "DONE"
#       <more code>
#     fi
#
#   Copyright:
#     © 2022/09 AMJones <am@jonesiscoding.com>
#   License:
#     For the full copyright and license information, please view the LICENSE
#     file that was distributed with this source code.
# */

#
# Prevent module from being sourced more than once
#
[ "${BASH_SOURCE[0]}" != "$0" ] && [ -n "$sourced_lib_output" ] && return 0

# /*!
#   Public: Echos the given line in MAGENTA, typically to indicate important
#   text for the user to read.
#
#   $1  The message to show
# */
output::msgln() {
  $_libsMacOutput_Notifying && output::defaultbg "SEE BELOW"
  echo -e "${_libsMacOutput_Magenta}${1}${_libsMacOutput_EndColor}"
}

# /*!
#   Public: Echos the given line in YELLOW, typically to indicate a query.
#   Automatically handles closing of a previous notify line, if applicable.
#
#   $1  The message to show
# */
output::qln() {
  $_libsMacOutput_Notifying && output::defaultbg "SEE BELOW"
  echo -e "${_libsMacOutput_Yellow}${1}${_libsMacOutput_EndColor}"
}

# /*!
#   Public: Echos the given line in BLUE, typically to indicate information.
#   Automatically handles closing of a previous notify line, if applicable.
#
#   $1  The message to show
# */
output::infoln() {
  $_libsMacOutput_Notifying && output::defaultbg "SEE BELOW"
  echo -e "${_libsMacOutput_Blue}${1}${_libsMacOutput_EndColor}"
}

# /*!
#   Public: Echos the given line in GREEN, typically to indicate information.
#   Automatically handles closing of a previous notify line, if applicable.
#
#   $1  The message to show
# */
output::successln() {
  $_libsMacOutput_Notifying && output::successbg "SUCCESS"
  echo -e "${_libsMacOutput_Green}${1}${_libsMacOutput_EndColor}"
}

# /*!
#   Public: Echos the given line in RED, typically to indicate information.
#   Automatically handles closing of a previous notify line, if applicable.
#
#   $1  The message to show
# */
output::errorln() {
  $_libsMacOutput_Notifying && output::errorbg "ERROR"
  echo -e "${_libsMacOutput_Red}${1}${_libsMacOutput_EndColor}"
}

# /*!
#   Public: Outputs a single horizontal rule
# */
function output::hr() {
  echo -e "$_libsMacOutput_Line"
}

# /*!
#   Public: Outputs a blank line
# */
function output::blankln() {
  echo -e ""
}

# /*!
#   Public: Outputs the given argument in blue, padded with periods.  Designed to be
#   used with th output::*bg functions for a display of work in progress, then a badge
#   of success/failure.
#
#   $1  The notification text
# */
output::notify() {
  local padding="............................................................................"
  _libsMacOutput_Notifying=true
  printf "${_libsMacOutput_Blue}%s${_libsMacOutput_EndColor}%s " "$1" "${padding:${#1}}"
}

# /*!
#   Public: Outputs a [BADGE] with the BADGE in green. Designed to be used after
#   the output::notify function to confirm that the previous action was successful.
#
#   $1  The badge label
# */
output::successbg() {
  local BADGE
  BADGE=${1:-SUCCESS}
  $_libsMacOutput_Notifying && echo -e "[${_libsMacOutput_Green}$BADGE${_libsMacOutput_EndColor}]"
  _libsMacOutput_Notifying=false

  return 0
}

# /*!
#   Public: Outputs a [BADGE] with the BADGE without color. Designed to be used after
#   the output::notify function to confirm that the previous action was successful.
#
#   $1  The badge label
# */
output::defaultbg() {
  local BADGE
  BADGE=${1:-DONE}
  $_libsMacOutput_Notifying && echo -e "[$BADGE]"
  _libsMacOutput_Notifying=false

  return 0
}

# /*!
#   Public: Outputs a [BADGE] with the BADGE in RED. Designed to be used after
#   the output::notify function to confirm that the previous action was successful.
#
#   $1  The badge label
# */
output::errorbg() {
  local BADGE
  BADGE=${1:-ERROR}
  $_libsMacOutput_Notifying && echo -e "[${_libsMacOutput_Red}$BADGE${_libsMacOutput_EndColor}]"
  _libsMacOutput_Notifying=false

  return 0
}

#
# Initialization Code
#
if [ -z "$sourced_lib_mac_output" ]; then
  # shellcheck disable=SC2034
  sourced_lib_output=0

  # Internal Variables
  _libsMacOutput_Notifying=false
  _libsMacOutput_Line="----------------------------------------------------------------------------"

  # Set ANSI color codes if appropriate for this terminal
  if [ -n "$TERM" ] && [ "$TERM" != "dumb" ]; then
    _libsMacOutput_Yellow=$(/usr/bin/tput setaf 3)  #"\033[1;33m"
    _libsMacOutput_Magenta=$(/usr/bin/tput setaf 5) #"\033[1;35m"
    _libsMacOutput_Green=$(/usr/bin/tput setaf 2)   #"\033[1;32m"
    _libsMacOutput_Blue=$(/usr/bin/tput setaf 4)    #"\033[1;36m"
    _libsMacOutput_Red=$(/usr/bin/tput setaf 1)     #"\033[1;31m"
    _libsMacOutput_EndColor=$(/usr/bin/tput sgr0)   #"\033[0m"
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
