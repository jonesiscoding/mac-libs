#!/bin/bash

if [[ $(type -t "os::network::wifi::ipv4") != function ]]; then
  # shellcheck source=./ipv4.sh disable=SC2164
  source "$( cd "$(/usr/bin/dirname "${BASH_SOURCE[0]}")" ; /bin/pwd -P )/ipv4.sh"
fi

function os::network::wifi::isActive() {
  local ip

  ip=$(os::network::wifi::ipv4)

  [ -z "$ip" ] && return 1

  return 0
}


