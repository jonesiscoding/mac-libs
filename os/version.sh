#!/bin/bash

# Prevent being sourced more than once
[ "${BASH_SOURCE[0]}" != "$0" ] && [ -n "$sourced_lib_mac_version" ] && return 0

function os::version::build() {
  [ -z "$_libsMacVersion_Build" ] && _libsMacVersion_Build=$(/usr/bin/sw_vers -BuildVersion)
  echo "$_libsMacVersion_Build"
}

function os::version::full() {
  [ -z "$_libsMacVersion_Version" ] && _libsMacVersion_Version=$(/usr/bin/sw_vers -productVersion)
  echo "$_libsMacVersion_Version"
}

function os::version::major() {
  os::version::full | /usr/bin/cut -d "." -f1
}

function os::version::minor() {
  os::version::full | /usr/bin/cut -d "." -f2
}

function os::version::name() {
  local MAJOR
  local MINOR

  MAJOR=$(os::version::major)
  if [ "$MAJOR" -eq "10" ]; then
    MINOR=$(os::version::minor)
    [ "${MINOR:-0}" -eq "5" ] && echo "Leopard" && return 0
    [ "${MINOR:-0}" -eq "6" ] && echo "Snow Leopard" && return 0
    [ "${MINOR:-0}" -eq "7" ] && echo "Lion" && return 0
    [ "${MINOR:-0}" -eq "8" ] && echo "Mountain Lion" && return 0
    [ "${MINOR:-0}" -eq "9" ] && echo "Mavericks" && return 0
    [ "${MINOR:-0}" -eq "10" ] && echo "Yosemite" && return 0
    [ "${MINOR:-0}" -eq "11" ] && echo "El Capitan" && return 0
    [ "${MINOR:-0}" -eq "12" ] && echo "Sierra" && return 0
    [ "${MINOR:-0}" -eq "13" ] && echo "High Sierra" && return 0
    [ "${MINOR:-0}" -eq "14" ] && echo "Mojave" && return 0
    [ "${MINOR:-0}" -eq "15" ] && echo "Catalina" && return 0
  fi

  [ "$MAJOR" -eq "11" ] && echo "Big Sur" && return 0
  [ "$MAJOR" -eq "12" ] && echo "Monterey" && return 0
  [ "$MAJOR" -eq "13" ] && echo "Ventura" && return 0

  echo "Unknown" && return 0
}

function os::version::patch() {
  os::version::full | /usr/bin/cut -d "." -f2
}

if [ -z "$sourced_lib_mac_version" ]; then
  # shellcheck disable=SC2034
  sourced_lib_mac_version=0
  _libsMacVersion_Version=""
  _libsMacVersion_Build=""
fi