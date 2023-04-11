#!/bin/bash

# /*
#   Library:
#     The mac-libs library contains functionality to ease repeated needs in macOS management scripts.
#
#   Usage:
#     Usage depends on how scripts are run; the stub you source can change which user the functions interact with.
#
#     This stub is for scripts run as the shell user:
#
#       * All user functions will automatically use the $USER environment variable.
#       * Includes various 'error::xxx' functions.
#
#     For scripts intended to interact with a different user, or run via Jamf Pro, see "root.sh" or "jamf.sh"
#
#   Example:
#
#       source "<path-to-os-libs>/core.sh"
#       source "<path-to-os-libs>/other/lib/script.sh"
#
#   Library Copyright:
#     © 2022/09 AMJones <am@jonesiscoding.com>
#
#     Some code attributable to other sources and offers.  See comments in specific functions.
#
#   License:
#     For the full copyright and license information, please view the LICENSE
#     file that was distributed with this source code.
# */

[ -z "$libsMacUser" ] && libsMacUser="$USER"

# shellcheck source=./_errors.sh disable=SC2164
source "$( cd "$(/usr/bin/dirname "${BASH_SOURCE[0]}")" ; /bin/pwd -P )/errors.sh"