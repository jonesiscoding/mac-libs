#!/bin/bash

#
# User/Console Initialization
#

# Prevent sourcing twice
[ "${BASH_SOURCE[0]}" != "$0" ] && [ -n "$sourced_lib_mac_user_console" ] && return 0
# shellcheck disable=SC2034
sourced_lib_mac_user_console=0

#
# User/Console Functions
#

# /*!
#   Public: Shows the username of the current console user, if any is logged in.
# */
function user::console() {
  echo "show State:/Users/ConsoleUser" | /usr/sbin/scutil | /usr/bin/awk '/Name :/ && ! /loginwindow/ { print $3 }'
}

# /*!
#   Public: Shows the ID of the current console user, if any is logged in.
# */
function user::console::id() {
  local uname

  uname=$(user::console)
  [[ -n "$uname" ]] && /usr/bin/id -u "$uname"
}
