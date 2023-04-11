#!/bin/bash

# /*
#   Module:
#     Contains functions to ease the retrieval of information about the content cache serving this Mac.
#     Deprecated in favor of individual files.
#
#   Example:
#     source "<path-to-os-libs>/os/cache.sh"
#
#     See functions for additional examples
#
#   Copyright:
#     © 2022/09 AMJones <am@jonesiscoding.com>
#   License:
#     For the full copyright and license information, please view the LICENSE
#     file that was distributed with this source code.
# */

# /*
#   Module:
#     Contains functions for reading macOS network settings & particulars.
#     Deprecated in favor of individual function files.
# */

# shellcheck disable=SC2164
fnPath="$( cd "$(/usr/bin/dirname "${BASH_SOURCE[0]}")" ; /bin/pwd -P )/cache"

# shellcheck source=./cache/personal.sh
source "$fnPath/personal.sh"
# shellcheck source=./cache/shared.sh
source "$fnPath/shared.sh"