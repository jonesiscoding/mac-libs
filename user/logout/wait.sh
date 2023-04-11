#!/bin/bash

if [[ $(type -t "user::console") != function ]]; then
  # shellcheck source=../console.sh disable=SC2164
  source "$( cd "$(/usr/bin/dirname "${BASH_SOURCE[0]}")" ; /bin/pwd -P )/../console.sh"
fi

if [[ $(type -t "user::logout::force") != function ]]; then
  # shellcheck source=./force.sh disable=SC2164
  source "$( cd "$(/usr/bin/dirname "${BASH_SOURCE[0]}")" ; /bin/pwd -P )/force.sh"
fi


function user::logout::wait() {
  local delay
  local force
  local reps
  local tUser
  local inc

  delay=${1:-30}
  force=${2}
  tUser=$(user::console)

  # Force the Delay to be Divisible by 5, unless it is 0
  [ "$delay" -lt "5" ] && [ "$delay" -ne "0" ] && delay=5

  # Delay
  if [ "$delay" -ne "0" ]; then
    reps=$((delay/5))
    inc=0
    while [ -n "$tUser" ] && [ "$inc" -lt "$reps" ]
    do
        sleep 5
        inc=$((inc+1))
        tUser=$(user::console)
    done
  fi

  # Force User Logout if there IS a user
  if [ -n "$tUser" ] && [ -n "$force" ]; then
    user::logout::forced
  fi

  # Check one last time and give appropriate return code
  if [ -z "$(user::console)" ]; then
    return 0
  else
    return 1
  fi
}