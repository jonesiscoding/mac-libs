#!/bin/bash

[ "${BASH_SOURCE[0]}" != "$0" ] && [ -n "$sourced_lib_updates_settings" ] && return 0

function _getManagedPlistPath() {
  if [ -z "$_libsMacUpdates_Plist" ]; then
    _libsMacUpdates_ManagedPlist="/Library/Managed Preferences/$(updates::settings::domain).plist"
  fi

  [ -f "$_libsMacUpdates_ManagedPlist" ] && echo "$_libsMacUpdates_ManagedPlist" && return 0

  return 1
}

function updates::settings::domain() {
  echo "$libsMacBundlePrefix.softwareupdate"
}

function updates::settings::deferral::soft() {
  # Allow Override if Variable Set and Override is Allowed in Managed Settings
  [ -n "$libsMacUpdatesSoftLimit" ] && updates::settings::override && echo "$libsMacUpdatesSoftLimit" && return 0

  # Get the Value from the Managed Plist
  /usr/bin/defaults read "$(_getManagedPlistPath)" maxDeferrals 2>/dev/null || echo "7"
}

function updates::settings::deferral::hard() {
  local soft

  # Allow Override if Variable Set and Override is Allowed in Managed Settings
  [ -n "$libsMacUpdatesHardLimit" ] && updates::settings::override && echo "$libsMacUpdatesHardLimit" && return 0

  # Retrieve from Plist
  soft=$(updates::settings::deferral::soft)
  echo $((soft * 2)) && return 0
}

function updates::settings::override() {
  local val

  val=$(/usr/bin/defaults read "$(_getManagedPlistPath)" allowOverride 2>/dev/null || echo "0")

  if [[ $val -eq 1 ]]; then
    # Allow Override
    return 0
  else
    # Do Not Allow Override
    return 1
  fi
}

function updates::settings::updateTime() {
  # Allow Override if Variable Set and Override is Allowed in Managed Settings
  [ -n "$updateTime" ] && updates::settings::override && echo "$updateTime" && return 0

  # Get the Value from the Managed Plist
  /usr/bin/defaults read "$(_getManagedPlistPath)" updateTime 2>/dev/null || echo "7pm"
}

function updates::settings::workDir() {
  if [ -z "$_libsMacMdm_WorkDir" ]; then
    _libsMacMdm_WorkDir=$(/usr/bin/defaults read "$(_getManagedPlistPath)" workPath 2>/dev/null || echo "/Library/Application\ Support/MDM")

    # Allow Override if Variable Set and Override is Allowed in Managed Settings
    [ -n "$libsMacMdmWorkDir" ] && updates::settings::override && _libsMacMdm_WorkDir="$libsMacMdmWorkDir"

    [ ! -d "$_libsMacMdm_WorkDir" ] && /bin/mkdir -p "$_libsMacMdm_WorkDir"
  fi

  echo "$_libsMacMdm_WorkDir";
}

if [ -z "$sourced_lib_mac_updates_settings" ]; then
  # shellcheck disable=SC2034
  sourced_lib_mac_updates_settings=0

  #
  # Internal Variables
  #
  _libsMacUpdates_ManagedPlist=""
  _libsMacMdm_WorkDir=""

  #
  # Global Variables
  #
  [ -z "$libsMacBundlePrefix" ] && libsMacBundlePrefix="org.organization"
fi