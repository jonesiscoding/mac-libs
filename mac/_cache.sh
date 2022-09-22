#!/bin/bash

# /*
#   Module:
#     Contains functions to ease the retrieval of information about the content cache serving this Mac.
#
#   Example:
#     source "<path-to-mac-libs>/mac/_cache.sh"
#
#     See functions for additional examples
#
#   Copyright:
#     © 2022/09 AMJones <am@jonesiscoding.com>
#   License:
#     For the full copyright and license information, please view the LICENSE
#     file that was distributed with this source code.
# */

# Prevent being sourced more than once
[ "${BASH_SOURCE[0]}" != "$0" ] && [ -n "$sourced_lib_mac_cache" ] && return 0

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

# /*!
#   Public: Retrieves IP addresses of any personal asset cache this Mac is utilizing. The value is then cached to
#   prevent additional overhead when using the function repeatedly.
#
#   Example:
#     cacheIPs=$(mac::cache::personal)
# */
function mac::cache::personal() {
  [ -z "$_libsMacCache_Personal" ] && _libsMacCache_Personal=$(_getAssetCacheLocators "personal")
  echo "$_libsMacCache_Personal"
}

# /*!
#   Public: Retrieves IP addresses of any shared asset cache this Mac is utilizing. The value is then cached to prevent
#   additional overhead when using the function repeatedly.
#
#   Example:
#     cacheIPs=$(mac::cache::shared)
# */
function mac::cache::shared() {
  [ -z "$_libsMacCache_Shared" ] && _libsMacCache_Shared=$(_getAssetCacheLocators "shared")
  echo "$_libsMacCache_Shared"
}

#
# Initialization Code
#
if [ -z "$sourced_lib_mac_cache" ]; then
  # shellcheck disable=SC2034
  sourced_lib_mac_cache=0

  # Internal Variables
  _libsMacCache_Personal=""
  _libsMacCache_Shared=""
fi
