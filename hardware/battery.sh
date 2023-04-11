#!/bin/bash

# /*
#   Module:
#     Contains functions to allow easy retrieval of battery information
#
#   Example:
#     source "<path-to-os-libs>/os/battery.sh"
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
fnPath="$( cd "$(/usr/bin/dirname "${BASH_SOURCE[0]}")" ; /bin/pwd -P )/battery"

# shellcheck source=./battery/percentage.sh
source "$fnPath/percentage.sh"
# shellcheck source=./battery/is-charging.sh
source "$fnPath/is-charging.sh"
# shellcheck source=./battery/is-fully-charged.sh
source "$fnPath/is-fully-charged.sh"
# shellcheck source=./battery/cycles.sh
source "$fnPath/cycles.sh"
# shellcheck source=./battery/serial.sh
source "$fnPath/serial.sh"




