#!/bin/bash

if [[ $(type -t "_getAssetCacheLocators") != function ]]; then
  # shellcheck source=./_shared.sh disable=SC2164
  source "$( cd "$(/usr/bin/dirname "${BASH_SOURCE[0]}")" ; /bin/pwd -P )/_shared.sh"
fi

# /*!
#   Public: Retrieves IP addresses of any personal asset cache this Mac is utilizing. The value is then cached to
#   prevent additional overhead when using the function repeatedly.
#
#   Example:
#     cacheIPs=$(os::os::cache::personal)
# */
function os::cache::personal() {
  _getAssetCacheLocators "shared"
}