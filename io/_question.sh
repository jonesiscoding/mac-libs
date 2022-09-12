#!/bin/bash

# Prevent being sourced more than once
[ "${BASH_SOURCE[0]}" != "$0" ] && [ -n "$sourced_lib_question" ] && return 0

if [ -z "$sourced_lib_output" ]; then
  # shellcheck source=./_output.sh
  source "$libSourcePath/io/_output.sh"
fi

function question::ask() {
  local reply

  echo -e -n "${_libsMacOutput_Yellow}$1${_libsMacOutput_EndColor} [y/n] "
  read -r reply </dev/tty
  case "$reply" in
  Y* | y*) return 0 ;;
  N* | n*) return 1 ;;
  esac
}

function question::text() {
  local ANSWER
  local QUESTION
  local DEFAULT

  DEFAULT="$2"
  QUESTION="${_libsMacOutput_Yellow}$1${_libsMacOutput_EndColor} ${DEFAULT:+ [$DEFAULT]}"

  read -r -ep "$QUESTION: " ANSWER || return 1

  echo "${ANSWER:-$DEFAULT}"
  return 0
}

function question::choice() {
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

if [ -z "$sourced_lib_question" ]; then
  # shellcheck disable=SC2034
  sourced_lib_question=0
fi
