#!/bin/bash

# Prevent being sourced more than once
[ "${BASH_SOURCE[0]}" != "$0" ] && [ -n "$sourced_lib_mac_cache" ] && return 0

function _getAssetCacheLocators() {
  local DATA

  DATA=$(/usr/bin/AssetCacheLocatorUtil 2>&1)

  echo "$DATA" | /usr/bin/grep guid | /usr/bin/grep "$1 caching: yes" | /usr/bin/awk '{print$4}' | /usr/bin/cut -d ':' -f1 | /usr/bin/uniq
}

function mac::getPersonalCaches() {
  [ -z "$_libsMacCache_Personal" ] && _libsMacCache_Personal=$(_getAssetCacheLocators "shared")
  echo "$_libsMacCache_Personal"
}

function mac::getSharedCaches() {
  [ -z "$_libsMacCache_Shared" ] && _libsMacCache_Shared=$(_getAssetCacheLocators "shared")
  echo "$_libsMacCache_Shared"
}

if [ -z "$sourced_lib_mac_cache" ]; then
  # shellcheck disable=SC2034
  sourced_lib_mac_cache=0
  _libsMacCache_Personal=""
  _libsMacCache_Shared=""
fi

