#!/bin/bash

# /*
#   Library:
#     The mac-libs library contains functionality to ease repeated needs in macOS management scripts.
#
#   Usage:
#     Usage depends on how scripts are run; the stub you source can change which user the functions interact with.
#
#     This stub is for scripts run as root, but intended to use a different user for various user functions.
#
#       * Includes the 'user::init <username>' function to set the specific user.
#       * Includes the 'user::init::console' function to set the user from the console.
#       * Includes various 'error::xxx' functions.
#
#     For scripts intended to interact with the user running the script, or run via Jamf Pro, see "core.sh" or "jamf.sh"
#
#   Example:
#
#       source "<path-to-os-libs>/root.sh"
#       source "<path-to-os-libs>/other/lib/script.sh"
#       user::init::console
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

# shellcheck source=./_errors.sh disable=SC2164
source "$( cd "$(/usr/bin/dirname "${BASH_SOURCE[0]}")" ; /bin/pwd -P )/_errors.sh"

function user::init::console() {
  libsMacUser=$(echo "show State:/Users/ConsoleUser" | /usr/sbin/scutil | /usr/bin/awk '/Name :/ && ! /loginwindow/ { print $3 }')
}

function user::init::script() {
  libsMacUser="$USER"
}

function user::init() {
  libsMacUser="$1"
}
