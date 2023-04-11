#!/bin/bash

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