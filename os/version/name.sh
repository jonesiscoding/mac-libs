#!/bin/bash

if [[ $(type -t "os::version::major") != function ]]; then
  # shellcheck source=./major.sh disable=SC2164
  source "$( cd "$(/usr/bin/dirname "${BASH_SOURCE[0]}")" ; /bin/pwd -P )/major.sh"
fi

if [[ $(type -t "os::version::minor") != function ]]; then
  # shellcheck source=./minor.sh disable=SC2164
  source "$( cd "$(/usr/bin/dirname "${BASH_SOURCE[0]}")" ; /bin/pwd -P )/minor.sh"
fi

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