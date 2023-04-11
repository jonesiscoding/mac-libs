#!/bin/bash

# /*!
#   Internal: Retrieves the IP addresses of the given type of asset cache.
#
#   $1 The type of cache to query for; shared or personal.
# */
function _getAssetCacheLocators() {
  local DATA

  DATA=$(/usr/bin/AssetCacheLocatorUtil 2>&1)

  echo "$DATA" | /usr/bin/grep guid | /usr/bin/grep "$1 caching: yes" | /usr/bin/awk '{print$4}' | /usr/bin/cut -d ':' -f1 | /usr/bin/uniq
}