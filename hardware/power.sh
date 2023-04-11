#!/bin/bash

# /*
#   Module:
#     Contains functions to ease the retrieval of power information on this Mac.
#
#   Example:
#     source "<path-to-os-libs>/os/power.sh"
#     Deprecated in favor of individual function files.
#
#     See functions for additional examples
#
#   Copyright:
#     © 2022/09 AMJones <am@jonesiscoding.com>
#
#   License:
#     For the full copyright and license information, please view the LICENSE
#     file that was distributed with this source code.
# */


# shellcheck disable=SC2164
fnPath="$( cd "$(/usr/bin/dirname "${BASH_SOURCE[0]}")" ; /bin/pwd -P )/power"

# shellcheck source=./power/is-display-no-sleep.sh
source "$fnPath/is-display-no-sleep.sh"
# shellcheck source=./power/is-plugged-in.sh
source "$fnPath/is-plugged-in.sh"
