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
    return 0
  else
    return 1
  fi
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
  local consoleUserId

  consoleUserId=$(/usr/bin/id -u "$(_consoleUser)")
  if ! /bin/launchctl kickstart -k "gui/$consoleUserId/com.apple.SoftwareUpdateNotificationManager"; then
		if ! /bin/launchctl kickstart -k "gui/$consoleUserId/com.apple.SoftwareUpdateNotificationManager"; then
		  return 1
		fi
	fi

	return 0
}