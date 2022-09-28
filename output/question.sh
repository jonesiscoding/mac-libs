#!/bin/bash
# /*
#   Module:
#     Contains functions to allow for easy questions/answers in any bash script.
#
#   Example:
#     source "<path-to-os-libs>/output/question.sh"
#     <various code>
#     <see function examples>
#
#   Copyright:
#     © 2022/09 AMJones <am@jonesiscoding.com>
#   License:
#     For the full copyright and license information, please view the LICENSE
#     file that was distributed with this source code.
# */

# Prevent being sourced more than once
[ "${BASH_SOURCE[0]}" != "$0" ] && [ -n "$sourced_lib_question" ] && return 0

if [ -z "$sourced_lib_output" ]; then
  # shellcheck source=./output.sh
  source "$libsMacSourcePath/io/output.sh"
fi

# /*!
#   Public: Outputs question text in yellow, and returns the appropriate code
#   based on the user's answer.
#
#   Example:
#     if output::question::ask "Is your favorite color yellow?"; then
#        <code for yellow>
#     else
#        <code for other colors>
#     fi
#
#   $1  The question
# */
function output::question::ask() {
  local reply

  echo -e -n "${_libsMacOutput_Yellow}$1${_libsMacOutput_EndColor} [y/n] "
  read -r reply </dev/tty
  case "$reply" in
  Y* | y*) return 0 ;;
  N* | n*) return 1 ;;
  esac
}

# /*!
#   Public: Outputs question text in yellow, and waits for the user to type a reply
#   followed by the enter key.
#
#   Example:
#     response=$(output::question::text "What is your quest?")
#
#   $1  The question
# */
function output::question::text() {
  local ANSWER
  local QUESTION
  local DEFAULT

  DEFAULT="$2"
  QUESTION="${_libsMacOutput_Yellow}$1${_libsMacOutput_EndColor} ${DEFAULT:+ [$DEFAULT]}"

  read -r -ep "$QUESTION: " ANSWER || return 1

  echo "${ANSWER:-$DEFAULT}"
  return 0
}

# /*!
#   Public: Outputs question text in yellow, with the choices printed above.
#
#   Example:
#     choices=("African" "European")
#     answer=$(output::question::choice "Which kind of swallow is it?" "African European"; then
#
#   $1  The question string
#   $2  The selections, enclosed in quotes, space delimited
# */
function output::question::choice() {
  local choice
  local choices

  PS3=$'\n'"${_libsMacOutput_Yellow}${1}${_libsMacOutput_EndColor} "
  choices="$2"
  select choice in $choices; do
    echo "$choice"
    break
  done

  return 0
}

#
# Initialization Code
#
if [ -z "$sourced_lib_question" ]; then
  # shellcheck disable=SC2034
  sourced_lib_question=0
fi
