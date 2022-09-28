#!/bin/bash

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