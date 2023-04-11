#!/bin/bash

function os::network::interface::ipv4() {
  /sbin/ifconfig "${1}" | grep "inet " | cut -d ' ' -f2 2>/dev/null
}