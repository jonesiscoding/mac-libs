#!/bin/bash

# /*!
#   Internal: Shows the console user
# */
function _consoleUser() {
  echo "show State:/Users/ConsoleUser" | /usr/sbin/scutil | /usr/bin/awk '/Name :/ && ! /loginwindow/ { print $3 }'
}

# /*!
#   Public: Evaluates whether the Software Update preference pane is open
# */
function updates::isPreferencePaneOpen() {
  if /bin/ps aux | /usr/bin/grep -v "grep" | /usr/bin/grep -q "System/Library/PreferencePanes/SoftwareUpdate.prefPane"; then
    return 0
  else
    return 1
  fi
}

# /*!
#   Public: Opens the Software Update Preference Pane
# */
function updates::open::preferencePane() {
  local consoleUser consoleUserId
  consoleUser=$(_consoleUser)
  consoleUserId=$(/usr/bin/id -u "$consoleUser")

  if [ -z "$consoleUserId" ] || ! /bin/launchctl asuser "$consoleUserId" /usr/bin/open /System/Library/PreferencePanes/SoftwareUpdate.prefPane; then
    return 1
  else
    return 0
  fi
}

# /*!
#   Public: Opinionated check if system is ready to install updates, based on power and encryption job status.
# */
function updates::ready::system() {

  if [ -f /usr/bin/fdesetup ] && /usr/bin/fdesetup status | /usr/bin/grep -q 'Encryption in progress'; then
    errors::add "Encrypting File Vault"
    return 1
  fi

  if ! hardware::power::isPluggedIn; then
    errors::add "On Battery Power"
    return 1
  fi

  return 0
}

# /*!
#   Public: Opinionated check if user is ready for notifications or updates, base on display no sleep assertations and
#   user focus mode selection.
# */
function updates::ready::user() {
  local uFocus
  if local::isUserPresent; then

    if hardware::power::isDisplayNoSleep; then
      errors::add "Display No Sleep"
      return 1
    fi

    uFocus=$(user::focus)
    if [ -n "$uFocus" ]; then
      errors::add "User Focus $uFocus"
      return 1
    fi
  fi

  return 0
}

# /*!
#   Public: Removes any existing softwareupdate preferences, then kickstarts softwareupdated.
# */
function updates::restart::softwareupdated() {
  /usr/bin/defaults delete /Library/Preferences/com.apple.SoftwareUpdate.plist > /dev/null 2>&1
  [ -f "/Library/Preferences/com.apple.SoftwareUpdate.plist" ] && rm /Library/Preferences/com.apple.SoftwareUpdate.plist
  if /bin/launchctl kickstart -k system/com.apple.softwareupdated; then
    return 0
  else
    return 1
  fi
}

# /*!
#   Public: If a user is present, restarts the Software Update Notification Manager, otherwise restarts softwareupdated.
# */
function updates::restart::SoftwareUpdateNotificationManager() {
  local cUserId cUser

  cUser=$(_consoleUser)
  if [ -n "$cUser" ]; then
    cUserId=$(/usr/bin/id -u "$cUser")
    if ! /bin/launchctl kickstart -k "gui/$cUserId/com.apple.SoftwareUpdateNotificationManager"; then
      if ! /bin/launchctl kickstart -k "gui/$cUserId/com.apple.SoftwareUpdateNotificationManager"; then
        return 1
      fi
    fi
  elif ! /bin/launchctl kickstart -k system/com.apple.softwareupdated; then
    return 1
  fi

  return 0
}