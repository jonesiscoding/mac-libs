#!/bin/bash

# /*
#   Module:
#     Contains functions for reading macOS security settings.
#     Deprecated in favor of individual function files.
# */

# shellcheck disable=SC2164
fnPath="$( cd "$(/usr/bin/dirname "${BASH_SOURCE[0]}")" ; /bin/pwd -P )/security"

# shellcheck source=./security/is-bootstrap-token-escrowed.sh
source "$fnPath/is-bootstrap-token-escrowed.sh"
# shellcheck source=./security/is-encrypting-file-vault.sh
source "$fnPath/is-encrypting-file-vault.sh"

