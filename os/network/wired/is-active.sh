#!/bin/bash

if [[ $(type -t "os::network::wired::ipv4") != function ]]; then
  # shellcheck source=./ipv4.sh disable=SC2164
  source "$( cd "$(/usr/bin/dirname "${BASH_SOURCE[0]}")" ; /bin/pwd -P )/ipv4.sh"
fi

function os::network::wired::isActive() {
  local ip

  ip=$(os::network::wired::ipv4)

  [ -z "$ip" ] && return 1

  return 0
}


