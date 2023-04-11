#!/bin/bash

if [[ $(type -t "os::network::wifi::interfaces") != function ]]; then
  # shellcheck source=./interfaces.sh disable=SC2164
  source "$( cd "$(/usr/bin/dirname "${BASH_SOURCE[0]}")" ; /bin/pwd -P )/interfaces.sh"
fi

function os::network::interface::isActive() {
  local interface IP

  interface="$1"
  IP=$(os::network::interface::ipv4 "$interface")

  # Empty, Not Active
  [ -z "$IP" ] && return 1
  # Local IP, Not Active
  [ "${IP:5}" == "127.0" ] && return 1
  # Private IP, Not Active
  [ "${IP:7}" == "169.254" ] && return 1

  return 0
}