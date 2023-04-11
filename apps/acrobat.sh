#!/bin/bash

# /*
#   Module:
#     Contains functions that work with Adobe Acrobat DC, Reader, and XI
#     Deprecated in favor of individual function files.
#
#   Example:
#     source "<path-to-os-libs>/os/acrobat.sh"
#     <various code>
#     <see function examples>
#
#   Copyright:
#     © 2022/09 AMJones <am@jonesiscoding.com>
#   License:
#     For the full copyright and license information, please view the LICENSE
#     file that was distributed with this source code.
# */

# shellcheck disable=SC2164
fnPath="$( cd "$(/usr/bin/dirname "${BASH_SOURCE[0]}")" ; /bin/pwd -P )/acrobat"

# shellcheck source=./acrobat/path.sh
source "$fnPath/path.sh"
# shellcheck source=./acrobat/version.sh
source "$fnPath/version.sh"
# shellcheck source=./acrobat/handler.sh
source "$fnPath/handler.sh"
# shellcheck source=./acrobat/uninstall.sh
source "$fnPath/uninstall.sh"