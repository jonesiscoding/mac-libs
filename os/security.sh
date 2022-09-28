#!/bin/bash

# Prevent being sourced more than once
[ "${BASH_SOURCE[0]}" != "$0" ] && [ -n "$sourced_lib_mac_security" ] && return 0

function os::security::isBootstrapTokenEscrowed() {
  local STATUS

  STATUS=$(/usr/bin/sudo /usr/bin/profiles status -type bootstraptoken 2>&1)

  if ! echo "$STATUS" | /usr/bin/grep -q "Error:"; then
    if ! echo "$STATUS" | /usr/bin/grep -q "NO"; then
      if echo "$STATUS" | /usr/bin/grep -q "YES"; then
        return 0
      fi
    fi
  fi

  return 1
}

function os::security::isEncryptingFileVault() {
  [ -f /usr/bin/fdesetup ] && /usr/bin/fdesetup status | /usr/bin/grep -q 'Encryption in progress'
}

# Initialize library variables
if [ -z "$sourced_lib_mac_security" ]; then
  # shellcheck disable=SC2034
  sourced_lib_mac=0
fi