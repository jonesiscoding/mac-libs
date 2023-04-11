#!/bin/bash

function user::focus() {
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