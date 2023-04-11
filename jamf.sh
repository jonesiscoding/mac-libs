#!/bin/bash

# /*
#   Library:
#     The mac-libs library contains functionality to ease repeated needs in macOS management scripts.
#
#   Usage:
#     Usage depends on how scripts are run; the stub you source can change which user the functions interact with.
#
#     This stub is for scripts run via Jamf, and has the following functionality:
#
#       * Automatically transfers $1/$2/$3 to $jamfRoot, $jamfHost, $jamfUser and shifts remaining arguments to $1, etc.
#         To avoid this behavior, set $libsMacJamfInit prior to sourcing this file.
#       * Includes the 'user::init::jamf' function which will use the username given by Jamf in various user functions.
#       * Includes various 'error::xxx' functions.
#
#     For scripts intended to run without Jamf, see "root.sh" or "core.sh"
#
#   Example:
#
#       source "<path-to-os-libs>/jamf.sh"
#       source "<path-to-os-libs>/other/lib/script.sh"
#       user::init::jamf
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
source "$( cd "$(/usr/bin/dirname "${BASH_SOURCE[0]}")" ; /bin/pwd -P )/root.sh"

function _isJamf() {
  local cName firstCharFirstArg
  cName=$(/usr/sbin/scutil --get ComputerName)
  firstCharFirstArg=$(/usr/bin/printf '%s' "$1" | /usr/bin/cut -c 1)
  if [ "$firstCharFirstArg" == "/" ] && [ "$2" == "$cName" ]; then
    return 0
  else
    return 1
  fi
}

function user::init::jamf() {
  libsMacUser="$jamfUser"
}

if [ -z "$libsJamfInit" ]; then
  libsJamfInit=":::_:::"
  if _isJamf "$@"; then
    # shellcheck disable=SC2034
    jamfMountPoint="$1"
    # shellcheck disable=SC2034
    jamfHostName="$2"
    # shellcheck disable=SC2034
    jamfUser="$3"
    # Remove Jamf Arguments
    shift 3
    # Blank first Output Line for Prettier Jamf Logs
    echo ""
  fi
fi