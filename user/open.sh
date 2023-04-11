#!/bin/bash

function user::open() {
  local tUid
  local tOpen

  tUid=$(/usr/bin/id -u "$libsMacUser")
  tOpen="${1}"

  # shellcheck disable=SC2086
  /bin/launchctl asuser $tUid /usr/bin/open "${tOpen}" >/dev/null 2>&1 &
}