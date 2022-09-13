#!/bin/bash

function input::getOption() {
  local key index query

  query="$1"

  for index in "${_libsMacInput_Options[@]}"
  do
    key="${index%%"$_libsMacInput_OptionPrefix"*}"
    if [ "$key" == "$query" ]; then
      echo "${index##*"$_libsMacInput_OptionPrefix"}"
      return 0
    fi
  done

  return 1
}

function input::hasOption() {
  local key index query

  query="$1"

  for index in "${_libsMacInput_Options[@]}"
  do
    key="${index%%"$_libsMacInput_OptionPrefix"*}"
    if [ "$key" == "$query" ]; then
      return 0
    fi
  done

  return 1
}

#
# Initialization Code
#
if [ -z "$sourced_lib_input" ]; then
  # shellcheck disable=SC2034
  sourced_lib_input=0

  # Internal Variables
  _libsMacInput_Options=()
  _libsMacInput_Arguments=()
  _libsMacInput_OptionPrefix=":::_:::"

  # Parse and Remove Jamf Arguments
  if [ -n "$sourced_lib_root" ]; then
    if core::isJamf; then
      # shellcheck disable=SC2034
      libsMacJamfMountPoint="$1"
      # shellcheck disable=SC2034
      libsMacJamfHostName="$2"
      # shellcheck disable=SC2034
      libsMacJamfUser="$3"
      shift 3
    fi
  fi

  # Parse Options & Remove from Arguments
  for i in "$@"
  do
    if [ "${i:0:2}" == "--" ]; then
      optName="${i:2}"
      if echo "${optName}" | grep -q "="; then
        optVal=$(echo "${optName}" | cut -d'=' -f2)
        optName=$(echo "${optName}" | cut -d'=' -f1)
      else
        optVal=1
      fi
      _libsMacInput_Options+=("${optName}$_libsMacInput_OptionPrefix${optVal}")
    else
      _libsMacInput_Arguments+=("${i}")
    fi
  done
  set -- "${_libsMacInput_Arguments[@]}"
fi