#!/bin/bash

# /*
#   Module:
#     Contains functions to ease the retrieval of hardware information on this Mac.
#     Deprecated in favor of individual function files.
#
#   Example:
#     source "<path-to-os-libs>/os/hardware.sh"
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
fnPath="$( cd "$(/usr/bin/dirname "${BASH_SOURCE[0]}")" ; /bin/pwd -P )"

# shellcheck source=./is-apple-silicon.sh
source "$fnPath/is-apple-silicon.sh"
# shellcheck source=./is-macbook.sh
source "$fnPath/is-macbook.sh"
# shellcheck source=./is-t2.sh
source "$fnPath/is-t2.sh"
# shellcheck source=./model/name.sh
source "$fnPath/model/name.sh"

# /*!
#   Public: Retrieves the model name of this Mac
#   Deprecated: Name Changed to hardware::model::name
#
#   Example:
#     model=$(hardware::model::name)
# */
function hardware::model() {
  hardware::model::name
}

