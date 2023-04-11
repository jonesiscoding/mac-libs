#!/bin/bash

function os::network::vpn::interfaces() {
  /sbin/ifconfig -u | /usr/bin/grep 'POINTOPOINT' | cut -d: -f1
}

