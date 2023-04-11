#!/bin/bash

function os::network::getWiFiInterfaces() {
  /usr/sbin/networksetup -listallhardwareports | grep -A2 'Wi-Fi\|Airport' | grep -o en.
}