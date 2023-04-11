#!/bin/bash

if [[ $(type -t "os::network::wifi::interfaces") != function ]]; then
  # shellcheck source=./interfaces.sh disable=SC2164
  source "$( cd "$(/usr/bin/dirname "${BASH_SOURCE[0]}")" ; /bin/pwd -P )/interfaces.sh"
fi

if [[ $(type -t "os::network::interface::ipv4") != function ]]; then
  # shellcheck source=../interface/ipv4.sh disable=SC2164
  source "$( cd "$(/usr/bin/dirname "${BASH_SOURCE[0]}")" ; /bin/pwd -P )/../interface/ipv4.sh"
fi

function os::network::wifi::ipv4() {
  local interfaces
  local interface
  local ip

  interfaces=$(os::network::wifi::interfaces)
  while IFS= read -r interface
  do
     ip=$(os::network::interface::ipv4 "$interface")

     [ -n "$ip" ] && echo "$ip" && return 0
  done <<< "$interfaces"

  return 1
}