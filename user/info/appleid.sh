#!/bin/bash

function user::appleid() {
  local plist

  plist="/Users/$libsMacUser/Library/Preferences/MobileMeAccounts.plist"

  if [ -f "$plist" ]; then
    /usr/bin/defaults read "$plist" Accounts | grep AccountID | cut -d '"' -f 2
  else
    echo ""
  fi
}