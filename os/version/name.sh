#!/bin/bash

# @description Outputs the friendly name for the macOS version
# @stdout macOS Version Name
function os::version::name() {
  local name license

  # From the License
  license="/System/Library/CoreServices/Setup Assistant.app/Contents/Resources/en.lproj/OSXSoftwareLicense.rtf'"
  if [ -f "$license" ]; then
    name=$(/usr/bin/awk '/SOFTWARE LICENSE AGREEMENT FOR macOS/' "$license" | awk -F 'macOS ' '{print $NF}' | awk '{print substr($0, 0, length($0)-1)}')
    [ -n "$name" ] && echo "$name" && return 0
  fi

  # Backup in case the method above starts failing
  case $(/usr/bin/sw_vers -productVersion) in
    10.5.* ) echo "Leopard" && return 0        ;;
    10.6.* ) echo "Snow Leopard" && return 0   ;;
    10.7.* ) echo "Lion" && return 0           ;;
    10.8.* ) echo "Mountain Lion" && return 0  ;;
    10.9* )  echo "Mavericks" && return 0       ;;
    10.10* ) echo "Yosemite" && return 0       ;;
    10.11* ) echo "El Capitan" && return 0     ;;
    10.12* ) echo "Sierra" && return 0         ;;
    10.13* ) echo "High Sierra" && return 0    ;;
    10.14* ) echo "Mojave" && return 0         ;;
    10.15* ) echo "Catalina" && return 0       ;;
    11.* )   echo "Big Sur" && return 0        ;;
    12.* )   echo "Monterey" && return 0       ;;
    13.* )   echo "Ventura" && return 0        ;;
    14.* )   echo "Sonoma" && return 0         ;;
    15.* )   echo "Sequoia" && return 0         ;;
    26.* )   echo "Tahoe" && return 0         ;;
    * )      echo "Unknown" && return 1        ;;
  esac
}
