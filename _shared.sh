#!/bin/bash

# Prevent being sourced more than once
[ "${BASH_SOURCE[0]}" != "$0" ] && [ -n "$sourced_lib_shared" ] && return 0

function dependency::assert() {
  local deps

  deps=("$@")
  for e in "${deps[@]}"
  do
     if ! dependency::exists "$e"; then
       echo "ERROR: The dependency '$e' was not found. Exiting..."
       exit 1
     fi
  done

  return 0
}

function dependency::exists() {
  local dPath

  dPath=$(dependency::path "$1")
  if [ -z "$dPath" ]; then
    return 1
  else
    return 0
  fi
}

function dependency::path() {
  local dep
  local dPath
  local binPath

  dep="$1"

  # Loop Through $_libsMacCore_Bin for previously found paths
  for tryPath in "${_libsMacCore_Bin[@]}"
  do
     [ "${tryPath##*/}" == "$dep" ] && echo "$tryPath" && return 0
  done

  # Try which, to use the current PATH
  dPath=$(/usr/bin/which "$dep")
  [ -n "$dPath" ] && _libsMacCore_Bin+=("$dPath") && echo "$dPath" && return 0

  # Use Path Helper
  if [ -x /usr/libexec/path_helper ]; then
    # shellcheck disable=SC2046,SC2006
    dPath=$(eval `/usr/libexec/path_helper -s` && /usr/bin/which "$dep")
    [ -n "$dPath" ] && _libsMacCore_Bin+=("$dPath") && echo "$dPath" && return 0
  fi

  # Loop Through $libBinPaths
  for binPath in "${libsMacBinPaths[@]}"
  do
     if [ -f "$binPath/$dep" ]; then
       _libsMacCore_Bin+=("$binPath/$dep") && echo "$binPath/$dep" && return 0
     fi
  done

  return 1
}

function errors::file {
  local file
  file="/tmp/$(/usr/bin/basename "$0").err"
  /usr/bin/touch "$file"
  echo "$file"
}

function errors::add() {
  local errorMsg errorFile

  errorMsg="$1"
  errorFile=$(errors::file)

  echo "$errorMsg" >> "$errorFile"

  return 0
}

function errors::reset() {
  local errorFile

  errorFile=$(errors::file)
  /bin/rm "$errorFile"
  /usr/bin/touch "$errorFile"

  return 0
}

function errors::get() {
  local errorFile indent spacer err

  errorFile=$(errors::file)
  indent="${1:-0}"
  if [[ $indent -gt 0 ]]; then
    spacer=$(for ((i=1; i <= indent; i++)); do printf "%s" " "; done)
  else
    spacer=""
  fi

  while IFS="" read -r err || [ -n "$err" ]
  do
    printf '%s%s\n' "$spacer" "$err"
  done < "$errorFile"
}

if [ -z "$sourced_lib_shared" ]; then
  # shellcheck disable=SC2034
  sourced_lib_shared=0

  errors::reset

  #
  # Internal Variables
  #

  # All previously located executables
  _libsMacCore_Bin=()

fi