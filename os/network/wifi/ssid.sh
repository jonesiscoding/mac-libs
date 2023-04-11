#!/bin/bash

function os::network::wifi::ssid() {
  /System/Library/PrivateFrameworks/Apple80211.framework/Resources/airport -I  | /usr/bin/awk -F' SSID: '  '/ SSID: / {print $2}'
}

