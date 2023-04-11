#!/bin/bash

# /*
#   Module:
#     Contains functions for reading macOS network settings & particulars.
#     Deprecated in favor of individual function files.
# */

# shellcheck disable=SC2164
fnPath="$( cd "$(/usr/bin/dirname "${BASH_SOURCE[0]}")" ; /bin/pwd -P )/network"

# shellcheck source=./network/interface/ipv4.sh
source "$fnPath/interface/ipv4.sh"
# shellcheck source=./network/interface/is-active.sh
source "$fnPath/interface/is-active.sh"
# shellcheck source=./network/bluetooth/interfaces.sh
source "$fnPath/bluetooth/interfaces.sh"
# shellcheck source=./network/vpn/interfaces.sh
source "$fnPath/vpn/interfaces.sh"
# shellcheck source=./network/wifi/interfaces.sh
source "$fnPath/wifi/interfaces.sh"
# shellcheck source=./network/wifi/ssid.sh
source "$fnPath/wifi/ssid.sh"
# shellcheck source=./network/wired/interfaces.sh
source "$fnPath/wired/interfaces.sh"
# shellcheck source=./network/bluetooth/ipv4.sh
source "$fnPath/bluetooth/ipv4.sh"
# shellcheck source=./network/wifi/ipv4.sh
source "$fnPath/wifi/ipv4.sh"
# shellcheck source=./network/wired/ipv4.sh
source "$fnPath/wired/ipv4.sh"
# shellcheck source=./network/vpn/is-active.sh
source "$fnPath/vpn/is-active.sh"
# shellcheck source=./network/wifi/is-active.sh
source "$fnPath/wifi/is-active.sh"
# shellcheck source=./network/wired/is-active.sh
source "$fnPath/wired/is-active.sh"

function os::network::getVpnInterfaces() {
  os::network::vpn::interfaces
}

function os::network::getWiFiInterfaces() {
  os::network::wifi::interfaces
}

function os::network::getWiFiSSID() {
  os::network::wifi::ssid
}

function os::network::getWiredInterfaces() {
    os::network::wired::interfaces
}

function os::network::getIpv4() {
  os::network::interface::ipv4 "$1"
}

function os::network::getVpnIp() {
  os::network::vpn::ipv4
}

function os::network::getWiFiIp() {
  os::network::wifi::ipv4
}

function os::network::getWiredIp() {
  os::network::wired::ipv4
}

function os::network::isInterfaceActive() {
  os::network::interface::isActive "$1"
}

function os::network::isVpnActive() {
  os::network::vpn::isActive
}

function os::network::isWiFiActive() {
  os::network::wifi::isActive
}

function os::network::isWiredActive() {
  os::network::wired::isActive
}