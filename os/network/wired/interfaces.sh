#!/bin/bash

function os::network::wired::interfaces() {
  local ports wifi all bluetooth vpn interface wired

  ports=$(/usr/sbin/networksetup -listallhardwareports)
  wifi=$(echo "$ports" | grep -A2 'Wi-Fi\|Airport' | grep -o en.)
  bluetooth=$(echo "$ports" | grep -A2 'Bluetooth' | grep -o en.)
  all=$(echo "$ports" | grep 'en' | grep -o en.)
  vpn=$(/sbin/ifconfig -u | /usr/bin/grep 'POINTOPOINT' | cut -d: -f1)
  wired=()
  while IFS= read -r interface
  do
    [[ " ${wifi[*]} " =~ " ${interface} " ]] && continue
    [[ " ${vpn[*]} " =~ " ${interface} " ]] && continue
    [[ " ${bluetooth[*]} " =~ " ${interface} " ]] && continue

    echo "${interface}"
  done <<< "$all"

  return 0
}