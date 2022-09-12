#!/bin/bash

# Prevent being sourced more than once
[ "${BASH_SOURCE[0]}" != "$0" ] && [ -n "$sourced_lib_mac_user" ] && return 0

function mac::user::appleid() {
  local plist

  plist="/Users/$libsMacUser/Library/Preferences/MobileMeAccounts.plist"

  if [ -f "$plist" ]; then
    /usr/bin/defaults read "$plist" Accounts | grep AccountID | cut -d '"' -f 2
  else
    echo ""
  fi
}

function mac::user::console() {
  show State:/Users/ConsoleUser | /usr/sbin/scutil | /usr/bin/awk '/Name :/ && ! /loginwindow/ { print $3 }'
}

function mac::user::dir() {
  echo "/Users/${libsMacUser}"
}

function mac::user::focus() {
  local major
  local focus

  focus=""
  major=$(/usr/bin/sw_vers -productVersion | cut -d "." -f1)
  if [ "$major" -eq "10" ]; then
    focus=$(/usr/bin/sudo -u "$libsMacUser" defaults -currentHost read "/Users/$libsMacUser/Library/Preferences/ByHost/com.apple.notificationcenterui" doNotDisturb 2>/dev/null)
  elif [ "$major" -eq "11" ]; then
    focus=$(/usr/bin/plutil -extract dnd_prefs xml1 -o - "/Users/$libsMacUser/Library/Preferences/com.apple.ncprefs.plist" | xmllint --xpath "string(//data)" - | base64 --decode | plutil -convert xml1 - -o - | grep -ic userPref)
  else
    focus=$(/usr/bin/plutil -extract data.0.storeAssertionRecords.0.assertionDetails.assertionDetailsModeIdentifier raw -o - "/Users/$libsMacUser/Library/DoNotDisturb/DB/Assertions.json" | grep -ic com.apple.)
  fi

  if [ -n "$focus" ] && [ "$focus" != "0" ]; then
    echo "$focus"
  fi
}

function mac::user::forceLogout() {
  if /bin/launchctl asuser "$(user::id)" sudo -iu "$(user::username)" /usr/bin/osascript -e \'tell app "System Events" to log out\'; then
    /bin/sleep 5
    return 0
  else
    return 1
  fi
}

function mac::user::fullname() {
  /usr/bin/id -F "$libsMacUser"
}

function mac::user::id() {
  /usr/bin/id -u "$libsMacUser"
}

function mac::user::idle() {
  local S MM M H IDLE
  if user::isConsole; then
    # Get MacOSX idletime. Shamelessly stolen from http://bit.ly/yVhc5H
    IDLE=$(/usr/sbin/ioreg -c IOHIDSystem | /usr/bin/awk '/HIDIdleTime/ {print int($NF/1000000000); exit}' | /usr/bin/xargs)

    if [ "${IDLE}" -gt 0 ]; then
      # shellcheck disable=SC2219
      let S=${IDLE}%60
      MM=$((IDLE/60)) #Total number of minutes
      # shellcheck disable=SC2219
      let M=${MM}%60
      # shellcheck disable=SC2219
      let H=${MM}/60
      [ "$H" -gt "0" ] && printf "%02d%s" "$H" "h"
      [ "$M" -gt "0" ] && printf "%02d%s" "$M" "m"
      /usr/bin/printf "%02d%s" "$S" "s"
    fi

    return 0
  fi

  return 1
}

function mac::user::isActive() {
  local IDLE
  if mac::user::isConsole; then
    # Get MacOSX idletime. Shamelessly stolen from http://bit.ly/yVhc5H
    IDLE=$(/usr/sbin/ioreg -c IOHIDSystem | /usr/bin/awk '/HIDIdleTime/ {print int($NF/1000000000); exit}' | /usr/bin/xargs)
    if [ "${IDLE}" -gt 0 ]; then
      # shellcheck disable=SC2219
      let MM=IDLE/60
      if [ "$MM" -lt "6" ]; then
        return 0
      fi
    fi
  fi

  return 1
}

function mac::user::isConsole() {
  if [ "$libsMacUser" == "$(mac::user::console)" ]; then
    return 0
  else
    return 1
  fi
}

function mac::user::name() {
  /usr/bin/dscl . -read "$(mac::user::dir)" RealName | /usr/bin/sed -n 's/^ //g;2p'
}

function mac::user::open() {
  local TUID
  local TOPEN

  TUID=$(/usr/bin/id -u "$libsMacUser")
  TOPEN="${1}"

  # shellcheck disable=SC2086
  /bin/launchctl asuser $TUID /usr/bin/open "${TOPEN}" >/dev/null 2>&1 &
}

function mac::user::run() {
  /usr/bin/su - "$libsMacUser" -c "$1"
}

function user::shell() {
  /usr/bin/finger "$libsMacUser" | /usr/bin/grep 'Shell: ' | /usr/bin/cut -d ':' -f3
}

function mac::user::username() {
  echo "$libsMacUser"
}

function mac::user::waitLogout() {
  local delay
  local force
  local reps
  local tUser
  local inc

  delay=${1:-30}
  force=${2}
  tUser=$(mac::user::console)

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
        tUser=$(mac::user::console)
    done
  fi

  # Force User Logout if there IS a user
  if [ -n "$tUser" ] && [ -n "$force" ]; then
    mac::user::forceLogout
  fi

  # Check one last time and give appropriate return code
  if [ -z "$(mac::user::console)" ]; then
    return 0
  else
    return 1
  fi
}

if [ -z "$sourced_lib_mac_user" ]; then
  # shellcheck disable=SC2034
  sourced_lib_mac_user=0
fi