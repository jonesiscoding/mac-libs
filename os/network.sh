#!/bin/bash

# Prevent being sourced more than once
[ "${BASH_SOURCE[0]}" != "$0" ] && [ -n "$sourced_lib_mac_network" ] && return 0

function os::network::getBluetoothInterfaces() {
  if [ ${#_libsMacNetwork_Bluetooth[@]} -eq 0 ]; then
    _libsMacNetwork_Bluetooth=$(/usr/sbin/networksetup -listallhardwareports | grep -A2 'Bluetooth' | grep -o en.)
  fi

  echo "$_libsMacNetwork_Bluetooth"

  return 0
}

function os::network::getVpnInterfaces() {
  if [ ${#_libsMacNetwork_Vpn[@]} -eq 0 ]; then
    _libsMacNetwork_Vpn=$(/sbin/ifconfig -u | /usr/bin/grep 'POINTOPOINT' | cut -d: -f1)
  fi

  echo "$_libsMacNetwork_Vpn"

  return 0
}

function os::network::getWiFiInterfaces() {
  if [ ${#_libsMacNetwork_Wifi[@]} -eq 0 ]; then
    _libsMacNetwork_Wifi=$(/usr/sbin/networksetup -listallhardwareports | grep -A2 'Wi-Fi\|Airport' | grep -o en.)
  fi

  echo "$_libsMacNetwork_Wifi"

  return 0
}

function os::network::getWiFiSSID() {
  /System/Library/PrivateFrameworks/Apple80211.framework/Resources/airport -I  | /usr/bin/awk -F' SSID: '  '/ SSID: / {print $2}'
}

function os::network::getWiredInterfaces() {
  local interfaces

  if [ ${#_libsMacNetwork_Wifi[@]} -eq 0 ]; then
    interfaces=$(/usr/sbin/networksetup -listallhardwareports | grep 'en' | grep -o en.)
    while IFS= read -r interface
    do
      _isWiFiInterface "${interface}" && continue
      _isBluetoothInterface "${interface}" && continue
      _isVpnInterface "${interface}" && continue

      _libsMacNetwork_Wired+=("${interface}")
    done <<< "$interfaces"
  fi

  echo "$_libsMacNetwork_Wifi"

  return 0
}

function os::network::getIpv4() {
  /sbin/ifconfig "${1}" | grep "inet " | cut -d ' ' -f2 2>/dev/null
}

function os::network::getVpnIp() {
  local interfaces
  local interface
  local ip

  interfaces=$(os::network::getVpnInterfaces)

  while IFS= read -r interface
  do
     ip=$(os::network::getIpv4 "$interface")

     if [ -n "$ip" ]; then
       echo "$ip" && return 0
     fi
  done <<< "$interfaces"

  return 1
}

function os::network::getWiFiIp() {
  local interfaces
  local interface
  local ip

  interfaces=$(os::network::getWiFiInterfaces)

  while IFS= read -r interface
  do
     ip=$(os::network::getIpv4 "$interface")

     [ -n "$ip" ] && echo "$ip" && return 0
  done <<< "$interfaces"

  return 1
}

function os::network::getWiredIp() {
  local interfaces
  local interface
  local ip

  interfaces=$(os::network::getWiredInterfaces)

  while IFS= read -r interface
  do
    if [ -n "$interface" ]; then
      ip=$(os::network::getIpv4 "$interface")

       [ -n "$ip" ] && echo "$ip" && return 0
    fi
  done <<< "$interfaces"

  return 1
}

function os::network::isInterfaceActive() {
  _isActiveIp "$(os::network::getIpv4 "${1}")" || return 1

  return 0
}

function os::network::isVpnActive() {
  _isActiveIp "$(os::network::getVpnIp)" || return 1

  return 0
}

function os::network::isWiFiActive() {
  _isActiveIp "$(os::network::getWiFiIp)" || return 1

  return 0
}

function os::network::isWiredActive() {
  _isActiveIp "$(os::network::getWiredIp)" || return 1

  return 0
}

function _isActiveIp() {
  local IP="${1}"

  # Empty, Not Active
  [ -z "$IP" ] && return 1
  # Local IP, Not Active
  [ "${IP:5}" == "127.0" ] && return 1
  # Private IP, Not Active
  [ "${IP:7}" == "169.254" ] && return 1

  return 0
}

function _isBluetoothInterface() {
  local test
  local interfaces

  test="${1}"
  interfaces=$(os::network::getBluetoothInterfaces)

  while IFS= read -r interface
  do
    [ "${test}" == "${interface}" ] && return 0
  done <<< "$interfaces"

  return 1
}

function _isVpnInterface() {
  local test
  local interfaces

  test="${1}"
  interfaces=$(os::network::getVpnInterfaces)

  while IFS= read -r interface
  do
    [ "${test}" == "${interface}" ] && return 0
  done <<< "$interfaces"

  return 1
}

function _isWiFiInterface() {
  local test
  local interfaces

  test="${1}"
  interfaces=$(os::network::getWiFiInterfaces)

  while IFS= read -r interface
  do
    [ "${test}" == "${interface}" ] && return 0
  done <<< "$interfaces"

  return 1
}

#
# Initialization Code
#

if [ -z "$sourced_lib_mac_network" ]; then
  # shellcheck disable=SC2034
  sourced_lib_mac_network=0
  # Internal Variables Below
  _libsMacNetwork_Bluetooth=()
  _libsMacNetwork_Vpn=()
  _libsMacNetwork_Wifi=()
  _libsMacNetwork_Wired=()
fi

