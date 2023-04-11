#!/bin/bash

# /*
#   Module:
#     Contains functions for reading macOS Version
#     Deprecated in favor of individual function files.
# */

# shellcheck disable=SC2164
fnPath="$( cd "$(/usr/bin/dirname "${BASH_SOURCE[0]}")" ; /bin/pwd -P )/version"

# shellcheck source=./version/major.sh
source "$fnPath/major.sh"
# shellcheck source=./version/minor.sh
source "$fnPath/minor.sh"
# shellcheck source=./version/patch.sh
source "$fnPath/patch.sh"
# shellcheck source=./version/name.sh
source "$fnPath/name.sh"
# shellcheck source=./version/build.sh
source "$fnPath/build.sh"
# shellcheck source=./version/full.sh
source "$fnPath/full.sh"