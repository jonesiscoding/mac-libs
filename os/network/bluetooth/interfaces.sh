#!/bin/bash

function os::network::bluetooth::interfaces() {
  /usr/sbin/networksetup -listallhardwareports | grep -A2 'Bluetooth' | grep -o en.
}