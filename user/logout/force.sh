#!/bin/bash

if [[ $(type -t "user::console") != function ]]; then
  # shellcheck source=../console.sh disable=SC2164
  source "$( cd "$(/usr/bin/dirname "${BASH_SOURCE[0]}")" ; /bin/pwd -P )/../console.sh"
fi

function user::logout::forced() {
  local consoleUserId consoleUserName

  consoleUserName=$(user::console)
  consoleUserId=$(/usr/bin/id -u "$consoleUserName")

  if /bin/launchctl asuser "$consoleUserId" sudo -iu "$consoleUserName" /usr/bin/osascript -e "tell application \"loginwindow\" to «event aevtrlgo»"; then
    /bin/sleep 5
    return 0
  else
    return 1
  fi
}